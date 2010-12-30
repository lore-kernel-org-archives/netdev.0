From: Milton Miller <miltonm@bga.com>
Subject: [PATCH] mac80211: fix mesh forwarding when ratelimited too
Date: Thu, 30 Dec 2010 02:01:03 -0600
Message-ID: <mac80211-rx-ratelimit-goto@mdm.bga.com>
References: <1293009307.3531.13.camel@jlt3.sipsolutions.net>
	<AANLkTik9PS-wKYg=XC0bUaZ=a99d-FdUmzZfvALVQ9Tv@mail.gmail.com>
	<201012262159.oBQLxOsw008865@hera.kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Javier Cardona <javier@cozybit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit b51aff057c9d0ef6c529dc25fd9f775faf7b6c63 said:

    Under memory pressure, the mac80211 mesh code
    may helpfully print a message that it failed
    to clone a mesh frame and then will proceed
    to crash trying to use it anyway. Fix that.
    
Avoid the reference whenever the frame copy is unsuccessful
regardless of the debug message being suppressed or printed.

Cc: stable@kernel.org [2.6.27+] 
Signed-off-by: Milton Miller <miltonm@bga.com>
---
I chose a seperate if vs nesting the ratelimit check to avoid shifting
the printk further to the right.

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index b01e467..e98668f 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1788,11 +1788,11 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 
 			fwd_skb = skb_copy(skb, GFP_ATOMIC);
 
-			if (!fwd_skb && net_ratelimit()) {
+			if (!fwd_skb && net_ratelimit())
 				printk(KERN_DEBUG "%s: failed to clone mesh frame\n",
 						   sdata->name);
+			if (!fwd_skb)
 				goto out;
-			}
 
 			fwd_hdr =  (struct ieee80211_hdr *) fwd_skb->data;
 			memcpy(fwd_hdr->addr2, sdata->vif.addr, ETH_ALEN);
