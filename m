From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf: net/core/filter.c:2115 suspicious rcu_dereference_protected()
 usage!
Date: Wed, 30 Mar 2016 13:33:44 +0200
Message-ID: <56FBB998.5090504@iogearbox.net>
References: <56CB29D5.9090000@oracle.com> <20160329125823.GB15048@unicorn.suse.cz> <56FA8935.8030109@iogearbox.net> <56FA93AF.8060001@iogearbox.net> <20160330094224.GC15048@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, ast@plumgrid.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35998 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbcC3Ldw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 07:33:52 -0400
In-Reply-To: <20160330094224.GC15048@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2016 11:42 AM, Michal Kubecek wrote:
> On Tue, Mar 29, 2016 at 04:39:43PM +0200, Daniel Borkmann wrote:
>>>
>>>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>>>> index afdf950617c3..7417d7c20bab 100644
>>>> --- a/drivers/net/tun.c
>>>> +++ b/drivers/net/tun.c
>>>> @@ -1818,11 +1818,13 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
>>>>   static void tun_detach_filter(struct tun_struct *tun, int n)
>>>>   {
>>>>       int i;
>>>> -    struct tun_file *tfile;
>>>>
>>>>       for (i = 0; i < n; i++) {
>>>> -        tfile = rtnl_dereference(tun->tfiles[i]);
>>>> -        sk_detach_filter(tfile->socket.sk);
>>>> +        struct sock *sk = rtnl_dereference(tun->tfiles[i])->socket.sk;
>>>> +
>>>> +        lock_sock(sk);
>>>> +        sk_detach_filter(sk);
>>>> +        release_sock(sk);
>>>>       }
>>>>
>>>>       tun->filter_attached = false;
>>>>
>>>
>>> In tun case, the control path for tun_attach_filter() and tun_detach_filter()
>>> is under RTNL lock (held in __tun_chr_ioctl()).
>>>
>>> So in the BPF core the rcu_dereference_protected(<sk_filter>, sock_owned_by_user(sk))
>>> looks like a false positive in this specific use case to me, that we should probably
>>> just silence.
>>>
>>> Running the filter via sk_filter() in tun device happens under rcu_read_lock(),
>>> so the dereference and assignment pair seems okay to me.
>>>
>>> Was wondering whether we should convert this to unattached BPF filter, but this
>>> would break with existing expectations from sk_filter() (e.g. security modules).
>>
>> If we want to silence it, could be something like the below (only compile-tested):
>>
>>   drivers/net/tun.c      |  8 +++++---
>>   include/linux/filter.h |  4 ++++
>>   net/core/filter.c      | 33 +++++++++++++++++++++------------
>>   3 files changed, 30 insertions(+), 15 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index afdf950..510e90a 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -622,7 +622,8 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
>>
>>   	/* Re-attach the filter to persist device */
>>   	if (!skip_filter && (tun->filter_attached == true)) {
>> -		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
>> +		err = __sk_attach_filter(&tun->fprog, tfile->socket.sk,
>> +					 lockdep_rtnl_is_held());
>>   		if (!err)
>>   			goto out;
>>   	}
>> @@ -1822,7 +1823,7 @@ static void tun_detach_filter(struct tun_struct *tun, int n)
>>
>>   	for (i = 0; i < n; i++) {
>>   		tfile = rtnl_dereference(tun->tfiles[i]);
>> -		sk_detach_filter(tfile->socket.sk);
>> +		__sk_detach_filter(tfile->socket.sk, lockdep_rtnl_is_held());
>>   	}
>>
>>   	tun->filter_attached = false;
>> @@ -1835,7 +1836,8 @@ static int tun_attach_filter(struct tun_struct *tun)
>>
>>   	for (i = 0; i < tun->numqueues; i++) {
>>   		tfile = rtnl_dereference(tun->tfiles[i]);
>> -		ret = sk_attach_filter(&tun->fprog, tfile->socket.sk);
>> +		ret = __sk_attach_filter(&tun->fprog, tfile->socket.sk,
>> +					 lockdep_rtnl_is_held());
>>   		if (ret) {
>>   			tun_detach_filter(tun, i);
>>   			return ret;
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index 43aa1f8..a51a536 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -465,10 +465,14 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
>>   void bpf_prog_destroy(struct bpf_prog *fp);
>>
>>   int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>> +int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
>> +		       bool locked);
>>   int sk_attach_bpf(u32 ufd, struct sock *sk);
>>   int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>>   int sk_reuseport_attach_bpf(u32 ufd, struct sock *sk);
>>   int sk_detach_filter(struct sock *sk);
>> +int __sk_detach_filter(struct sock *sk, bool locked);
>> +
>>   int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
>>   		  unsigned int len);
>>
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index 2429918..02f2f6c 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -1149,7 +1149,8 @@ void bpf_prog_destroy(struct bpf_prog *fp)
>>   }
>>   EXPORT_SYMBOL_GPL(bpf_prog_destroy);
>>
>> -static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
>> +static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk,
>> +			    bool locked)
>>   {
>>   	struct sk_filter *fp, *old_fp;
>>
>> @@ -1165,10 +1166,8 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
>>   		return -ENOMEM;
>>   	}
>>
>> -	old_fp = rcu_dereference_protected(sk->sk_filter,
>> -					   sock_owned_by_user(sk));
>> +	old_fp = rcu_dereference_protected(sk->sk_filter, locked);
>>   	rcu_assign_pointer(sk->sk_filter, fp);
>> -
>>   	if (old_fp)
>>   		sk_filter_uncharge(sk, old_fp);
>>
>> @@ -1247,7 +1246,8 @@ struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
>>    * occurs or there is insufficient memory for the filter a negative
>>    * errno code is returned. On success the return is zero.
>>    */
>> -int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>> +int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
>> +		       bool locked)
>>   {
>>   	struct bpf_prog *prog = __get_filter(fprog, sk);
>>   	int err;
>> @@ -1255,7 +1255,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>>   	if (IS_ERR(prog))
>>   		return PTR_ERR(prog);
>>
>> -	err = __sk_attach_prog(prog, sk);
>> +	err = __sk_attach_prog(prog, sk, locked);
>>   	if (err < 0) {
>>   		__bpf_prog_release(prog);
>>   		return err;
>> @@ -1263,7 +1263,12 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>>
>>   	return 0;
>>   }
>> -EXPORT_SYMBOL_GPL(sk_attach_filter);
>> +EXPORT_SYMBOL_GPL(__sk_attach_filter);
>> +
>> +int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>> +{
>> +	return __sk_attach_filter(fprog, sk, sock_owned_by_user(sk));
>> +}
>>
>>   int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>>   {
>> @@ -1309,7 +1314,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
>>   	if (IS_ERR(prog))
>>   		return PTR_ERR(prog);
>>
>> -	err = __sk_attach_prog(prog, sk);
>> +	err = __sk_attach_prog(prog, sk, sock_owned_by_user(sk));
>>   	if (err < 0) {
>>   		bpf_prog_put(prog);
>>   		return err;
>> @@ -2445,7 +2450,7 @@ static int __init register_sk_filter_ops(void)
>>   }
>>   late_initcall(register_sk_filter_ops);
>>
>> -int sk_detach_filter(struct sock *sk)
>> +int __sk_detach_filter(struct sock *sk, bool locked)
>>   {
>>   	int ret = -ENOENT;
>>   	struct sk_filter *filter;
>> @@ -2453,8 +2458,7 @@ int sk_detach_filter(struct sock *sk)
>>   	if (sock_flag(sk, SOCK_FILTER_LOCKED))
>>   		return -EPERM;
>>
>> -	filter = rcu_dereference_protected(sk->sk_filter,
>> -					   sock_owned_by_user(sk));
>> +	filter = rcu_dereference_protected(sk->sk_filter, locked);
>>   	if (filter) {
>>   		RCU_INIT_POINTER(sk->sk_filter, NULL);
>>   		sk_filter_uncharge(sk, filter);
>> @@ -2463,7 +2467,12 @@ int sk_detach_filter(struct sock *sk)
>>
>>   	return ret;
>>   }
>> -EXPORT_SYMBOL_GPL(sk_detach_filter);
>> +EXPORT_SYMBOL_GPL(__sk_detach_filter);
>> +
>> +int sk_detach_filter(struct sock *sk)
>> +{
>> +	return __sk_detach_filter(sk, sock_owned_by_user(sk));
>> +}
>>
>>   int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
>>   		  unsigned int len)
>> --
>> 1.9.3
>
> Looks good to me.
>
> I'm just not sure checking if we hold the right lock depending on caller
> is worth the extra complexity. After all, what is really needed is to
> hold _some_ lock guaranteeing sk_attach_prog() and sk_detach_filter()
> are safe so that just changing the condition in both to
>
>    sock_owned_by_user(sk) || lockdep_rtnl_is_held()

It would certainly silence it, but would be less accurate in terms of lock
proving as opposed to the diff above. E.g. rntl could be held elsewhere,
while someone attaches a socket filter w/o having locked the socket (currently
not the case, but it would kind of defeat the purpose of rcu_dereference_protected()
here). Was thinking about using a extra socket flag to indicate it's
externally managed, but it's not really worth wasting sk's flags bit
space just for this corner case.

> could suffice.
>
>                                                          Michal Kubecek
>
