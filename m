From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/3] net: Swap ordering of tests in
 ip_route_input_mc
Date: Mon, 28 Sep 2015 11:10:38 -0700
Message-ID: <20150928181038.20320.17966.stgit@ahduyck-vm-fedora22>
References: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34443 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717AbbI1SKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 14:10:39 -0400
Received: by padhy16 with SMTP id hy16so180776355pad.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 11:10:39 -0700 (PDT)
In-Reply-To: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just swaps the ordering of one of the conditional tests in
ip_route_input_mc.  Specifically it swaps the testing for the source
address to see if it is loopback, and the test to see if we allow a
loopback source address.

The reason for swapping these two tests is because it is much faster to
test if an address is loopback than it is to dereference several pointers
to get at the net structure to see if the use of loopback is allowed.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/route.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6bab84503cd9..43508c8d08e2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1487,9 +1487,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	    skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
-	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
-		if (ipv4_is_loopback(saddr))
-			goto e_inval;
+	if (ipv4_is_loopback(saddr) && !IN_DEV_ROUTE_LOCALNET(in_dev))
+		goto e_inval;
 
 	if (ipv4_is_zeronet(saddr)) {
 		if (!ipv4_is_local_multicast(daddr))
