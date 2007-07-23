From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: net/bluetooth/rfcomm/tty.c: use-after-free
Date: Mon, 23 Jul 2007 09:47:12 +0200
Message-ID: <1185176832.7111.32.camel@violet>
References: <20070723012543.GW26212@stusta.de>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-EtPTDyWlzq4wPVJ9lUcf"
Cc: Ville Tervo <ville.tervo@nokia.com>, netdev@vger.kernel.org,
	bluez-devel@lists.sf.net, maxk@qualcomm.com,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070723012543.GW26212@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--=-EtPTDyWlzq4wPVJ9lUcf
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Adrian,

> Commit 8de0a15483b357d0f0b821330ec84d1660cadc4e added the following 
> use-after-free in net/bluetooth/rfcomm/tty.c:
> 
> <--  snip  -->
> 
> ...
> static int rfcomm_dev_add(struct rfcomm_dev_req *req, struct rfcomm_dlc *dlc)
> {
> ...
>         if (IS_ERR(dev->tty_dev)) {
>                 list_del(&dev->list);
>                 kfree(dev);
>                 return PTR_ERR(dev->tty_dev);
>         }
> ...
> 
> <--  snip  -->
> 
> Spotted by the Coverity checker.

really good catch. I fully overlooked that one. The attached patch
should fix it.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


--=-EtPTDyWlzq4wPVJ9lUcf
Content-Disposition: attachment; filename=patch
Content-Type: text/x-patch; name=patch; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 23ba61a..22a8320 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -267,7 +267,7 @@ static int rfcomm_dev_add(struct rfcomm_dev_req *req, struct rfcomm_dlc *dlc)
 out:
 	write_unlock_bh(&rfcomm_dev_lock);
 
-	if (err) {
+	if (err < 0) {
 		kfree(dev);
 		return err;
 	}
@@ -275,9 +275,10 @@ out:
 	dev->tty_dev = tty_register_device(rfcomm_tty_driver, dev->id, NULL);
 
 	if (IS_ERR(dev->tty_dev)) {
+		err = PTR_ERR(dev->tty_dev);
 		list_del(&dev->list);
 		kfree(dev);
-		return PTR_ERR(dev->tty_dev);
+		return err;
 	}
 
 	return dev->id;

--=-EtPTDyWlzq4wPVJ9lUcf
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--=-EtPTDyWlzq4wPVJ9lUcf
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bluez-devel mailing list
Bluez-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/bluez-devel

--=-EtPTDyWlzq4wPVJ9lUcf--
