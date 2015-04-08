From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 01/14] parport: return value of attach and parport_register_driver
Date: Wed,  8 Apr 2015 16:50:27 +0530
Message-ID: <1428492040-5581-2-git-send-email-sudipm.mukherjee@gmail.com>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-i2c@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-spi@vger.kernel.org, devel@driverdev.osuosl.org,
	alsa-devel@alsa-project.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jean Delvare <jdelvare@suse.de>,
	Wolfram Sang <wsa@the-dreams.de>,
	Rodolfo Giometti <giometti@enneenne.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Mark Brown <broonie@kernel.org>,
	Willy Tarreau <willy@meta-x.org>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34418 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbbDHLVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 07:21:06 -0400
In-Reply-To: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as of now, we are not checking if attach or parport_register_driver
has succeeded or failed. But attach can fail in the places where they
have been used. Lets check the return of attach, and if attach fails
then parport_register_driver should also fail. We can have multiple
parallel port so we only mark attach as failed only if it has never
returned a 0.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/parport/share.c | 20 +++++++++++++++-----
 include/linux/parport.h |  2 +-
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/parport/share.c b/drivers/parport/share.c
index 3fa6624..640ce41 100644
--- a/drivers/parport/share.c
+++ b/drivers/parport/share.c
@@ -148,23 +148,33 @@ static void get_lowlevel_driver (void)
  *	callback, but if the driver wants to take a copy of the
  *	pointer it must call parport_get_port() to do so.
  *
- *	Returns 0 on success.  Currently it always succeeds.
+ *	Returns 0 on success.
  **/
 
 int parport_register_driver (struct parport_driver *drv)
 {
 	struct parport *port;
+	int ret, err;
+	bool attached = false;
 
 	if (list_empty(&portlist))
 		get_lowlevel_driver ();
 
 	mutex_lock(&registration_lock);
-	list_for_each_entry(port, &portlist, list)
-		drv->attach(port);
-	list_add(&drv->list, &drivers);
+	list_for_each_entry(port, &portlist, list) {
+		err = drv->attach(port);
+		if (err == 0)
+			attached = true;
+		else
+			ret = err;
+	}
+	if (attached) {
+		list_add(&drv->list, &drivers);
+		ret = 0;
+	}
 	mutex_unlock(&registration_lock);
 
-	return 0;
+	return ret;
 }
 
 /**
diff --git a/include/linux/parport.h b/include/linux/parport.h
index c22f125..9411065 100644
--- a/include/linux/parport.h
+++ b/include/linux/parport.h
@@ -249,7 +249,7 @@ struct parport {
 
 struct parport_driver {
 	const char *name;
-	void (*attach) (struct parport *);
+	int (*attach)(struct parport *);
 	void (*detach) (struct parport *);
 	struct list_head list;
 };
-- 
1.8.1.2
