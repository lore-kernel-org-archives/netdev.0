From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: kernel 2.6.23.8: KERNEL: assertion in net/ipv4/tcp_input.c
Date: Mon, 31 Dec 2007 14:03:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712311340001.31661@kivilampi-30.cs.helsinki.fi>
References: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de>
 <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
 <200712131751.15578.wolfgang.walter@studentenwerk.mhn.de>
 <Pine.LNX.4.64.0712142240220.1400@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-484762526-1199101208=:31661"
Cc: Netdev <netdev@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>,
	Robert Henney <robh@rut.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35187 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757457AbXLaMDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 07:03:51 -0500
In-Reply-To: <Pine.LNX.4.64.0712142240220.1400@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0712311341060.31661@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-484762526-1199101208=:31661
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712311340211.31661@kivilampi-30.cs.helsinki.fi>

On Fri, 14 Dec 2007, Ilpo Järvinen wrote:

> On Thu, 13 Dec 2007, Wolfgang Walter wrote:
> 
> > it happened again with your patch applied:
> > 
> > WARNING: at net/ipv4/tcp_input.c:1018 tcp_sacktag_write_queue()
> > 
> > Call Trace:
> > <IRQ>  [<ffffffff80549290>] tcp_sacktag_write_queue+0x7d0/0xa60
> > [<ffffffff80283869>] add_partial+0x19/0x60
> > [<ffffffff80549ac4>] tcp_ack+0x5a4/0x1d70
> > [<ffffffff8054e625>] tcp_rcv_established+0x485/0x7b0
> > [<ffffffff80554c3d>] tcp_v4_do_rcv+0xed/0x3e0
> > [<ffffffff80556fe7>] tcp_v4_rcv+0x947/0x970
> > [<ffffffff80538c6c>] ip_local_deliver+0xac/0x290
> > [<ffffffff80538862>] ip_rcv+0x362/0x6c0
> > [<ffffffff804fc5d3>] netif_receive_skb+0x323/0x420
> > [<ffffffff8042ab40>] tg3_poll+0x630/0xa50
> > [<ffffffff804fecba>] net_rx_action+0x8a/0x140
> > [<ffffffff8023a269>] __do_softirq+0x69/0xe0
> > [<ffffffff8020d47c>] call_softirq+0x1c/0x30
> > [<ffffffff8020f315>] do_softirq+0x35/0x90
> > [<ffffffff8023a105>] irq_exit+0x55/0x60
> > [<ffffffff8020f3f0>] do_IRQ+0x80/0x100
> > [<ffffffff8020c7d1>] ret_from_intr+0x0/0xa
> > <EOI>
> 
> ...Yeah, as I suspected, left_out != 0 when sacked_out and lost_out are 
> zero. I'll try to read the code again to see how that could happen (in 
> any case this is just annoying at the best, no other harm but the 
> message is being done). ...If nothing comes up I might ask you to run
> with another test patch but it might take week or so until I've enough
> time to dig into this fully because I must also come familiar with 
> something as pre-historic as the 2.6.23 (there are already large number
> of related changes since then, both in upcoming 2.6.24 and some in 
> net-2.6.25)... :-)

...I checked and found this one place from where left_out inconsistency 
could develop from in stable-2.6.23 or earlier. No idea though how we end 
up there and do not sync afterwards. Adding WARN_ON to that branch might 
help but it will give false positives too from sacktag_write_queue
due to DSACKs. 

...If either of you wants to, you could add WARN_ON(1) to that modified 
block too and just ignore those now and then stack_traces having
tcp_sacktag_write_queue calling tcp_fragment (they are not suspect because 
they occur due to DSACKs and sync before the assertion).

-- 
 i.

--
[PATCH] [TCP]: Try to fix left_out inconsistency

This spot performs (ie., doesn't perform it) obviously incorrect
counting for left_out though I know very few ways to call
tcp_fragment() for SACKED_ACKED skbs (DSACK seems to be the only
case, and perhaps some split-after-first ACK SACK blocks could
cause this as well and both fill sync after the loop). Those
usually shouldn't lead to any adjustments of pcount though (and 
tcp_sync_left_out()s are all over the code so it's very narrow
maze to not "hit" them in between which could remove all temporal 
inconsistencies). Therefore this might not be the actually cause
of the detected inconsistencies but due to complexity of
corner-case  scenarios it seems still be a worth of try (I might
have missed some path :-)).

This is only valid for stable-2.6.23 or earlier because
anything before that drops left_out and calculates it on
the fly from lost_out and sacked_out and is therefore always
consistently in sync.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 666d8a5..9fc08cb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -677,8 +677,10 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 
 		tp->packets_out -= diff;
 
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
 			tp->sacked_out -= diff;
+			tp->left_out -= diff;
+		}
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
 			tp->retrans_out -= diff;
 
-- 
1.5.0.6

---696243703-484762526-1199101208=:31661--
