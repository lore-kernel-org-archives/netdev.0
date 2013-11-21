From: wangweidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net] net: sctp: fix copying sk_v6_rcv_saddr in sctp_v6_create_accept_sk
Date: Thu, 21 Nov 2013 14:49:57 +0800
Message-ID: <528DAD15.20901@huawei.com>
References: <1384858284-2246-1-git-send-email-dborkman@redhat.com> <528B85E2.5080403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:11149 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3KUGuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:50:24 -0500
In-Reply-To: <528B85E2.5080403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/19 23:38, Vlad Yasevich wrote:
> On 11/19/2013 05:51 AM, Daniel Borkmann wrote:
>> Wang reported an issue that lksctp's test_getname_v6 seems to fail.
>>
>> The issue is that we do not copy sk_v6_rcv_saddr over to the new
>> socket, although the comment above says so regarding rcv_saddr.
>>
>> Commit 914e1c8b6980 ("sctp: Inherit all socket options from parent
>> correctly.") originally moved that over to sctp_copy_sock(), but
>> after commit efe4208f47f9 ("ipv6: make lookups simpler and faster")
>> this no longer holds and the actual value of sk_v6_rcv_saddr was
>> no longer being migrated.
>>
>> With this patch, the lksctp test suite passes again for IPv6.
>>
>> Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  net/sctp/ipv6.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>> index 7567e6f..be08592 100644
>> --- a/net/sctp/ipv6.c
>> +++ b/net/sctp/ipv6.c
>> @@ -661,6 +661,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
>>  	 * and getpeername().
>>  	 */
>>  	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
>> +	newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
>>  
>>  	sk_refcnt_debug_inc(newsk);
>>  
>>
> 
> This fixes the issue for the accept() case, but the bug is still there
> in the peeloff case.
> 
> I think you should make sctp_copy_sock() use sock_copy() for now.  It
> looks like it will catch all the cases.
> 

I copied the part of the sock_copy() codes into sctp_v6_create_accept_sk instead of
sctp_copy_sock for testing. Like this:

--------------

@@ -645,7 +645,11 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 
        sock_init_data(NULL, newsk);
 
-       sctp_copy_sock(newsk, sk, asoc);
+       memcpy(newsk, sk, offsetof(struct sock, sk_dontcopy_begin));
+
+       memcpy(&newsk->sk_dontcopy_end, &sk->sk_dontcopy_end,
+              sk->sk_prot->obj_size - offsetof(struct sock, sk_dontcopy_end));
+
        sock_reset_flag(sk, SOCK_ZAPPED);
 
        newsctp6sk = (struct sctp6_sock *)newsk;

--------------

when I did the test_getname_v6 of lksctp tools. It would hang. And I used the ps aux,
I can see the process got a D+ STAT.

BTW, I test it in the virtual machine.

So I think: when we use the sock_copy or which calls it, maybe we will get the problem here.
Is there I do something wrong?

Thanks. 

> We can then look at possibly getting rid of sctp_copy_sock() for net-next.
> 
> -vlad
> 
> 
> 
