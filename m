From: "Benjamin Li" <benli@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Fri, 19 Feb 2010 11:57:06 -0800
Message-ID: <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
 <1262149691.2788.63.camel@localhost>
 <20100219091034.5fbb0165@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-XGRma+xSadb8Oj3qWR4i"
Cc: NetDEV <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100219091034.5fbb0165@pluto.restena.lu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XGRma+xSadb8Oj3qWR4i
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 8bit

Hi Bruno,

No problems.  Thanks for following up with this problem, I really
appreciate all your help.

>From your logs it looks like the device came up using MSI, but in the
MSI-X poll routine was being called:

[    9.836673] bnx2: eth0: using MSI
...

[  134.643459]  [<ffffffffa004019e>] bnx2_poll_msix+0x3e/0xd0 [bnx2]
[  134.643465]  [<ffffffff8135bcd1>] netpoll_poll+0xe1/0x3c0

which is incorrect.  If we are in MSI mode, the bnx2_poll() routine
should be used.

I think what is going on here is that during the bnx2x driver
initialization the current bnx2 driver adds all possible NAPI structures
that map to all the hardware vectors (BNX2_MAX_MSIX_VEC=9) to the NAPI
list in the net_device structure regardless if they are used or not
(Seen in drivers/net/bnx2.c:bnx2_init_napi()).  This can cause
uninitialized NAPI structures to be placed on the napi_list.  Because
this device is in MSI mode, only 1 vector is initialized.   Now, the
problem is triggered when net/core/netpoll.c:poll_napi() is called.
This is because this routine will run through the entire napi_list
calling all the poll routines.  In your particular case, it is calling
the poll routine on an uninitialized vector causing the kernel panic.

Please try the patch below to see if it solves your problem.  Note, this
only have been compile tested and tested against basic traffic runs.
Unfortunately, I could not reproduce the kernel panic with the
instructions below to verify the patch.

Thanks again for all your help in helping us track this down.

-Ben

