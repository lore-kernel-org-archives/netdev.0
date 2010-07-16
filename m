From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [2/5] Interrupt
 control bitmap
Date: Thu, 15 Jul 2010 18:20:03 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007150121400.25472@localhost.localdomain>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain> <alpine.LRH.2.00.1007070222110.6105@localhost.localdomain> <alpine.LRH.2.00.1007131746370.32055@localhost.localdomain> <20100714.140433.59678649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Ronghua Zhang <ronghua@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714.140433.59678649.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 14 Jul 2010, David Miller wrote:

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> Date: Tue, 13 Jul 2010 17:48:04 -0700 (PDT)
> 
> > -	__le32		reserved[3];
> > +	__le32		intrCtrl;
> > +	__le32		reserved[2];
> >  };
> >  
>  ...
> > +	adapter->shared->devRead.intrConf.intrCtrl &= ~VMXNET3_IC_DISABLE_ALL;
>  ...
> > +	adapter->shared->devRead.intrConf.intrCtrl |= VMXNET3_IC_DISABLE_ALL;
>  ...
> > +	devRead->intrConf.intrCtrl |= VMXNET3_IC_DISABLE_ALL;
> 
> You need to use cpu_to_le32() and similar when accessing this value.
> 
> If you run "sparse" with endianness checking enabled you'll see
> warnings showing alerting you to this issue...
> 

Reposting the patch with the endianness fix.

---

A new bit map 'intrCtrl' is introduced in the DriverShared area. The 
driver Ashould update VMXNET3_IC_DISABLE_ALL bit before writing IMR.

Signed-off-by: Ronghua Zang <ronghua@vmware.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

 drivers/net/vmxnet3/vmxnet3_defs.h |    6 +++++-
 drivers/net/vmxnet3/vmxnet3_drv.c  |    5 +++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index b4889e6..ca7727b 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -464,6 +464,9 @@ enum vmxnet3_intr_type {
 /* addition 1 for events */
 #define VMXNET3_MAX_INTRS      25
 
+/* value of intrCtrl */
+#define VMXNET3_IC_DISABLE_ALL  0x1   /* bit 0 */
+
 
 struct Vmxnet3_IntrConf {
 	bool		autoMask;
@@ -471,7 +474,8 @@ struct Vmxnet3_IntrConf {
 	u8		eventIntrIdx;
 	u8		modLevels[VMXNET3_MAX_INTRS];	/* moderation level for
 							 * each intr */
-	__le32		reserved[3];
+	__le32		intrCtrl;
+	__le32		reserved[2];
 };
 
 /* one bit per VLAN ID, the size is in the units of u32	*/
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 5a50d10..df3d2ac 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -72,6 +72,8 @@ vmxnet3_enable_all_intrs(struct vmxnet3_adapter *adapter)
 
 	for (i = 0; i < adapter->intr.num_intrs; i++)
 		vmxnet3_enable_intr(adapter, i);
+	adapter->shared->devRead.intrConf.intrCtrl &=
+					cpu_to_le32(~VMXNET3_IC_DISABLE_ALL);
 }
 
 
@@ -80,6 +82,8 @@ vmxnet3_disable_all_intrs(struct vmxnet3_adapter *adapter)
 {
 	int i;
 
+	adapter->shared->devRead.intrConf.intrCtrl |=
+					cpu_to_le32(VMXNET3_IC_DISABLE_ALL);
 	for (i = 0; i < adapter->intr.num_intrs; i++)
 		vmxnet3_disable_intr(adapter, i);
 }
@@ -1880,6 +1884,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		devRead->intrConf.modLevels[i] = adapter->intr.mod_levels[i];
 
 	devRead->intrConf.eventIntrIdx = adapter->intr.event_intr_idx;
+	devRead->intrConf.intrCtrl |= cpu_to_le32(VMXNET3_IC_DISABLE_ALL);
 
 	/* rx filter settings */
 	devRead->rxFilterConf.rxMode = 0;
