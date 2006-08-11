From: Patrick McHardy <kaber@trash.net>
Subject: [RFC PPP]: carrier/operstate support
Date: Fri, 11 Aug 2006 16:03:09 +0200
Message-ID: <44DC8E1D.9020907@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080302010009040204030906"
Cc: paulus@samba.org, linux-ppp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:15772 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751118AbWHKODO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 10:03:14 -0400
To: Linux Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080302010009040204030906
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080302010009040204030906
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[PPP]: carrier/operstate support

Add support for setting carrier state and operstate of ppp devices.
The patch works as follows:

- Initially, ppp devices come up with carrier off and npmode set to NPMODE_DROP

- In non-demand mode (dialin or permanent connection), when the IP*CP
  protocols transition to UP state, the ppp daemon will change the npmode
  to NPMODE_PASS, at which point the carrier state is set to "on".
  On hangup the ppp daemon will change it back to NPMODE_DROP and the
  carrier state is changed back to "off".

- In demand mode, the PPP daemon will set npmode to NPMODE_PASS immediately
  (moving the interface to "carrier up" state) and set the SC_LOOP_TRAFFIC
  flag until demand is signalled. While SC_LOOP_TRAFFIC is set, the interface
  is put in dormant state. As soon as demand is signaled this flag will get
  cleared and npmode set to NPMODE_QUEUE (which is unsupported by the kernel),
  so the carrier state is changed to "off" until the IP*CB protocols
  transition to UP.

So simply put: a non-demand interface in in "carrier off" state until its
able to pass traffic, demand interfaces are in "carrier on, dormant" state
while waiting for demand, "carrier off" state while connecting and "carrier on"
state when able to pass traffic.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 821791c11bee40ec1bedbb86a03a995475c85b2c
tree 4c466550537e6bf4bc4b8f32171caf7d7349ca81
parent 99c4451081b0ea2107ba4827f7d518e1c739cf1b
author Patrick McHardy <kaber@trash.net> Fri, 11 Aug 2006 16:01:15 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 11 Aug 2006 16:01:15 +0200

 drivers/net/ppp_generic.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 0ec6e9d..e01b7e9 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -639,6 +639,12 @@ static int ppp_ioctl(struct inode *inode
 		ppp_lock(ppp);
 		cflags = ppp->flags & ~val;
 		ppp->flags = val & SC_FLAG_BITS;
+		if (ppp->dev != NULL) {
+			if (ppp->flags & SC_LOOP_TRAFFIC)
+				netif_dormant_on(ppp->dev);
+			else
+				netif_dormant_off(ppp->dev);
+		}
 		ppp_unlock(ppp);
 		if (cflags & SC_CCP_OPEN)
 			ppp_ccp_closed(ppp);
@@ -719,9 +725,20 @@ static int ppp_ioctl(struct inode *inode
 			if (copy_to_user(argp, &npi, sizeof(npi)))
 				break;
 		} else {
+			ppp_lock(ppp);
 			ppp->npmode[i] = npi.mode;
-			/* we may be able to transmit more packets now (??) */
-			netif_wake_queue(ppp->dev);
+			if (ppp->dev != NULL) {
+				for (i = 0; i < NUM_NP; i++) {
+					if (ppp->npmode[i] == NPMODE_PASS) {
+						netif_carrier_on(ppp->dev);
+						netif_wake_queue(ppp->dev);
+						break;
+					}
+				}
+				if (i == NUM_NP)
+					netif_carrier_off(ppp->dev);
+			}
+			ppp_unlock(ppp);
 		}
 		err = 0;
 		break;
@@ -2420,7 +2437,8 @@ ppp_create_interface(int unit, int *retp
 	init_ppp_file(&ppp->file, INTERFACE);
 	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
 	for (i = 0; i < NUM_NP; ++i)
-		ppp->npmode[i] = NPMODE_PASS;
+		ppp->npmode[i] = NPMODE_DROP;
+	netif_carrier_off(dev);
 	INIT_LIST_HEAD(&ppp->channels);
 	spin_lock_init(&ppp->rlock);
 	spin_lock_init(&ppp->wlock);

--------------080302010009040204030906--
