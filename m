From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 98/98]
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to
 restricted __be16
Date: Sat, 01 Dec 2012 05:02:50 +0800
Message-ID: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23777 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312Ab2K3VDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 16:03:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2
commit: 1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2 [98/98] myri10ge: Add vlan rx for better GRO perf.


sparse warnings:

+ drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
+ drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
+ drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
+ drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
+ drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:16: sparse: restricted __be16 degrades to integer
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1888:16: sparse: incorrect type in argument 1 (different base types)
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1888:16:    expected unsigned int [unsigned] val
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1888:16:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2334:24: sparse: incorrect type in assignment (different address spaces)
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2334:24:    expected unsigned char [usertype] *itable
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2334:24:    got unsigned char [noderef] [usertype] <asn:2>*
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2336:48: sparse: incorrect type in argument 2 (different address spaces)
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2336:48:    expected void volatile [noderef] <asn:2>*addr
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2336:48:    got unsigned char [usertype] *
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:2760:60: sparse: dubious: x & !y
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3839:13: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3839:13: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3839:13: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3839:13: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3839:13: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3839:13: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3841:26: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3841:26: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3841:26: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3841:26: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3841:26: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:3841:26: sparse: cast to restricted __be32
drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1434:35: sparse: context imbalance in 'myri10ge_intr' - different lock contexts for basic block

vim +1286 drivers/net/ethernet/myricom/myri10ge/myri10ge.c

1b4c44e6 Andrew Gallatin 2012-11-30  1270   * the tag ourselves to be able to achieve GRO performance that
1b4c44e6 Andrew Gallatin 2012-11-30  1271   * is comparable to LRO.
1b4c44e6 Andrew Gallatin 2012-11-30  1272   */
1b4c44e6 Andrew Gallatin 2012-11-30  1273  
1b4c44e6 Andrew Gallatin 2012-11-30  1274  static inline void
1b4c44e6 Andrew Gallatin 2012-11-30  1275  myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
1b4c44e6 Andrew Gallatin 2012-11-30  1276  {
1b4c44e6 Andrew Gallatin 2012-11-30  1277  	u8 *va;
1b4c44e6 Andrew Gallatin 2012-11-30  1278  	struct vlan_ethhdr *veh;
1b4c44e6 Andrew Gallatin 2012-11-30  1279  	struct skb_frag_struct *frag;
1b4c44e6 Andrew Gallatin 2012-11-30  1280  	__wsum vsum;
1b4c44e6 Andrew Gallatin 2012-11-30  1281  
1b4c44e6 Andrew Gallatin 2012-11-30  1282  	va = addr;
1b4c44e6 Andrew Gallatin 2012-11-30  1283  	va += MXGEFW_PAD;
1b4c44e6 Andrew Gallatin 2012-11-30  1284  	veh = (struct vlan_ethhdr *)va;
1b4c44e6 Andrew Gallatin 2012-11-30  1285  	if ((dev->features & NETIF_F_HW_VLAN_RX) == NETIF_F_HW_VLAN_RX &&
1b4c44e6 Andrew Gallatin 2012-11-30 @1286  	    veh->h_vlan_proto == ntohs(ETH_P_8021Q)) {
1b4c44e6 Andrew Gallatin 2012-11-30  1287  		/* fixup csum if needed */
1b4c44e6 Andrew Gallatin 2012-11-30  1288  		if (skb->ip_summed == CHECKSUM_COMPLETE) {
1b4c44e6 Andrew Gallatin 2012-11-30  1289  			vsum = csum_partial(va + ETH_HLEN, VLAN_HLEN, 0);
1b4c44e6 Andrew Gallatin 2012-11-30  1290  			skb->csum = csum_sub(skb->csum, vsum);
1b4c44e6 Andrew Gallatin 2012-11-30  1291  		}
1b4c44e6 Andrew Gallatin 2012-11-30  1292  		/* pop tag */
1b4c44e6 Andrew Gallatin 2012-11-30  1293  		__vlan_hwaccel_put_tag(skb, ntohs(veh->h_vlan_TCI));
1b4c44e6 Andrew Gallatin 2012-11-30  1294  		memmove(va + VLAN_HLEN, va, 2 * ETH_ALEN);

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
