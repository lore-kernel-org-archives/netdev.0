From: Jerry Chu <hkchu@google.com>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Wed, 5 Sep 2012 16:07:06 -0700
Message-ID: <CAPshTCgVGBpqgrMR8ub4+WKpEDMmPtPRfri8-35TVuHbf_H4yA@mail.gmail.com>
References: <20120904140411.GB15068@localhost>
	<5046361C.5070602@pengutronix.de>
	<87mx15zfze.fsf@xmission.com>
	<20120905145508.GA9450@localhost>
	<50476931.20100@pengutronix.de>
	<1346859046.13121.144.camel@edumazet-glaptop>
	<1346859645.13121.146.camel@edumazet-glaptop>
	<1346864220.13121.157.camel@edumazet-glaptop>
	<20120905222850.GA11230@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120905222850.GA11230@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 5, 2012 at 3:28 PM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> On Wed, Sep 05, 2012 at 06:57:00PM +0200, Eric Dumazet wrote:
>> On Wed, 2012-09-05 at 17:40 +0200, Eric Dumazet wrote:
>>
>> > Could you test the following patch please ?
>
> It works - no single error for 1000 boots!

Sorry for introducing the bug, one of the casualties dealing with code
that is shared
outside of TCP. I did spend some effort adding special checks but I was wrong in
assuming inet_create() will zero all the field including fastopenq
inside icsk_accept_queue
inside struct inet_connection_sock - although this is true for TCP and
DCCP, SCTP doesn't
have inet_connection_sock hence inet_csk(sk) is bogus.

Kudo to Eric for fixing it quickly before I got to it.

Jerry

>
> btw, the first bad commit has been bisected to
>
>         commit 8336886f786fdacbc19b719c1f7ea91eb70706d4
>         Author: Jerry Chu <hkchu@google.com>
>         Date:   Fri Aug 31 12:29:12 2012 +0000
>
>             tcp: TCP Fast Open Server - support TFO listeners
>
>> > (Not sure why sctp doesnt memset/bzero its whole socket by the way...)
>> >
>> > Thanks
>>
>> Here is a more complete patch, as there are three potential problems,
>> not only one :
>
> Great! I'll start tests for it.
>
> Thanks,
> Fengguang
>
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index 4f70ef0..845372b 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -149,11 +149,8 @@ void inet_sock_destruct(struct sock *sk)
>>               pr_err("Attempt to release alive inet socket %p\n", sk);
>>               return;
>>       }
>> -     if (sk->sk_type == SOCK_STREAM) {
>> -             struct fastopen_queue *fastopenq =
>> -                     inet_csk(sk)->icsk_accept_queue.fastopenq;
>> -             kfree(fastopenq);
>> -     }
>> +     if (sk->sk_protocol == IPPROTO_TCP)
>> +             kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
>>
>>       WARN_ON(atomic_read(&sk->sk_rmem_alloc));
>>       WARN_ON(atomic_read(&sk->sk_wmem_alloc));
>> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
>> index 8464b79..f0c5b9c 100644
>> --- a/net/ipv4/inet_connection_sock.c
>> +++ b/net/ipv4/inet_connection_sock.c
>> @@ -314,7 +314,7 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
>>       newsk = req->sk;
>>
>>       sk_acceptq_removed(sk);
>> -     if (sk->sk_type == SOCK_STREAM && queue->fastopenq != NULL) {
>> +     if (sk->sk_protocol == IPPROTO_TCP && queue->fastopenq != NULL) {
>>               spin_lock_bh(&queue->fastopenq->lock);
>>               if (tcp_rsk(req)->listener) {
>>                       /* We are still waiting for the final ACK from 3WHS
>> @@ -775,7 +775,7 @@ void inet_csk_listen_stop(struct sock *sk)
>>
>>               percpu_counter_inc(sk->sk_prot->orphan_count);
>>
>> -             if (sk->sk_type == SOCK_STREAM && tcp_rsk(req)->listener) {
>> +             if (sk->sk_protocol == IPPROTO_TCP && tcp_rsk(req)->listener) {
>>                       BUG_ON(tcp_sk(child)->fastopen_rsk != req);
>>                       BUG_ON(sk != tcp_rsk(req)->listener);
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
