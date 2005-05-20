From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 15:42:20 -0400
Message-ID: <20050520194220.GA18259@havoc.gtf.org>
References: <1116609329.31523.16.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1116609329.31523.16.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 20, 2005 at 10:15:29AM -0700, Michael Chan wrote:
> A new driver bnx2 for Broadcom bcm5706 is available. Since the patch is
> over 500K, I've put it on the ftp server:
> 
> ftp://Net_sys_anon@ftp1.broadcom.com/bnx2-2.patch
> 
> The patch also includes new 1000BASE-X advertisement bit definitions in
> mii.h


Here's my in-depth review:


0) Please use 'jgarzik@pobox.com' for open source stuff, and
'jgarzik@redhat.com' only for private Red Hat (NDA'd) stuff.  I know all
these email addresses can be confusing; I apologize.


1) [style] don't use braces, when a single statement follows an 'if',
'for', etc.

+               bp->duplex = DUPLEX_FULL;
+       }
+       else {
+               bp->duplex = DUPLEX_HALF;
+       }
+
+       if (!(bmcr & BMCR_ANENABLE)) {
+               return 0;
+       }

[several areas of code need this]


2) bnx2_read_phy() returns a value, but the code quite often ignores its
return value.


3) ditto for bnx2_write_phy()


4) ditto for bnx2_reset_phy()


5) ditto for bnx2_init_phy()


6) too many magic numbers in phy init.  Please define constants for the
BCM-specific phy registers, and register bits, where reasonable.

+       if (bp->dev->mtu > 1500) {
+               u32 val;
+
+               /* Set extended packet length bit */
+               bnx2_write_phy(bp, 0x18, 0x7);
+               bnx2_read_phy(bp, 0x18, &val);
+               bnx2_write_phy(bp, 0x18, (val & 0xfff8) | 0x4000);
+
+               bnx2_write_phy(bp, 0x1c, 0x6c00);
+               bnx2_read_phy(bp, 0x1c, &val);
+               bnx2_write_phy(bp, 0x1c, (val & 0x3ff) | 0xec02);
+       }
+       else {
+               u32 val;
+
+               bnx2_write_phy(bp, 0x18, 0x7);
+               bnx2_read_phy(bp, 0x18, &val);
+               bnx2_write_phy(bp, 0x18, val & ~0x4007);
+
+               bnx2_write_phy(bp, 0x1c, 0x6c00);
+               bnx2_read_phy(bp, 0x1c, &val);
+               bnx2_write_phy(bp, 0x1c, (val & 0x3fd) | 0xec00);
+       }


7) the delays in bnx2_fw_sync(), bnx2_reset_chip() and bnx2_init_chip()
might work better as sleeps, rather than udelay, since you are always
in process context, and its not a performance critical path.

As a general rule for all driver programming, msleep() is preferred over
udelay() / mdelay().  udelay() spins, while msleep() allows other
[possibly high priority real-time] processes to continue.

Note that tg3 needs fixing for this too, but nobody has been motivated
enough to care.


8) excessive stack size in bnx2_alloc_bad_rbuf():

+       u16 good_mbuf[512];

a 1024-byte object is simply unacceptable, given that that is fully 1/4
of a 4K stack, for users that use the 4K stack option.

Typical solution is kmalloc'ing a temporary buffer.


9) [additional review]  DaveM, others: is this correct for all arches?

+       if (unlikely((align = (unsigned long) skb->data & 0x7))) {
+               skb_reserve(skb, 8 - align);
+       }


10) [additional review] doesn't bnx2_rx_int() need to move the rmb()
inside the loop?  Are you protecting against the compiler
reordering/caching loads/stores, or against SMP CPUs?


10.1) [additional review] is the rmb() even needed in bnx2_rx_int(),
since its caller also uses rmb()?


11) Don't use IRQ_RETVAL(1), use IRQ_NONE / IRQ_HANDLED for the constant
cases.


12) use a named constant rather than magic number (aka numeric constant):

+               if ((len > (bp->dev->mtu + ETH_HLEN)) &&
+                       (htons(skb->protocol) != 0x8100)) {


13) [additional review] why is CHECKSUM_UNNECESSARY used when
cksum==0xffff or cksum==0 ?

+                       u16 cksum = rx_hdr->l2_fhdr_tcp_udp_xsum;
+
+                       if ((cksum == 0xffff) || (cksum == 0)) {
+                               skb->ip_summed = CHECKSUM_UNNECESSARY;
+                       }


14) is D0 guaranteed after 50 usec?

+               /* No more memory access after this point until
+                * device is brought back to D0.
+                */
+               udelay(50);
+               break;


15) the following loop is just silly.  use mdelay or (preferably)
msleep.

+       if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
+           (CHIP_ID(bp) == CHIP_ID_5706_A1)) {
+
+               for (i = 0; i < 500; i++) {
+                       udelay(30);
+               }
+       }


