From: Andrej Ota <andrej@ota.si>
Subject: [PATCH] [Bug 24472] Kernel panic - not syncing: Fatal Exception
Date: Fri, 10 Dec 2010 15:49:08 +0100
Message-ID: <4D023DE4.8000400@ota.si>
References: <20101210091505.GA7868@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.toshio.org ([193.189.180.35]:34417 "EHLO mta.toshio.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832Ab0LJOtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 09:49:21 -0500
In-Reply-To: <20101210091505.GA7868@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move kfree_skb which was causing memory corruption to new location, while still keeping appropriate return value for function __pppoe_xmit. Prevents memory corruption and consequent kernel panic when PPPoE peer terminates the link.

Signed-off-by: Andrej Ota [andrej@ota.si]
Reported-by: Pawel Staszewski [pstaszewski@artcom.pl]
---
 drivers/net/pppoe.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index d72fb05..1a21dce 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -924,8 +924,10 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	/* Copy the data if there is no space for the header or if it's
 	 * read-only.
 	 */
-	if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len))
+	if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len)) {
+		kfree_skb(skb);
 		goto abort;
+	}

 	__skb_push(skb, sizeof(*ph));
 	skb_reset_network_header(skb);
@@ -947,7 +949,6 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	return 1;

 abort:
-	kfree_skb(skb);
 	return 0;
 }

---

Andrej Ota.
