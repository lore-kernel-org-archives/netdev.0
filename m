From: Andrew Morton <akpm@digeo.com>
Subject: Re: Bonding driver unreliable under high CPU load
Date: Sat, 14 Sep 2002 20:24:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D83FD6B.4B492B7D@digeo.com>
References: <15747.26107.382619.200566@pcg.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pascal Brisset <pascal.brisset-ml@wanadoo.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pascal Brisset wrote:
> 
> I would like to confirm the problem reported by Tony Cureington at
> http://sourceforge.net/mailarchive/forum.php?thread_id=1015008&forum_id=2094
> 
> Problem: In MII-monitoring mode, when the CPU load is high,
> the ethernet bonding driver silently fails to detect dead links.
> 
> How to reproduce:
> i686, 2.4.19; "modprobe bonding mode=1 miimon=100"; ifenslave two
> interfaces; ping while you plug/unplug cables. Bonding will
> switch to the available interface, as expected. Now load the CPU
> with "while(1) { }", and failover will not work at all anymore.
> 
> Explanation:
> The bonding driver monitors the state of its slave interfaces by
> calling their dev->do_ioctl(SIOCGMIIREG|ETHTOOL_GLINK) from a
> timer callback function. Whenever this occurs during a user task,
> the get_user() in the ioctl handling code of the slave fails with
> -EFAULT because the ifreq struct is allocated in the stack of the
> timer function, above 0xC0000000. In that case, the bonding driver
> considers the link up by default.
> 
> This problem went unnoticed because for most applications, when the
> active link dies, the host becomes idle and the monitoring function
> gets a chance to run during a kernel thread (in which case it works).
> The active-backup switchover is just slower than it should be.
> Serious trouble only happens when the active link dies during a long,
> CPU-intensive job.
> 
> Is anyone working on a fix ? Maybe running the monitoring stuff in
> a dedicated task ?

Running the ioctl in interrupt context is bad.  Probably what should
happen here is that the whole link monitoring function be pushed up
to process context via a schedule_task() callout, or a do it in a 
dedicated kernel thread.

This patch will probably make it work, but the slave device's ioctl simply
isn't designed to be called from this context - it could try to take
a semaphore, or a non-interrupt-safe lock or anything.

--- linux-2.4.20-pre7/drivers/net/bonding.c	Thu Sep 12 20:35:22 2002
+++ linux-akpm/drivers/net/bonding.c	Sat Sep 14 20:23:45 2002
@@ -208,6 +208,7 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
+#include <asm/processor.h>
 #include <linux/errno.h>
 
 #include <linux/netdevice.h>
@@ -401,6 +402,7 @@ static u16 bond_check_dev_link(struct ne
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 	struct ethtool_value etool;
+	int ioctl_ret;
 
 	if ((ioctl = dev->do_ioctl) != NULL)  { /* ioctl to access MII */
 		/* TODO: set pointer to correct ioctl on a per team member */
@@ -416,7 +418,13 @@ static u16 bond_check_dev_link(struct ne
 		/* effect...                                               */
 	        etool.cmd = ETHTOOL_GLINK;
 	        ifr.ifr_data = (char*)&etool;
-		if (ioctl(dev, &ifr, SIOCETHTOOL) == 0) {
+		{
+			mm_segment_t old_fs = get_fs();
+			set_fs(KERNEL_DS);
+			ioctl_ret = ioctl(dev, &ifr, SIOCETHTOOL);
+			set_fs(old_fs);
+		}
+		if (ioctl_ret == 0) {
 			if (etool.data == 1) {
 				return(MII_LINK_READY);
 			} 


-
