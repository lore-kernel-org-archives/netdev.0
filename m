From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH SECURITY]: orinoco: Information leakage due to incorrect
 padding
Date: Tue, 04 Oct 2005 21:33:10 -0400
Message-ID: <1128475990.11708.21.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Meder Kydyraliev <meder-ljIgrh4ImVw@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: orinoco-devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

orinoco: Information leakage due to incorrect padding

The orinoco driver can send uninitialized data exposing random pieces of
the system memory.  This happens because data is not padded with zeroes
when its length needs to be increased.

Reported by Meder Kydyraliev <meder-ljIgrh4ImVw@public.gmane.org>

Please try to get it to Linux 2.6.14 and maybe even 2.6.13.y.  It's a
security issue.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -490,9 +490,14 @@ static int orinoco_xmit(struct sk_buff *
 		return 0;
 	}
 
-	/* Length of the packet body */
-	/* FIXME: what if the skb is smaller than this? */
-	len = max_t(int,skb->len - ETH_HLEN, ETH_ZLEN - ETH_HLEN);
+	/* Check packet length, pad short packets, round up odd length */
+	len = max_t(int, ALIGN(skb->len, 2), ETH_ZLEN);
+	if (skb->len < len) {
+		skb = skb_padto(skb, len);
+		if (skb == NULL)
+			goto fail;
+	}
+	len -= ETH_HLEN;
 
 	eh = (struct ethhdr *)skb->data;
 
@@ -544,8 +549,7 @@ static int orinoco_xmit(struct sk_buff *
 		p = skb->data;
 	}
 
-	/* Round up for odd length packets */
-	err = hermes_bap_pwrite(hw, USER_BAP, p, ALIGN(data_len, 2),
+	err = hermes_bap_pwrite(hw, USER_BAP, p, data_len,
 				txfid, data_off);
 	if (err) {
 		printk(KERN_ERR "%s: Error %d writing packet to BAP\n",


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
