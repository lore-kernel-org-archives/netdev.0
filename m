From: <raghavendra.koushik@wipro.com>
Subject: RE: Submission for S2io 10GbE driver
Date: Wed, 25 Feb 2004 11:33:53 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4223A04BF7D1B941A25246ADD0462FF50115A824@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <raghavendra.koushik@s2io.com>,
        <ravinandan.arakali@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <jgarzik@pobox.com>, <leonid.grossman@s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,
	some questions on few of your comments.

>>30) do not call netif_stop_queue() and netif_wake_queue() on link 
>>events, in s2io_link.  Simply call netif_carrier_{on,off}.

When link goes down and I just call netif_carrier_off the upper layer
still continues to send packets to the s2io_xmit routine. In order to 
avoid this, I stop the queue and a corresponding wake when link returns.
Is there any particular reason why this should be avoided?

>>28) are you aware that all of s2io_tx_watchdog is inside the 
>>dev->tx_lock spinlock?  I am concern s2io_tx_watchdog execution time may
>>be quite excessive a duration to hold a spinlock.

Actually no. The intention is to reset the NIC and re-initialize it in the
tx_watchdog function and I'am not sure how else to do this.
Do you foresee a problem with the current method, because for most part of 
the function the queue would be in a stopped state (the netif_stop_queue is 
called right on top of s2io_close and the queue is woken up at almost
the end of s2io_open). 

>>29) never call netif_wake_queue() unconditionally.  only call it if you 
>>are 100% certain that the net stack is allowed to add another packet to 
>>your hardware's TX queue(s).

I wake the queue in txIntrHandler without checking anything because at this 
point I'am certain that some free transmit descriptors are available for 
new xmit. The tx Interrupt arrives only after one or more Tx descriptor and
buffer were successfully DMA'ed to the NIC and the ownership of these 
descriptor(s) is returned to the host.


Regards

Koushik



-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Tuesday, February 17, 2004 5:59 AM
To: Leonid Grossman
Cc: netdev@oss.sgi.com; raghavendra.koushik@s2io.com; 'ravinandan arakali'
Subject: Re: Submission for S2io 10GbE driver


Comments:

1) use ULL suffix on u64 constants.

static u64 round_robin_reg0 = 0x0001020304000105;
static u64 round_robin_reg1 = 0x0200030106000204;
static u64 round_robin_reg2 = 0x0103000502010007;
static u64 round_robin_reg3 = 0x0304010002060500;
static u64 round_robin_reg4 = 0x0103020400000000;

2) you'll want to (unfortunately) add #ifdefs around the PCI_xxx_ID 
constants, because a full submission to the kernel includes a patch to 
include/linux/pci_ids.h.

/* VENDOR and DEVICE ID of XENA. */
#define PCI_VENDOR_ID_S2IO      0x17D5
#define PCI_DEVICE_ID_S2IO_WIN  0x5731
#define PCI_DEVICE_ID_S2IO_UNI  0x5831

3) AS_A_MODULE is incorrect.

/* Load driver as a module */
#define AS_A_MODULE

First, it is defined unconditionally.  Second, it should not even exist. 
  The kernel module API is intentionally designed such that the source 
code functions whether a kernel module or built into vmlinux, without 
#ifdefs.  So, simply remove the ifdefs.

As a general rule, Linux kernel source code tries to be as free of 
ifdefs as possible.

4) You will of course need to change CONFIGURE_ETHTOOL_SUPPORT, 
CONFIGURE_NAPI_SUPPORT to Kconfig-generate CONFIG_xxx defines, when 
submitting.

5) again, follow the kernel's no-ifdef philosophy:

#ifdef KERN_26
static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs); #else void s2io_isr(int irq, void *dev_id, struct pt_regs *regs); #endif /** KERN_26 **/

The "irqreturn_t" type was designed specifically to work without #ifdefs 
in earlier kernels.  Here is the proper compatibility code, taken from 
release kernel 2.4.25's include/linux/interrupt.h:

	/* For 2.6.x compatibility */
	typedef void irqreturn_t;
	#define IRQ_NONE
	#define IRQ_HANDLED
	#define IRQ_RETVAL(x)

I hope you notice a key philosophy emerging ;-)  You want to write a 
no-ifdef driver for 2.6, and then use the C pre-processor, typedefs, and 
other tricks to make the driver work on earlier kernels with as little 
modification as possible.

Look at http://sf.net/projects/gkernel/  module "kcompat" for an example 
of a toolkit which allows you to write a current driver, and then use it 
on older kernels.

6) delete, not needed

#ifdef UNDEFINED
         suspend:NULL,
         resume:NULL,
#endif

7) memory leak on error
                 /*  Allocating all the Rx blocks */
                 for (j = 0; j < blk_cnt; j++) {
                         size = (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
                         tmp_v_addr = pci_alloc_consistent(nic->pdev, size,
                                                           &tmp_p_addr);
                         if (tmp_v_addr == NULL) {
                                 return -ENOMEM;
                         }
                         memset(tmp_v_addr, 0, size);

8) memory leak on error

/* Allocation and initialization of Statistics block */
         size = sizeof(StatInfo_t);
         mac_control->stats_mem = pci_alloc_consistent
             (nic->pdev, size, &mac_control->stats_mem_phy);

         if (!mac_control->stats_mem) {
                 return -ENOMEM;
         }

9) if you store a pointer for your shared memory, it is wasteful to 
store an -additional- flag indicating this memory has been allocated. 
simply check for NULL.

         if (nic->_fResource & TXD_ALLOCED) {
                 nic->_fResource &= ~TXD_ALLOCED;
                 pci_free_consistent(nic->pdev,
                                     mac_control->txd_list_mem_sz,

10) ULL suffix

         write64(&bar0->swapper_ctrl, 0xffffffffffffffff);
         val64 = (SWAPPER_CTRL_PIF_R_FE |

11) ditto this for other 64-bit constants

12) never mdelay() for this long.  Either create a timer, or make sure 
you're in process constant and sleep via schedule_timeout().

