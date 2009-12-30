From: "Benjamin Li" <benli@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 29 Dec 2009 21:08:11 -0800
Message-ID: <1262149691.2788.63.camel@localhost>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-62Fv3BkCFDvAB1BtGXCz"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751604AbZL3FIS@vger.kernel.org>
In-Reply-To: <20091229145403.39f82773@pluto.restena.lu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-62Fv3BkCFDvAB1BtGXCz
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 8bit

Hi Bruno.

Could you try running with the attached patch?  This debug patch is
built against the linux-2.6.31.9 kernel.  I think the panic is occuring
right before a reset has occured due to a TX timeout.  To see if this is
happening, this patch will print hardware state information when a TX
timeout occurs.  If you could run with this patch and send the logs when
the panic occurs, I would really appreciate it.

Thanks again.

-Ben

On Tue, 2009-12-29 at 05:54 -0800, Bruno Prémont wrote:
> On Tue, 29 Dec 2009 01:05:40 "Benjamin Li" <benli@broadcom.com> wrote:
> > Hi Bruno,
> > 
> > It looks like the the NULL dereference is happening at a0fc.
> > 
> > a0f8:       48 8b 42 70             mov 0x70(%rdx),%rax 
> > a0fc:       0f b7 10                movzwl (%rax),%edx
> > a0ff:       31 c0                   xor    %eax,%eax
> > 
> > The offset of 0x70 is the bp field in the bnx2_napi structure.  (Seen
> > in the bnx2_napi structure dump below)  These lines are found in the
> > routine, bnx2_get_hw_tx_cons() which look like they were inlined by
> > the compiler.  More specifically it looks like the dereference of the
> > hw_tx_cons_ptr failed.
> > 
> > cons = *bnapi->hw_tx_cons_ptr;
> > 
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=drivers/net/bnx2.c;h=06b901152d4487fa04164437cc179661b44657fe;hb=74fca6a42863ffacaf7ba6f1936a9f228950f657#l2761
> > 
> > To be sure this is the case, could you send the .config file you are
> > using or if you could send me the bnx2 kernel module built with the
> > CFLAG '-g', then we can definitely verify where in the code it is
> > crashing.
> > 
> > Did you see anything suspicious in the system kernel logs?  If you
> > could isolate the logs from when the machine booted to when it crash
> > and send it to us it would be very helpful. 
> 
> It crashes every now and then (since netconsole is enabled it does not
> survive 24 hours :( ) while or just after transmitting log messages with
> netconsole, the messages being transmitted are logging that occurs with
> netfilter 'LOG' target.
> 
> Sample output as seen by netconsole recipient (1 packet per line, IP
> addresses masked):
> 
> [ 2115.949606] (reject)output: IN= OUT=eth0
> SRC=***.**.*.** DST=**.***.**.***
> LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=29589
> DF
> PROTO=TCP
> SPT=58991 DPT=80
> WINDOW=5840
> RES=0x00
> SYN
> URGP=0
> 
> [ 2115.949704] (reject)output: IN= OUT=eth0
> SRC=***.**.*.** DST=**.***.**.***
> [ 2115.949729] BUG: unable to handle kernel NULL pointer dereference at (null)
> [ 2115.949732] IP: [<ffffffffa00680fc>] bnx2_poll_work+0x2c/0x12d0 [bnx2]
> [ 2115.949742] PGD 5b6f0067 PUD 59c04067 PMD 0
> [ 2115.949744] Oops: 0000 [#1] SMP
> [ 2115.949746] last sysfs file: /sys/kernel/uevent_seqnum
> [ 2115.949749] CPU 3
> [ 2115.949750] Modules linked in: dm_round_robin scsi_dh_rdac ipmi_devintf netconsole squashfs configfs zlib_inflate ext2 loop dm_multipath scsi_dh dm_mod sg sr_mod cdrom ata_piix h
> pwdt qla2xxx ipmi_si ahci bnx2 ipmi_msghandler libata uhci_hcd ehci_hcd
> [ 2115.949764] Pid: 7926, comm: php-cgi Not tainted 2.6.31.9-x86_64 #1 ProLiant DL360 G5
> [ 2115.949766] RIP: 0010:[<ffffffffa00680fc>]  [<ffffffffa00680fc>] bnx2_poll_work+0x2c/0x12d0 [bnx2]
> 
> Looks like netpoll is triggering suicide on BNX2.
> 
> Any way to get the NULL-pointer non-fatal would help a lot! (any
> sensible thing to do when bnapi->hw_tx_cons_ptr is NULL that would
> allow the system to continue working without killing everything?)
> 
> 
> Regards,
> Bruno
> 

--=-62Fv3BkCFDvAB1BtGXCz
Content-Disposition: attachment;
 filename=bnx2_ftq_state_dump.diff
Content-Type: text/plain;
 charset=us-ascii;
 name=bnx2_ftq_state_dump.diff
Content-Transfer-Encoding: 7bit

diff --git a/linux-2.6.31.9/drivers/net/bnx2.c b/linux-2.6.31.9/drivers/net/bnx2.c
index 06b9011..140bd48 100644
--- a/linux-2.6.31.9/drivers/net/bnx2.c
+++ b/linux-2.6.31.9/drivers/net/bnx2.c
@@ -6239,11 +6239,111 @@ bnx2_reset_task(struct work_struct *work)
 	bnx2_netif_start(bp);
 }
 
+
+static void bnx2_dump_ftq(struct bnx2 *bp)
+{
+	printk(KERN_ERR PFX "<--- start FTQ dump on %s --->\n", bp->dev->name);
+	printk(KERN_ERR PFX "%s: BNX2_RV2P_PFTQ_CTL %x\n", bp->dev->name,
+	       REG_RD(bp, BNX2_RV2P_PFTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_RV2P_TFTQ_CTL %x\n", bp->dev->name,
+	       REG_RD(bp, BNX2_RV2P_TFTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_RV2P_MFTQ_CTL %x\n", bp->dev->name,
+	       REG_RD(bp, BNX2_RV2P_MFTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_TBDR_FTQ_CTL %x\n", bp->dev->name,
+	       REG_RD(bp, BNX2_TBDR_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_TDMA_FTQ_CTL %x\n", bp->dev->name,
+	       REG_RD(bp, BNX2_TDMA_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_TXP_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_TPAT_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_RXP_CFTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CFTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_RXP_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_COM_COMXQ_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_COM_COMXQ_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_COM_COMTQ_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_COM_COMTQ_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_COM_COMQ_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_COM_COMQ_FTQ_CTL));
+	printk(KERN_ERR PFX "%s: BNX2_CP_CPQ_FTQ_CTL %x\n", bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPQ_FTQ_CTL));
+	printk(KERN_ERR PFX
+	       "%s: TXP mode %x state %x evt_mask %x pc %x pc %x instr %x\n",
+	       bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_CPU_MODE),
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_CPU_STATE),
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_CPU_EVENT_MASK),
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_TXP_CPU_INSTRUCTION));
+	printk(KERN_ERR PFX
+	       "%s: TPAT mode %x state %x evt_mask %x pc %x pc %x instr %x\n",
+	       bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_CPU_MODE),
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_CPU_STATE),
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_CPU_EVENT_MASK),
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_TPAT_CPU_INSTRUCTION));
+	printk(KERN_ERR PFX
+	       "%s: RXP mode %x state %x evt_mask %x pc %x pc %x instr %x\n",
+	       bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CPU_MODE),
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CPU_STATE),
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CPU_EVENT_MASK),
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_RXP_CPU_INSTRUCTION));
+	printk(KERN_ERR PFX
+	       "%s: COM mode %x state %x evt_mask %x pc %x pc %x instr %x\n",
+	       bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_COM_CPU_MODE),
+	       bnx2_reg_rd_ind(bp, BNX2_COM_CPU_STATE),
+	       bnx2_reg_rd_ind(bp, BNX2_COM_CPU_EVENT_MASK),
+	       bnx2_reg_rd_ind(bp, BNX2_COM_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_COM_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_COM_CPU_INSTRUCTION));
+	printk(KERN_ERR PFX
+	       "%s: CP mode %x state %x evt_mask %x pc %x pc %x instr %x\n",
+	       bp->dev->name,
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPU_MODE),
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPU_STATE),
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPU_EVENT_MASK),
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPU_PROGRAM_COUNTER),
+	       bnx2_reg_rd_ind(bp, BNX2_CP_CPU_INSTRUCTION));
+	printk(KERN_ERR PFX "<--- end FTQ dump on %s --->\n", bp->dev->name);
+}
+
+static void
+bnx2_dump_state(struct bnx2 *bp)
+{
+	printk(KERN_ERR PFX "DEBUG: intr_sem[%x]\n", 
+		atomic_read(&bp->intr_sem));
+	printk(KERN_ERR PFX "DEBUG: EMAC_TX_STATUS[%08x] RPM_MGMT_PKT_CTRL[%08x]\n",
+		REG_RD(bp, BNX2_EMAC_TX_STATUS),
+		REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
+	printk(KERN_ERR PFX "DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
+		bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P0),
+		bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P1));
+	printk(KERN_ERR PFX "DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
+		REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
+	if (bp->flags & BNX2_FLAG_USING_MSIX)
+		printk(KERN_ERR PFX "DEBUG: PBA[%08x]\n",
+			REG_RD(bp, BNX2_PCI_GRC_WINDOW3_BASE));
+}
+
+
 static void
 bnx2_tx_timeout(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
+	bnx2_dump_ftq(bp);
+	bnx2_dump_state(bp);
+
 	/* This allows the netif to be shutdown gracefully before resetting */
 	schedule_work(&bp->reset_task);
 }
diff --git a/linux-2.6.31.9/drivers/net/bnx2.h b/linux-2.6.31.9/drivers/net/bnx2.h
index a4f12fd..0ec9df2 100644
--- a/linux-2.6.31.9/drivers/net/bnx2.h
+++ b/linux-2.6.31.9/drivers/net/bnx2.h
@@ -6342,6 +6342,8 @@ struct l2_fhdr {
 
 #define BNX2_MCP_ROM					0x00150000
 #define BNX2_MCP_SCRATCH				0x00160000
+#define BNX2_MCP_STATE_P1				0x0016f9c8
+#define BNX2_MCP_STATE_P0				0x0016fdc
 
 #define BNX2_SHM_HDR_SIGNATURE				BNX2_MCP_SCRATCH
 #define BNX2_SHM_HDR_SIGNATURE_SIG_MASK			 0xffff0000

--=-62Fv3BkCFDvAB1BtGXCz--
