From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Sat, 24 Apr 2010 12:11:27 +0100
Message-ID: <20100424121127.084b9766@linux.intel.com>
References: <20100423143356.7092.45260.stgit@localhost.localdomain>
	<20100423.163127.62645049.davem@davemloft.net>
	<20100423.163545.157549100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:30508 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752623Ab0DXLqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 07:46:50 -0400
In-Reply-To: <20100423.163545.157549100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Apr 2010 16:35:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Fri, 23 Apr 2010 16:31:27 -0700 (PDT)
> 
> > I'll apply this to net-2.6, thanks Alan.
> 
> Nevermind...
> 
> Doesn't apply to net-2.6, but even when I fix that up it doesn't
> even compile.  There is no 'dev' variable present etc.
> 
> You even use a combination of "dev" and "netdev" in the resulting
> code block.
> 
> If it doesn't even build, I doubt it's been tested either.

No idea why it won't apply - I guess net has diverged from -next in
this area. Other problem is not typing "stg ref" before "stg export"

(If it doesn't apply I'll look at it next weekend when -next and -net ought to be back in sync ?)


commit 526fb792b745da7c9532725a1a6ecc83a01110cf
Author: Alan Cox <alan@linux.intel.com>
Date:   Sat Apr 24 12:09:23 2010 +0100

    e100: Fix the TX workqueue race
    
    Nothing stops the workqueue being left to run in parallel with close or a
    few other operations. This causes double unmaps and the like.
    
    See kerneloops.org #1041230 for an example
    
    Signed-off-by: Alan Cox <alan@linux.intel.com>

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3e8d000..ef97bfc 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -168,6 +168,7 @@
 #include <linux/ethtool.h>
 #include <linux/string.h>
 #include <linux/firmware.h>
+#include <linux/rtnetlink.h>
 #include <asm/unaligned.h>
 
 
@@ -2280,8 +2281,13 @@ static void e100_tx_timeout_task(struct work_struct *work)
 
 	netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
 		     "scb.status=0x%02X\n", ioread8(&nic->csr->scb.status));
-	e100_down(netdev_priv(netdev));
-	e100_up(netdev_priv(netdev));
+
+	rtnl_lock();
+	if (netif_running(netdev)) {
+		e100_down(netdev_priv(netdev));
+		e100_up(netdev_priv(netdev));
+	}
+	rtnl_unlock();
 }
 
 static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
