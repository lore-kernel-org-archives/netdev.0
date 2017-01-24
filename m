From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 24 Jan 2017 11:38:51 +1100
Message-ID: <20170124113851.359ed2be@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/mpls/af_mpls.c

between commit:

  9f427a0e474a ("net: mpls: Fix multipath selection for LSR use case")

from the net tree and commit:

  27d691056bde ("mpls: Packet stats")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/mpls/af_mpls.c
index 5b77377e5a15,4dc81963af8f..000000000000
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@@ -98,10 -94,35 +94,35 @@@ bool mpls_pkt_too_big(const struct sk_b
  }
  EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
  
+ void mpls_stats_inc_outucastpkts(struct net_device *dev,
+ 				 const struct sk_buff *skb)
+ {
+ 	struct mpls_dev *mdev;
+ 
+ 	if (skb->protocol == htons(ETH_P_MPLS_UC)) {
+ 		mdev = mpls_dev_get(dev);
+ 		if (mdev)
+ 			MPLS_INC_STATS_LEN(mdev, skb->len,
+ 					   tx_packets,
+ 					   tx_bytes);
+ 	} else if (skb->protocol == htons(ETH_P_IP)) {
+ 		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+ #if IS_ENABLED(CONFIG_IPV6)
+ 	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+ 		struct inet6_dev *in6dev = __in6_dev_get(dev);
+ 
+ 		if (in6dev)
+ 			IP6_UPD_PO_STATS(dev_net(dev), in6dev,
+ 					 IPSTATS_MIB_OUT, skb->len);
+ #endif
+ 	}
+ }
+ EXPORT_SYMBOL_GPL(mpls_stats_inc_outucastpkts);
+ 
 -static u32 mpls_multipath_hash(struct mpls_route *rt,
 -			       struct sk_buff *skb, bool bos)
 +static u32 mpls_multipath_hash(struct mpls_route *rt, struct sk_buff *skb)
  {
  	struct mpls_entry_decoded dec;
 +	unsigned int mpls_hdr_len = 0;
  	struct mpls_shim_hdr *hdr;
  	bool eli_seen = false;
  	int label_index;
@@@ -280,27 -308,24 +310,24 @@@ static int mpls_forward(struct sk_buff 
  	hdr = mpls_hdr(skb);
  	dec = mpls_entry_decode(hdr);
  
 -	/* Pop the label */
 -	skb_pull(skb, sizeof(*hdr));
 -	skb_reset_network_header(skb);
 -
 -	skb_orphan(skb);
 -
  	rt = mpls_route_input_rcu(net, dec.label);
- 	if (!rt)
+ 	if (!rt) {
+ 		MPLS_INC_STATS(mdev, rx_noroute);
  		goto drop;
+ 	}
  
 -	nh = mpls_select_multipath(rt, skb, dec.bos);
 +	nh = mpls_select_multipath(rt, skb);
  	if (!nh)
- 		goto drop;
- 
- 	/* Find the output device */
- 	out_dev = rcu_dereference(nh->nh_dev);
- 	if (!mpls_output_possible(out_dev))
- 		goto drop;
+ 		goto err;
  
 +	/* Pop the label */
 +	skb_pull(skb, sizeof(*hdr));
 +	skb_reset_network_header(skb);
 +
 +	skb_orphan(skb);
 +
  	if (skb_warn_if_lro(skb))
- 		goto drop;
+ 		goto err;
  
  	skb_forward_csum(skb);
  
