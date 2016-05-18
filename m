From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 6/8] batman-adv: Fix integer overflow in batadv_iv_ogm_calc_tq
Date: Wed, 18 May 2016 13:04:50 +0800
Message-ID: <1463547892-11290-7-git-send-email-a@unstable.cc>
References: <1463547892-11290-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:26059 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899AbcERFGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 01:06:25 -0400
In-Reply-To: <1463547892-11290-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@open-mesh.com>

The undefined behavior sanatizer detected an signed integer overflow in a
setup with near perfect link quality

    UBSAN: Undefined behaviour in net/batman-adv/bat_iv_ogm.c:1246:25
    signed integer overflow:
    8713350 * 255 cannot be represented in type 'int'

The problems happens because the calculation of mixed unsigned and signed
integers resulted in an integer multiplication.

      batadv_ogm_packet::tq (u8 255)
    * tq_own (u8 255)
    * tq_asym_penalty (int 134; max 255)
    * tq_iface_penalty (int 255; max 255)

The tq_iface_penalty, tq_asym_penalty and inv_asym_penalty can just be
changed to unsigned int because they are not expected to become negative.

Fixes: c039876892e3 ("batman-adv: add WiFi penalty")
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 1b5bbafc0fa3..ce2f203048d3 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1180,9 +1180,10 @@ static bool batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	u8 total_count;
 	u8 orig_eq_count, neigh_rq_count, neigh_rq_inv, tq_own;
 	unsigned int neigh_rq_inv_cube, neigh_rq_max_cube;
-	int tq_asym_penalty, inv_asym_penalty, if_num;
+	int if_num;
+	unsigned int tq_asym_penalty, inv_asym_penalty;
 	unsigned int combined_tq;
-	int tq_iface_penalty;
+	unsigned int tq_iface_penalty;
 	bool ret = false;
 
 	/* find corresponding one hop neighbor */
-- 
2.8.2
