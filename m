From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 9990] New: tg3: eth0: The system may be
 re-ordering memory-mapped I/O cycles
Date: Thu, 14 Feb 2008 13:25:27 -0800
Message-ID: <1203024327.13495.21.camel@dell>
References: <bug-9990-10286@http.bugzilla.kernel.org/>
 <20080214102425.0fc8e3c1.akpm@linux-foundation.org>
 <20080214185627.GK856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org, netdev <netdev@vger.kernel.org>,
	ralf.hildebrandt@charite.de
To: "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3835 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755220AbYBNVXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 16:23:43 -0500
In-Reply-To: <20080214185627.GK856@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-14 at 13:56 -0500, Andy Gospodarek wrote:
> On Thu, Feb 14, 2008 at 10:24:25AM -0800, Andrew Morton wrote:
> > On Thu, 14 Feb 2008 01:59:12 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=9990
> > > 
> > >            Summary: tg3: eth0: The system may be re-ordering memory-mapped
> > >                     I/O cycles
> > >            Product: Drivers
> > >            Version: 2.5
> > >      KernelVersion: 2.6.24-git18
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Network
> > >         AssignedTo: jgarzik@pobox.com
> > >         ReportedBy: ralf.hildebrandt@charite.de
> > > 
> > > 
> 
> That should be a simple matter of adding the right pci-ids to
> tg3_get_invariants -- hopefully Ralf will respond and we can get that
> knocked out quickly.
> 
> 

It doesn't look like it was re-ordered IO.  If it was, it should have
self-recovered without hitting the BUG().

One possibility is that the nr_frags in the SKB got corrupted before the
TX SKB was freed.  The driver relies on the nr_frags in the SKB to find
the packet boundaries in the TX ring.  If it cannot find the packet
boundaries, it will exhibit the same symptom as re-ordered IO, only that
it cannot be self-recovered.

Ralf, please try this debug patch with the same traffic condition you
ran before.  This patch stores the nr_frags when transmitting an SKB.
During tx completion, it will compare the stored nr_frags with the one
in the SKB and will print out something in dmesg if they don't match.

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index db606b6..73f1ddd 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3324,12 +3324,20 @@ static void tg3_tx(struct tg3 *tp)
 		struct tx_ring_info *ri = &tp->tx_buffers[sw_idx];
 		struct sk_buff *skb = ri->skb;
 		int i, tx_bug = 0;
+		unsigned short nr_frags = ri->nr_frags;
 
 		if (unlikely(skb == NULL)) {
 			tg3_tx_recover(tp);
 			return;
 		}
 
+		if (nr_frags != skb_shinfo(skb)->nr_frags) {
+			printk(KERN_ALERT "tg3: %s: Tx skb->nr_frags corrupted "
+				"before skb is freed. Expected nr_frags %d, "
+				"corrupted nr_frags %d\n", tp->dev->name,
+				nr_frags, skb_shinfo(skb)->nr_frags);
+		}
+
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(ri, mapping),
 				 skb_headlen(skb),
@@ -3339,7 +3347,7 @@ static void tg3_tx(struct tg3 *tp)
 
 		sw_idx = NEXT_TX(sw_idx);
 
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		for (i = 0; i < nr_frags; i++) {
 			ri = &tp->tx_buffers[sw_idx];
 			if (unlikely(ri->skb != NULL || sw_idx == hw_idx))
 				tx_bug = 1;
@@ -4105,6 +4113,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 				 len, PCI_DMA_TODEVICE);
 		if (i == 0) {
 			tp->tx_buffers[entry].skb = new_skb;
+			tp->tx_buffers[entry].nr_frags = 0;
 			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, new_addr);
 		} else {
 			tp->tx_buffers[entry].skb = NULL;
@@ -4211,6 +4220,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
 	tp->tx_buffers[entry].skb = skb;
+	tp->tx_buffers[entry].nr_frags = skb_shinfo(skb)->nr_frags;
 	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 	tg3_set_txd(tp, entry, mapping, len, base_flags,
@@ -4388,6 +4398,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
 	tp->tx_buffers[entry].skb = skb;
+	tp->tx_buffers[entry].nr_frags = skb_shinfo(skb)->nr_frags;
 	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 	would_hit_hwbug = 0;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 3938eb3..d4a3aca 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2098,6 +2098,7 @@ struct tx_ring_info {
 	struct sk_buff			*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 	u32				prev_vlan_tag;
+	unsigned short			nr_frags;
 };
 
 struct tg3_config_info {




