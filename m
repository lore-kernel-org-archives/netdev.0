From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH RFC net-next 3/3] net/core/sock.c: sk_clone_lock() should
 only do get_net() if the parent is not a kernel socket
Date: Thu, 30 Jul 2015 11:29:08 -0700
Message-ID: <CAHA+R7N7kF9=qACWrnfpR2N5F+nbmnZTvA9+c79x7-RFX5Aang@mail.gmail.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com>
	<15334c31275787177fb1d12927604ee87d3938d4.1438245718.git.sowmini.varadhan@oracle.com>
	<1438261607.20182.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev <netdev@vger.kernel.org>,
	ajaykumar.hotchandani@oracle.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33303 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbG3S3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 14:29:09 -0400
Received: by ykdv124 with SMTP id v124so274444ykd.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 11:29:08 -0700 (PDT)
In-Reply-To: <1438261607.20182.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2015 at 6:06 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-07-30 at 04:55 -0400, Sowmini Varadhan wrote:
>> The newsk returned by sk_clone_lock should hold a get_net()
>> reference if, and only if, the parent is not a kernel socket
>> (making this similar to sk_alloc()).
>>
>> E.g,. for the SYN_RECV call path, tcp_v4_syn_recv_sock->..inet_csk_clone_lock
>> sets up the syn_recv newsk from sk_clone_lock. When the parent (listen)
>> socket is a kernel socket (defined in sk_alloc() as having
>> sk_net_refcnt == 0), then the newsk should also have a 0 sk_net_refcnt
>> and should not hold a get_net() reference.
>>
>> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>> ---
>>  net/core/sock.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 08f16db..371d1b7 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1497,7 +1497,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>>               sock_copy(newsk, sk);
>>
>>               /* SANITY */
>> -             get_net(sock_net(newsk));
>> +             if (likely(newsk->sk_net_refcnt))
>> +                     get_net(sock_net(newsk));
>>               sk_node_init(&newsk->sk_node);
>>               sock_lock_init(newsk);
>>               bh_lock_sock(newsk);
>
> CC Eric Biederman
>
> It looks this should be submitted for 'net' tree, not 'net-next'
>

It only affects TCP kernel sockets, and we only have few use cases in tree,
and it looks like dlm does its own ->accpet(), so net-next should be fine.
