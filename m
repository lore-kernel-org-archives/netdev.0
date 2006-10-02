From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Mon, 02 Oct 2006 11:08:19 +0200
Message-ID: <1159780099.2655.35.camel@ux156>
References: <1159435399.2648.17.camel@ux156>
	 <451D8BD1.5020906@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:12173 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750898AbWJBJHc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 05:07:32 -0400
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <451D8BD1.5020906@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James,

Good points. Just a few comments.

> The EEPROM contents typically represent the configuration and operating
> parameters which have been tested and certified to be operational.
> 
> These would represent the only settings which a user can operate with
> and still be covered by existing certifications.

Also, the EEPROM could potentially contain limitations of the device
itself, a device manufactured for channels 1-11 might not even operate
correctly in channel 14, I guess.

> The kernel should enforce the parameters as specified by the
> hardware/driver.  In the event that a driver does not advertise a set of
> capabilities, the kernel should select the minimal "safe set", which
> would be a subset of the 2.4Ghz spectrum and likely exclude all of 5.2Ghz.

Right. Note that for bcm43xx for example, we know that these devices
have been certified all over the world and hence the EEPROM information
is effectively useless because it just tells us for which region this
particular device was manufactured, the vendor actually programs this
info and not Broadcom. Hence, in the driver, we'd probably announce some
rather liberal set of parameters.

Maybe there's a need for two different sets of parameters here: one that
the hardware can potentially be used at (usually known to the driver),
and one that it was certified for (the eeprom country info for a given
device)?

> With hardware that restricts operation to the capabilities it was tested
> and calibrated for, this will likely result in a broken user experience
> -- if they try and use a device on channel 13 and the device restricts
> operation to channels 1 - 11, tuning operations will fail.

Yes, makes sense to enforce this all the way through to userspace and
refuse broadening of the limitations from what the driver announced.

This does, however, mean that we cannot just have one global set of
parameters because different hardware might behave differently, if I use
a card manufactured for the somewhere else and it restricts operating to
the eeprom limitations, then that means that I can potentially not make
use of the full permitted spectrum for where I am, and hence will not
want this card to restrict other cards in the system that may be
certified for that broader spectrum. On the other hand, since the other
card is not certified for the broader spectrum there should not be a way
to force it to operate there since it may misbehave.

The conclusion, it seems, is to have two different sets of limitations:
 (a) a global set of regulatory limitations that is completely
     controlled by external information (802.11d anouncements, user
     specified operating country, ...) and set by the userspace daemon
     that analyses all these things and
 (b) a device specific set of limitations initialised by the driver to
     the ranges supported by the card (what the card was certified for
     etc)

Both (a) and (b) are initialised to some sort of (to be determined)
'safe set', (b) then given by the driver for each wiphy, and (a) by the
userspace daemon.

Then, when a given card operates, the kernel makes sure that operation
is limited to adhere to both sets of limitations. Of course there needs
to be some userspace interface to query both (a) and (b).

This makes sure that
 - devices always only operate in the ranges they were certified with
 - operations is additionally limited to what the current locale permits
 - 802.11d is possible within those ranges that the devices allow

Does that sound sane?

johannes
