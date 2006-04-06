From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Wed, 5 Apr 2006 17:42:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0604051734230.9255@lindenhurst-2.jf.intel.com>
References: <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru>
 <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru>
 <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru>
 <20060331121007.GA2146@king.bitgnome.net> <442D1F26.8050601@kernelpanic.ru>
 <20060331123514.GA13500@gondor.apana.org.au> <20060403210123.GA27698@king.bitgnome.net>
 <20060403213907.GA32406@linuxace.com> <44319AFF.4090101@kernelpanic.ru>
 <Pine.WNT.4.63.0604051500530.2496@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Boris B. Zhmurov" <bb@kernelpanic.ru>,
	Phil Oester <kernel@linuxace.com>, Mark Nipper <nipsy@bitgnome.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, Andi Kleen <ak@suse.de>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0604051500530.2496@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Wed, 5 Apr 2006, Jesse Brandeburg wrote:

> I'll also send a patch today to back-rev the xmit routine to the 5.6.10.1 
> state.

I'm in a bit of a hurry, but I wanted to send these debug patches out.  
Forgive me if my mailer decides to munge them.
I'd suggest trying the first one and then both together.
The first fixes up the tso function only to be like 5.6.10.1-k2.
The second builds on the first, and incorporates more of the tx changes.
  
I built and tested the driver with patches on 2.6.16, with pci-x adapters.  
I removed some workarounds for PCIe adapters, but I dont think anyone 
having this problem has a PCIe adapter anyway.  I saw no TX hangs and ran 
some bi-directional tests, so i think the driver should work okay.  Just 
warning you I did minimal testing.

*********************
e1000: transmit the old fashioned way

It seems back in the day of 2.6.11, there were no sk_forward_alloc
asserions.  Forward port that transmit code to see if it fixes the issues
in today's kernel.  Unfortunately it doesn't have all the bug fixes that
the current code has, but if we get transmit timeouts we can add in
workarounds appropriately.

this changes only the e1000_tso function

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

 drivers/net/e1000/e1000_main.c |   37 ++++++-------------------------------
 1 files changed, 6 insertions(+), 31 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
