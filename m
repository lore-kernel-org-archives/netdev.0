From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: kernel 2.6.23.8: KERNEL: assertion in net/ipv4/tcp_input.c
Date: Thu, 13 Dec 2007 17:51:15 +0100
Message-ID: <200712131751.15578.wolfgang.walter@studentenwerk.mhn.de>
References: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de> <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:57223 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750825AbXLMQvR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 11:51:17 -0500
In-Reply-To: <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ilpo,

it happened again with your patch applied:

WARNING: at net/ipv4/tcp_input.c:1018 tcp_sacktag_write_queue()

Call Trace:
<IRQ>  [<ffffffff80549290>] tcp_sacktag_write_queue+0x7d0/0xa60
[<ffffffff80283869>] add_partial+0x19/0x60
[<ffffffff80549ac4>] tcp_ack+0x5a4/0x1d70
[<ffffffff8054e625>] tcp_rcv_established+0x485/0x7b0
[<ffffffff80554c3d>] tcp_v4_do_rcv+0xed/0x3e0
[<ffffffff80556fe7>] tcp_v4_rcv+0x947/0x970
[<ffffffff80538c6c>] ip_local_deliver+0xac/0x290
[<ffffffff80538862>] ip_rcv+0x362/0x6c0
[<ffffffff804fc5d3>] netif_receive_skb+0x323/0x420
[<ffffffff8042ab40>] tg3_poll+0x630/0xa50
[<ffffffff804fecba>] net_rx_action+0x8a/0x140
[<ffffffff8023a269>] __do_softirq+0x69/0xe0
[<ffffffff8020d47c>] call_softirq+0x1c/0x30
[<ffffffff8020f315>] do_softirq+0x35/0x90
[<ffffffff8023a105>] irq_exit+0x55/0x60
[<ffffffff8020f3f0>] do_IRQ+0x80/0x100
[<ffffffff8020c7d1>] ret_from_intr+0x0/0xa
<EOI>


Am Montag, 3. Dezember 2007 14:34 schrieb Ilpo J=E4rvinen:
> On Mon, 3 Dec 2007, Wolfgang Walter wrote:
> > with kernel 2.6.23.8 we saw a
> >
> > KERNEL: assertion ((int)tcp_packets_in_flight(tp) >=3D 0) failed at
> > net/ipv4/tcp_input.c (1292)
>
> Is this the only message? Are there any Leak printouts?
> Any tweaking done to TCP related sysctls?

net/core/somaxconn=3D2048
net/ipv4/tcp_syncookies=3D1
net/ipv4/tcp_max_syn_backlog=3D8192
net/ipv4/tcp_max_tw_buckets=3D1800000
net/ipv4/tcp_window_scaling=3D0
net/ipv4/tcp_timestamps=3D0

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

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
