From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/10] [bonding 2.6] fix 802.3ad long fail over with high UDP Tx stress
Date: Thu, 4 Sep 2003 20:43:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042043.53654.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3=
ad.c
--- a/drivers/net/bonding/bond_3ad.c	Thu Sep  4 20:17:51 2003
+++ b/drivers/net/bonding/bond_3ad.c	Thu Sep  4 20:17:52 2003
@@ -37,6 +37,16 @@
  * 2003/05/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Renamed bond_3ad_link_status_changed() to
  *	  bond_3ad_handle_link_change() for compatibility with TLB.
+ *
+ * 2003/05/20 - Amir Noam <amir.noam at intel dot com>
+ *	- Fix long fail over time when releasing last slave of an active
+ *	  aggregator - send LACPDU on unbind of slave to tell partner this
+ *	  port is no longer aggregatable.
+ *
+ * 2003/06/25 - Tsippy Mendelson <tsippy.mendelson at intel dot com>
+ *	- Send LACPDU as highest priority packet to further fix the above
+ *	  problem on very high Tx traffic load where packets may get dropped
+ *	  by the slave.
  */
=20
 #include <linux/skbuff.h>
@@ -45,6 +55,7 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/if_bonding.h>
+#include <linux/pkt_sched.h>
 #include "bonding.h"
 #include "bond_3ad.h"
=20
@@ -905,6 +916,7 @@ static int ad_lacpdu_send(struct port *p
 	skb->mac.raw =3D skb->data;
 	skb->nh.raw =3D skb->data + ETH_HLEN;
 	skb->protocol =3D PKT_TYPE_LACPDU;
+	skb->priority =3D TC_PRIO_CONTROL;
=20
 	lacpdu_header =3D (struct lacpdu_header *)skb_put(skb, length);
=20
diff -Nuarp a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3=
ad.h
--- a/drivers/net/bonding/bond_3ad.h	Thu Sep  4 20:17:51 2003
+++ b/drivers/net/bonding/bond_3ad.h	Thu Sep  4 20:17:52 2003
@@ -165,7 +165,7 @@ typedef struct marker {
 	//  =3D 0x02  (marker response information)
 	u8 marker_length;	 //  =3D 0x16
 	u16 requester_port;	 //   The number assigned to the port by the reques=
ter
-	struct mac_addr requester_system;      //   The requester=92s system id
+	struct mac_addr requester_system;      //   The requester's system id
 	u32 requester_transaction_id;	//   The transaction id allocated by the =
requester,
 	u16 pad;		 //  =3D 0
 	u8 tlv_type_terminator;	     //  =3D 0x00
