From: janitor@sternwelten.at
Subject: [patch 16/18]  net/airo: replace 	schedule_timeout() with msleep()/msleep_interuptible()
Date: Sun, 31 Oct 2004 00:43:10 +0200
Message-ID: <E1CO1wE-0002hu-WE@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep()/msleep_interruptible() [as appropriate]
instead of schedule_timeout() to guarantee the task delays as
expected. Also uses set_current_state() instead of direct assignment of
current->state in one place.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/wireless/airo.c |   27 ++++++++---------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff -puN drivers/net/wireless/airo.c~msleep+msleep_interruptible-drivers_net_wireless_airo drivers/net/wireless/airo.c
--- linux-2.6.10-rc1/drivers/net/wireless/airo.c~msleep+msleep_interruptible-drivers_net_wireless_airo	2004-10-24 17:05:35.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/wireless/airo.c	2004-10-24 17:05:35.000000000 +0200
@@ -1699,9 +1699,8 @@ static int readBSSListRid(struct airo_in
 			issuecommand(ai, &cmd, &rsp);
 			up(&ai->sem);
 			/* Let the command take effect */
-			set_current_state (TASK_INTERRUPTIBLE);
 			ai->task = current;
-			schedule_timeout (3*HZ);
+			msleep_interruptible(3*1000);
 			ai->task = NULL;
 		}
 	rc = PC4500_readrid(ai, first ? RID_BSSLISTFIRST : RID_BSSLISTNEXT,
@@ -2686,11 +2685,9 @@ int reset_card( struct net_device *dev ,
 		return -1;
 	waitbusy (ai);
 	OUT4500(ai,COMMAND,CMD_SOFTRESET);
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/5);
+	msleep(200);
 	waitbusy (ai);
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/5);
+	msleep(200);
 	if (lock)
 		up(&ai->sem);
 	return 0;
@@ -2950,7 +2947,7 @@ static int airo_thread(void *data) {
 				}
 				break;
 			}
-			current->state = TASK_RUNNING;
+			set_current_state(TASK_RUNNING);
 			remove_wait_queue(&ai->thr_wait, &wait);
 			locked = 1;
 		}
@@ -5518,12 +5515,12 @@ static int airo_pci_resume(struct pci_de
 	} else {
 		OUT4500(ai, EVACK, EV_AWAKEN);
 		OUT4500(ai, EVACK, EV_AWAKEN);
-		schedule_timeout(HZ/10);
+		msleep_interruptible(100);
 	}
 
 	set_bit (FLAG_COMMIT, &ai->flags);
 	disable_MAC(ai, 0);
-        schedule_timeout (HZ/5);
+        msleep_interruptible(200);
 	if (ai->SSID) {
 		writeSsidRid(ai, ai->SSID, 0);
 		kfree(ai->SSID);
@@ -7472,8 +7469,7 @@ int cmdreset(struct airo_info *ai) {
 
 	OUT4500(ai,COMMAND,CMD_SOFTRESET);
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* WAS 600 12/7/00 */
+	ssleep(1);			/* WAS 600 12/7/00 */
 
 	if(!waitbusy (ai)){
 		printk(KERN_INFO "Waitbusy hang AFTER RESET\n");
@@ -7500,8 +7496,7 @@ int setflashmode (struct airo_info *ai) 
 		OUT4500(ai, SWS3, FLASH_COMMAND);
 		OUT4500(ai, COMMAND,0);
 	}
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/2); /* 500ms delay */
+	msleep(500);		/* 500ms delay */
 
 	if(!waitbusy(ai)) {
 		clear_bit (FLAG_FLASHING, &ai->flags);
@@ -7611,8 +7606,7 @@ int flashputbuf(struct airo_info *ai){
 int flashrestart(struct airo_info *ai,struct net_device *dev){
 	int    i,status;
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* Added 12/7/00 */
+	ssleep(1);			/* Added 12/7/00 */
 	clear_bit (FLAG_FLASHING, &ai->flags);
 	if (test_bit(FLAG_MPI, &ai->flags)) {
 		status = mpi_init_descriptors(ai);
@@ -7627,8 +7621,7 @@ int flashrestart(struct airo_info *ai,st
 				( ai, 2312, i >= MAX_FIDS / 2 );
 		}
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* Added 12/7/00 */
+	ssleep(1);			/* Added 12/7/00 */
 	return status;
 }
 #endif /* CISCO_EXT */
_
