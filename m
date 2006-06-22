From: Jeff Garzik <jeff@garzik.org>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Thu, 22 Jun 2006 19:22:09 -0400
Message-ID: <449B2621.7080607@garzik.org>
References: <0BB3E5E7462EEA4295BC02D49691DC0717688F@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-driver@qlogic.com, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:31725 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750779AbWFVXWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 19:22:15 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC0717688F@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
> ftp://ftp.qlogic.com/outgoing/linux/network/upstream/2.02.00k34/qla3xxxp
> atch1-v2.02.00-k34.txt

Your mailer breaks this into two lines, which is a pain.

Comments on this updated version:

1) [semi-major] Infinite loop in ql_sem_spinlock(), if hardware is 
faulty or been unplugged.

2) Similarly, other rare hardware conditions could cause 
ql_sem_spinlock() to wait for a very, very long time.

3) [minor] PCI_POSTING() macro seems a bit ugly to me.  No good 
suggestions on better paths... maybe at least make it a static inline, 
to enable better type checking.

4) [minor] ql_wait_for_drvr_lock() should use ssleep() rather than msleep()

5) What is the point of using the hardware semaphore?  Is a firmware 
competing with the device driver somehow, and its activities require 
synchronization with the OS driver?

6) [major] The locking model is wrong for the API.  The very low level 
functions ql_read_common_reg() and ql_write_common_reg() take a spinlock 
inside their guts, which is quite expensive when you read the rest of 
the code:

> +       /* Clock in a zero, then do the start bit */
> +       ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,+                           ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
> +                           AUBURN_EEPROM_DO_1);
> +       ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,+                           ISP_NVRAM_MASK | qdev->
> +                           eeprom_cmd_data | AUBURN_EEPROM_DO_1 |
> +                           AUBURN_EEPROM_CLK_RISE);
> +       ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,+                           ISP_NVRAM_MASK | qdev->
> +                           eeprom_cmd_data | AUBURN_EEPROM_DO_1 |
> +                           AUBURN_EEPROM_CLK_FALL);

The above quoted code just acquired and released the spinlock three 
times, an operation that could have _obviously_ been reduced to a single 
lock acquire + release.  In fact, the situation is worse than it sounds, 
because there were a bunch more ql_write_common_reg() calls in the 
function I quoted from.

Thus, this locking is _too_ low-level, and it _prevents_ more 
intelligent use of spinlocks, e.g.

	spin_lock_foo()
	write reg
	write reg
	read reg
	spin_unlock_foo()

I would venture to say that this locking model is largely useless in 
practice.  A better locking scheme is not only far more optimal, it 
would also be more _provable_ (such as with Ingo's lock validator).

7) Severe lack of comments.

8) [readability] ql_link_state_machine() suffers from overzealous 
indentation, which was caused by the functions large size.  At the very 
least, I would suggest breaking out the "/* configure the MAC */" 
sequence into a separate function.

9) [minor] "N/A" appears to be an inaccurate value for fw_version in 
ql_get_drvinfo()

10) [semi-major] More over-locking.  You take the TX spinlock for 
_every_ TX, in ql_process_mac_tx_intr() [which only processes a single 
TX completion] -> ql_free_txbuf().

11) General comment:  Have you noticed that all hot path operations save 
for ->hard_start_xmit() occur entirely inside adapter_lock ?

12) For new drivers, we see additional work and little value for 
maintained #ifdef'd NAPI and non-NAPI code paths.  Just pick the best 
one (and justify that decision with sound technical rationale).

13) The tx_lock appears to offer no value outside of the normal locking.

14) Surely there is a better way to down the adapter than masking the 
interrupts and resetting the adapter?  If this is ever used in non-MSI 
situations (common in Linux today), there is the possibility of 
screaming interrupts, in shared-interrupt situations.

15) I wonder if SA_SHIRQ needs to be set, for MSI?

16) [minor] several other places where ssleep() could be used

17) the following tests in ql3xxx_remove() should be eliminated, as they 
are impossible:

+       if (ndev == NULL)

+       if (qdev == NULL) {

18) [minor] standard practice is to print the driver name and version in 
pci_driver::probe(), on the first call to that function.  Your driver 
acts differently from others, by printing it in ql3xxx_init_module()




