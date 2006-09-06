From: Greg KH <gregkh@suse.de>
Subject: [patch 05/37] bridge-netfilter: dont overwrite memory outside of skb
Date: Wed, 6 Sep 2006 15:55:16 -0700
Message-ID: <20060906225516.GF15922@kroah.com>
References: <20060906224631.999046890@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964921AbWIFXBU@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	David Miller <davem@davemloft.net>
Content-Disposition: inline; filename="bridge-netfilter-don-t-overwrite-memory-outside-of-skb.patch"
In-Reply-To: <20060906225444.GA15922@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@osdl.org>

The bridge netfilter code needs to check for space at the
front of the skb before overwriting; otherwise if skb from
device doesn't have headroom, then it will cause random
memory corruption.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 include/linux/netfilter_bridge.h |   16 ++++++++++++----
 net/bridge/br_forward.c          |   10 +++++++---
 2 files changed, 19 insertions(+), 7 deletions(-)

--- linux-2.6.17.11.orig/include/linux/netfilter_bridge.h
+++ linux-2.6.17.11/include/linux/netfilter_bridge.h
@@ -47,18 +47,26 @@ enum nf_br_hook_priorities {
 #define BRNF_BRIDGED			0x08
 #define BRNF_NF_BRIDGE_PREROUTING	0x10
 
-
 /* Only used in br_forward.c */
-static inline
-void nf_bridge_maybe_copy_header(struct sk_buff *skb)
+static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
 {
+	int err;
+
 	if (skb->nf_bridge) {
 		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			err = skb_cow(skb, 18);
+			if (err)
+				return err;
 			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
 			skb_push(skb, 4);
-		} else
+		} else {
+			err = skb_cow(skb, 16);
+			if (err)
+				return err;
 			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
+		}
 	}
+	return 0;
 }
 
 /* This is called by the IP fragmenting code and it ensures there is
--- linux-2.6.17.11.orig/net/bridge/br_forward.c
+++ linux-2.6.17.11/net/bridge/br_forward.c
@@ -43,11 +43,15 @@ int br_dev_queue_push_xmit(struct sk_buf
 	else {
 #ifdef CONFIG_BRIDGE_NETFILTER
 		/* ip_refrag calls ip_fragment, doesn't copy the MAC header. */
-		nf_bridge_maybe_copy_header(skb);
+		if (nf_bridge_maybe_copy_header(skb))
+			kfree_skb(skb);
+		else
 #endif
-		skb_push(skb, ETH_HLEN);
+		{
+			skb_push(skb, ETH_HLEN);
 
-		dev_queue_xmit(skb);
+			dev_queue_xmit(skb);
+		}
 	}
 
 	return 0;

--
