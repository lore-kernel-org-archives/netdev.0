From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon:  caller is netif_rx
Date: Mon, 12 Apr 2010 21:40:51 +0200
Message-ID: <1271101251.16881.135.camel@edumazet-laptop>
References: <1271100042.9831.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58242 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab0DLTsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 15:48:12 -0400
Received: by bwz19 with SMTP id 19so3404bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 12:48:10 -0700 (PDT)
In-Reply-To: <1271100042.9831.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 15:20 -0400, Eric Paris a =C3=A9crit :
> I get about 9 of these near the start of the system while userspace i=
s
> first coming up.  The  virtual machine in question is mostly Fedora 1=
4
> with a kernel from linux-next as of today.  The hardware is RHEL 5.5
> with KVM:
>=20
> tree: git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.g=
it
> tag: next-20100412
> commit: bbeecf185fe464ccd7ee97ce6d3646ad686995b4
>=20
> I'm not sure what else to collect, give, test, try, show, debug or wh=
at
> have you so let me know.  Attached is my full dmesg and config.
>=20
> [   14.203970] BUG: using smp_processor_id() in preemptible [00000000=
] code: avahi-daemon/2093
> [   14.204025] caller is netif_rx+0xfa/0x110
> [   14.204032] Pid: 2093, comm: avahi-daemon Tainted: G        W  2.6=
=2E34-rc3-next-20100412+ #65
> [   14.204035] Call Trace:
> [   14.204064]  [<ffffffff81278fe5>] debug_smp_processor_id+0x105/0x1=
10
> [   14.204070]  [<ffffffff8142163a>] netif_rx+0xfa/0x110
> [   14.204090]  [<ffffffff8145b631>] ip_dev_loopback_xmit+0x71/0xa0
> [   14.204095]  [<ffffffff8145b892>] ip_mc_output+0x192/0x2c0
> [   14.204099]  [<ffffffff8145d610>] ip_local_out+0x20/0x30
> [   14.204105]  [<ffffffff8145d8ad>] ip_push_pending_frames+0x28d/0x3=
d0
> [   14.204119]  [<ffffffff8147f1cc>] udp_push_pending_frames+0x14c/0x=
400
> [   14.204125]  [<ffffffff814803fc>] udp_sendmsg+0x39c/0x790
> [   14.204137]  [<ffffffff814891d5>] inet_sendmsg+0x45/0x80
> [   14.204149]  [<ffffffff8140af91>] sock_sendmsg+0xf1/0x110
> [   14.204177]  [<ffffffff810e3a89>] ? might_fault+0xb9/0xd0
> [   14.204184]  [<ffffffff810e3a3e>] ? might_fault+0x6e/0xd0
> [   14.204189]  [<ffffffff8140dc6c>] sys_sendmsg+0x20c/0x380
> [   14.204205]  [<ffffffff811107f1>] ? do_sync_write+0xd1/0x110
> [   14.204211]  [<ffffffff810e3a3e>] ? might_fault+0x6e/0xd0
> [   14.204233]  [<ffffffff8100ad82>] system_call_fastpath+0x16/0x1b

Good spot, RPS changed a bit netif_rx() requirements.

I would change ip_dev_loopback_xmit() to call netif_rx_ni() instead...

David, Tom ?

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



