From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 5/8] orinoco: Optimize orinoco_join_ap()
Date: Thu, 01 Sep 2005 20:06:06 -0400
Message-ID: <1125619566.29016.4.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree cb289b9f9b2a0f3ae7070a008f22e383b37526ee (from 56bfcdb38b3d04c1f8c1fd705e411f4be53b663c)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Thu Sep 1 19:05:16 2005 -0400

    Optimize orinoco_join_ap() - break from loop once the requested
BSSID
    is found.

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1049,12 +1049,13 @@ static void orinoco_join_ap(struct net_d
 	struct join_req {
 		u8 bssid[ETH_ALEN];
 		u16 channel;
 	} __attribute__ ((packed)) req;
 	const int atom_len = offsetof(struct prism2_scan_apinfo, atim);
-	struct prism2_scan_apinfo *atom;
+	struct prism2_scan_apinfo *atom = NULL;
 	int offset = 4;
+	int found = 0;
 	u8 *buf;
 	u16 len;
 
 	/* Allocate buffer for scan results */
 	buf = kmalloc(MAX_SCAN_LEN, GFP_KERNEL);
@@ -1085,19 +1086,22 @@ static void orinoco_join_ap(struct net_d
 
 	/* Go through the scan results looking for the channel of the AP
 	 * we were requested to join */
 	for (; offset + atom_len <= len; offset += atom_len) {
 		atom = (struct prism2_scan_apinfo *) (buf + offset);
-		if (memcmp(&atom->bssid, priv->desired_bssid, ETH_ALEN) == 0)
-			goto found;
+		if (memcmp(&atom->bssid, priv->desired_bssid, ETH_ALEN) == 0) {
+			found = 1;
+			break;
+		}
 	}
 
-	DEBUG(1, "%s: Requested AP not found in scan results\n",
-	      dev->name);
-	goto out;
+	if (! found) {
+		DEBUG(1, "%s: Requested AP not found in scan results\n",
+		      dev->name);
+		goto out;
+	}
 
- found:
 	memcpy(req.bssid, priv->desired_bssid, ETH_ALEN);
 	req.channel = atom->channel;	/* both are little-endian */
 	err = HERMES_WRITE_RECORD(hw, USER_BAP, HERMES_RID_CNFJOINREQUEST,
 				  &req);
 	if (err)


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
