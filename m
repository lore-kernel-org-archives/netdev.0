From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Mon, 11 Aug 2014 13:56:26 -0700
Message-ID: <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org>
References: <1407780269.28221.63.camel@chimera> <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org> <1407789645.28221.68.camel@chimera>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407789645.28221.68.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

>> isn't this dangerous to just allow writing to wiphy.perm_addr via
>> sysfs. We ran into the same issue with Bluetooth and ROM only devices
>> that have to unique address. Doing this via sysfs seems the wrong
>> approach. It is messy and full of potential race conditions. I clearly
>> opted against the sysfs solution for Bluetooth. Instead we build an
>> infrastructure that allowed doing it cleanly via the Bluetooth mgmt
>> API. Controllers that have no unique address are brought up as
>> unconfigured and userspace clearly knows that it has to take steps to
>> get an address programmed into the controller.
> 
> My inclination is to agree; however, this does not exist for WiFi and
> implementing it would require modifying every single driver.

so what? That is not a reason to just hack something into sysfs. If it means every driver needs to be modified, then that has to be done.

>> And I think something similar should be done for WiFi. It might be
>> better to not create the initial wlan0 netdev interface if the
>> hardware has not a single unique address available. That way the
>> supplicant can just either get one from the flash filesystem or make
>> up a proper random one before creating the netdev interface.
>> 
> The initial wlan0 netdev interface is *not* created, but the PHY records
> a MAC address that cannot be overriden at the level that this sysfs node
> reads. Perhaps a compromise would be to create a single new syscall to
> write to it?

The initial wlan0 can be removed as every other netdev attached to the wiphy. It can also be as easily re-created.

Since the wiphy does not have a valid MAC address, my proposal here would be to just not create the wlan0 in the first place. This means that the wiphy can be still discovered via nl80211.

It also means that the wlan0 netdev needs to be created by userspace now. And a valid NL80211_ATTR_MAC be provided. Similar to what is already done for P2P devices at the moment. That should just solve the problem.

We really do not want to announce a netdev when registering the wiphy device and then having to mess with its MAC address via sysfs somehow. This all needs to be properly reflected over RTNL.

Regards

Marcel
