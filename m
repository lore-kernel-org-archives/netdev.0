From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Net module Realtek 8110S/8169S
Date: Thu, 25 Mar 2004 00:04:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040325000431.A30067@electric-eye.fr.zoreil.com>
References: <HV3PKU$46A35E9C06E9DB9727EB43EC9861B7A1@libero.it>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "markes.albert@libero.it" <markes.albert@libero.it>
Content-Disposition: inline
In-Reply-To: <HV3PKU$46A35E9C06E9DB9727EB43EC9861B7A1@libero.it>; from markes.albert@libero.it on Wed, Mar 24, 2004 at 11:10:06PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

markes.albert@libero.it <markes.albert@libero.it> :
[...]
>       Fisrt, excuse for my bad english. I have big problem with module r8169
> shipped with kernel 2.6.4. My system is a Pentium4HT, mainborad is a MSI 865PE
> Neo2-P with integrated Fast Ethernet Realtek 8110s/8169S (as I see in bios
> message). When I transfer a big file (size > 5Mb) from my system to another PC,
> it freeze without any message. The

Please describe the freeze in a few words:
- transfer dead but computer is still fine;
- keyboard stuck;
- leds do not change any more.

> only messages that I see in the log are some line with text "eth0: Too much work
> at interrupt!", not at same time with hang. I think is NIC module problem

Good to know.

> because  only operation I do is transfer file (with samba client) in tty (not in
> X). With kernel 2.6.3 the problem isn't show.

Can you issue a 'dd if=/dev/my_hard_drive of=/dev/null bs=1024k' and
see if it performs well for, say 2 or 3 minutes ? If it works dd your file
to some other file so that it gets cached in memory (if possible) and try
the copy again.

[...]
>      With Kernel 2.6.3 I noticed only a thing, if I unplugged the cable and
> re-plug the network not respond (not link on NIC). Only if I stop and start
> then daemon, network return-up. 

It is known but your report is still welcome.

[...]
>      For nmi watchdog I don't see the option in kernel menu. If you tell me
> how... I'll try...

Processor type and features  --->
[...]
  x x[ ] Symmetric multi-processing support                               x x   
  x x[ ] Preemptible Kernel                                               x x   
  x x[*] Local APIC support on uniprocessors                              x x   

Enable as well:

Kernel hacking  --->
[...]
  x x            [*] Magic SysRq key                                      x x   

Pass "nmi_watchdog=1" through the kernel boot command line, verify that you
have "kernel.sysrq = 1" in your /etc/sysctl.conf and if something goes wrong
try to issue an alt+sysrq+t (sysrq appears as the "print" key amongst the
three keys left to the leds). Verify that alt+sysrq+t is fine _before_ the
problem appears. If you do not understand, ask again.

>      I tryed vanilla-kernel and Andrew Morton's kernel.
> Any Idea? 

1 - Let's rule out the disk first;
2 - then if kernel gets stuck and leds refuse to change state, r8169 may be
    spinning in irq context, either because there is still a off by one error
    or because something corrupted the Rx/Tx descriptors. Try again -mm with
    attached patch and see if messages pop-up (easy to apply by hand if it
    needs to).

Please send lspci, dmesg and friends off-list (tarball for instance).

--
Ueimor

--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-break-irq-loop.patch"

 drivers/net/r8169.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff -puN drivers/net/r8169.c~r8169-break-irq-loop drivers/net/r8169.c
--- linux-2.6.5-rc2/drivers/net/r8169.c~r8169-break-irq-loop	2004-03-24 23:52:23.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/r8169.c	2004-03-24 23:56:26.000000000 +0100
@@ -1345,6 +1345,7 @@ rtl8169_tx_interrupt(struct net_device *
 		     void *ioaddr)
 {
 	unsigned long dirty_tx, tx_left = 0;
+	int max_try = 8192;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -1353,7 +1354,7 @@ rtl8169_tx_interrupt(struct net_device *
 	dirty_tx = tp->dirty_tx;
 	tx_left = tp->cur_tx - dirty_tx;
 
-	while (tx_left > 0) {
+	while ((tx_left > 0) && --max_try) {
 		int entry = dirty_tx % NUM_TX_DESC;
 
 		if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
@@ -1371,6 +1372,9 @@ rtl8169_tx_interrupt(struct net_device *
 		}
 	}
 
+	if (!max_try)
+		printk(KERN_INFO "%s: strangeness in Tx handler", dev->name);
+
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		if (netif_queue_stopped(dev))
@@ -1406,6 +1410,7 @@ rtl8169_rx_interrupt(struct net_device *
 {
 	unsigned long cur_rx, rx_left;
 	int delta;
+	int max_try = 8192;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -1414,7 +1419,7 @@ rtl8169_rx_interrupt(struct net_device *
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
 
-	while (rx_left > 0) {
+	while ((rx_left > 0) && --max_try) {
 		int entry = cur_rx % NUM_RX_DESC;
 		u32 status = le32_to_cpu(tp->RxDescArray[entry].status);
 
@@ -1461,6 +1466,9 @@ rtl8169_rx_interrupt(struct net_device *
 		rx_left--;
 	}
 
+	if (!max_try)
+		printk(KERN_INFO "%s: strangeness in Rx handler", dev->name);
+
 	tp->cur_rx = cur_rx;
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);

_

--6c2NcOVqGQ03X4Wi--
