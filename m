From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission #3  for S2io 10GbE driver
Date: Sat, 28 Feb 2004 15:21:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4040F866.9040200@pobox.com>
References: <000001c3fe0c$af99c9e0$0300a8c0@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <000001c3fe0c$af99c9e0$0300a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Looking a lot better.  A few merge issues remain, and some operational 
ones as well.  There are 39 issues in this review, but IMO they are 
mostly minor issues that don't require much thought or work.


Comments:

0) to repeat myself from an earlier review...  grumble...
You CANNOT use NETIF_F_HW_CSUM, when your hardware does not provide the 
checksum value.  You must use NETIF_F_IP_CSUM.  Your use of 
NETIF_F_HW_CSUM + CHECKSUM_UNNECESSARY is flat out incorrect.

1) the makefile is for out-of-tree stuff.  The proper makefile will be 
much smaller.  So just submit a proper in-tree Makefile.

2) (in general) we don't want the compatibility stuff in-tree, that's 
for out-of-tree as well.

3) just submit a patch to include/linux/pci_ids.h instead of the following

+/* VENDOR and DEVICE ID of XENA. */
+#ifndef PCI_VENDOR_ID_S2IO
+#define PCI_VENDOR_ID_S2IO      0x17D5
+#define PCI_DEVICE_ID_S2IO_WIN  0x5731
+#define PCI_DEVICE_ID_S2IO_UNI  0x5831
+#endif

4) just delete the SET_NETDEV_DEV(), FREE_NETDEV, and IRQ_NONE 
compatibility defines.  these are in 2.4 just like 2.6.

5) Many PCI posting bugs remain.  FixMacAddress is an excellent 
illustration:

+       write64(&bar0->gpio_control, 0x0040600000000000ULL);
+       udelay(10);
+       write64(&bar0->gpio_control, 0x0000600000000000ULL);
+       udelay(10);
+       write64(&bar0->gpio_control, 0x0020600000000000ULL);
+       udelay(10);
+       write64(&bar0->gpio_control, 0x0060600000000000ULL);
+       udelay(10);

The delay is _not_ guaranteed at all, because you do not know when that 
write64() will actually be sent to the PCI bus.  Only a read[bwl,64] is 
guaranteed to flush the write to the PCI device.

So, the above code does not function as you would expect, on all platforms.

6) More examples of PCI posting bugs, in startNic:

+       write64(&bar0->mc_rldram_mrs, val64);
+       set_current_state(TASK_UNINTERRUPTIBLE);
+       schedule_timeout(HZ / 10);

and

+       write64(&bar0->dtx_control, 0x8007051500000000ULL);
+       udelay(50);
+       write64(&bar0->dtx_control, 0x80070515000000E0ULL);
+       udelay(50);
+       write64(&bar0->dtx_control, 0x80070515001F00E4ULL);
+       udelay(50);

7) for fragmented skb's, you should be using pci_map_page() not 
pci_map_single().  Example in drivers/net/tg3.c.

8) (style) in alarmIntrHandler, due to line wrapping, Lindent has 
rendered the 'do' loop rather unreadable.

9) you cannot sleep inside the interrupt handler.  Therefore the 
schedule_timeout() in alarmIntrHandler is very wrong.

10) never use a plain constant when calling schedule_timeout(), such as 
in waitForCmdComplete.  Always calculate the desired delay based on the 
HZ constant.  Otherwise, your delay varies depending on platform.  HZ 
represents one second, in jiffies.  So half a second delay would be "HZ 
/ 2", etc.  Also, when fixing, be careful that your HZ-based calculation 
will never evaluate to zero.

11) ditto s2io_reset

12) ditto s2io_close.  etc.

13) in s2io_xmit, kfree the skb (drop it) if you don't have enough free 
space to queue it.  this is normally a BUG condition, since proper use 
of netif_{start,stop,wake}_queue() will guarantee that s2io_xmit will 
only be called when there is free space to queue another skb.

14) spin_lock(), not spin_lock_irqsave(), in your interrupt handler. 
spin_lock_irqsave() is normally used in any of three cases:  (1) don't 
know whether you're in an ISR or not, (2) definitely not in an ISR, or 
(3) your ISR is called from more than one hardware interrupt.  None of 
these three is the case.

15) does s2io_get_stats need locking?

