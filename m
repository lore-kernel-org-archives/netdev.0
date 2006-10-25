From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Wed, 25 Oct 2006 12:18:18 -0400
Message-ID: <43e72e890610250918t505b117lfb2cb39dd8f444c5@mail.gmail.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
	 <1161646361.3942.21.camel@johannes.berg>
	 <43e72e890610232233t14ee98f6j5d5facf1b7aab08b@mail.gmail.com>
	 <20061024120303.GB30724@tuxdriver.com>
	 <43e72e890610241041l5d442753xd6cef0bca789db33@mail.gmail.com>
	 <20061025102443.3997dbad@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, "Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:13263 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932444AbWJYQSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 12:18:20 -0400
Received: by ug-out-1314.google.com with SMTP id 32so140292ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 09:18:19 -0700 (PDT)
To: "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <20061025102443.3997dbad@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/06, Jiri Benc <jbenc@suse.cz> wrote:
> On Tue, 24 Oct 2006 13:41:12 -0400, Luis R. Rodriguez wrote:
> > Sure -- we can have on the ieee80211_conf struct an array of all
> > regulatory domains stack values that the device supports
> > (REGDOMAIN_FCC or 0x10 for FCC for example) if the developer agrees
> > the device has been certified to match the regulatory domain
> > restrictions as the stack defines it. I believe most modern devices
> > adhere to the PtMP restrictions pretty loosely and the magic is left
> > to the driver when the device is being certified so ultimately I see
> > devices sharing regulatory domains restrictions rather than defining
> > their own though. I'd consider defining your own device-specific
> > regulatory domain would be more of an exception we'd have to deal with
> > but that remains to be seen yet huh.
>
> It sounds overcomplicated to me. I'd rather like to see something like
> this:
> 1. As part of the initialization of the hardware, the driver detects
>    that the device is certified for (say) channels 2 to 10 (that's not
>    a real-life example, fortunately :-)).

BTW we should also record the max Intentional Radiator (IR) power and
define the default antenna gain then. That way the max IR to be used
can be restricted by regdomain max EIRP - antenna gain. Currently
d80211.h ieee80211_conf has a u8 power_level and u8 antenna_max. I
assume antenna_max here is max antenna gain, but is power_level max IR
or max computed EIRP? If its max IR then great.

> 2. The driver reports this somewhere (softmac drivers would report this
>    to the stack).

The the ieee80211_conf struct should work.

> 3. Based on outside conditions (userspace - or something - tells us
>    about actual regdomain), the stack (or whatever) calls the driver and
>    passes allowed channels etc. to it (if the driver wants that
>    information). There is already previously reported driver's
>    limitation taken in the account in that information.

BTW this was what I intended for phase I for ieee80211_regdomain on
d80211. Currently d80211 drivers define their channels as an array.
After we cleared how we'd integrate it into the stack I then wanted to
write a get_reg_channels(dev) and we'd use the device's mode and stack
regdomain to give the driver back all valid channels for the stack's
current regdomain.

> 4. If the outside conditions change (802.11d or user emigrates or
>    something) that callback is called again with a new data.

Through this approach the question then becomes do we inspect the
device's saved limitations and compare to available regulatory domains
and

(a) based on that comparison select only a few regulatory domains that
the device supports, or
(b) do we do allow the device to jump to any regulatory domain and
later do the proper validation?

I think (a) is the way to go and is similar to what I suggested in the
quoted text above but is more of a dynamic autoselection of supported
regultory domains vs the driver-writer-lists-supported-regdomains
approach.

This is overcomplicated but AFAICT no other wireless stack has taken a
good stab at assuring devices comply to regdomains centrally through a
wireless stack. The problem is that dealing with all wireless devices
and coming up with a way to assure all do comply to regulatory domains
in a meaninful logical way without regard to where the MLME is
implemented is slightly overcomplicated.

> I.e.:
> - I see no point in building a list of regdomains suported by the
>   hardware.

Point taken -- the regulatory domain should just mask the device's
capabilities based on locale.

> - It's pretty common that the device has some limitation stated in the
>   EPROM and the stack/something should deal with it in a way that is easy
>   to use in a driver.

ACK

  Luis
