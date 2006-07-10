From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Mon, 10 Jul 2006 17:29:05 -0400
Message-ID: <20060710212900.GF13775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:46091 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965239AbWGJV3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 17:29:32 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 120bda20c6f64b32e8bfbdd7b34feafaa5f5332e:
  Linus Torvalds:
        Linux 2.6.18-rc1

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Daniel Drake:
      zd1211rw: usb_clear_halt not allowed in IRQ context

Larry Finger:
      bcm43xx-softmac: Fix an off-by-one condition in handle_irq_noise

 drivers/net/wireless/bcm43xx/bcm43xx_main.c |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c      |   12 +++---------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index e1c5a93..3889f79 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1547,7 +1547,7 @@ static void handle_irq_noise(struct bcm4
 		goto generate_new;
 
 	/* Get the noise samples. */
-	assert(bcm->noisecalc.nr_samples <= 8);
+	assert(bcm->noisecalc.nr_samples < 8);
 	i = bcm->noisecalc.nr_samples;
 	noise[0] = limit_value(noise[0], 0, ARRAY_SIZE(radio->nrssi_lt) - 1);
 	noise[1] = limit_value(noise[1], 0, ARRAY_SIZE(radio->nrssi_lt) - 1);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index ce1cb2c..72f9052 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -375,10 +375,8 @@ static void int_urb_complete(struct urb 
 	case -ENODEV:
 	case -ENOENT:
 	case -ECONNRESET:
-		goto kfree;
 	case -EPIPE:
-		usb_clear_halt(urb->dev, EP_INT_IN);
-		/* FALL-THROUGH */
+		goto kfree;
 	default:
 		goto resubmit;
 	}
@@ -580,10 +578,8 @@ static void rx_urb_complete(struct urb *
 	case -ENODEV:
 	case -ENOENT:
 	case -ECONNRESET:
-		return;
 	case -EPIPE:
-		usb_clear_halt(urb->dev, EP_DATA_IN);
-		/* FALL-THROUGH */
+		return;
 	default:
 		dev_dbg_f(urb_dev(urb), "urb %p error %d\n", urb, urb->status);
 		goto resubmit;
@@ -749,11 +745,9 @@ static void tx_urb_complete(struct urb *
 	case -ENODEV:
 	case -ENOENT:
 	case -ECONNRESET:
+	case -EPIPE:
 		dev_dbg_f(urb_dev(urb), "urb %p error %d\n", urb, urb->status);
 		break;
-	case -EPIPE:
-		usb_clear_halt(urb->dev, EP_DATA_OUT);
-		/* FALL-THROUGH */
 	default:
 		dev_dbg_f(urb_dev(urb), "urb %p error %d\n", urb, urb->status);
 		goto resubmit;
-- 
John W. Linville
linville@tuxdriver.com