16) (style) If you are going to comment each function, you might as well 
do it in the "kernel-doc" style, which allows the comments to be picked 
up by automated tools.  The format is

	/**
	 *	function_name - short description
	 *	@argument1: argument 1 description
	 *	@argument2: argument 2 description
	 *	...
	 * SOMETHING:
	 * blah blah blah
	 * SOMETHING ELSE:
	 * blah blah blah

The "ALL_CAPS:" indicates a new section/paragraph, in the document.

Once this is done, you may add a stub document to Documentation/DocBook/ 
and then create your driver's nicely-formatted documentation using "make 
pdfdocs", "make psdocs", or "make htmldocs".

17) this define belongs in include/linux/ethtool.h, if it's not there 
already...
+#define SPEED_10000 10000

18) remove #ifdefs such as
+#if defined(ETHTOOL_GREGS)
+       info->regdump_len = XENA_REG_SPACE;
+#endif

since this exists in both 2.4 and 2.6 kernels.

19) ditto:
+#ifdef ETHTOOL_PHYS_ID

20) for the ethtool EEPROM and register dumps, it would be nice to 
submit a patch to me for ethtool (http://sf.net/projects/gkernel/), 
which generates a verbose dump rather than a bunch of hex numbers 
incomprehensible to the user.  This is a long, boring, but easy task 
suitable to an intern, so I understand if it's not done immediately ;-)

21) s2io_ethtool_nway_reset should restart PHY autonegotiation, not 
reset the entire card

22) eliminate s2io_ethtool_get_link, it duplicates a generic (and 
equivalent) function in net/core/ethtool.c

23) ditto, for the s2io_ethtool_{get,set}_{sg,rx,tx}_csum stuff

24) don't explicitly set members to NULL in netdev_ethtool_ops

25) the update to s2io_tx_watchdog still leaves something to be desired. 
  You are no longer performing the could-take-a-long-time card reset 
inside of spin_lock_bh()... you are now doing it inside the timer 
interrupt :(  Move this to process context by using schedule_work() 
[2.6] or schedule_task [2.4]

27) Unconditional netif_wake_queue() in s2io_link() still unfixed.  You 
must check for room for additional TX, before calling 
netif_{start,wake}_queue().  Consider what happens if the link goes down 
under the TX-full condition [netif_stop_queue]... instant bug.

28) do NOT specify PCI latency timer value as non-zero. 
pci_set_master() chooses an appropriate latency timer value.  It is 
acceptable to leave this in as an option, as long as the module option's 
default is zero:

+static u8 latency_timer = 0xff;

29) (style) don't bother casting a void pointer:

+/*  Private member variable initialized to s2io NIC structure */
+       sp = (nic_t *) dev->priv;

30) redundant assignment of 'sp':

+       dev->irq = pdev->irq;
+       dev->base_addr = (unsigned long) sp->bar0;
+       sp = (nic_t *) dev->priv;

31) kill the #ifdef

+#ifdef SET_ETHTOOL_OPS
+       SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
+#endif

This one is particularly silly, because SET_ETHTOOL_OPS() is -designed- 
to eliminate ifdefs.  A driver wishing to be compatible will provide its 
own SET_ETHTOOL_OPS definition, guaranteeing it can be used 
unconditionally in the driver code here.

32) mark s2io_starter with "__init"

33) kill this:

+#ifndef ETH_ALEN
+#define ETH_ALEN    6
+#endif

34) the definitions of SUCCESS and FAILURE are incorrect.  The driver 
should return 0 on success, and a negative errno-based error code on 
failure.  -EBUSY, -EOPNOTSUPP, etc.

35) kill this:

+#ifndef SUPPORTED_10000baseT_Full
+#define SUPPORTED_10000baseT_Full (1 << 12)
+#endif

36) (feature addition) you have a ton of NIC-specific statistics.  You 
should make those available to users, via ethtool.

37) kill all of this:

+/*  OS related system calls */
+
+#ifndef readq
+static inline u64 read64(void *addr)
+{
+       u64 ret = 0;
+       ret = readl(addr + 4);
+       (u64) ret <<= 32;
+       (u64) ret |= readl(addr);
+
+       return ret;
+}
+#else
+static inline u64 read64(void *addr)
+{
+       u64 ret = readq(addr);
+       return ret;
+}
+#endif
+#define read32(addr, ret)  ret =  readl(addr);
+#define read16(addr, ret)  ret =  readw(addr);
+#define read8(addr, ret)   ret =  readb(addr);
+
+#ifndef writeq
+static inline void write64(void *addr, u64 val)
+{
+       writel((u32) (val), addr);
+       writel((u32) (val >> 32), (addr + 4));
+}
+#else
+#define write64(addr, ret) writeq(ret,(void *)addr)
+#endif
+#define write32(addr, ret) writel(ret,(void *)addr);
+#define write16(addr, ret) writew(ret,(void *)addr);
+#define write8(addr, ret)  writeb(ret,(void *)addr);

38) sysctl_xframe.conf belongs somewhere in Documentation/*
