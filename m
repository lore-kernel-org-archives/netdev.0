From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH net-next 2/2] dsa: mv88e6xxx.c: Hardware reset the chip if
 available
Date: Thu, 19 Nov 2015 14:32:43 +0800
Message-ID: <564D6D0B.8010204@electromag.com.au>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-3-git-send-email-andrew@lunn.ch>
 <564D2F16.1020701@electromag.com.au> <20151119022514.GE25930@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy3.45ru.net.au ([203.30.46.155]:58842 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752314AbbKSGcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 01:32:50 -0500
In-Reply-To: <20151119022514.GE25930@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/11/2015 10:25 AM, Andrew Lunn wrote:
 >> This is a general query about what is the preferred method of allocating gpios.
 >> The gpiod* family of functions provided similar functionality and automatically
 >> deal with active low / high outputs, direction, inital value  etc...
 >> I raise this more for knowledge on what method I should use for my patches.
 >
 > I first tried using gpiod, but failed. The API requires that the gpios
 > be in the root of the device's subtree in the DT blob. But here the
 > gpios are associated to a switch, and the switch part of the subtree
 > is one level down. gpiod has no way to get them from there.
Hadn't dug into the gpiod stuff that far. Yes looks like there limited support for
extracting from sub nodes. There's devm_get_gpiod_from_child which looks like it
does something like that but I don't have any idea how to go from an of_node to
a fwnode_handle.

 > +		gpio = of_get_named_gpio_flags(child, "reset-gpios", 0,
 > +					       &flags);
 > +		if (gpio_is_valid(gpio)) {
 > +			ret = devm_gpio_request_one(dev, gpio, flags,
 > +						    "switch_reset");
 > +			if (ret)
 > +				goto out_free_chip;

The flags passed into devm_gpio_request_one are of type GPIOF_* which don't
match the device tree definitions for flags. As your handling the device flags
manually I think devm_gpio_request_one flags should be 0. Or you can translate
the device tree flags and get devm_gpio_request_one to configure the polarity etc.
Then I think you don't need to do your polarity inversions later on.

 >
 >> Other than that the concept looks good and something I has been
 >> looking at adding.
 >
 > Please feel free to test it on your hardware and send a Tested-by :-)
Worked as expected on my hardware, can see the line toggle, chip is configured correctly.

Tested-by: Phil Reid <preid@electromag.com.au>


 >
 >> Would it be worth considering placing the chip in reset on driver
 >> remove?  I have an battery powered hardware platform using one of
 >> this marvell devices and for certain configurations we don't need
 >> the switch active. So unloading the module to place the device in
 >> reset and would save power.  Reloading would reinitialise the port.
 >
 > I think we first need to get module unload/load working reliably.
 > This is being worked on. But i'm not against this in principle.  Power
 > saving in general needs working on for Marvall devices. There is no
 > suspend/resume support for example. It would also be good to ensure
 > the PHYs are powered off when not needed, etc.
Seems a sound plan.




-- 
Regards
Phil Reid
