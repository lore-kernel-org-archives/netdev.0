From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Thu, 15 Dec 2011 20:00:06 +0100
Message-ID: <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EE8F884.1010304@hp.com>
	 <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	 <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA3D58.5010101@hp.com>
	 <20111215104440.1eef9e47@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40515 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1LOTAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 14:00:10 -0500
Received: by faar15 with SMTP id r15so2552996faa.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 11:00:08 -0800 (PST)
In-Reply-To: <20111215104440.1eef9e47@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 10:44 -0800, Stephen Hemminger a =
=C3=A9crit :
> On Thu, 15 Dec 2011 10:32:56 -0800
> Rick Jones <rick.jones2@hp.com> wrote:
>=20
> >=20
> > > More exactly, we call dev_queue_xmit_nit() from dev_hard_start_xm=
it()
> > > _before_ giving skb to device driver.
> > >
> > > If device driver returns NETDEV_TX_BUSY, and a qdisc was setup on=
 the
> > > device, packet is requeued.
> > >
> > > Later, when queue is allowed to send again packets, packet is
> > > retransmitted (and traced a second time in dev_queue_xmit_nit())
> >=20
> > Is this then an unintended consequence bug, or a known feature?
> >=20
> > rick
> >=20
> > > You can see the 'requeues' counter from "tc -s -d qdisc" output :
> > >
> > > qdisc mq 0: dev eth2 root
> > >   Sent 29421597369 bytes 20301716 pkt (dropped 0, overlimits 0 re=
queues 371)
> > >   backlog 0b 0p requeues 371
> >=20
> > Sure enough:
> >=20
> > $ tc -s -d qdisc
> > qdisc mq 0: dev eth0 root
> >   Sent 2212158799862 bytes 1938268098 pkt (dropped 0, overlimits 0=20
> > requeues 4975139)
> >   backlog 0b 0p requeues 4975139
> >=20
> > rick jones
>=20
> Device's work better if the driver proactively manages stop_queue/wak=
e_queue.
> Old devices used TX_BUSY, but newer devices tend to manage the queue
> themselves.
>=20

Some 'new' drivers like igb can be fooled in case skb is gso segmented =
?

Because igb_xmit_frame_ring() needs skb_shinfo(skb)->nr_frags + 4
descriptors, igb should stop its queue not at MAX_SKB_FRAGS + 4, but
MAX_SKB_FRAGS*4

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/et=
hernet/intel/igb/igb_main.c
index 89d576c..989da36 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4370,7 +4370,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *s=
kb,
 	igb_tx_map(tx_ring, first, hdr_len);
=20
 	/* Make sure there is space in the ring for the next send. */
-	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS + 4);
+	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS * 4);
=20
 	return NETDEV_TX_OK;
