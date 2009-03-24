From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 9/9] [PATCH] claw: fix minor findings from code analysis tool
Date: Tue, 24 Mar 2009 13:29:13 +0100
Message-ID: <20090324124336.491137000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	"Andrew H. Richter" <richtera@us.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:43480 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758683AbZCXMnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:40 -0400
Content-Disposition: inline; filename=628-claw-beam.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew H. Richter <richtera@us.ibm.com>

This patch fixes two problems in the claw driver identified by
static code analysis:
o Change in case differentiation of received sense codes
o Use correct data length in claw hard_start_xmit routine

Signed-off-by: Andrew H. Richter <richtera@us.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |   44 ++++++++++++++++++++------------------------
 1 file changed, 20 insertions(+), 24 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2009-03-19 11:16:40.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/claw.c	2009-03-19 11:16:40.000000000 +0100
@@ -1033,7 +1033,7 @@ static int
 pages_to_order_of_mag(int num_of_pages)
 {
 	int	order_of_mag=1;		/* assume 2 pages */
-	int	nump=2;
+	int	nump;
 
 	CLAW_DBF_TEXT_(5, trace, "pages%d", num_of_pages);
 	if (num_of_pages == 1)   {return 0; }  /* magnitude of 0 = 1 page */
@@ -1187,37 +1187,31 @@ ccw_check_unit_check(struct chbk * p_ch,
 	dev_warn(dev, "The communication peer of %s disconnected\n",
 		ndev->name);
 
-        if (sense & 0x40) {
-                if (sense & 0x01) {
+	if (sense & 0x40) {
+		if (sense & 0x01) {
 			dev_warn(dev, "The remote channel adapter for"
 				" %s has been reset\n",
 				ndev->name);
-                }
-        }
-        else if (sense & 0x20) {
-                if (sense & 0x04) {
+		}
+	} else if (sense & 0x20) {
+		if (sense & 0x04) {
 			dev_warn(dev, "A data streaming timeout occurred"
 				" for %s\n",
 				ndev->name);
-                }
-                else  {
-			dev_warn(dev, "A data transfer parity error occurred"
-				" for %s\n",
-				ndev->name);
-                }
-        }
-        else if (sense & 0x10) {
-                if (sense & 0x20) {
+		} else if (sense & 0x10) {
 			dev_warn(dev, "The remote channel adapter for %s"
 				" is faulty\n",
 				ndev->name);
-                }
-                else {
-			dev_warn(dev, "A read data parity error occurred"
+		} else {
+			dev_warn(dev, "A data transfer parity error occurred"
 				" for %s\n",
 				ndev->name);
-                }
-        }
+		}
+	} else if (sense & 0x10) {
+		dev_warn(dev, "A read data parity error occurred"
+			" for %s\n",
+			ndev->name);
+	}
 
 }   /*    end of ccw_check_unit_check    */
 
@@ -1254,7 +1248,7 @@ find_link(struct net_device *dev, char *
 			break;
 	}
 
-        return 0;
+	return rc;
 }    /*    end of find_link    */
 
 /*-------------------------------------------------------------------*
@@ -1366,7 +1360,10 @@ claw_hw_tx(struct sk_buff *skb, struct n
                 privptr->p_write_free_chain=p_this_ccw->next;
                 p_this_ccw->next=NULL;
                 --privptr->write_free_count; /* -1 */
-                bytesInThisBuffer=len_of_data;
+		if (len_of_data >= privptr->p_env->write_size)
+			bytesInThisBuffer = privptr->p_env->write_size;
+		else
+			bytesInThisBuffer = len_of_data;
                 memcpy( p_this_ccw->p_buffer,pDataAddress, bytesInThisBuffer);
                 len_of_data-=bytesInThisBuffer;
                 pDataAddress+=(unsigned long)bytesInThisBuffer;
@@ -2516,7 +2513,6 @@ unpack_read(struct net_device *dev )
 	p_dev = &privptr->channel[READ].cdev->dev;
 	p_env = privptr->p_env;
         p_this_ccw=privptr->p_read_active_first;
-        i=0;
 	while (p_this_ccw!=NULL && p_this_ccw->header.flag!=CLAW_PENDING) {
 		pack_off = 0;
 		p = 0;

