From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH linux1394-2.6.git 07/15] ieee1394: eth1394: make MTU
	configurable
Date: Tue, 3 Apr 2007 23:55:40 +0200 (CEST)
Message-ID: <tkrat.9c9fbb8f6ef568dc@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
	<tkrat.6cd13266811f2f6d@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.6cd13266811f2f6d@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On  2 Apr, I wrote:
> +static int eth1394_data_len = 1500;
> +module_param_named(mtu, eth1394_data_len, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(mtu, "MTU (default = 1500)");

Can be solved without a new module load parameter.


From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: ieee1394: eth1394: allow MTU bigger than 1500

RFC 2734 says: "IP-capable nodes may operate with an MTU size larger
than the default [1500 octets], but the means by which a larger MTU is
configured are beyond the scope of this document."

Allow users to set an MTU bigger than 1500.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
Replaces patch "ieee1394: eth1394: make MTU configurable"

 drivers/ieee1394/eth1394.c |   34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -136,9 +136,6 @@ static const int hdr_type_len[] = {
 	sizeof(struct eth1394_sf_hdr)
 };
 
-/* For now, this needs to be 1500, so that XP works with us */
-#define ETH1394_DATA_LEN	ETH_DATA_LEN
-
 static const u16 eth1394_speedto_maxpayload[] = {
 /*     S100, S200, S400, S800, S1600, S3200 */
 	512, 1024, 2048, 4096,  4096,  4096
@@ -262,17 +259,27 @@ static void ether1394_tx_timeout(struct 
 	ether1394_host_reset(host);
 }
 
+static inline int ether1394_max_mtu(struct hpsb_host* host)
+{
+	return (1 << (host->csr.max_rec + 1))
+			- sizeof(union eth1394_hdr) - ETHER1394_GASP_OVERHEAD;
+}
+
 static int ether1394_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int max_rec =
-		((struct eth1394_priv *)netdev_priv(dev))->host->csr.max_rec;
+	int max_mtu;
 
-	if (new_mtu < 68 ||
-	    new_mtu > ETH1394_DATA_LEN ||
-	    new_mtu > (1 << (max_rec + 1)) - sizeof(union eth1394_hdr) -
-		      ETHER1394_GASP_OVERHEAD)
+	if (new_mtu < 68)
 		return -EINVAL;
 
+	max_mtu = ether1394_max_mtu(
+			((struct eth1394_priv *)netdev_priv(dev))->host);
+	if (new_mtu > max_mtu) {
+		ETH1394_PRINT(KERN_INFO, dev->name,
+			      "Local node constrains MTU to %d\n", max_mtu);
+		return -ERANGE;
+	}
+
 	dev->mtu = new_mtu;
 	return 0;
 }
@@ -476,13 +483,10 @@ static void ether1394_reset_priv(struct 
 			max_speed = host->speed[i];
 	priv->bc_sspd = max_speed;
 
-	/* We'll use our maximum payload as the default MTU */
 	if (set_mtu) {
-		int max_payload = 1 << (host->csr.max_rec + 1);
-
-		dev->mtu = min(ETH1394_DATA_LEN,
-			       (int)(max_payload - sizeof(union eth1394_hdr) -
-				     ETHER1394_GASP_OVERHEAD));
+		/* Use the RFC 2734 default 1500 octets or the maximum payload
+		 * as initial MTU */
+		dev->mtu = min(1500, ether1394_max_mtu(host));
 
 		/* Set our hardware address while we're at it */
 		memcpy(dev->dev_addr, &guid, sizeof(u64));

-- 
Stefan Richter
-=====-=-=== -=-- ---==
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
