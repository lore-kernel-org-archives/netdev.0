From: Thomas Sailer <sailer@ife.ee.ethz.ch>
Subject: Re: [RESEND]: RNDIS host: adjust MTU instead of
	refusing to talk	to devices with MTU < 1.5k
Date: Tue, 09 Oct 2007 17:39:44 +0200
Message-ID: <1191944384.10858.89.camel@xbox360>
References: <1191932609.10858.64.camel@xbox360>
	<20071009151832.9B5FF1ACD0D@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>, greg@kroah.com,
	linux-usb-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071009151832.9B5FF1ACD0D@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-09 at 08:18 -0700, David Brownell wrote:

> > This patch makes the host RNDIS driver talk to RNDIS devices with an MTU
> > less than 1.5k, instead of refusing to talk to such a device.
> > Please apply.
> >
> > Signed-Off-by: Thomas Sailer <t.sailer@alumni.ethz.ch>
> 
> Acked-by: David Brownell <dbrownell@users.sourceforge.net>
> 
> ... but patches in drivers/net go to netdev, not linux-usb-devel.
> And it'd be nice if the patch comment mentioned some particular
> device that's been observed to act this way.

Ok, next try.

The device in question is a low power radio device that speaks the
bpqether protocol over ethernet. bpqether frames are never longer than
320 bytes, so there is no need to support 1.5kbyte MTU in the device
firmware.

Tom

Signed-Off-by: Thomas Sailer <t.sailer@alumni.ethz.ch>

--- 1/drivers/net/usb/rndis_host.c.orig	2007-09-04 17:51:11.000000000 +0200
+++ 2/drivers/net/usb/rndis_host.c	2007-09-04 17:54:26.000000000 +0200
@@ -512,11 +512,18 @@
 	}
 	tmp = le32_to_cpu(u.init_c->max_transfer_size);
 	if (tmp < dev->hard_mtu) {
-		dev_err(&intf->dev,
-			"dev can't take %u byte packets (max %u)\n",
-			dev->hard_mtu, tmp);
-		retval = -EINVAL;
-		goto fail_and_release;
+		if (tmp <= net->hard_header_len) {
+			dev_warn(&intf->dev,
+				 "dev can't take %u byte packets (max %u)\n",
+				 net->hard_header_len+1, tmp);
+			retval = -EINVAL;
+			goto fail_and_release;
+		}
+		dev->hard_mtu = tmp;
+		net->mtu = dev->hard_mtu - net->hard_header_len;
+		dev_warn(&intf->dev,
+			 "dev can't take %u byte packets (max %u), adjusting MTU to %u\n",
+			 dev->hard_mtu, tmp, net->mtu);
 	}
 
 	/* REVISIT:  peripheral "alignment" request is ignored ... */



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
