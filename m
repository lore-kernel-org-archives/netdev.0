From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH 4/9] sky2: fix shutdown synchronization
Date: Fri, 19 Jun 2009 08:53:30 +0900
Message-ID: <4A3AD37A.8080703@ring3k.org>
References: <20090617173031.703636683@vyatta.com>	<20090617173139.828049268@vyatta.com>	<4A3ACCCF.1080605@ring3k.org> <20090618164105.6f17481e@nehalam>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406000600010402090602"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:45117 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbZFRXyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 19:54:35 -0400
Received: by pxi27 with SMTP id 27so1397542pxi.33
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 16:54:37 -0700 (PDT)
In-Reply-To: <20090618164105.6f17481e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070406000600010402090602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> On Fri, 19 Jun 2009 08:25:03 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
>> Hi Steven,
>>
>> After applying your complete patch series, I'm still getting crashes in 
>> sky2_poll, and I can make them go away by adding an msleep(1) before 
>> these lines in sky2_down.
>>
> 
> adding msleep adds delay so interrupt and packets can clear, that is okay,
> but would rather have something deterministic?  perhaps it needs to poll
> irq status register or napi status.

Well, having a check for NULL rx_ring in sky2_poll functions is a little 
more deterministic, but I know you don't like that :-)

Another possibility is to try reordering the shutdown, I can have a go 
at experimenting with that.

I have found two other potential problems:

* there appears to be a race in sky2_poll (patch attached)

* sky2_up can cause receiver hangs due to a similar race to the one in 
sky2_down (I have some code which stops that from happening and will try 
put this top of your changes and push a patch out today for your inspection)

thanks,

Mike

--------------070406000600010402090602
Content-Type: text/x-patch;
 name="0001-Fix-a-race-condition-in-sky2_poll.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-Fix-a-race-condition-in-sky2_poll.patch"

>From e9a7e8c1863a998428046bf7eaf7951379645822 Mon Sep 17 00:00:00 2001
From: Mike McCormack <mikem@ring3k.org>
Date: Thu, 18 Jun 2009 20:37:41 +0900
Subject: [PATCH] Fix a race condition in sky2_poll

Clear interrupt only when the status buffer is fully drained,
Make sure to clear interrupt when work_done == work_limit
 and the buffer is drained.
---
 drivers/net/sky2.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7681d28..ca1e9e5 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2524,9 +2524,6 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 		}
 	} while (hw->st_idx != idx);
 
-	/* Fully processed status ring so clear irq */
-	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-
 exit_loop:
 	sky2_rx_done(hw, 0, total_packets[0], total_bytes[0]);
 	sky2_rx_done(hw, 1, total_packets[1], total_bytes[1]);
@@ -2779,9 +2776,16 @@ static int sky2_poll(struct napi_struct *napi, int work_limit)
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
-	while ((idx = sky2_read16(hw, STAT_PUT_IDX)) != hw->st_idx) {
+	idx = sky2_read16(hw, STAT_PUT_IDX);
+	while (idx != hw->st_idx) {
 		work_done += sky2_status_intr(hw, work_limit - work_done, idx);
 
+		/* If we fully processed the status ring, clear the irq */
+		idx = sky2_read16(hw, STAT_PUT_IDX);
+		if (idx == hw->st_idx) {
+			sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+			break;
+		}
 		if (work_done >= work_limit)
 			goto done;
 	}
-- 
1.5.6.5


--------------070406000600010402090602--
