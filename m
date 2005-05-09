From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Add tagged status support
Date: Mon, 09 May 2005 14:44:42 -0700
Message-ID: <1115675082.8570.10.camel@rh4>
References: <20050505211735.3829cff2.davem@davemloft.net>
 <1115418431.15156.153.camel@rh4>
 <20050509124832.2a073e11.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050509124832.2a073e11.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-05-09 at 12:48 -0700, David S. Miller wrote:

> Here is my current patch, how does it look.
> 

> @@ -6005,6 +6079,16 @@ static int tg3_open(struct net_device *d
>  
>  	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
>  		err = tg3_test_msi(tp);
> +
> +		/* All MSI supporting chips should support tagged
> +		 * status.  Assert that this is the case.
> +		 */
> +		if (!(tp->tg3_flags2 & TG3_FLAG_TAGGED_STATUS)) {
> +			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
> +			       "Not using MSI.\n", tp->dev->name);
> +			err = -EINVAL;
> +		}
> +
>  		if (err) {
>  			spin_lock_irq(&tp->lock);
>  			spin_lock(&tp->tx_lock);

I found one typo during testing, flags2 should have been flags:

+		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {


I think it will be better to move up this block of code because here we
are at the point of returning error from tg3_open().

Something like this:

diff -Nru h/drivers/net/tg3.c i/drivers/net/tg3.c
--- h/drivers/net/tg3.c	2005-05-09 14:12:37.000000000 -0700
+++ i/drivers/net/tg3.c	2005-05-09 14:24:19.000000000 -0700
@@ -6010,7 +6010,14 @@
 	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
 	    (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5750_AX) &&
 	    (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5750_BX)) {
-		if (pci_enable_msi(tp->pdev) == 0) {
+		/* All MSI supporting chips should support tagged
+		 * status.  Assert that this is the case.
+		 */
+		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
+			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
+			       "Not using MSI.\n", tp->dev->name);
+		}
+		else if (pci_enable_msi(tp->pdev) == 0) {
 			u32 msi_mode;
 
 			msi_mode = tr32(MSGINT_MODE);
@@ -6080,15 +6087,6 @@
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		err = tg3_test_msi(tp);
 
-		/* All MSI supporting chips should support tagged
-		 * status.  Assert that this is the case.
-		 */
-		if (!(tp->tg3_flags2 & TG3_FLAG_TAGGED_STATUS)) {
-			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
-			       "Not using MSI.\n", tp->dev->name);
-			err = -EINVAL;
-		}
-
 		if (err) {
 			spin_lock_irq(&tp->lock);
 			spin_lock(&tp->tx_lock);
