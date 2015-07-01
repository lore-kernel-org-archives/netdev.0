From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Thu, 2 Jul 2015 01:26:42 +0200
Message-ID: <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
	<20150701.141402.587634025761326092.davem@davemloft.net>
	<CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
	<CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:33621 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbbGAX0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 19:26:44 -0400
Received: by wgck11 with SMTP id k11so49054154wgc.0
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 16:26:43 -0700 (PDT)
In-Reply-To: <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 2, 2015 at 1:18 AM, Alex Gartrell <alexgartrell@gmail.com> wrote:
> On Wednesday, July 1, 2015, Eric Dumazet <edumazet@google.com> wrote:
>>
>> On Wed, Jul 1, 2015 at 11:14 PM, David Miller <davem@davemloft.net> wrote:
>> > From: Alex Gartrell <agartrell@fb.com>
>> > Date: Wed, 1 Jul 2015 13:13:09 -0700
>> >
>> >> If we early-demux bind a TCP_TIMEWAIT socket to an skb and then orphan
>> >> it
>> >> (as we need to do in the ipvs forwarding case), sock_wfree and
>> >> sock_rfree
>> >> are going to reach into the inet_timewait_sock and mess with fields
>> >> that
>> >> don't exist.
>> >>
>> >> Signed-off-by: Alex Gartrell <agartrell@fb.com>
>> >
>> > If we're forwarding, we should not find a local socket, period.
>>
>> A socket cannot change state to TCP_TIMEWAIT.
>>
>> A new object is allocated and old one is removed from ehash, then
>> freed (rcu rules being applied)
>>
>> Also sock_wfree() has nothing to do with early demux. It is for output
>> path skbs only.
>
>
> Alright I kind of cheated and didn't include full context here. The problem
> is that within ipvs we are getting  packets that have been early demuxed and
> associated with time wait sockets which we then wish to forward immediately
> (ip_vs_xmit.c).  Under normal circumstances it would never be associated
> with any sk at all, but it is because of early demux, so we want to drop the
> relationship by calling skb_orphan.  This invokes the destructor which lands
> us there.
>
> So that is how we reach this illegal "treating a twsk like an sk" state.
>
> If there is a better way to drop the association than skb_orphan I will use
> it.

I think you are mistaken Alex.

socket early demux cannot possibly set skb->destructor to sock_rfree()

If skb->destructor is set by early demux, it correctly points to sock_edemux()

And this one correctly handles all socket variants.

/* All sockets share common refcount, but have different destructors */
void sock_gen_put(struct sock *sk)
{
        if (!atomic_dec_and_test(&sk->sk_refcnt))
                return;

        if (sk->sk_state == TCP_TIME_WAIT)
                inet_twsk_free(inet_twsk(sk));
        else if (sk->sk_state == TCP_NEW_SYN_RECV)
                reqsk_free(inet_reqsk(sk));
        else
                sk_free(sk);
}
EXPORT_SYMBOL_GPL(sock_gen_put);

void sock_edemux(struct sk_buff *skb)
{
        sock_gen_put(skb->sk);
}
EXPORT_SYMBOL(sock_edemux);
