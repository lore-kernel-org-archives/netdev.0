From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH 2/2] Add a netlink attribute INET_DIAG_SECCTX
Date: Thu, 1 Sep 2011 17:33:07 +0800
Message-ID: <4E5F5153.6070708@windriver.com>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com> <1314779777-12669-3-git-send-email-rongqing.li@windriver.com> <2593215.lUI7et83Qv@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52739 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627Ab1IAJdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 05:33:21 -0400
In-Reply-To: <2593215.lUI7et83Qv@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2011 05:18 AM, Paul Moore wrote:
> On Wednesday, August 31, 2011 04:36:17 PM rongqing.li@windriver.com wrote:
>> From: Roy.Li<rongqing.li@windriver.com>
>>
>> Add a new netlink attribute INET_DIAG_SECCTX to dump the security
>> context of TCP sockets.
>
> You'll have to forgive me, I'm not familiar with the netlink code used by
> netstat and friends, but is there anyway to report back the security context
> of UDP sockets?  Or does the code below handle that already?
>
> In general, AF_INET and AF_INET6 sockets, regardless of any upper level
> protocols, have security contexts associated with them and it would be nice to
> see them in netstat.
>

Yes, this is real concern, If the dumping tcp security context can be 
accepted
by netdev, I am planning to implement it for ipv4 udp socket, unix socket.
then ipv6..

>> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
>> index 389a2e6..1faf752 100644
>> --- a/net/ipv4/inet_diag.c
>> +++ b/net/ipv4/inet_diag.c
>> @@ -34,6 +34,8 @@
>>
>>   #include<linux/inet_diag.h>
>>
>> +#define MAX_SECCTX_LEN 128
>
> I'll echo Stephen's concerns that this is too small.  A MCS/MLS system with a
> moderate number of categories could bump into this limit without too much
> difficulty.
>

I will reconsider this as Stephen's suggestion, just size the buffer 
appropriately
for the actual secctx length, so that, your next question will be fixed 
since we
have enough memory to place the security context.

>>   struct inet_diag_entry {
>> @@ -108,6 +110,25 @@ static int inet_csk_diag_fill(struct sock *sk,
>>   		       icsk->icsk_ca_ops->name);
>>   	}
>>
>> +	if (ext&  (1<<  (INET_DIAG_SECCTX - 1))) {
>> +		u32 ctxlen = 0;
>> +		void *secctx;
>> +		int error;
>> +
>> +		error = security_sk_getsecctx(sk,&secctx,&ctxlen);
>> +
>> +		if (!error&&  ctxlen) {
>> +			if (ctxlen<  MAX_SECCTX_LEN) {
>> +				strcpy(INET_DIAG_PUT(skb, INET_DIAG_SECCTX,
>> +					ctxlen + 1), secctx);
>> +			} else {
>> +				strcpy(INET_DIAG_PUT(skb, INET_DIAG_SECCTX,
>> +					2), "-");
>
> Is the "-" string a special value already interpreted by the userspace tools?
> If not, you might consider using a string that would indicate an out-of-space
> condition occurred; at first glance I thought the "-" string indicated no
> context.
>
>> +			}
>> +			security_release_secctx(secctx, ctxlen);
>> +		}
>> +	}
>> +
>>   	r->idiag_family = sk->sk_family;
>>   	r->idiag_state = sk->sk_state;
>>   	r->idiag_timer = 0;
>> @@ -246,7 +267,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff
>> *skb, static int inet_diag_get_exact(struct sk_buff *in_skb,
>>   			       const struct nlmsghdr *nlh)
>>   {
>> -	int err;
>> +	int err, len;
>>   	struct sock *sk;
>>   	struct inet_diag_req *req = NLMSG_DATA(nlh);
>>   	struct sk_buff *rep;
>> @@ -293,10 +314,17 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
>> goto out;
>>
>>   	err = -ENOMEM;
>> -	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
>> -				     sizeof(struct inet_diag_meminfo) +
>> -				     handler->idiag_info_size + 64)),
>> -			GFP_KERNEL);
>> +	len = sizeof(struct inet_diag_msg) + 64;
>> +
>> +	len += (req->idiag_ext&  (1<<  (INET_DIAG_MEMINFO - 1))) ?
>> +		sizeof(struct inet_diag_meminfo) : 0;
>> +	len += (req->idiag_ext&  (1<<  (INET_DIAG_INFO - 1))) ?
>> +		handler->idiag_info_size : 0;
>> +	len += (req->idiag_ext&  (1<<  (INET_DIAG_SECCTX - 1))) ?
>> +		MAX_SECCTX_LEN : 0;
>> +
>> +	rep = alloc_skb(NLMSG_SPACE(len), GFP_KERNEL);
>
> How much of a problem would it be if you just allocated an entire page (or 4k
> in the case of huge pages) and used that?  Is memory usage a concern here?
>

The memory usage is main concern, or else the 4k page is good idea.
Other side is that this function is few called, so the 4k maybe acceptable.



-- 
Best Reagrds,
Roy | RongQing Li