old mode 100644
new mode 100755
index e3d3778..2b8fb87
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2519,57 +2519,34 @@ e1000_tso(struct e1000_adapter *adapter,
 {
 #ifdef NETIF_F_TSO
 	struct e1000_context_desc *context_desc;
-	struct e1000_buffer *buffer_info;
 	unsigned int i;
 	uint32_t cmd_length = 0;
 	uint16_t ipcse = 0, tucse, mss;
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
-	int err;
 
 	if (skb_shinfo(skb)->tso_size) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
-
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
-		if (skb->protocol == ntohs(ETH_P_IP)) {
-			skb->nh.iph->tot_len = 0;
-			skb->nh.iph->check = 0;
-			skb->h.th->check =
-				~csum_tcpudp_magic(skb->nh.iph->saddr,
+		skb->nh.iph->tot_len = 0;
+		skb->nh.iph->check = 0;
+		skb->h.th->check = ~csum_tcpudp_magic(skb->nh.iph->saddr,
 						   skb->nh.iph->daddr,
 						   0,
 						   IPPROTO_TCP,
 						   0);
-			cmd_length = E1000_TXD_CMD_IP;
-			ipcse = skb->h.raw - skb->data - 1;
-#ifdef NETIF_F_TSO_IPV6
-		} else if (skb->protocol == ntohs(ETH_P_IPV6)) {
-			skb->nh.ipv6h->payload_len = 0;
-			skb->h.th->check =
-				~csum_ipv6_magic(&skb->nh.ipv6h->saddr,
-						 &skb->nh.ipv6h->daddr,
-						 0,
-						 IPPROTO_TCP,
-						 0);
-			ipcse = 0;
-#endif
-		}
 		ipcss = skb->nh.raw - skb->data;
 		ipcso = (void *)&(skb->nh.iph->check) - (void *)skb->data;
+		ipcse = skb->h.raw - skb->data - 1;
 		tucss = skb->h.raw - skb->data;
 		tucso = (void *)&(skb->h.th->check) - (void *)skb->data;
 		tucse = 0;
 
 		cmd_length |= (E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
-			       E1000_TXD_CMD_TCP | (skb->len - (hdr_len)));
+			       E1000_TXD_CMD_IP | E1000_TXD_CMD_TCP |
+			       (skb->len - (hdr_len)));
 
 		i = tx_ring->next_to_use;
 		context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
-		buffer_info = &tx_ring->buffer_info[i];
 
 		context_desc->lower_setup.ip_fields.ipcss  = ipcss;
 		context_desc->lower_setup.ip_fields.ipcso  = ipcso;
@@ -2581,8 +2558,6 @@ e1000_tso(struct e1000_adapter *adapter,
 		context_desc->tcp_seg_setup.fields.hdr_len = hdr_len;
 		context_desc->cmd_and_length = cpu_to_le32(cmd_length);
 
-		buffer_info->time_stamp = jiffies;
-
 		if (++i == tx_ring->count) i = 0;
 		tx_ring->next_to_use = i;
 



*************************************


e1000: implement old xmit_frame

It seems back in the day of 2.6.11, there were no sk_forward_alloc
asserions.  Forward port that transmit code to see if it fixes the issues
in today's kernel.  Unfortunately it doesn't have all the bug fixes that
the current code has, but if we get transmit timeouts we can add in
workarounds appropriately.

this changes the e1000_xmit_frame function, and some ancilliaries

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

 drivers/net/e1000/e1000_main.c |   90 ++--------------------------------------
 1 files changed, 4 insertions(+), 86 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 2b8fb87..18790b6 100755
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2725,10 +2725,7 @@ e1000_tx_queue(struct e1000_adapter *ada
 	if (likely(tx_flags & E1000_TX_FLAGS_TSO)) {
 		txd_lower |= E1000_TXD_CMD_DEXT | E1000_TXD_DTYP_D |
 		             E1000_TXD_CMD_TSE;
-		txd_upper |= E1000_TXD_POPTS_TXSM << 8;
-
-		if (likely(tx_flags & E1000_TX_FLAGS_IPV4))
-			txd_upper |= E1000_TXD_POPTS_IXSM << 8;
+		txd_upper |= (E1000_TXD_POPTS_IXSM | E1000_TXD_POPTS_TXSM) << 8;
 	}
 
 	if (likely(tx_flags & E1000_TX_FLAGS_CSUM)) {
@@ -2803,41 +2800,6 @@ no_fifo_stall_required:
 	return 0;
 }
 
-#define MINIMUM_DHCP_PACKET_SIZE 282
-static inline int
-e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
-{
-	struct e1000_hw *hw =  &adapter->hw;
-	uint16_t length, offset;
-	if (vlan_tx_tag_present(skb)) {
-		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
-			( adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) )
-			return 0;
-	}
-	if ((skb->len > MINIMUM_DHCP_PACKET_SIZE) && (!skb->protocol)) {
-		struct ethhdr *eth = (struct ethhdr *) skb->data;
-		if ((htons(ETH_P_IP) == eth->h_proto)) {
-			const struct iphdr *ip =
-				(struct iphdr *)((uint8_t *)skb->data+14);
-			if (IPPROTO_UDP == ip->protocol) {
-				struct udphdr *udp =
-					(struct udphdr *)((uint8_t *)ip +
-						(ip->ihl << 2));
-				if (ntohs(udp->dest) == 67) {
-					offset = (uint8_t *)udp + 8 - skb->data;
-					length = skb->len - offset;
-
-					return e1000_mng_write_dhcp_info(hw,
-							(uint8_t *)udp + 8,
-							length);
-				}
-			}
-		}
-	}
-	return 0;
-}
-
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -2852,7 +2814,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
- 	int tso;
 	unsigned int f;
 	len -= skb->data_len;
 
@@ -2876,44 +2837,18 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	 * overrun the FIFO, adjust the max buffer len if mss
 	 * drops. */
 	if (mss) {
-		uint8_t hdr_len;
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
-
-	/* TSO Workaround for 82571/2 Controllers -- if skb->data
-	 * points to just header, pull a few bytes of payload from
-	 * frags into skb->data */
-		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len)) &&
-			(adapter->hw.mac_type == e1000_82571 ||
-			adapter->hw.mac_type == e1000_82572)) {
-			unsigned int pull_size;
-			pull_size = min((unsigned int)4, skb->data_len);
-			if (!__pskb_pull_tail(skb, pull_size)) {
-				printk(KERN_ERR "__pskb_pull_tail failed.\n");
-				dev_kfree_skb_any(skb);
-				return NETDEV_TX_OK;
-			}
-			len = skb->len - skb->data_len;
-		}
 	}
 
 	/* reserve a descriptor for the offload context */
 	if ((mss) || (skb->ip_summed == CHECKSUM_HW))
 		count++;
-	count++;
+	count++;	/* for sentinel desc */
 #else
 	if (skb->ip_summed == CHECKSUM_HW)
 		count++;
 #endif
-
-#ifdef NETIF_F_TSO
-	/* Controller Erratum workaround */
-	if (!skb->data_len && tx_ring->last_tx_tso &&
-		!skb_shinfo(skb)->tso_size)
-		count++;
-#endif
-
 	count += TXD_USE_COUNT(len, max_txd_pwr);
 
 	if (adapter->pcix_82544)
@@ -2933,9 +2868,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	if (adapter->pcix_82544)
 		count += nr_frags;
 
-	if (adapter->hw.tx_pkt_filtering && (adapter->hw.mac_type == e1000_82573) )
-		e1000_transfer_dhcp_info(adapter, skb);
-
 	local_irq_save(flags);
 	if (!spin_trylock(&tx_ring->tx_lock)) {
 		/* Collision - tell upper layer to requeue */
@@ -2967,25 +2899,11 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	first = tx_ring->next_to_use;
 
-	tso = e1000_tso(adapter, tx_ring, skb);
-	if (tso < 0) {
-		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
-		return NETDEV_TX_OK;
-	}
-
-	if (likely(tso)) {
-		tx_ring->last_tx_tso = 1;
+	if(likely(e1000_tso(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_TSO;
-	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
+	else if(likely(e1000_tx_csum(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	/* Old method was to assume IPv4 packet by default if TSO was enabled.
-	 * 82571 hardware supports TSO capabilities for IPv6 as well...
-	 * no longer assume, we must. */
-	if (likely(skb->protocol == ntohs(ETH_P_IP)))
-		tx_flags |= E1000_TX_FLAGS_IPV4;
-
 	e1000_tx_queue(adapter, tx_ring, tx_flags,
 	               e1000_tx_map(adapter, tx_ring, skb, first,
 	                            max_per_txd, nr_frags, mss));


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
