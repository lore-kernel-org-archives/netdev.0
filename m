From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] net/s2io: replace schedule_timeout() with msleep()/ssleep_interruptible()
Date: Mon, 1 Nov 2004 12:20:47 -0800
Message-ID: <20041101202047.GG1730@us.ibm.com>
References: <E1CO1vc-00022t-N2@sputnik> <4184C7EE.5070107@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C7EE.5070107@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 06:09:34AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >@@ -2846,11 +2838,10 @@ static int s2io_ethtool_idnic(struct net
> > 		sp->id_timer.data = (unsigned long) sp;
> > 	}
> > 	mod_timer(&sp->id_timer, jiffies);
> >-	set_current_state(TASK_INTERRUPTIBLE);
> > 	if (data)
> >-		schedule_timeout(data * HZ);
> >+		msleep_interruptible(data * 1000);
> 
> 
> clearly wants ssleep() here

Here is this patch. Depends, of course, on the patch sent just now to
lkml/kj which adds ssleep_interruptible to linux/delay.h.

Description: Uses msleep()/msleep_interruptible()/ssleep_interruptible()
[as appropriate] to guarantee the task delays as expected. I decided to
leave the MAX_SCHEDULE_TIMEOUT as is, since the overhead of converting
to seconds/msecs and then back again within the corresponding sleep()
function seemed unnecessary.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-rc1-vanilla/drivers/net/s2io.c	2004-10-30 15:33:29.000000000 -0700
+++ 2.6.10-rc1/drivers/net/s2io.c	2004-11-01 12:19:22.000000000 -0800
@@ -555,8 +555,7 @@ static int initNic(struct s2io_nic *nic)
 	val64 = 0;
 	writeq(val64, &bar0->sw_reset);
 	val64 = readq(&bar0->sw_reset);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 2);
+	msleep(500);
 
 	/*  Enable Receiving broadcasts */
 	val64 = readq(&bar0->mac_cfg);
@@ -803,8 +802,7 @@ static int initNic(struct s2io_nic *nic)
 				  dev->name);
 			return -1;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		time++;
 	}
 
@@ -838,8 +836,7 @@ static int initNic(struct s2io_nic *nic)
 			return -1;
 		}
 		time++;
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 	}
 
 	/* Initializing proper values as Pause threshold into all 
@@ -1182,8 +1179,7 @@ static int startNic(struct s2io_nic *nic
 	writeq(val64, &bar0->mc_rldram_mrs);
 	val64 = readq(&bar0->mc_rldram_mrs);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 10);	/* Delay by around 100 ms. */
+	msleep(100);			/* Delay by around 100 ms. */
 
 	/* Enabling ECC Protection. */
 	val64 = readq(&bar0->adapter_control);
@@ -1891,8 +1887,7 @@ int waitForCmdComplete(nic_t * sp)
 			ret = SUCCESS;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		if (cnt++ > 10)
 			break;
 	}
@@ -1931,15 +1926,13 @@ void s2io_reset(nic_t * sp)
 	 * As of now I'am just giving a 250ms delay and hoping that the
 	 * PCI write to sw_reset register is done by this time.
 	 */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 4);
+	msleep(250);
 
 	/* Restore the PCI state saved during initializarion. */
 	pci_restore_state(sp->pdev);
 	s2io_init_pci(sp);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 4);
+	msleep(250);
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
@@ -2157,8 +2150,7 @@ int s2io_close(struct net_device *dev)
 
 /* If the device tasklet is running, wait till its done before killing it */
 	while (atomic_read(&(sp->tasklet_status))) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 10);
+		msleep(100);
 	}
 	tasklet_kill(&sp->task);
 
@@ -2169,8 +2161,7 @@ int s2io_close(struct net_device *dev)
 			break;
 		}
 
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		cnt++;
 		if (cnt == 10) {
 			DBG_PRINT(ERR_DBG,
@@ -2846,11 +2837,12 @@ static int s2io_ethtool_idnic(struct net
 		sp->id_timer.data = (unsigned long) sp;
 	}
 	mod_timer(&sp->id_timer, jiffies);
-	set_current_state(TASK_INTERRUPTIBLE);
-	if (data)
-		schedule_timeout(data * HZ);
-	else
+	if (data) {
+		ssleep_interruptible(data);
+	} else {
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
+	}
 	del_timer_sync(&sp->id_timer);
 
 	return 0;
@@ -2943,8 +2935,7 @@ static u32 readEeprom(nic_t * sp, int of
 			data = I2C_CONTROL_GET_DATA(val64);
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		exit_cnt++;
 	}
 
@@ -2983,8 +2974,7 @@ static int writeEeprom(nic_t * sp, int o
 				ret = 0;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
+		msleep(50);
 		exit_cnt++;
 	}
 
@@ -3256,8 +3246,7 @@ static int s2io_bistTest(nic_t * sp, uin
 			ret = 0;
 			break;
 		}
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 10);
+		msleep(100);
 		cnt++;
 	}
 
@@ -3356,8 +3345,7 @@ static int s2io_rldramTest(nic_t * sp, u
 			val64 = readq(&bar0->mc_rldram_test_ctrl);
 			if (val64 & MC_RLDRAM_TEST_DONE)
 				break;
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ / 5);
+			msleep(200);
 		}
 
 		if (cnt == 5)
@@ -3373,8 +3361,7 @@ static int s2io_rldramTest(nic_t * sp, u
 			val64 = readq(&bar0->mc_rldram_test_ctrl);
 			if (val64 & MC_RLDRAM_TEST_DONE)
 				break;
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ / 2);
+			msleep(500);
 		}
 
 		if (cnt == 5)
@@ -3711,8 +3698,7 @@ static void s2io_set_link(unsigned long 
 	/* Allow a small delay for the NICs self initiated 
 	 * cleanup to complete.
 	 */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ / 10);
+	msleep(100);
 
 	val64 = readq(&bar0->adapter_status);
 	if (verify_xena_quiescence(val64, nic->device_enabled_once)) {