16) [long term; grunt work] it would be nice if somebody would submit
patches to ethtool, for verbose register dump of bnx2 and tg3


17) you may prefer msleep_interruptible() ?

+       for (i = 0; i < 10; i++) {
+               if ((REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD) & 0xffff) !=
+                       status_idx) {
+
+                       break;
+               }
+
+               current->state = TASK_INTERRUPTIBLE;
+               schedule_timeout(1);
+       }



18) you can eliminate one call to request_irq, by lengthening the 'if' test:

+       if ((CHIP_ID(bp) != CHIP_ID_5706_A0) &&
+               (CHIP_ID(bp) != CHIP_ID_5706_A1) &&
+               !disable_msi) {
+
+               if (pci_enable_msi(bp->pdev) == 0) {
+                       bp->flags |= USING_MSI_FLAG;
+                       rc = request_irq(bp->pdev->irq, bnx2_msi, 0, dev->name,
+                                       dev);
+               }
+               else {
+                       rc = request_irq(bp->pdev->irq, bnx2_interrupt,
+                                       SA_SHIRQ, dev->name, dev);
+               }
+       }
+       else {
+               rc = request_irq(bp->pdev->irq, bnx2_interrupt, SA_SHIRQ,
+                               dev->name, dev);
+       }



19) [additional review] need flush_scheduled_work(), if using work queues?


20) is there any reason to #ifdef BCM_TSO?  2.4.x kernels I suppose?


21) need to call bnx2_netif_stop() in bnx2_close()


22) [namespace] s/ETH_NUM_STATS/BNX2_NUM_STATS/


23) use msleep_interruptible() in bnx2_phys_id()

+               current->state = TASK_INTERRUPTIBLE;
+               schedule_timeout(HZ / 2);
+               if (signal_pending(current))
+                       break;


24) consider using pci_enable_msi() in bnx2_init_board(), rather than
the request_irq() callsite.


25) don't assign dev->mem_{start,end}, it's pointless.  Some drivers
use it to pass _information_ these days, even.


26) Note that some PCI buses have speeds other than what is listed
in bnx2_init_board().  Some weirdo platforms even vary the PCI bus
speed (which is legal).


27) isn't 'timer_interval == HZ' too rapid a timer?  Does it really need
to fire every second?


28) use SET_ETHTOOL_OPS(), if you are backporting to 2.4.x as item #20
indicates.


29) do not use NETIF_F_SG independent of NETIF_F_xx_CSUM.

+       dev->features |= NETIF_F_SG;
+       if (bp->flags & USING_DAC_FLAG)
+               dev->features |= NETIF_F_HIGHDMA;
+       dev->features |= NETIF_F_IP_CSUM;


30) as David mentioned in a previous email, mark everything 'static':

+int COM_b06FwReleaseMajor = 0x0;
+int COM_b06FwReleaseMinor = 0x0;
+int COM_b06FwReleaseFix = 0x0;
+u32 COM_b06FwStartAddr = 0x080004a0;
+u32 COM_b06FwTextAddr = 0x08000000;
+int COM_b06FwTextLen = 0x4594;
+u32 COM_b06FwDataAddr = 0x080045e0;
+int COM_b06FwDataLen = 0x0;
+u32 COM_b06FwRodataAddr = 0x08004598;
+int COM_b06FwRodataLen = 0x18;
+u32 COM_b06FwBssAddr = 0x08004600;
+int COM_b06FwBssLen = 0x88;
+u32 COM_b06FwSbssAddr = 0x080045e0;
+int COM_b06FwSbssLen = 0x1c;
+u32 COM_b06FwText[(0x4594/4) + 1] = {


31) use arrays, as requested in a previous email:

+       u16 status_tx_quick_consumer_index0;
+       u16 status_tx_quick_consumer_index1;
+       u16 status_tx_quick_consumer_index2;
+       u16 status_tx_quick_consumer_index3;
+       u16 status_rx_quick_consumer_index0;
+       u16 status_rx_quick_consumer_index1;
+       u16 status_rx_quick_consumer_index2;
+       u16 status_rx_quick_consumer_index3;
+       u16 status_rx_quick_consumer_index4;
+       u16 status_rx_quick_consumer_index5;
+       u16 status_rx_quick_consumer_index6;
+       u16 status_rx_quick_consumer_index7;
+       u16 status_rx_quick_consumer_index8;
+       u16 status_rx_quick_consumer_index9;
+       u16 status_rx_quick_consumer_index10;
+       u16 status_rx_quick_consumer_index11;
+       u16 status_rx_quick_consumer_index12;
+       u16 status_rx_quick_consumer_index13;
+       u16 status_rx_quick_consumer_index14;
+       u16 status_rx_quick_consumer_index15;


32) [speling] s/fileds/fields/

 /* End of fileds used in the performance code paths. */


33) [ack]  I ACK the changes to linux/mii.h [I am the maintainer]
