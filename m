From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon:  caller is netif_rx
Date: Thu, 15 Apr 2010 15:16:41 +0200
Message-ID: <1271337401.16881.2563.camel@edumazet-laptop>
References: <1271100042.9831.20.camel@localhost>
	 <1271101251.16881.135.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:62206 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab0DONQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 09:16:50 -0400
Received: by bwz25 with SMTP id 25so1572925bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 06:16:49 -0700 (PDT)
In-Reply-To: <1271101251.16881.135.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 21:40 +0200, Eric Dumazet a =C3=A9crit :
> Good spot, RPS changed a bit netif_rx() requirements.
>=20
> I would change ip_dev_loopback_xmit() to call netif_rx_ni() instead..=
=2E
>=20
> David, Tom ?
>=20
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index c65f18e..d1bcc9f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -120,7 +120,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *n=
ewskb)
>  	newskb->pkt_type =3D PACKET_LOOPBACK;
>  	newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
>  	WARN_ON(!skb_dst(newskb));
> -	netif_rx(newskb);
> +	netif_rx_ni(newskb);
>  	return 0;
>  }
> =20

After some confusion, it seems this was the right fix after all :)

[PATCH] ip: Fix ip_dev_loopback_xmit()

Eric Paris got following trace with a linux-next kernel

[   14.203970] BUG: using smp_processor_id() in preemptible [00000000]
code: avahi-daemon/2093
[   14.204025] caller is netif_rx+0xfa/0x110
[   14.204035] Call Trace:
[   14.204064]  [<ffffffff81278fe5>] debug_smp_processor_id+0x105/0x110
[   14.204070]  [<ffffffff8142163a>] netif_rx+0xfa/0x110
[   14.204090]  [<ffffffff8145b631>] ip_dev_loopback_xmit+0x71/0xa0
[   14.204095]  [<ffffffff8145b892>] ip_mc_output+0x192/0x2c0
[   14.204099]  [<ffffffff8145d610>] ip_local_out+0x20/0x30
[   14.204105]  [<ffffffff8145d8ad>] ip_push_pending_frames+0x28d/0x3d0
[   14.204119]  [<ffffffff8147f1cc>] udp_push_pending_frames+0x14c/0x40=
0
[   14.204125]  [<ffffffff814803fc>] udp_sendmsg+0x39c/0x790
[   14.204137]  [<ffffffff814891d5>] inet_sendmsg+0x45/0x80
[   14.204149]  [<ffffffff8140af91>] sock_sendmsg+0xf1/0x110
[   14.204189]  [<ffffffff8140dc6c>] sys_sendmsg+0x20c/0x380
[   14.204233]  [<ffffffff8100ad82>] system_call_fastpath+0x16/0x1b

While current linux-2.6 kernel doesnt emit this warning, bug is latent
and might cause unexpected failures.

ip_dev_loopback_xmit() runs in process context, preemption enabled, so
must call netif_rx_ni() instead of netif_rx(), to make sure that we
process pending software interrupt.

Reported-by: Eric Paris <eparis@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65f18e..d1bcc9f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -120,7 +120,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *new=
skb)
 	newskb->pkt_type =3D PACKET_LOOPBACK;
 	newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	WARN_ON(!skb_dst(newskb));
-	netif_rx(newskb);
+	netif_rx_ni(newskb);
 	return 0;
 }
=20


