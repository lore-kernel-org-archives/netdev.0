From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH]  net/gt96100eth: replace gt96100_delay() with msleep_interruptible()
Date: Fri, 5 Nov 2004 09:46:25 -0800
Message-ID: <20041105174625.GB1707__37542.1128971086$1099699327$gmane$org@us.ibm.com>
References: <E1CO1vu-0002Lf-5c@sputnik> <4184C72F.8000905@pobox.com> <20041101190841.GB1730@us.ibm.com> <418B2FF6.8030907@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <418B2FF6.8030907@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 05, 2004 at 02:47:02AM -0500, Jeff Garzik wrote:
> Nishanth Aravamudan wrote:
> >On Sun, Oct 31, 2004 at 06:06:23AM -0500, Jeff Garzik wrote:
> >
> >>janitor@sternwelten.at wrote:
> >>
> >>>@@ -528,7 +517,7 @@ abort(struct net_device *dev, u32 abort_
> >>>	// wait for abort to complete
> >>>	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
> >>>		// snooze for 20 msec and check again
> >>>-		gt96100_delay(1);
> >>>+		msleep_interruptible(20);
> >>>	
> >>>		if (--timedout == 0) {
> >>
> >>
> >>don't change the behavior of the driver, even if it disagrees with the 
> >>comment.
> >
> >
> >Ok, please find the corrected patch below.
> >
> >Description: Uses msleep_interruptible() instead of gt96100_delay()
> >to guarantee the task delays as expected. Removes prototype and
> >definition of now unused gt96100_delay() function. Corrects one comment
> >to correspond to the code.
> >
> >Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >
> >
> >--- 2.6.10-rc1-vanilla/drivers/net/gt96100eth.c	2004-10-30 
> >15:33:30.000000000 -0700
> >+++ 2.6.10-rc1/drivers/net/gt96100eth.c	2004-11-01 
> >11:05:37.000000000 -0800
> >@@ -59,7 +59,6 @@
> > // prototypes
> > static void* dmaalloc(size_t size, dma_addr_t *dma_handle);
> > static void dmafree(size_t size, void *vaddr);
> >-static void gt96100_delay(int msec);
> > static int gt96100_add_hash_entry(struct net_device *dev,
> > 				  unsigned char* addr);
> > static void read_mib_counters(struct gt96100_private *gp);
> >@@ -183,16 +182,6 @@ static void dmafree(size_t size, void *v
> > 	free_pages((unsigned long)vaddr, get_order(size));
> > }
> > 
> >-static void gt96100_delay(int ms)
> >-{
> >-	if (in_interrupt())
> >-		return;
> >-	else {
> >-		current->state = TASK_INTERRUPTIBLE;
> >-		schedule_timeout(ms*HZ/1000);
> 
> I'm still worried about this patch, because
> 
> 1) in_interrupt() check disappears, and

This is true... I have changed the patch significantly, leaving the
gt96100_delay() function intact and simply replacing the else result
with msleep_interruptible(). Does this newer patch look better to you?
Thanks for all the input!

> 2) does driver already include linux/delay.h ?

Yes, it does.



Description: Uses msleep_interruptible() instead of schedule_timeout()
in the gt96100_delay() function. Corrects one comment to correspond to
the code.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-rc1-vanilla/drivers/net/gt96100eth.c	2004-11-05 09:42:37.000000000 -0800
+++ 2.6.10-rc1/drivers/net/gt96100eth.c	2004-11-05 09:45:48.000000000 -0800
@@ -187,10 +187,8 @@ static void gt96100_delay(int ms)
 {
 	if (in_interrupt())
 		return;
-	else {
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(ms*HZ/1000);
-	}
+	else
+		msleep_interruptible(ms);
 }
 
 static int
@@ -527,7 +525,7 @@ abort(struct net_device *dev, u32 abort_
 
 	// wait for abort to complete
 	while (GT96100ETH_READ(gp, GT96100_ETH_SDMA_COMM) & abort_bits) {
-		// snooze for 20 msec and check again
+		// snooze for 1 msec and check again
 		gt96100_delay(1);
 	
 		if (--timedout == 0) {
