From: Stefan Rompf <srompf@isg.de>
Subject: Patch: Make linkwatch more robust against rtnl holders
Date: Sun, 15 Feb 2004 15:11:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402151511.49432.srompf@isg.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_l43LAPCXzGeOIJ6"
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_l43LAPCXzGeOIJ6
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David,

the attached patch updates the linkwatch code so that it backs off and retries 
whenever it cannot get the rtnl semaphore.

This makes it more robust against unrelated processes calling 
flush_scheduled_work() while holding the rtnl lock. This problem was reported 
on netdev for the sungem driver.

I preferred rescheduling every 1/10 second against creating a kernel thread as 
the code is shorter, and the situation should not happen anyway.

Stefan

--Boundary-00=_l43LAPCXzGeOIJ6
Content-Type: text/x-diff;
  charset="us-ascii";
  name="patch-linkwatch-2.6.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="patch-linkwatch-2.6.1"

--- net/core/link_watch.c.old	2003-12-26 20:38:25.000000000 +0100
+++ net/core/link_watch.c	2004-01-30 20:07:57.000000000 +0100
@@ -84,6 +84,8 @@
 
 static void linkwatch_event(void *dummy)
 {
+	if (rtnl_shlock_nowait()) goto out_err1;
+	if (rtnl_exlock_nowait()) goto out_err2;
 	/* Limit the number of linkwatch events to one
 	 * per second so that a runaway driver does not
 	 * cause a storm of messages on the netlink
@@ -92,11 +94,16 @@
 	linkwatch_nextevent = jiffies + HZ;
 	clear_bit(LW_RUNNING, &linkwatch_flags);
 
-	rtnl_shlock();
-	rtnl_exlock();
 	linkwatch_run_queue();
 	rtnl_exunlock();
 	rtnl_shunlock();
+
+	return;
+
+out_err2:
+	rtnl_shunlock();
+out_err1:
+	schedule_delayed_work(&linkwatch_work, HZ / 10);
 }
 
 

--Boundary-00=_l43LAPCXzGeOIJ6--
