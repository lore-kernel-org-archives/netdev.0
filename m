From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][patch] Fix 802.3ad long fail over with high UDP Tx stress
Date: Thu, 26 Jun 2003 18:04:34 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0306261530340.18704-100000@jrslxjul1.npdj.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Amir Noam <amir.noam@intel.com>, "Chad N. Tindel" <ctindel@calma.pair.com>,
   Jay Vosburgh <fubar@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>,
   Noam Marom <noam.marom@intel.com>, Shmulik Hen <shmulik.hen@intel.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bond-devel <bonding-devel@lists.sourceforge.net>,
   linux-net <linux-net@vger.kernel.org>, linux-netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	This patch fixes a problem detected by our QA group. On very high
bi-directional stress traffic, removing the last slave of the active
aggregator results in long failover time to another aggregator (upto 90
sec). The fix is to send LACPDU packets with the highest priority
(TC_PRIO_CONTROL), to overcome the possibility of packets being dropped
from the adapter's queue. This further fixes the original long failover
problem reported by Jay Vosburgh on April 3rd and fixed by us on May 20th.
We verified it fixes the problem for 1000Mbps adapters, but it may still
not entirely fix it for 10/100 adapters since they simply can't handle th=
e
load. In the latter case, the failover may have to wait the entire
timeout.

	Since we still don't use bitkeeper, this patch should be applied
on top of Marcelo's 2.4.22-pre1 patch plus Jeff Garzik's 2.4 net driver
updates from from June 20Th 2.4.22-pre1-netdrvr1.

	There is also a small fix for a non-printable character that
somehow snuck into bond_3ad.h.

--=20
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |


diff -Nuarp linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_3ad.c lin=
ux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_3ad.c
--- linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_3ad.c	Wed Jun 25 =
16:33:22 2003
+++ linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_3ad.c	Wed J=
un 25 16:33:23 2003
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

 #include <linux/skbuff.h>
@@ -45,6 +55,7 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/if_bonding.h>
+#include <linux/pkt_sched.h>
 #include "bonding.h"
 #include "bond_3ad.h"

@@ -905,6 +916,7 @@ static int ad_lacpdu_send(struct port *p
 	skb->mac.raw =3D skb->data;
 	skb->nh.raw =3D skb->data + ETH_HLEN;
 	skb->protocol =3D PKT_TYPE_LACPDU;
+	skb->priority =3D TC_PRIO_CONTROL;

 	lacpdu_header =3D (struct lacpdu_header *)skb_put(skb, length);

diff -Nuarp linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_3ad.h lin=
ux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_3ad.h
--- linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_3ad.h	Wed Jun 25 =
16:33:22 2003
+++ linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_3ad.h	Wed J=
un 25 16:33:23 2003
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
diff -Nuarp linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_main.c li=
nux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_main.c	Wed Jun 25=
 16:33:22 2003
+++ linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_main.c	Wed =
Jun 25 16:33:23 2003
@@ -429,7 +429,7 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"

-#define DRV_VERSION		"2.2.12"
+#define DRV_VERSION		"2.2.13"
 #define DRV_RELDATE		"June 25, 2003"
 #define DRV_NAME		"bonding"
 #define DRV_DESCRIPTION		"Ethernet Channel Bonding Driver"
