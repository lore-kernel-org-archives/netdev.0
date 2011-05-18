From: Alan Stern <stern@rowland.harvard.edu>
Subject: RE: [PATCH v2] CDC NCM: release interfaces fix in unbind()
Date: Wed, 18 May 2011 15:10:52 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1105181450150.2131-100000@iolanthe.rowland.org>
References: <2AC7D4AD8BA1C640B4C60C61C8E520153E3ACE0774@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "gregkh@suse.de" <gregkh@suse.de>,
	"oliver@neukum.org" <oliver@neukum.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:38197 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933484Ab1ERTKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 15:10:55 -0400
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3ACE0774@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 May 2011, Alexey ORISHKO wrote:

> > From: Alan Stern [mailto:stern@rowland.harvard.edu]
> > Sent: Wednesday, May 18, 2011 4:55 PM
> > 
> > Here and later on, the patch seems to have forgotten about the control
> > interface.  Is this deliberate or an oversight?
> > 
> > Alan Stern
> 
> Kernel docs says, that usb_driver_claim_interface() is used by usb
> device drivers that need to claim more than one interface. I assume,
> it's needed for second interface only. Am I wrong?

Well, if a driver wants to claim three interfaces (which is more than 
one), it would call usb_driver_claim_interface() for both the second 
and third interfaces, not only the second.

In general, when the driver gets probed for any one of the interfaces,
it should identify all the interfaces it's interested in and claim
them.  However, it should skip the interface currently being probed --
that usb_driver_claim_interface() call would fail anyway since an
interface can't be claimed while it is being probed.

Similarly, when any of the interfaces is unbound, the driver should 
release them all.

> NCM driver was partly based on ECM code. I did check existing drivers
> for CDC ACM and CDC ECM, which also uses 2 interfaces: master (control)
> and data (bulk), but I was unable to find any code, which claims master
> interface.
> 
> If we need explicitly claim/release master interface (which is *intf
> parameter in bind() and unbind()), then cdc-acm and usb_ether drivers
> should be updated as well.

As far as I can tell, those drivers check that they are being probed
for the control interface, so all they need to claim is the data
interface.

You could do something similar -- have the bind routine return 
-ENODEV if it's not being called for the control interface.  But the 
unbind routine would still have to release both interfaces, since it 
can't rely on being called for the control interface first.

Alan Stern

