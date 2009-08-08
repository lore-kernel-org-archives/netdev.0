From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivers/net/tokenring: Use status field rather than state
 field
Date: Sat, 8 Aug 2009 08:47:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908080846000.25176@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:52704 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553AbZHHGrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2009 02:47:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In general in this file, it is the status field, not the state field, that
contains values like OPEN and CLOSED.  Indeed, in the first error case, it
is the field status that is initialized.  I have thus assumed that all of
the error handling code should be the same, and moved it to the end of the
function to emphasize its commonality.

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/tokenring/smctr.c       |   36 +++++--------------
 1 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 6515894..f789f51 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3091,11 +3091,7 @@ static int smctr_lobe_media_test(struct net_device *dev)
         /* Setup the lobe media test. */
         smctr_lobe_media_test_cmd(dev);
         if(smctr_wait_cmd(dev))
-        {
-                smctr_reset_adapter(dev);
-                tp->status = CLOSED;
-                return (LOBE_MEDIA_TEST_FAILED);
-        }
+		goto err;
 
         /* Tx lobe media test frames. */
         for(i = 0; i < 1500; ++i)
@@ -3103,20 +3099,12 @@ static int smctr_lobe_media_test(struct net_device *dev)
                 if(smctr_send_lobe_media_test(dev))
                 {
                         if(perror)
-                        {
-                                smctr_reset_adapter(dev);
-                                tp->state = CLOSED;
-                                return (LOBE_MEDIA_TEST_FAILED);
-                        }
+				goto err;
                         else
                         {
                                 perror = 1;
                                 if(smctr_lobe_media_test_cmd(dev))
-                                {
-                                        smctr_reset_adapter(dev);
-                                        tp->state = CLOSED;
-                                        return (LOBE_MEDIA_TEST_FAILED);
-                                }
+					goto err;
                         }
                 }
         }
@@ -3124,28 +3112,24 @@ static int smctr_lobe_media_test(struct net_device *dev)
         if(smctr_send_dat(dev))
         {
                 if(smctr_send_dat(dev))
-                {
-                        smctr_reset_adapter(dev);
-                        tp->state = CLOSED;
-                        return (LOBE_MEDIA_TEST_FAILED);
-                }
+			goto err;
         }
 
         /* Check if any frames received during test. */
         if((tp->rx_fcb_curr[MAC_QUEUE]->frame_status)
                 || (tp->rx_fcb_curr[NON_MAC_QUEUE]->frame_status))
-        {
-                smctr_reset_adapter(dev);
-                tp->state = CLOSED;
-                return (LOBE_MEDIA_TEST_FAILED);
-        }
+			goto err;
 
         /* Set receive mask to "Promisc" mode. */
         tp->receive_mask = saved_rcv_mask;
 
         smctr_chg_rx_mask(dev);
 
-        return (0);
+	 return 0;
+err:
+	smctr_reset_adapter(dev);
+	tp->status = CLOSED;
+	return LOBE_MEDIA_TEST_FAILED;
 }
 
 static int smctr_lobe_media_test_cmd(struct net_device *dev)
