From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [4/5] Do not reset
 when the device is not opened
Date: Thu, 15 Jul 2010 18:20:52 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007151448260.25472@localhost.localdomain>
References: <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain> <alpine.LRH.2.00.1007070229030.5939@localhost.localdomain> <alpine.LRH.2.00.1007131749030.32055@localhost.localdomain> <20100714.140718.115934967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Ronghua Zhang <ronghua@vmware.com>,
	Matthieu Bucchianeri <matthieu@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714.140718.115934967.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 14 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Tue, 13 Jul 2010 17:49:52 -0700 (PDT)
> 
> > 
> > Do not reset when the device is not opened
> > 
> > If a reset is scheduled, and the device goes thru close and open, it
> > may happen that reset and open may run in parallel.
> > The reset code now bails out if the device is not opened.
> >  
> > Signed-off-by: Ronghua Zang <ronghua@vmware.com>
> > Signed-off-by: Matthieu Bucchianeri <matthieu@vmware.com>
> > Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> Testing IFF_UP is just making your race hole a little smaller but
> it isn't fixing the problem.
> 
> In fact, there really isn't any legitimate reason for a driver
> to test the IFF_UP state bit.  netif_running() is the correct
> test, and asynchronous work queue things like resets should
> synchronize with open/close using the RTNL lock so that your
> test of netif_running() is a stable one.
> 

Is this what you suggest :

---

Hold rtnl_lock to get the right link state.

While asynchronously resetting the device, hold rtnl_lock to get the 
right value from netif_running. If a reset is scheduled, and the device
goes thru close and open, it may happen that reset and open may run in 
parallel. Holding rtnl_lock will avoid this.

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
