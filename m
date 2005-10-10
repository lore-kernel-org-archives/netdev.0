From: Olaf Hering <olh@suse.de>
Subject: [PATCH] pcnet32 does not use the PROM address on powerpc
Date: Mon, 10 Oct 2005 16:23:44 +0200
Message-ID: <20051010142344.GA26737@suse.de>
References: <20051008104725.GA10248@suse.de> <20051008120316.GA12122@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org
Content-Disposition: inline
In-Reply-To: <20051008120316.GA12122@suse.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

 On Sat, Oct 08, Olaf Hering wrote:

>  On Sat, Oct 08, Olaf Hering wrote:
> 
> > I have a 44p 270, which gets all 0xFF as MAC address if I power if off
> > and on again. Further reboots do not fix it.
> > But it does get the correct one if I boot into SMS and do a netboot,
> > further reboots will always get the correct MAC address



The CSR contains garbage after a coldboot on RS/6000.
One some systems (like my 44p 270) the MAC address is all FF,
on others (like my B50) it is ff:ff:ff:fd:ff:6b.

It can eventually be fixed by loading pcnet32, set the interface
into the UP state, rmmod pcnet32 and load it again. But this worked
only on the 270.

Only netbooting after a cold start provides the correct MAC address
via prom and CSR. This makes it very unreliable.
I dont know why the MAC is stored in two different places. Remove
the special case for powerpc, which was added in early 2.4 development.

Signed-off-by: Olaf Hering <olh@suse.de>

 drivers/net/pcnet32.c |    5 -----
 1 files changed, 5 deletions(-)

Index: linux-2.6.14-rc3/drivers/net/pcnet32.c
===================================================================
--- linux-2.6.14-rc3.orig/drivers/net/pcnet32.c
+++ linux-2.6.14-rc3/drivers/net/pcnet32.c
@@ -1172,12 +1172,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 
     if (memcmp(promaddr, dev->dev_addr, 6)
 	|| !is_valid_ether_addr(dev->dev_addr)) {
-#ifndef __powerpc__
 	if (is_valid_ether_addr(promaddr)) {
-#else
-	if (!is_valid_ether_addr(dev->dev_addr)
-	    && is_valid_ether_addr(promaddr)) {
-#endif
 	    if (pcnet32_debug & NETIF_MSG_PROBE) {
 		printk(" warning: CSR address invalid,\n");
 		printk(KERN_INFO "    using instead PROM address of");

-- 
short story of a lazy sysadmin:
 alias appserv=wotan
