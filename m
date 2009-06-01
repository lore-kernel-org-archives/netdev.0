From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.30rc7: ksoftirqd CPU saturation (x86-64 and
	x86-32 both) (in-tree e1000e at fault)
Date: Mon, 01 Jun 2009 20:12:13 +0100
Message-ID: <87hbyzzs36.fsf_-_@hades.wkstn.nix>
References: <87prdozxns.fsf@hades.wkstn.nix>
	<20090531170350.1355b3f1.akpm@linux-foundation.org>
	<87ljoczu3p.fsf@hades.wkstn.nix>
	<20090531.215855.142666346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090531.215855.142666346.davem@davemloft.net> (David Miller's
	message of "Sun, 31 May 2009 21:58:55 -0700 (PDT)")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 1 Jun 2009, David Miller uttered the following:

> From: Nix <nix@esperi.org.uk>
> Date: Mon, 01 Jun 2009 01:16:26 +0100
>
>> I plan to try out 2.6.29 (and back to 2.6.25 or thereabouts) tomorrow
>> and see if it ever worked: if it did I'll bisect for it (rendered tricky
>> by the out-of-tree e1000e driver, but doable: it would be easier if I
>> had a clue where the e1000-devel git tree is, if anywhere, but I still
>> have no idea despite considerable searching).
>
> Why are you using the out-of-tree e1000e driver?  What's wrong
> with the one in the tree? :-)

My original speculations were wrong: it goes wrong with 32-bit as well
as 64-bit kernels. The key is that it only ever goes wrong with the
in-tree driver. When I compiled the faulty kernels (32- and 64-bit), I
forgot to copy the out-of-tree driver into place. Use the out-of-tree
driver, and the CPU hogging goes away. So this is an in-tree e1000e
driver bug, definitely. The card is an 82574L.

I could bisect for it, but I have no real evidence that the in-tree
driver *ever* worked with this card. When the machine came from the
vendor it was running 2.6.25... and the out-of-tree driver.

I'll hunt backwards a bit and see if it works in 2.6.28 or something
like that. Maybe I'll be lucky.


--- out-of-tree driver with this patch needed to compile, previously
posted to e1000-devel without comment from anyone: probably the upstream
git tree, wherever that is, already has it:

diff -u e1000e-0.5.18.3/src/kcompat.h drivers/net/e1000e/kcompat.h
--- e1000e-0.5.18.3/src/kcompat.h	2009-03-05 18:43:14.000000000 +0000
+++ drivers/net/e1000e/kcompat.h	2009-05-21 23:46:04.000000000 +0100
@@ -141,12 +141,6 @@
 #endif
 #endif
 
-#ifndef IRQ_HANDLED
-#define irqreturn_t void
-#define IRQ_HANDLED
-#define IRQ_NONE
-#endif
-
 #ifndef SET_NETDEV_DEV
 #define SET_NETDEV_DEV(net, pdev)
 #endif
@@ -1650,4 +1644,12 @@
 #define pci_request_selected_regions_exclusive(pdev, bars, name) \
 		pci_request_selected_regions(pdev, bars, name)
 #endif /* < 2.6.29 */
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,30) )
+#ifndef IRQ_HANDLED
+#define irqreturn_t void
+#define IRQ_HANDLED
+#define IRQ_NONE
+#endif
+#endif /* < 2.6.30 */
 #endif /* _KCOMPAT_H_ */
diff -u e1000e-0.5.18.3/src/kcompat_ethtool.c drivers/net/e1000e/kcompat_ethtool.c
--- e1000e-0.5.18.3/src/kcompat_ethtool.c	2009-03-05 18:43:14.000000000 +0000
+++ drivers/net/e1000e/kcompat_ethtool.c	2009-05-20 21:28:02.000000000 +0100
@@ -54,6 +54,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <asm/uaccess.h>
+#include <net/net_namespace.h>
 
 #include "kcompat.h"
 
@@ -782,7 +783,7 @@
 #define ETHTOOL_OPS_COMPAT
 int ethtool_ioctl(struct ifreq *ifr)
 {
-	struct net_device *dev = __dev_get_by_name(ifr->ifr_name);
+	struct net_device *dev = __dev_get_by_name(&init_net, ifr->ifr_name);
 	void *useraddr = (void *) ifr->ifr_data;
 	u32 ethcmd;
 

------------------------------------------------------------------------------
OpenSolaris 2009.06 is a cutting edge operating system for enterprises 
looking to deploy the next generation of Solaris that includes the latest 
innovations from Sun and the OpenSource community. Download a copy and 
enjoy capabilities such as Networking, Storage and Virtualization. 
Go to: http://p.sf.net/sfu/opensolaris-get
