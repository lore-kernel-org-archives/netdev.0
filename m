From: janitor@sternwelten.at
Subject: [patch 10/18]  net/g96100eth: replace 	gt96100_delay() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:42:49 +0200
Message-ID: <E1CO1vu-0002Lf-5c@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of gt96100_delay() so
that the task delays as expected. Remove the prototype and definition of
gt96100_delay(). As I currently understand it, the check for interrupt
context is not necessary in gt96100_delay(), as such a sleep will be
caught within the scheduler.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/gt96100eth.c |   19 ++++---------------
 1 files changed, 4 insertions(+), 15 deletions(-)

diff -puN drivers/net/gt96100eth.c~msleep_interruptible-drivers_net_gt96100eth drivers/net/gt96100eth.c
--- linux-2.6.10-rc1/drivers/net/gt96100eth.c~msleep_interruptible-drivers_net_gt96100eth	2004-10-24 17:05:12.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/gt96100eth.c	2004-10-24 17:05:12.000000000 +0200
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
@@ -528,7 +517,7 @@ abort(struct net_device *dev, u32 abort_
 	// wait for abort to complete
 	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
 		// snooze for 20 msec and check again
-		gt96100_delay(1);
+		msleep_interruptible(20);
 	
 		if (--timedout == 0) {
 			err("%s: timeout!!\n", __FUNCTION__);
_
