From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 02/11] ixgbe: add XDP support for pass and drop
 actions
Date: Fri, 21 Apr 2017 16:52:31 +0000
Message-ID: <87618083B2453E4A8714035B62D679927E4AF1CA@FMSMSX105.amr.corp.intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
 <20170421015029.18994-3-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Fastabend, John R" <john.r.fastabend@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:21256 "EHLO mga07.intel.com"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1423233AbdDUSCv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 14:02:51 -0400
In-Reply-To: <20170421015029.18994-3-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Jeff Kirsher
>Sent: Thursday, April 20, 2017 6:50 PM
>To: davem@davemloft.net
>Cc: Fastabend, John R <john.r.fastabend@intel.com>; netdev@vger.kernel.org;
>nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com; Kirsher,
>Jeffrey T <jeffrey.t.kirsher@intel.com>
>Subject: [net-next 02/11] ixgbe: add XDP support for pass and drop actions
>
>From: John Fastabend <john.r.fastabend@intel.com>
>
>Basic XDP drop support for ixgbe. Uses READ_ONCE/xchg semantics on XDP
>programs instead of rcu primitives as suggested by Daniel Borkmann and
>Alex Duyck.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
>Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   4 +-
> drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   4 +-
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 163
>+++++++++++++++++++----
> 3 files changed, 144 insertions(+), 27 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>index 656ca8f69768..cb14813b0080 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>@@ -318,6 +318,7 @@ struct ixgbe_ring {
> 	struct ixgbe_ring *next;	/* pointer to next ring in q_vector */
> 	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
> 	struct net_device *netdev;	/* netdev ring belongs to */
>+	struct bpf_prog *xdp_prog;
> 	struct device *dev;		/* device for DMA mapping */
> 	struct ixgbe_fwd_adapter *l2_accel_priv;
> 	void *desc;			/* descriptor ring memory */
>@@ -555,6 +556,7 @@ struct ixgbe_adapter {
> 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
> 	/* OS defined structs */
> 	struct net_device *netdev;
>+	struct bpf_prog *xdp_prog;
> 	struct pci_dev *pdev;
>
> 	unsigned long state;
>@@ -835,7 +837,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter);
> void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
> void ixgbe_reset(struct ixgbe_adapter *adapter);
> void ixgbe_set_ethtool_ops(struct net_device *netdev);
>-int ixgbe_setup_rx_resources(struct ixgbe_ring *);
>+int ixgbe_setup_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
> int ixgbe_setup_tx_resources(struct ixgbe_ring *);
> void ixgbe_free_rx_resources(struct ixgbe_ring *);
> void ixgbe_free_tx_resources(struct ixgbe_ring *);
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>index 59730ede4746..79a126d9e091 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
>@@ -1128,7 +1128,7 @@ static int ixgbe_set_ringparam(struct net_device
>*netdev,
> 			       sizeof(struct ixgbe_ring));
>
> 			temp_ring[i].count = new_rx_count;
>-			err = ixgbe_setup_rx_resources(&temp_ring[i]);
>+			err = ixgbe_setup_rx_resources(adapter, &temp_ring[i]);
> 			if (err) {
> 				while (i) {
> 					i--;
>@@ -1761,7 +1761,7 @@ static int ixgbe_setup_desc_rings(struct
>ixgbe_adapter *adapter)
> 	rx_ring->netdev = adapter->netdev;
> 	rx_ring->reg_idx = adapter->rx_ring[0]->reg_idx;
>
>-	err = ixgbe_setup_rx_resources(rx_ring);
>+	err = ixgbe_setup_rx_resources(adapter, rx_ring);
> 	if (err) {
> 		ret_val = 4;
> 		goto err_nomem;
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>index afff2ca7f8c0..3dac3918e0c9 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>@@ -49,6 +49,9 @@
> #include <linux/if_macvlan.h>
> #include <linux/if_bridge.h>
> #include <linux/prefetch.h>
>+#include <linux/bpf.h>
>+#include <linux/bpf_trace.h>
>+#include <linux/atomic.h>
> #include <scsi/fc/fc_fcoe.h>
> #include <net/udp_tunnel.h>
> #include <net/pkt_cls.h>
>@@ -1855,6 +1858,10 @@ static void ixgbe_dma_sync_frag(struct ixgbe_ring
>*rx_ring,
>  * @rx_desc: pointer to the EOP Rx descriptor
>  * @skb: pointer to current skb being fixed
>  *
>+ * Check if the skb is valid in the XDP case it will be an error pointer.
>+ * Return true in this case to abort processing and advance to next
>+ * descriptor.
>+ *
>  * Check for corrupted packet headers caused by senders on the local L2
>  * embedded NIC switch not setting up their Tx Descriptors right.  These
>  * should be very rare.
>@@ -1873,6 +1880,10 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring
>*rx_ring,
> {
> 	struct net_device *netdev = rx_ring->netdev;
>
>+	/* XDP packets use error pointer so abort at this point */
>+	if (IS_ERR(skb))
>+		return true;
>+
> 	/* verify that the packet does not have any known errors */
> 	if (unlikely(ixgbe_test_staterr(rx_desc,
> 					IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
>@@ -2048,7 +2059,7 @@ static void ixgbe_put_rx_buffer(struct ixgbe_ring
>*rx_ring,
> 		/* hand second half of page back to the ring */
> 		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
> 	} else {
>-		if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
>+		if (!IS_ERR(skb) && IXGBE_CB(skb)->dma == rx_buffer->dma) {
> 			/* the page has been released from the ring */
> 			IXGBE_CB(skb)->page_released = true;
> 		} else {
>@@ -2069,10 +2080,10 @@ static void ixgbe_put_rx_buffer(struct ixgbe_ring
>*rx_ring,
>
> static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
> 					   struct ixgbe_rx_buffer *rx_buffer,
>-					   union ixgbe_adv_rx_desc *rx_desc,
>-					   unsigned int size)
>+					   struct xdp_buff *xdp,
>+					   union ixgbe_adv_rx_desc *rx_desc)
> {
>-	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
>+	unsigned int size = xdp->data_end - xdp->data;
> #if (PAGE_SIZE < 8192)
> 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
> #else

This patch introduces a build error in the case where PAGE_SIZE >= 8192
because the "size" parameter was removed from the function parameters, but
it is still being used to calculate truesize for that case.

This was caught by the test build robot:

drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:2173:36: error: 'size' undeclared (first use in this function)
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:2173:5: error: 'size' undeclared (first use in this function)

I also warned about this error before, but it was not resolved.

Thanks,
Emil