On Fri, 2010-02-19 at 00:10 -0800, Bruno Prémont wrote:
> Hi Benjamin,
> 
> On Tue, 29 Dec 2009 21:08:11 "Benjamin Li" wrote:
> > Could you try running with the attached patch?  This debug patch is
> > built against the linux-2.6.31.9 kernel.  I think the panic is
> > occuring right before a reset has occured due to a TX timeout.  To
> > see if this is happening, this patch will print hardware state
> > information when a TX timeout occurs.  If you could run with this
> > patch and send the logs when the panic occurs, I would really
> > appreciate it.
> > 
> > Thanks again.
> > 
> > -Ben
> 
> Sorry for replying only this late but I've been too busy with other
> things.
> 
> Anyhow, I've been doing some more testing yesterday and today and now
> am able to reproduce the/a crash pretty easily.
> 
> Either running netconsole and doing 'echo t > /proc/sysrq-trigger' via
> SSH on otherwise idle server (from local console nothing bad happens),
> but then I have no means to communicate with the kernel (I guess it's
> deadlocked somewhere in printk code)
> 
> The slightly less easy way to trigger it is with a dummy module that
> kind of simulates netconsole behavior but with dummy data (see
> attached). I have to have some more traffic (TCP?) going on for the bug
> to trigger and tell my module multiple times to push data. This way
> server is still accessible via VGA or serial console.
> 
> Attached are my 'netbomb.c' (which is a modified netconsole.c) and
> full kernel log. This time running a 2.6.33-rc8-git3 kernel, having
> forward-ported your patch above (e.g. half of it was already present)
> 
> 
> I this time I got the following trace:
> [  134.643292] BUG: unable to handle kernel NULL pointer dereference at (null)
> [  134.643304] IP: [<ffffffffa003edc2>] bnx2_poll_work+0x32/0x13d0 [bnx2]
> [  134.643314] PGD 2a972a067 PUD 2aa245067 PMD 0
> [  134.643319] Oops: 0000 [#1] SMP
> [  134.643323] last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:04.6/class
> [  134.643328] CPU 4
> [  134.643334] Pid: 3226, comm: cat Not tainted 2.6.33-rc8-git3-x86_64 #3 /ProLiant DL360 G5
> [  134.643339] RIP: 0010:[<ffffffffa003edc2>]  [<ffffffffa003edc2>] bnx2_poll_work+0x32/0x13d0 [bnx2]
> [  134.643347] RSP: 0018:ffff8802a9643b38  EFLAGS: 00010092
> [  134.643351] RAX: 0000000000000000 RBX: ffff8802afab57c0 RCX: 0000000000000010
> [  134.643355] RDX: 0000000000000000 RSI: ffff8802afab57c0 RDI: ffff8802afab4580
> [  134.643359] RBP: ffff8802a9643cd8 R08: ffff8802af051000 R09: 0000000000000007
> [  134.643363] R10: 000000000000000e R11: 0000000000000000 R12: 0000000000000000
> [  134.643367] R13: 0000000000000010 R14: 0000000000000000 R15: ffff8802afab4580
> [  134.643371] FS:  0000000000000000(0000) GS:ffff880028300000(0063) knlGS:00000000f765f6c0
> [  134.643376] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> [  134.643380] CR2: 0000000000000000 CR3: 00000002a9606000 CR4: 00000000000006e0
> [  134.643384] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  134.643388] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  134.643392] Process cat (pid: 3226, threadinfo ffff8802a9642000, task ffff8802aa14bff0)
> [  134.643396] Stack:
> [  134.643398]  0000000000000070 0000000000000002 0000000000000010 ffff8802afab57c0
> [  134.643404] <0> ffff8802afab4580 0000000300000002 0000000000000000 0000000100000002
> [  134.643410] <0> 0000000000000000 0000000200025220 ffffffff81862e80 0000000000000001
> [  134.643418] Call Trace:
> [  134.643427]  [<ffffffff8107e3fe>] ? __alloc_pages_nodemask+0xfe/0x660
> [  134.643433]  [<ffffffff811b6de6>] ? msi_set_mask_bit+0x26/0xc0
> [  134.643438]  [<ffffffff811b6e8b>] ? unmask_msi_irq+0xb/0x10
> [  134.643443]  [<ffffffff8106db54>] ? default_enable+0x24/0x40
> [  134.643448]  [<ffffffff8106d9b6>] ? check_irq_resend+0x26/0x70
> [  134.643453]  [<ffffffff8106cc23>] ? __enable_irq+0x73/0x80
> [  134.643459]  [<ffffffffa004019e>] bnx2_poll_msix+0x3e/0xd0 [bnx2]
> [  134.643465]  [<ffffffff8135bcd1>] netpoll_poll+0xe1/0x3c0
> [  134.643470]  [<ffffffff8135c168>] netpoll_send_skb+0x118/0x210
> [  134.643475]  [<ffffffff8135c45b>] netpoll_send_udp+0x1fb/0x210
> [  134.643480]  [<ffffffffa00981c5>] write_msg+0x95/0xd0 [netbomb]
> [  134.643485]  [<ffffffffa0098255>] netbomb_write+0x55/0xa4 [netbomb]
> [  134.643492]  [<ffffffff810f6581>] proc_reg_write+0x71/0xb0
> [  134.643498]  [<ffffffff810ab6cb>] vfs_write+0xcb/0x180
> [  134.643503]  [<ffffffff810ab870>] sys_write+0x50/0x90
> [  134.643509]  [<ffffffff8102a1a4>] sysenter_dispatch+0x7/0x2b
> [  134.643513] Code: 56 41 55 41 54 53 48 81 ec 78 01 00 00 48 89 bd 80 fe ff ff 48 89 b5 78 fe ff ff 89 95 74 fe ff ff 89 8d 70 fe ff ff 48 8b 46 70 <0f> b7 10 31 c0 80 fa ff 0f 94 c0 01 c2 66 39 96 12 02 00 00 0f
> [  134.643551] RIP  [<ffffffffa003edc2>] bnx2_poll_work+0x32/0x13d0 [bnx2]
> [  134.643557]  RSP <ffff8802a9643b38>
> [  134.643559] CR2: 0000000000000000
> [  134.643563] ---[ end trace 48bdec67d6d7aadb ]---
> 
> Running objdump on kernel compile with debugging symbols this matches:
> 000000000000ad90 <bnx2_poll_work>:
>         }
> }
> 
> static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
>                           int work_done, int budget)
> {
>     ad90:       55                      push   %rbp
>     ad91:       48 89 e5                mov    %rsp,%rbp
>     ad94:       41 57                   push   %r15
>     ad96:       41 56                   push   %r14
>     ad98:       41 55                   push   %r13
>     ad9a:       41 54                   push   %r12
>     ad9c:       53                      push   %rbx
>     ad9d:       48 81 ec 78 01 00 00    sub    $0x178,%rsp
>     ada4:       48 89 bd 80 fe ff ff    mov    %rdi,-0x180(%rbp)
>     adab:       48 89 b5 78 fe ff ff    mov    %rsi,-0x188(%rbp)
>     adb2:       89 95 74 fe ff ff       mov    %edx,-0x18c(%rbp)
>     adb8:       89 8d 70 fe ff ff       mov    %ecx,-0x190(%rbp)
> {
>         u16 cons;
> 
>         /* Tell compiler that status block fields can change. */
>         barrier();
>         cons = *bnapi->hw_tx_cons_ptr;
>     adbe:       48 8b 46 70             mov    0x70(%rsi),%rax
>     adc2:       0f b7 10                movzwl (%rax),%edx
>         barrier();
>         if (unlikely((cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT))
>                 cons++;
>     adc5:       31 c0                   xor    %eax,%eax
>     adc7:       80 fa ff                cmp    $0xff,%dl
>     adca:       0f 94 c0                sete   %al
>     adcd:       01 c2                   add    %eax,%edx
>                           int work_done, int budget)
> {
>         struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
>         struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
> 
>         if (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons)
>     adcf:       66 39 96 12 02 00 00    cmp    %dx,0x212(%rsi)
>     add6:       0f 84 4f 03 00 00       je     b12b <bnx2_poll_work+0x39b>
> 
> 
> So as already determined bnapi->hw_tx_cons_ptr is NULL... but nothing is
> happening after that on network side.
> 
> Regards,
> Bruno

--=-XGRma+xSadb8Oj3qWR4i
Content-Disposition: attachment;
 filename=bnx2_add_only_used_vectors.c
Content-Type: text/plain;
 charset=us-ascii;
 name=bnx2_add_only_used_vectors.c
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 65df1de..89aa211 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -247,6 +247,8 @@ static const struct flash_spec flash_5709 = {
 
 MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
+static void bnx2_init_napi(struct bnx2 *bp);
+
 static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
 	u32 diff;
@@ -6210,6 +6212,7 @@ bnx2_open(struct net_device *dev)
 	bnx2_disable_int(bp);
 
 	bnx2_setup_int_mode(bp, disable_msi);
+	bnx2_init_napi(bp);
 	bnx2_napi_enable(bp);
 	rc = bnx2_alloc_mem(bp);
 	if (rc)
@@ -8201,7 +8204,7 @@ bnx2_init_napi(struct bnx2 *bp)
 {
 	int i;
 
-	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
+	for (i = 0; i < bp->irq_nvecs; i++) {
 		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
 		int (*poll)(struct napi_struct *, int);
 
@@ -8270,7 +8273,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->ethtool_ops = &bnx2_ethtool_ops;
 
 	bp = netdev_priv(dev);
-	bnx2_init_napi(bp);
 
 	pci_set_drvdata(pdev, dev);
 

--=-XGRma+xSadb8Oj3qWR4i--
