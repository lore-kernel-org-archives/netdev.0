From: Jeff Garzik <jgarzik@pobox.com>
Subject: Centrino wireless review
Date: Tue, 09 Mar 2004 16:57:12 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404E3DB8.1000000@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jketreno@linux.co.intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks much to you and Intel for publishing this!

0) is the firmware blob truly a firmware blob, and not an x86 ELF blob? 
  In other words, will this firmware work on non-x86?

1) No locking in av5100_set_radio

2) proc_set_radio should not assume "any user data other than zero" 
means affirmative.  Reverse the sense of that test:  You want "1" to 
indicate affirmative, and "anything other than 1" to mean negative.

3) handle !CONFIG_PROC_FS

4) any use of "volatile" is probably a bug.  Either a memory barrier is 
needed, or cpu_relax(), or similar...

5) tasklets and work queues exist in both 2.4 and 2.6:

+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)
+       struct tasklet_struct irq_tasklet;
+#else
+       struct work_struct irq_work;
+       struct work_struct reset_work;
+       struct work_struct tx_work;
+#endif

So, if you want to use tasklets in 2.6, you may do so.

If you want to use work queues in 2.4, then simply provide the following 
substitution:
	s/work_struct/tq_struct/
	s/schedule_work/schedule_task/

6) unacceptably long wait in ipw2100_wait_for_card_state().  You want to 
do a schedule_timeout() from a kernel thread, if you really need to wait 
that long.

7) ditto sw_reset_and_clock

8) you want to use TASK_UNINTERRUPTIBLE, since you're delaying for 
hardware and don't care about signals sent to your thread:

+       for (i = 0, check = 0;
+            i < MAX_RF_KILL_CHECKS && check < RF_KILL_CHECK_THRESHOLD;
+            i++) {
+               set_current_state(TASK_INTERRUPTIBLE);
+               schedule_timeout(RF_KILL_CHECK_DELAY);

9) ditto

+               if ((val1 & IPW2100_CONTROL_PHY_OFF) &&
+                   (val2 & IPW2100_COMMAND_PHY_OFF)) {
+                       priv->phy_off = 1;
+                       return 0;
+               }
+
+               set_current_state(TASK_INTERRUPTIBLE);
+               schedule_timeout(HW_PHY_OFF_LOOP_DELAY);
+       }

10) unfortunately, the return value of pci_map_single() does not 
indicate failure.  While I applaud your efforts to check the return 
value (I wish more programmers did!), the PCI DMA API currently assumes 
success :(  Further and more importantly, zero can be a valid return value.

+       packet->rxp = (struct ipw2100_rx_packet *)packet->skb->data;
+       packet->dma_addr = pci_map_single(priv->pdev, packet->skb->data,
+                                         sizeof(struct ipw2100_rx_packet),
+                                         PCI_DMA_FROMDEVICE);
+       if (!packet->dma_addr) {

11) for the fragments being handled in X__ipw2100_tx_send_data, are you 
calling pci_map_single() more than once on the same skb data?

12) you disable hardware interrupts in ipw2100_interrupt before taking 
your spinlock... racy

13) no need to use spin_lock_irqsave() in your interrupt handler, 
spin_lock() is fine

14) check for inta==0 (no work... shared interrupt) and inta=0xffffffff 
(hardware disappeared) in your interrupt handler, before actually doing 
any real work.

15) persuant to #14, that implies you return a different value from your 
interrupt handler (IRQ_NONE/IRQ_HANDLED) depending on conditions

16) prefer ethtool's NIC-specific statistics feature, for exporting your 
own statistics

17) ditto for dumping hardware registers, EEPROM, etc.

18) this code in ipw2100_open() implies an incorrect assumption:

+
+       if (!priv->initialized) {

In dev->open(), you want to

	wake up the hardware
	initialize the hardware
	initialize the link

and likewise in dev->close() you do the opposite, in the opposite order. 
  The net stack guarantees there will be no operations while these 
functions are running, so there should be no need for an initialized 
flag at all.

This also serves to provide the user a way to reset the hardware, in the 
event that the driver does not notice the hardware has gone "out to lunch."

19) in ipw2100_tx_timeout(), you should never call 
netif_{start,wake}_queue() without first doing something to ensure that 
you can transmit.  A simple thing would be to simply drop all TX skb's.

20) (simple) propagate 'err' return value to caller, instead of just 
returning ENODEV:
+       err = pci_set_dma_mask(pdev, PCI_DMA_32BIT);
+       if (err) {
+               IPW2100_DEBUG_INFO("failed pci_set_dma_mask!\n");
+               pci_disable_device(pdev);
+               return -ENODEV;
+       }

21) do request_irq() in your dev->open() hook, not in ipw2100_pci_init_one

22) similar to #18, you do not need a 'registered' flag. 
ipw2100_pci_init_one fails (correctly), if it cannot register_netdev().

23) call ipw2100_proc_dev_init() before register_netdev().  otherwise 
you have a serious race between the /sbin/hotplug agent bringing up the 
interface, and the initialization of the procfs interface (which could 
fail).

24) I don't see that you need to list all 1001 (or so:)) PCI subsystem 
vendor ids...  just list the PCI vendor and device id.  (unless I'm 
missing something?)

25) the following code looks like it is the victim of a stupid GNU 
indent [not your fault].  Convert to C99 initializer style ".foo = val,"

+static struct pci_driver ipw2100_pci_driver = {
+      name:DRV_NAME,
+      id_table:ipw2100_pci_id_table,
+      probe:ipw2100_pci_init_one,
+      remove: __devexit_p(ipw2100_pci_remove_one),
+      suspend:0,
+      resume:0
+};

also delete the members you explicitly initialize to zero.

26) I'm curious, what is the locking/exclusion on the ipw2100_wx_xxx() 
functions?


Overall -- it's obviously incomplete, as you stated in your LKML 
posting.  But it's a good start, and more clean than a lot of wireless 
drivers.  Good job, keep up posted on development!  I'm definitely 
interested in merging this driver when it's a bit farther along.

Best regards and thanks,

	Jeff
