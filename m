From: janitor@sternwelten.at
Subject: [patch 08/16]  net/gt96100eth: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:03:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGB-0007q6-VQ@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. This is one (of
many) cases where I made a decision about replacing

set_current_state(TASK_INTERRUPTIBLE);
schedule_timeout(some_time);

with

msleep(jiffies_to_msecs(some_time));

msleep() is not exactly the same as the previous code, but I only did
this replacement where I thought long delays were *desired*. If this is
not the case here, then just disregard this patch. 

Thanks,
Nish

PS. In this patch, the last delay is a bit confusing. It, in code,
delayed for 1 msec, but the comment said 20 msecs, does anyone know
which it should be?



Description: Replace gt96100_delay() with msleep() to guarantee the
task delays for the desired time. Remove the definition of
gt96100_delay().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/gt96100eth.c |   19 ++++---------------
 1 files changed, 4 insertions(+), 15 deletions(-)

diff -puN drivers/net/gt96100eth.c~msleep-drivers_net_gt96100eth drivers/net/gt96100eth.c
--- linux-2.6.9-rc1-bk7/drivers/net/gt96100eth.c~msleep-drivers_net_gt96100eth	2004-09-01 19:35:29.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/gt96100eth.c	2004-09-01 19:35:29.000000000 +0200
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
+		msleep(1);
 
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: busy timeout!!\n", __FUNCTION__);
@@ -252,7 +241,7 @@ read_MII(int phy_addr, u32 reg)
 	// wait for read to complete
 	while (!((smir = GT96100_READ(GT96100_ETH_SMI_REG)) & smirReadValid)) {
 		// snooze for 1 msec and check again
-		gt96100_delay(1);
+		msleep(1);
 	
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: timeout!!\n", __FUNCTION__);
@@ -304,7 +293,7 @@ write_MII(int phy_addr, u32 reg, u16 dat
 	// wait for last operation to complete
 	while (GT96100_READ(GT96100_ETH_SMI_REG) & smirBusy) {
 		// snooze for 1 msec and check again
-		gt96100_delay(1);
+		msleep(1);
 	
 		if (--timedout == 0) {
 			printk(KERN_ERR "%s: busy timeout!!\n", __FUNCTION__);
@@ -528,7 +517,7 @@ abort(struct net_device *dev, u32 abort_
 	// wait for abort to complete
 	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
 		// snooze for 20 msec and check again
-		gt96100_delay(1);
+		msleep(20); // was gt96100_delay(1) -> should it be 20 or 1?
 	
 		if (--timedout == 0) {
 			err("%s: timeout!!\n", __FUNCTION__);

_
