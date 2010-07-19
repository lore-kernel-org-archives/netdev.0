From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [4/5] Do not reset
 when the device is not opened
Date: Mon, 19 Jul 2010 10:02:13 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007190958480.9943@localhost.localdomain>
References: <alpine.LRH.2.00.1007151448260.25472@localhost.localdomain> <20100715.183210.226762655.davem@davemloft.net> <alpine.LRH.2.00.1007160108240.12503@localhost.localdomain> <20100717.163538.137865264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Ronghua Zhang <ronghua@vmware.com>,
	Matthieu Bucchianeri <matthieu@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:16329 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755167Ab0GSRCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 13:02:14 -0400
In-Reply-To: <20100717.163538.137865264.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 17 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Fri, 16 Jul 2010 01:17:29 -0700 (PDT)
> 
> > 
> > 
> > On Thu, 15 Jul 2010, David Miller wrote:
> > 
> >> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> >> Date: Thu, 15 Jul 2010 18:20:52 -0700 (PDT)
> >> 
> >> > Is this what you suggest :
> >> > 
> >> > ---
> >> > 
> >> > Hold rtnl_lock to get the right link state.
> >> 
> >> It ought to work, but make sure that it is legal to take the
> >> RTNL semaphore in all contexts in which this code block
> >> might be called.
> >> 
> > 
> > This code block is called only from the workqueue handler, which runs in
> > process context, so it is legal to take rtnl semaphore.
> > Tested this code by simulating event interrupts (which schedule this 
> > code) at considerable frequency while the interface was brought up and
> > down in a loop. Similar stress testing had revealed the bug originally. 
> 
> Awesome, please submit this formally.  The copy you sent lacked a commit
> message and signoff.
> 

Reposting the patch formally.

David,
Thanks for your coperation.

->Shreyas

---
From: Shreyas Bhatewara <sbhatewara@vmware.com>

Hold rtnl_lock to get the right link state.

While asynchronously resetting the device, hold rtnl_lock to get the
right value from netif_running. If a reset is scheduled, and the device
goes thru close and open, it may happen that reset and open may run in
parallel. Holding rtnl_lock will avoid this.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

 drivers/net/vmxnet3/vmxnet3_drv.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1b0ce8c..c4d7e42 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2420,6 +2420,7 @@ vmxnet3_reset_work(struct work_struct *data)
 		return;
 
 	/* if the device is closed, we must leave it alone */
+	rtnl_lock();
 	if (netif_running(adapter->netdev)) {
 		printk(KERN_INFO "%s: resetting\n", adapter->netdev->name);
 		vmxnet3_quiesce_dev(adapter);
@@ -2428,6 +2429,7 @@ vmxnet3_reset_work(struct work_struct *data)
 	} else {
 		printk(KERN_INFO "%s: already closed\n", adapter->netdev->name);
 	}
+	rtnl_unlock();
 
 	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
 }
