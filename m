From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH]  net/gt96100eth: replace gt96100_delay() with msleep_interruptible()
Date: Mon, 1 Nov 2004 11:08:41 -0800
Message-ID: <20041101190841.GB1730@us.ibm.com>
References: <E1CO1vu-0002Lf-5c@sputnik> <4184C72F.8000905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C72F.8000905@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 06:06:23AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >@@ -528,7 +517,7 @@ abort(struct net_device *dev, u32 abort_
> > 	// wait for abort to complete
> > 	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
> > 		// snooze for 20 msec and check again
> >-		gt96100_delay(1);
> >+		msleep_interruptible(20);
> > 	
> > 		if (--timedout == 0) {
> 
> 
> don't change the behavior of the driver, even if it disagrees with the 
> comment.

Ok, please find the corrected patch below.

Description: Uses msleep_interruptible() instead of gt96100_delay()
to guarantee the task delays as expected. Removes prototype and
definition of now unused gt96100_delay() function. Corrects one comment
to correspond to the code.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-rc1-vanilla/drivers/net/gt96100eth.c	2004-10-30 15:33:30.000000000 -0700
+++ 2.6.10-rc1/drivers/net/gt96100eth.c	2004-11-01 11:05:37.000000000 -0800
@@ -59,7 +59,6 @@
 // prototypes
 static void* dmaalloc(size_t size, dma_addr_t *dma_handle);
 static void dmafree(size_t size, void *vaddr);
-static void gt96100_delay(int msec);
 static int gt96100_add_hash_entry(struct net_device *dev,
 				  unsigned char* addr);
 static void read_mib_counters(struct gt96100_private *gp);
@@ -183,16 +182,6 @@ static void dmafree(size_t size, void *v
 	free_pages((unsigned long)vaddr, get_order(size));
 }
 
-static void gt96100_delay(int ms)
-{
-	if (in_interrupt())
-		return;
-	else {
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(ms*HZ/1000);
-	}
-}
-
 static int
 parse_mac_addr(struct net_device *dev, char* macstr)
 {
@@ -238,7 +227,7 @@ read_MII(int phy_addr, u32 reg)
 	// wait for last operation to complete
 	while (GT96100_READ(GT96100_ETH_SMI_REG) & smirBusy) {
 		// snooze for 1 msec and check again
-		gt96100_delay(1);
+		msleep_interruptible(1);
 
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: busy timeout!!\n", __FUNCTION__);
@@ -252,7 +241,7 @@ read_MII(int phy_addr, u32 reg)
 	// wait for read to complete
 	while (!((smir = GT96100_READ(GT96100_ETH_SMI_REG)) & smirReadValid)) {
 		// snooze for 1 msec and check again
-		gt96100_delay(1);
+		msleep_interruptible(1);
 	
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: timeout!!\n", __FUNCTION__);
@@ -304,7 +293,7 @@ write_MII(int phy_addr, u32 reg, u16 dat
 	// wait for last operation to complete
 	while (GT96100_READ(GT96100_ETH_SMI_REG) & smirBusy) {
 		// snooze for 1 msec and check again
-		gt96100_delay(1);
+		msleep_interruptible(1);
 	
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: busy timeout!!\n", __FUNCTION__);
@@ -527,8 +516,8 @@ abort(struct net_device *dev, u32 abort_
 
 	// wait for abort to complete
 	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
-		// snooze for 20 msec and check again
-		gt96100_delay(1);
+		// snooze for 1 msec and check again
+		msleep_interruptible(1);
 	
 		if (--timedout == 0) {
 			err("%s: timeout!!\n", __FUNCTION__);
