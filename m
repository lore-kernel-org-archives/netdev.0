From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix copying sk_v6_rcv_saddr in sctp_v6_create_accept_sk
Date: Thu, 21 Nov 2013 10:08:00 +0100
Message-ID: <528DCD70.6060306@redhat.com>
References: <1384858284-2246-1-git-send-email-dborkman@redhat.com> <528B85E2.5080403@gmail.com> <528DAD15.20901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: wangweidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337Ab3KUJIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 04:08:12 -0500
In-Reply-To: <528DAD15.20901@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 07:49 AM, wangweidong wrote:
> On 2013/11/19 23:38, Vlad Yasevich wrote:
>> On 11/19/2013 05:51 AM, Daniel Borkmann wrote:
>>> Wang reported an issue that lksctp's test_getname_v6 seems to fail.
>>>
>>> The issue is that we do not copy sk_v6_rcv_saddr over to the new
>>> socket, although the comment above says so regarding rcv_saddr.
>>>
>>> Commit 914e1c8b6980 ("sctp: Inherit all socket options from parent
>>> correctly.") originally moved that over to sctp_copy_sock(), but
>>> after commit efe4208f47f9 ("ipv6: make lookups simpler and faster")
>>> this no longer holds and the actual value of sk_v6_rcv_saddr was
>>> no longer being migrated.
>>>
>>> With this patch, the lksctp test suite passes again for IPv6.
>>>
>>> Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>> ---
>>>   net/sctp/ipv6.c | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>> index 7567e6f..be08592 100644
>>> --- a/net/sctp/ipv6.c
>>> +++ b/net/sctp/ipv6.c
>>> @@ -661,6 +661,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
>>>   	 * and getpeername().
>>>   	 */
>>>   	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
>>> +	newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
>>>
>>>   	sk_refcnt_debug_inc(newsk);
>>>
>>>
>>
>> This fixes the issue for the accept() case, but the bug is still there
>> in the peeloff case.
>>
>> I think you should make sctp_copy_sock() use sock_copy() for now.  It
>> looks like it will catch all the cases.
>>
>
> I copied the part of the sock_copy() codes into sctp_v6_create_accept_sk instead of
> sctp_copy_sock for testing. Like this:
>
> --------------
>
> @@ -645,7 +645,11 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
>
>          sock_init_data(NULL, newsk);
>
> -       sctp_copy_sock(newsk, sk, asoc);
> +       memcpy(newsk, sk, offsetof(struct sock, sk_dontcopy_begin));
> +
> +       memcpy(&newsk->sk_dontcopy_end, &sk->sk_dontcopy_end,
> +              sk->sk_prot->obj_size - offsetof(struct sock, sk_dontcopy_end));
> +
>          sock_reset_flag(sk, SOCK_ZAPPED);
>
>          newsctp6sk = (struct sctp6_sock *)newsk;
>
> --------------
>
> when I did the test_getname_v6 of lksctp tools. It would hang. And I used the ps aux,
> I can see the process got a D+ STAT.
>
> BTW, I test it in the virtual machine.
>
> So I think: when we use the sock_copy or which calls it, maybe we will get the problem here.
> Is there I do something wrong?

Sorry, got distracted with other things in the mean time.

I will have a closer look at it very soon, so that we can find a proper fix.

> Thanks.
>
>> We can then look at possibly getting rid of sctp_copy_sock() for net-next.
>>
>> -vlad
>>
>>
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
