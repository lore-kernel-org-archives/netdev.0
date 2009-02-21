From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Sat, 21 Feb 2009 20:54:11 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902212042420.20526@wrl-59.cs.helsinki.fi>
References: <20090206054541.GA4954@gondor.apana.org.au>
 <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
 <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net>
 <20090209061151.GA3982@gondor.apana.org.au> <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
 <20090209072806.GB4380@gondor.apana.org.au> <Pine.LNX.4.64.0902091513190.31742@wrl-59.cs.helsinki.fi>
 <20090221132424.GA28861@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-756698155-1235241969=:20526"
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37125 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbZBUSyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 13:54:13 -0500
In-Reply-To: <20090221132424.GA28861@gondor.apana.org.au>
Content-ID: <Pine.LNX.4.64.0902212049440.20526@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-756698155-1235241969=:20526
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0902212049441.20526@wrl-59.cs.helsinki.fi>

On Sat, 21 Feb 2009, Herbert Xu wrote:

> On Mon, Feb 09, 2009 at 03:28:09PM +0200, Ilpo Järvinen wrote:
> >
> > Yes, that should work too except the gcc catchable typo.
> 
> Thanks, so let's try again for net-next:
> 
> tcp: Always set urgent pointer if it's beyond snd_nxt
> 
> Our TCP stack does not set the urgent flag if the urgent pointer
> does not fit in 16 bits, i.e., if it is more than 64K from the
> sequence number of a packet.
> 
> This behaviour is different from the BSDs, and clearly contradicts
> the purpose of urgent mode, which is to send the notification
> (though not necessarily the associated data) as soon as possible.
> Our current behaviour may in fact delay the urgent notification
> indefinitely if the receiver window does not open up.
> 
> Simply matching BSD however may break legacy applications which
> incorrectly rely on the out-of-band delivery of urgent data, and
> conversely the in-band delivery of non-urgent data.
> 
> Alexey Kuznetsov suggested a safe solution of following BSD only
> if the urgent pointer itself has not yet been transmitted.  This
> way we guarantee that when the remote end sees the packet with
> non-urgent data marked as urgent due to wrap-around we would have
> advanced the urgent pointer beyond, either to the actual urgent
> data or to an as-yet untransmitted packet.
> 
> The only potential downside is that applications on the remote
> end may see multiple SIGURG notifications.  However, this would
> occur anyway with other TCP stacks.  More importantly, the outcome
> of such a duplicate notification is likely to be harmless since
> the signal itself does not carry any information other than the
> fact that we're in urgent mode.
> 
> Thanks to Ilpo Järvinen for fixing a critical bug in this and
> Jeff Chua for reporting that bug.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index dda42f0..f5263c8 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -663,10 +663,14 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>  	th->urg_ptr		= 0;
>  
>  	/* The urg_mode check is necessary during a below snd_una win probe */
> -	if (unlikely(tcp_urg_mode(tp) &&
> -		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
> -		th->urg_ptr		= htons(tp->snd_up - tcb->seq);
> -		th->urg			= 1;
> +	if (unlikely(tcp_urg_mode(tp) && before(tcb->seq, tp->snd_up))) {
> +		if (before(tp->snd_up, tcb->seq + 0x10000)) {
> +			th->urg_ptr = htons(tp->snd_up - tcb->seq);
> +			th->urg = 1;
> +		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> +			th->urg_ptr = 0xFFFF;
> +			th->urg = 1;
> +		}
>  	}
>  
>  	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);

I thought this through already at the last time... so I think it really 
should work in all cases I could think of (including the below window 
probes whose existance is not very obvious before they bite back :-)):

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

But I mostly agree with Linus that URG is legacy that would be good
to just deprecate instead of trying to "fix" it.


-- 
 i.
---696208474-756698155-1235241969=:20526--
