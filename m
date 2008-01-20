From: Patrick McHardy <kaber@trash.net>
Subject: [AF_KEY]: Fix skb leak on pfkey_send_migrate() error
Date: Sun, 20 Jan 2008 16:12:28 +0100
Message-ID: <479364DC.40604@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080401050802050102070704"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59982 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbYATPN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 10:13:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080401050802050102070704
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080401050802050102070704
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 4dd3440faa345731c27337ee041c0e9abf2b70dc
Author: Patrick McHardy <kaber@trash.net>
Date:   Sun Jan 20 16:10:04 2008 +0100

    [AF_KEY]: Fix skb leak on pfkey_send_migrate() error
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 3667f44..16b72b5 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3591,27 +3591,29 @@ static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 		/* old ipsecrequest */
 		int mode = pfkey_mode_from_xfrm(mp->mode);
 		if (mode < 0)
-			return -EINVAL;
+			goto err;
 		if (set_ipsecrequest(skb, mp->proto, mode,
 				     (mp->reqid ?  IPSEC_LEVEL_UNIQUE : IPSEC_LEVEL_REQUIRE),
 				     mp->reqid, mp->old_family,
-				     &mp->old_saddr, &mp->old_daddr) < 0) {
-			return -EINVAL;
-		}
+				     &mp->old_saddr, &mp->old_daddr) < 0)
+			goto err;
 
 		/* new ipsecrequest */
 		if (set_ipsecrequest(skb, mp->proto, mode,
 				     (mp->reqid ? IPSEC_LEVEL_UNIQUE : IPSEC_LEVEL_REQUIRE),
 				     mp->reqid, mp->new_family,
-				     &mp->new_saddr, &mp->new_daddr) < 0) {
-			return -EINVAL;
-		}
+				     &mp->new_saddr, &mp->new_daddr) < 0)
+			goto err;
 	}
 
 	/* broadcast migrate message to sockets */
 	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL);
 
 	return 0;
+
+err:
+	kfree_skb(skb);
+	return -EINVAL;
 }
 #else
 static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,

--------------080401050802050102070704--
