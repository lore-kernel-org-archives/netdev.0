From: David Miller <davem@davemloft.net>
Subject: Re: sungem triggers NAPI warning
Date: Sun, 23 Mar 2008 03:35:58 -0700 (PDT)
Message-ID: <20080323.033558.118223124.davem@davemloft.net>
References: <1203457124.3874.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38719
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756246AbYCWKfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 06:35:47 -0400
In-Reply-To: <1203457124.3874.2.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 19 Feb 2008 22:38:43 +0100

> In order to trigger it, I have to transfer a lot of data. I have
> triggered it now with a full kernel recompilation using -j6 and distcc
> onto a fast machine (with tg3 network, direct cable, gbit), and with
> rsync transferring 26GiB data between the machines.

I'll push the following fix.

Ben, thanks for letting this fall through the cracks :-)

commit da990a2402aeaee84837f29054c4628eb02f7493
Author: David S. Miller <davem@davemloft.net>
Date:   Sun Mar 23 03:35:12 2008 -0700

    [SUNGEM]: Fix NAPI assertion failure.
    
    As reported by Johannes Berg:
    
    I started getting this warning with recent kernels:
    
    [  773.908927] ------------[ cut here ]------------
    [  773.908954] Badness at net/core/dev.c:2204
     ...
    
    If we loop more than once in gem_poll(), we'll
    use more than the real budget in our gem_rx()
    calls, thus eventually trigger the caller's
    assertions in net_rx_action().
    
    Subtract "work_done" from "budget" for the second
    arg to gem_rx() to fix the bug.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 9721279..4291458 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -912,7 +912,7 @@ static int gem_poll(struct napi_struct *napi, int budget)
 		 * rx ring - must call napi_disable(), which
 		 * schedule_timeout()'s if polling is already disabled.
 		 */
-		work_done += gem_rx(gp, budget);
+		work_done += gem_rx(gp, budget - work_done);
 
 		if (work_done >= budget)
 			return work_done;
