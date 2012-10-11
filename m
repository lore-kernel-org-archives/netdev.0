From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [3.5 regression / mcs7830 / bisected] bridge constantly toggeling between disabled and forwarding
Date: Thu, 11 Oct 2012 10:14:14 +0200
Message-ID: <201210111014.14533.linux@rainbow-software.org>
References: <20120723091504.2d035d28@xenia.leun.net> <201210090921.31415.linux@rainbow-software.org> <20121009105606.247658ca@xenia.leun.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Leun <lkml20120218@newton.leun.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1-out2.atlantis.sk ([80.94.52.71]:58039 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932450Ab2JKIOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 04:14:50 -0400
In-Reply-To: <20121009105606.247658ca@xenia.leun.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 October 2012, Michael Leun wrote:
> On Tue, 9 Oct 2012 09:21:31 +0200
>
> Ondrej Zary <linux@rainbow-software.org> wrote:
> > On Tuesday 09 October 2012, Michael Leun wrote:
> > > On Thu, 27 Sep 2012 10:39:05 -0700
> > >
> > > Greg KH <gregkh@linuxfoundation.org> wrote:
> > > > On Tue, Jul 24, 2012 at 01:36:34AM +0200, Michael Leun wrote:
> > > > > On Mon, 23 Jul 2012 09:15:04 +0200
> > > > > Michael Leun <lkml20120218@newton.leun.net> wrote:
> > > > >
> > > > > [see issue description below]
> > > > >
> > > > > Bisecting yielded
> > > > >
> > > > > b1ff4f96fd1c63890d78d8939c6e0f2b44ce3113 is the first bad commit
> > > > > commit b1ff4f96fd1c63890d78d8939c6e0f2b44ce3113
> > > > > Author: Ondrej Zary <linux@rainbow-software.org>
> > > > > Date:   Fri Jun 1 10:29:08 2012 +0000
> > > > >
> > > > >     mcs7830: Implement link state detection
> > > > >
> > > > >     Add .status callback that detects link state changes.
> > > > >     Tested with MCS7832CV-AA chip (9710:7830, identified as
> > > > > rev.C by the driver). Fixes
> > > > > https://bugzilla.kernel.org/show_bug.cgi?id=28532
> > > > >
> > > > >     Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > > > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > > > >
> > > > > :040000 040000 5480780cb5e75c57122a621fc3bab0108c16be27
> > > > >
> > > > > d97efd9cc0a465dff76bcd3a3c547f718f2a5345 M    drivers
> > > > >
> > > > >
> > > > > Reverting that from 3.5 makes the issue go away.
> > > >
> > > > Did this ever get resolved in 3.6-rc7 or any older kernel?  I
> > > > can't revert the patch from 3.5.y unless it's also fixed in
> > > > Linus's tree.
> > >
> > > Please excuse me for answering a bit late.
> > >
> > > No, that never got resolved, I still have the problem with 3.6 but
> > > I'm not shure about the correct solution.
> > >
> > > Maybe link state detection just does not work with some of that
> > > devices and we should have an possibility to enable/disable it per
> > > device, maybe it can be handeled with an blacklist of not working
> > > devices, maybe it could be fixed - I do not know and also do not
> > > know how to find out.
> > >
> > > But I'm willing to test.
> >
> > Does the problem appear only in a bridge? Or the link state detection
> >is completely wrong?
>
> As testing with patch below shows, it also happens without bridge, but
> I did not notice so far, because that log message I was complainig
> about originally of course comes from the bridge code.
>
> > Can you please apply this debug patch and provide the output?
> >
> > --- a/drivers/net/usb/mcs7830.c
> > +++ b/drivers/net/usb/mcs7830.c
> > @@ -638,6 +638,7 @@ static void mcs7830_status(struct usbnet *dev,
> > struct urb *urb) return;
> >
> >  	link = !(buf[1] & 0x20);
> > +	printk("netif_carrier_ok=%d, link=%d, buf[0]=0x%02x,
> > buf[1]=0x%02x\n", netif_carrier_ok(dev->net), link, buf[0], buf[1]);
> > if (netif_carrier_ok(dev->net) != link) { if (link) {
> >  			netif_carrier_on(dev->net);
>
> As far as I've seen:
>
> Bring device up - link state toggles a few times and stabilizes to up
>
> Start ping - link state toggles for every packet
>
> Test below done without bridge involved.
>
> Note: I renamed the interface to ue7 (I happen to have several of that
> devices).

Please try this patch, it should fix the problem.
(Remove the previous debug patch first.)


mcs7830: Fix link state detection

The device had an undocumented "feature": it can provide a sequence of
spurious link-down status data even if the link is up all the time.
A sequence of 10 was seen so update the link state only after the device
reports the same link state 20 times.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/usb/mcs7830.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03c2d8d..3a02a5d 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -117,6 +117,7 @@ enum {
 struct mcs7830_data {
 	u8 multi_filter[8];
 	u8 config;
+	u8 link_counter;
 };
 
 static const char driver_name[] = "MOSCHIP usb-ethernet driver";
@@ -633,19 +634,25 @@ static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 {
 	u8 *buf = urb->transfer_buffer;
 	bool link;
+	struct mcs7830_data *data = mcs7830_get_data(dev);
 
 	if (urb->actual_length < 16)
 		return;
 
 	link = !(buf[1] & 0x20);
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
-		} else
-			netif_carrier_off(dev->net);
-		netdev_dbg(dev->net, "Link Status is: %d\n", link);
-	}
+		data->link_counter++;
+		if (data->link_counter > 20) {
+			data->link_counter = 0;
+			if (link) {
+				netif_carrier_on(dev->net);
+				usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+			} else
+				netif_carrier_off(dev->net);
+			netdev_dbg(dev->net, "Link Status is: %d\n", link);
+		}
+	} else
+		data->link_counter = 0;
 }
 
 static const struct driver_info moschip_info = {


-- 
Ondrej Zary
