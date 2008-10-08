From: David Miller <davem@davemloft.net>
Subject: Re: phylib: Wake PHY state machine on interrupt
Date: Wed, 08 Oct 2008 15:47:43 -0700 (PDT)
Message-ID: <20081008.154743.187048380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: tpiepho@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755561AbYJHWsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 18:48:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With a minor coding style fix, I've applied your patch
as below.  Thanks.

commit 0acb28396728f42b6b1553c85d27c37513796043
Author: Trent Piepho <tpiepho@freescale.com>
Date:   Wed Oct 8 15:46:57 2008 -0700

    phylib: Wake PHY state machine on interrupt
    
    This way the phy layer will respond to a change in phy state immediately,
    instead of up to one second later when the state machine timer runs.
    
    Signed-off-by: Trent Piepho <tpiepho@freescale.com>
    Acked-by: Andy Fleming <afleming@freescale.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 0433fcd..20cc82c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -729,6 +729,12 @@ static void phy_change(struct work_struct *work)
 	if (err)
 		goto irq_enable_err;
 
+	/* Stop timer and run the state queue now.  The work function for
+	 * state_queue will start the timer up again.
+	 */
+	del_timer(&phydev->phy_timer);
+	schedule_work(&phydev->state_queue);
+
 	return;
 
 irq_enable_err:
