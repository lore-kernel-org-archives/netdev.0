From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: kernel 2.6.23.8: KERNEL: assertion in net/ipv4/tcp_input.c
Date: Mon, 3 Dec 2007 16:56:53 +0100
Message-ID: <200712031656.53142.wolfgang.walter@studentenwerk.mhn.de>
References: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de> <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:35798 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751145AbXLCP4z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 10:56:55 -0500
In-Reply-To: <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 3. Dezember 2007 14:34 schrieb Ilpo J=E4rvinen:
> On Mon, 3 Dec 2007, Wolfgang Walter wrote:
> > with kernel 2.6.23.8 we saw a
> >
> > KERNEL: assertion ((int)tcp_packets_in_flight(tp) >=3D 0) failed at
> > net/ipv4/tcp_input.c (1292)
>
> Is this the only message? Are there any Leak printouts?

No.

4 days earlier there were 3 messages: TCP: Treason uncloaked! Peer=20
a.b.c.d:80/56532 shrinks window 3535507131:3535513869. Repaired.

> Any tweaking done to TCP related sysctls?
> And for completeness, is GSO enabled (ethtool -k)?

rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

>
> Most likely I broke the manual synchronization for left_out in sackta=
g by
> skipping over it when packets_out =3D=3D 0 but so far I haven't been =
able to
> figure out how such state could develop in the first place... Ie., I
> couldn't find a case where tcp_fastretrans_alert wouldn't be called i=
f
> left_out was non-zero (and it did the sync_left_out after modifying
> either sacked_out or lost_out, IIRC).
>
> ...If you can reproduce it, you could try if this patch below changes

I don't know how to reproduce it - we never saw the message before. I'l=
l aply=20
the patch. Let see if the WARN_ON triggers before we update to a newer=20
kernel :-).

> anything (should silence the assert and trigger earlier a WARN_ON or
> two :-)). ...If this triggers, then I'm sure we can pollute TCP code
> by a larger number of more costly checks to catch it in early.
>
> This might reveal a long-standing inconsistency of left_out in some
> case I just couldn't come up with by code review. Left_out will be
> (is) anyway dropped as unnecessary in 2.6.24. In 2.6.23 sync for
> left_out occurs quite soon after that BUG_TRAP anyway so the effect
> won't be too dramatic, prior_in_flight would be once stale, won't
> lead to big problems (either missed cnwd or cwnd_cnt increment, or
> failure to do application limited check at that particular ACK).
>
> Thanks anyway for the report. ...If I figure something out here, I'll
> let you know.
>
> --
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index c9298a7..0c5194d 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1012,8 +1012,12 @@ tcp_sacktag_write_queue(struct sock *sk, struc=
t
> sk_buff *ack_skb, u32 prior_snd_ if (before(TCP_SKB_CB(ack_skb)->ack_=
seq,
> prior_snd_una - tp->max_window)) return 0;
>
> -	if (!tp->packets_out)
> +	if (!tp->packets_out) {
> +		WARN_ON(tp->sacked_out);
> +		WARN_ON(tp->lost_out);
> +		WARN_ON(tp->left_out);
>  		goto out;
> +	}
>
>  	/* SACK fastpath:
>  	 * if the only SACK change is the increase of the end_seq of
> @@ -1277,14 +1281,14 @@ tcp_sacktag_write_queue(struct sock *sk, stru=
ct
> sk_buff *ack_skb, u32 prior_snd_ }
>  	}
>
> +out:
> +
>  	tp->left_out =3D tp->sacked_out + tp->lost_out;
>
>  	if ((reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_CA_Lo=
ss &&
>  	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
>  		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
>
> -out:
> -
>  #if FASTRETRANS_DEBUG > 0
>  	BUG_TRAP((int)tp->sacked_out >=3D 0);
>  	BUG_TRAP((int)tp->lost_out >=3D 0);

Thanks and regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
