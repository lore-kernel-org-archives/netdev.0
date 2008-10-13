From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] pktgen: fix skb leak in case of failure
Date: Mon, 13 Oct 2008 17:22:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810131657250.3843@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1658324967-1223906593=:3843"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53130 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946AbYJMOWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 10:22:20 -0400
Content-ID: <Pine.LNX.4.64.0810131720430.3947@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1658324967-1223906593=:3843
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810131720431.3947@wrl-59.cs.helsinki.fi>

Seems that skb goes into void unless something magic happened
in pskb_expand_head in case of failure.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/core/pktgen.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fcb1031..b6b2a8e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2474,7 +2474,7 @@ static inline int process_ipsec(struct pktgen_dev *pkt_dev,
 				if (ret < 0) {
 					printk(KERN_ERR "Error expanding "
 					       "ipsec packet %d\n",ret);
-					return 0;
+					goto err;
 				}
 			}
 
@@ -2484,8 +2484,7 @@ static inline int process_ipsec(struct pktgen_dev *pkt_dev,
 			if (ret) {
 				printk(KERN_ERR "Error creating ipsec "
 				       "packet %d\n",ret);
-				kfree_skb(skb);
-				return 0;
+				goto err;
 			}
 			/* restore ll */
 			eth = (__u8 *) skb_push(skb, ETH_HLEN);
@@ -2494,6 +2493,9 @@ static inline int process_ipsec(struct pktgen_dev *pkt_dev,
 		}
 	}
 	return 1;
+err:
+	kfree_skb(skb);
+	return 0;
 }
 #endif
 
-- 
1.5.2.2
---696208474-1658324967-1223906593=:3843--
