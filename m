From: "Cureington, Tony" <tony.cureington@hp.com>
Subject: RE: [Bonding-devel] Re: Bonding driver unreliable under high CPU load
Date: Tue, 17 Sep 2002 14:28:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <72A87F7160C0994D8C5A36E2FDC227F502B3E70D@txnexc01.americas.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@digeo.com>,
   "Pascal Brisset" <pascal.brisset-ml@wanadoo.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've been running some similar code (on 2.4.18) that makes the ioctl a macro - we must handle the MII ioctls too. The patch below also corrects the mii pointer being assigned the address of a pointer (&ifr.ifr_data, ifr_data is a macro that produces a pointer) instead of the pointer itself.


The patch:

--- linux-2.4.20-pre7/drivers/net/bonding.c	Tue Sep 17 09:54:35 2002
+++ linux-2.4.20-pre7_mod/drivers/net/bonding.c	Tue Sep 17 11:18:28 2002
@@ -316,6 +316,28 @@
 #define IS_UP(dev)	((((dev)->flags & (IFF_UP)) == (IFF_UP)) && \
 			(netif_running(dev) && netif_carrier_ok(dev)))
 
+/* this IOCTL macro is used to prevent network drivers from returning -EFAULT
+ * from the ioctl, returning -EFAULT causes a link up status to be returned 
+ * from bond_check_dev_link even when the link is even connected. this macro 
+ * allows the get_user/copy_from_user in network drivers ioctls to work without 
+ * intermittently returning -EFAULT. this turns off argument validity 
+ * checking on the address passed to the network driver ioctl.
+ *
+ * this method of turning off argument validity checking is also used in the 
+ * following drivers:
+ *      /usr/src/linux/drivers/addon/iscsi/; addon/cpip; net/hamradio;
+ *      net/wan; sound/;
+ *
+ * ioctl must be set to dev->do_ioctl before this macro
+ */
+#define IOCTL(dev, arg, cmd) ({             \
+		int ret;                    \
+		mm_segment_t fs = get_fs(); \
+		set_fs(get_ds());           \
+		ret = ioctl(dev, arg, cmd); \
+		set_fs(fs);                 \
+		ret; })
+
 static void bond_restore_slave_flags(slave_t *slave)
 {
 	slave->dev->flags = slave->original_flags;
@@ -416,7 +438,7 @@
 		/* effect...                                               */
 	        etool.cmd = ETHTOOL_GLINK;
 	        ifr.ifr_data = (char*)&etool;
-		if (ioctl(dev, &ifr, SIOCETHTOOL) == 0) {
+		if (IOCTL(dev, &ifr, SIOCETHTOOL) == 0) {
 			if (etool.data == 1) {
 				return(MII_LINK_READY);
 			} 
@@ -431,13 +453,13 @@
 		 */
 
 		/* Yes, the mii is overlaid on the ifreq.ifr_ifru */
-		mii = (struct mii_ioctl_data *)&ifr.ifr_data;
-		if (ioctl(dev, &ifr, SIOCGMIIPHY) != 0) {
+		mii = (struct mii_ioctl_data *)ifr.ifr_data;
+		if (IOCTL(dev, &ifr, SIOCGMIIPHY) != 0) {
 			return MII_LINK_READY;	 /* can't tell */
 		}
 
 		mii->reg_num = 1;
-		if (ioctl(dev, &ifr, SIOCGMIIREG) == 0) {
+		if (IOCTL(dev, &ifr, SIOCGMIIREG) == 0) {
 			/*
 			 * mii->val_out contains MII reg 1, BMSR
 			 * 0x0004 means link established


> -----Original Message-----
> From: Andrew Morton [mailto:akpm@digeo.com]
> Sent: Saturday, September 14, 2002 10:24 PM
> To: Pascal Brisset
> Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> Subject: [Bonding-devel] Re: Bonding driver unreliable under high CPU
> load
> 
> 
> Pascal Brisset wrote:
> > 
> > I would like to confirm the problem reported by Tony Cureington at
> > 
> http://sourceforge.net/mailarchive/forum.php?thread_id=1015008
> &forum_id=2094
> > 
> > Problem: In MII-monitoring mode, when the CPU load is high,
> > the ethernet bonding driver silently fails to detect dead links.
> > 
> > How to reproduce:
> > i686, 2.4.19; "modprobe bonding mode=1 miimon=100"; ifenslave two
> > interfaces; ping while you plug/unplug cables. Bonding will
> > switch to the available interface, as expected. Now load the CPU
> > with "while(1) { }", and failover will not work at all anymore.
> > 
> > Explanation:
> > The bonding driver monitors the state of its slave interfaces by
> > calling their dev->do_ioctl(SIOCGMIIREG|ETHTOOL_GLINK) from a
> > timer callback function. Whenever this occurs during a user task,
> > the get_user() in the ioctl handling code of the slave fails with
> > -EFAULT because the ifreq struct is allocated in the stack of the
> > timer function, above 0xC0000000. In that case, the bonding driver
> > considers the link up by default.
> > 
> > This problem went unnoticed because for most applications, when the
> > active link dies, the host becomes idle and the monitoring function
> > gets a chance to run during a kernel thread (in which case 
> it works).
> > The active-backup switchover is just slower than it should be.
> > Serious trouble only happens when the active link dies 
> during a long,
> > CPU-intensive job.
> > 
> > Is anyone working on a fix ? Maybe running the monitoring stuff in
> > a dedicated task ?
> 
> Running the ioctl in interrupt context is bad.  Probably what should
> happen here is that the whole link monitoring function be pushed up
> to process context via a schedule_task() callout, or a do it in a 
> dedicated kernel thread.
> 
> This patch will probably make it work, but the slave device's 
> ioctl simply
> isn't designed to be called from this context - it could try to take
> a semaphore, or a non-interrupt-safe lock or anything.
> 
> --- linux-2.4.20-pre7/drivers/net/bonding.c	Thu Sep 12 20:35:22 2002
> +++ linux-akpm/drivers/net/bonding.c	Sat Sep 14 20:23:45 2002
> @@ -208,6 +208,7 @@
>  #include <asm/io.h>
>  #include <asm/dma.h>
>  #include <asm/uaccess.h>
> +#include <asm/processor.h>
>  #include <linux/errno.h>
>  
>  #include <linux/netdevice.h>
> @@ -401,6 +402,7 @@ static u16 bond_check_dev_link(struct ne
>  	struct ifreq ifr;
>  	struct mii_ioctl_data *mii;
>  	struct ethtool_value etool;
> +	int ioctl_ret;
>  
>  	if ((ioctl = dev->do_ioctl) != NULL)  { /* ioctl to 
> access MII */
>  		/* TODO: set pointer to correct ioctl on a per 
> team member */
> @@ -416,7 +418,13 @@ static u16 bond_check_dev_link(struct ne
>  		/* effect...                                    
>            */
>  	        etool.cmd = ETHTOOL_GLINK;
>  	        ifr.ifr_data = (char*)&etool;
> -		if (ioctl(dev, &ifr, SIOCETHTOOL) == 0) {
> +		{
> +			mm_segment_t old_fs = get_fs();
> +			set_fs(KERNEL_DS);
> +			ioctl_ret = ioctl(dev, &ifr, SIOCETHTOOL);
> +			set_fs(old_fs);
> +		}
> +		if (ioctl_ret == 0) {
>  			if (etool.data == 1) {
>  				return(MII_LINK_READY);
>  			} 
> 
> 
> -
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> Bonding-devel mailing list
> Bonding-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/bonding-devel
> 
