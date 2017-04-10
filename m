From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: neigh: make ->hh_len 32-bit
Date: Mon, 10 Apr 2017 11:11:17 +0300
Message-ID: <20170410081117.GB24514@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34481 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbdDJILV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 04:11:21 -0400
Received: by mail-lf0-f67.google.com with SMTP id x72so3261280lfb.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 01:11:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 16-bit ->hh_len doesn't save any memory, save some .text instead:

	add/remove: 0/0 grow/shrink: 1/6 up/down: 2/-19 (-17)
	function                                     old     new   delta
	neigh_update                                2312    2314      +2
	fwnet_header_cache                           199     197      -2
	eth_header_cache                             101      99      -2
	ip6_finish_output2                          2371    2368      -3
	vrf_finish_output6                          1522    1518      -4
	vrf_finish_output                           1413    1409      -4
	ip_finish_output2                           1627    1623      -4

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netdevice.h |    3 +--
 include/net/neighbour.h   |    4 ++--
 2 files changed, 3 insertions(+), 4 deletions(-)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -237,8 +237,7 @@ struct netdev_hw_addr_list {
 	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
 struct hh_cache {
-	u16		hh_len;
-	u16		__pad;
+	unsigned int	hh_len;
 	seqlock_t	hh_lock;
 
 	/* cached hardware header; allow for machine alignment needs.        */
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -450,7 +450,7 @@ static inline int neigh_hh_bridge(struct hh_cache *hh, struct sk_buff *skb)
 static inline int neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb)
 {
 	unsigned int seq;
-	int hh_len;
+	unsigned int hh_len;
 
 	do {
 		seq = read_seqbegin(&hh->hh_lock);
@@ -459,7 +459,7 @@ static inline int neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb
 			/* this is inlined by gcc */
 			memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);
 		} else {
-			int hh_alen = HH_DATA_ALIGN(hh_len);
+			unsigned int hh_alen = HH_DATA_ALIGN(hh_len);
 
 			memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
 		}
