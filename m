From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.25-rc2-git] rndis_host:  fix transfer size negotiation
Date: Fri, 22 Feb 2008 17:31:16 -0800
Message-ID: <200802221731.16698.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Jean-Christophe Dubois" <jcd@tribudubois.net>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:30998 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752384AbYBWBdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 20:33:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Christophe Dubois <jcd@tribudubois.net>

This patch should resolve a problem that's troubled support for
some RNDIS peripherals.  It seems to have boiled down to using a
variable to establish transfer size limits before it was assigned,
which caused those devices to fallback to a default "jumbogram"
mode we don't support.  Fix by assigning it earlier for RNDIS.

Signed-off-by: Jean-Christophe Dubois <jcd@tribudubois.net>
[ cleanups ]
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
This bugfix should be merged before 2.6.25-final.

 drivers/net/usb/rndis_host.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

--- g26.orig/drivers/net/usb/rndis_host.c	2008-02-01 22:24:38.000000000 -0800
+++ g26/drivers/net/usb/rndis_host.c	2008-02-16 12:55:35.000000000 -0800
@@ -16,10 +16,6 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-
-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
-
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -318,6 +314,14 @@ generic_rndis_bind(struct usbnet *dev, s
 	net->hard_header_len += sizeof (struct rndis_data_hdr);
 	dev->hard_mtu = net->mtu + net->hard_header_len;
 
+	dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
+	if (dev->maxpacket == 0) {
+		if (netif_msg_probe(dev))
+			dev_dbg(&intf->dev, "dev->maxpacket can't be 0\n");
+		retval = -EINVAL;
+		goto fail_and_release;
+	}
+
 	dev->rx_urb_size = dev->hard_mtu + (dev->maxpacket + 1);
 	dev->rx_urb_size &= ~(dev->maxpacket - 1);
 	u.init->max_transfer_size = cpu_to_le32(dev->rx_urb_size);