/* Remove XGXS from reset state*/
         val64 = 0;
         write64(&bar0->sw_reset, val64);
         mdelay(500);

13) memory writes without memory reads following them are often the 
victims of PCI write posting bugs.  At the very least, this driver 
appears to have many PCI write posting issues.

         write64(&bar0->dtx_control, 0x8000051500000000);
         udelay(50);
         write64(&bar0->dtx_control, 0x80000515000000E0);
         udelay(50);
         write64(&bar0->dtx_control, 0x80000515D93500E4);
         udelay(50);

         write64(&bar0->dtx_control, 0x8001051500000000);
         udelay(50);
         write64(&bar0->dtx_control, 0x80010515000000E0);
         udelay(50);
         write64(&bar0->dtx_control, 0x80010515001E00E4);
         udelay(50);

You are not guaranteed that the write will have completed, by the end of 
each udelay(), unless you first issue a PCI read of some sort.

14) another mdelay(500) loop to be fixed

/*  Wait for the operation to complete */
         time = 0;
         while (TRUE) {
                 val64 = read64(&bar0->rti_command_mem);
                 if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {
                         break;
                 }
                 if (time > 50) {
                         DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
                                   dev->name);
                         return -1;
                 }
                 time++;
                 mdelay(10);

15) you obviously mean TASK_UNINTERRUPTIBLE here:

/* Enabling MC-RLDRAM */
         val64 = read64(&bar0->mc_rldram_mrs);
         val64 |= MC_RLDRAM_QUEUE_SIZE_ENABLE | MC_RLDRAM_MRS_ENABLE;
         write64(&bar0->mc_rldram_mrs, val64);
         set_current_state(TASK_INTERRUPTIBLE);
         schedule_timeout(HZ / 10);

16) get this from struct pci_dev, not directly from the PCI bus:

         /* SXE-002: Initialize link and activity LED */
         ret =
             pci_read_config_word(nic->pdev, PCI_SUBSYSTEM_ID,
                                  (u16 *) & subid);

17) question: do you not support more advanced checksum offload?  like 
ipv6 or "hey I put the packet checksum <here>"

18) waitForCmdComplete can mdelay() an unacceptably long time

19) ditto s2io_reset.

20) your driver has its spinlocks backwards!  Your interrupt handler 
uses spin_lock_irqsave(), and your non-interrupt handling code uses 
spin_lock().  That's backwards from correct.

21) s2io_close could mdelay() for unacceptably long time.  Fortunately, 
you -can- sleep here, so just replace with schedule_timeout() calls.

22) remove the commented-out MOD_{INC,DEC}_USE_COUNT.

23) your tx_lock spinlock is completely unused.  oops.  :)  the spinlock 
covers two areas of code, both of which are mutually exclusive.

Given this and #20... you might want to make sure to build and test on 
SMP.  Even SMP kernels on uniprocessor hardware helps find spinlock 
deadlocks.

24) your tx_lock does not cover the interrupt handler code.  I presume 
this is an oversight?

25) delete s2io_set_mac_addr.  It's not needed.  It is preferred to use 
the default eth_mac_addr.  Follow this procedure, usually:

	a) During probe, obtain MAC address from "original source",
	usually EEPROM / SROM.
	b) Each time dev->open() is called, write MAC address to h/w.

26) check and make sure you initialize your link to off 
(netif_carrier_off(dev)), in your dev->open() function.  In the 
background, your phy state machine should call netif_carrier_on() once 
it is certain link has been established.

this _must_ be an asynchronous process.  You may not sleep and wait for 
link, in dev->open().

27) for current 2.4 and 2.6 kernels, please use struct ethtool_ops 
rather than a large C switch statement.

28) are you aware that all of s2io_tx_watchdog is inside the 
dev->tx_lock spinlock?  I am concern s2io_tx_watchdog execution time may
be quite excessive a duration to hold a spinlock.

29) never call netif_wake_queue() unconditionally.  only call it if you 
are 100% certain that the net stack is allowed to add another packet to 
your hardware's TX queue(s).

30) do not call netif_stop_queue() and netif_wake_queue() on link 
events, in s2io_link.  Simply call netif_carrier_{on,off}.

31) ULL suffix

         } else if (!pci_set_dma_mask(pdev, 0xffffffff)) {

32) missing call to pci_disable_device() on error:

                 if (pci_set_consistent_dma_mask
                     (pdev, 0xffffffffffffffffULL)) {
                         DBG_PRINT(ERR_DBG,
                                   "Unable to obtain 64bit DMA for \
                                         consistent allocations\n");
                         return -ENOMEM;

33) if you use CHECKSUM_UNNECESSARY, you should be using the 
less-capable NETIF_F_IP_CSUM.

         dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;

NETIF_F_HW_CSUM requires the actual checksum value.
