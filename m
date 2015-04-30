From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 1/3] etherdev: Avoid unnecessary byte swap in check for
 Ethertype
Date: Thu, 30 Apr 2015 14:53:48 -0700
Message-ID: <20150430215348.1798.15509.stgit@ahduyck-vm-fedora22>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbbD3Vxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 17:53:49 -0400
In-Reply-To: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change takes advantage of the fact that ETH_P_802_3_MIN is aligned to
512 so as a result we can actually ignore the lower 8b when comparing the
Ethertype to ETH_P_802_3_MIN.  This allows us to avoid a byte swap by simply
masking the value and comparing it to the byte swapped value for
ETH_P_802_3_MIN.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ethernet/eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index f3bad41d725f..60069318d5d1 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -178,7 +178,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(netdev_uses_dsa(dev)))
 		return htons(ETH_P_XDSA);
 
-	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
+	if (likely((eth->h_proto & htons(0xFF00)) >= htons(ETH_P_802_3_MIN)))
 		return eth->h_proto;
 
 	/*
