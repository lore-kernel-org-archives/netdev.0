From: Doug Kehn <rdkehn@yahoo.com>
Subject: [PATCH net-next-2.6] net/core: neighbour update Oops
Date: Tue, 13 Jul 2010 08:23:16 -0700 (PDT)
Message-ID: <734423.1943.qm@web52004.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52004.mail.re2.yahoo.com ([206.190.49.251]:40443 "HELO
	web52004.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752510Ab0GMP36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 11:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring DMVPN (GRE + openNHRP) and a GRE remote
address is configured a kernel Oops is observed.  The
obserseved Oops is caused by a NULL header_ops pointer
(neigh->dev->header_ops) in neigh_update_hhs() when

void (*update)(struct hh_cache*, const struct net_device*, const unsigned char *)
= neigh->dev->header_ops->cache_update;

is executed.  The dev associated with the NULL header_ops is
the GRE interface.  This patch guards against the
possibility that header_ops is NULL.

This Oops was first observed in kernel version 2.6.26.8.

Signed-off-by: Doug Kehn <rdkehn@yahoo.com>
---
 net/core/neighbour.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 6ba1c0e..a4e0a74 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -949,7 +949,10 @@ static void neigh_update_hhs(struct neighbour *neigh)
 {
 	struct hh_cache *hh;
 	void (*update)(struct hh_cache*, const struct net_device*, const unsigned char *)
-		= neigh->dev->header_ops->cache_update;
+		= NULL;
+
+	if (neigh->dev->header_ops)
+		update = neigh->dev->header_ops->cache_update;
 
 	if (update) {
 		for (hh = neigh->hh; hh; hh = hh->hh_next) {
-- 
1.7.0.4



      
