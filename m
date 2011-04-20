From: Tim Gardner <tim.gardner@canonical.com>
Subject: Fix atl1c event race (was Re: 2.6.38 dev_watchdog WARNING)
Date: Wed, 20 Apr 2011 11:59:57 -0600
Message-ID: <4DAF1F1D.1020108@canonical.com>
References: <4DADC8F2.9050700@canonical.com> <1303238959.2988.30.camel@bwh-desktop>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070501080606050006090902"
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:3149 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab1DTSAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 14:00:11 -0400
In-Reply-To: <1303238959.2988.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070501080606050006090902
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 04/19/2011 12:49 PM, Ben Hutchings wrote:
> On Tue, 2011-04-19 at 11:40 -0600, Tim Gardner wrote:
>> I'm seeing a lot of these kinds of bugs: WARNING: at
>> /build/buildd/linux-2.6.38/net/sched/sch_generic.c:256
>> dev_watchdog+0x213/0x220()
>>
>> The kernel is 2.6.38.2 plus Ubuntu cruft.
>>
>> A spot check of the 200+ hits on this string indicates they are
>> primarily due to these drivers:
>>
>> ipheth
>> atl1c
>> sis900
>> r8169
>>
>> As far as I can tell the warning happens when link is down on the media
>> (and has never been link UP) and are sent a transmit packet which never
>> completes. Is there a net/core or net/sched requirement to which these
>> drivers do not conform ? Are they not correctly indicating link status?
>
> The watchdog fires when the software queue has been stopped *and* the
> link has been reported as up for over dev->watchdog_timeo ticks.
>
> The software queue should be stopped iff the hardware queue is full or
> nearly full.  If the software queue remains stopped and the link is
> still reported up, then one of these things is happening:
>
> 1. The link went down but the driver didn't notice
> 2. TX completions are not being indicated or handled correctly
> 3. The hardware TX path has locked up
> 4. The link is stalled by excessive pause frames or collisions
> 5. Timeout is too low and/or low watermark is too high
> (there may be other explanations)
>
> I think the watchdog is primarily meant to deal with case 3, though all
> of cases 1-3 may be worked around by resetting the hardware.
>
> Ben.
>

I've been focusing on atl1c while trying to understand why link status 
flapping could cause these watchdog timeouts. I've a couple of log files 
with link state change information:

http://bugs.launchpad.net/bugs/766273
https://launchpadlibrarian.net/69926580/BootDmesg.txt
https://launchpadlibrarian.net/69926583/CurrentDmesg.txt

One thing of note is that there are 2 link UP messages in a row, 
something that should only be able to happen if there has been an 
intervening device reset (which is not evident in the logs). I've 
noticed that the work event scheduling is kind of racy, so perhaps this 
will help. See attached.

rtg
-- 
Tim Gardner tim.gardner@canonical.com

--------------070501080606050006090902
Content-Type: text/x-patch;
 name="0001-atl1c-Fix-work-event-interrupt-task-races.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-atl1c-Fix-work-event-interrupt-task-races.patch"

>From 6e92d53121dae5fa13c95c19b6076009df686de8 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Wed, 20 Apr 2011 11:31:09 -0600
Subject: [PATCH] atl1c: Fix work event interrupt/task races

The mechanism used to initiate work events from the interrupt
handler has a classic read/modify/write race between the interrupt
handler that sets the condition, and the worker task that reads and
clears the condition. Close these races by using atomic
bit fields.

Cc: stable@kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/atl1c/atl1c.h      |    6 +++---
 drivers/net/atl1c/atl1c_main.c |   14 +++++---------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 9ab5809..dec8110 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -566,9 +566,9 @@ struct atl1c_adapter {
 #define __AT_TESTING        0x0001
 #define __AT_RESETTING      0x0002
 #define __AT_DOWN           0x0003
-	u8 work_event;
-#define ATL1C_WORK_EVENT_RESET 		0x01
-#define ATL1C_WORK_EVENT_LINK_CHANGE	0x02
+	unsigned long work_event;
+#define	ATL1C_WORK_EVENT_RESET		0
+#define	ATL1C_WORK_EVENT_LINK_CHANGE	1
 	u32 msg_enable;
 
 	bool have_msi;
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 3824382..dffc7f7 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -325,7 +325,7 @@ static void atl1c_link_chg_event(struct atl1c_adapter *adapter)
 		}
 	}
 
-	adapter->work_event |= ATL1C_WORK_EVENT_LINK_CHANGE;
+	set_bit(ATL1C_WORK_EVENT_LINK_CHANGE, &adapter->work_event);
 	schedule_work(&adapter->common_task);
 }
 
@@ -337,20 +337,16 @@ static void atl1c_common_task(struct work_struct *work)
 	adapter = container_of(work, struct atl1c_adapter, common_task);
 	netdev = adapter->netdev;
 
-	if (adapter->work_event & ATL1C_WORK_EVENT_RESET) {
-		adapter->work_event &= ~ATL1C_WORK_EVENT_RESET;
+	if (test_and_clear_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event)) {
 		netif_device_detach(netdev);
 		atl1c_down(adapter);
 		atl1c_up(adapter);
 		netif_device_attach(netdev);
-		return;
 	}
 
-	if (adapter->work_event & ATL1C_WORK_EVENT_LINK_CHANGE) {
-		adapter->work_event &= ~ATL1C_WORK_EVENT_LINK_CHANGE;
+	if (test_and_clear_bit(ATL1C_WORK_EVENT_LINK_CHANGE,
+		&adapter->work_event))
 		atl1c_check_link_status(adapter);
-	}
-	return;
 }
 
 
@@ -369,7 +365,7 @@ static void atl1c_tx_timeout(struct net_device *netdev)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	/* Do the reset outside of interrupt context */
-	adapter->work_event |= ATL1C_WORK_EVENT_RESET;
+	set_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event);
 	schedule_work(&adapter->common_task);
 }
 
-- 
1.7.0.4


--------------070501080606050006090902--
