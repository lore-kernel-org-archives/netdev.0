From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: Add support for a switch reset
 gpio
Date: Thu, 19 Nov 2015 15:55:31 +0100
Message-ID: <20151119145531.GB25345@lunn.ch>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-2-git-send-email-andrew@lunn.ch>
 <564D8AAF.6060901@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37297 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030196AbbKSOzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2015 09:55:35 -0500
Content-Disposition: inline
In-Reply-To: <564D8AAF.6060901@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 09:39:11AM +0100, Neil Armstrong wrote:
> Hi Andrew,
> 
> On 11/19/2015 12:29 AM, Andrew Lunn wrote:
> > +		gpio = of_get_named_gpio_flags(child, "reset-gpios", 0,
> > +					       &flags);
> > +		if (gpio_is_valid(gpio)) {
> > +			ret = devm_gpio_request_one(dev, gpio, flags,
> > +						    "switch_reset");
> > +			if (ret)
> > +				goto out_free_chip;
> > +
> > +			cd->reset = gpio;
> > +			cd->reset_flags = flags;
> > +			off = (flags && OF_GPIO_ACTIVE_LOW ? 1 : 0);
> > +			gpio_direction_output(cd->reset, off);
> > +		}
> > +
> >  		for_each_available_child_of_node(child, port) {
> >  			port_reg = of_get_property(port, "reg", NULL);
> >  			if (!port_reg)
> > 
> 
> You could also use :
> gpio = of_get_named_gpio(child, "reset-gpios", 0)
> devm_gpio_request(dev, gpio, "switch_reset")
> 
> and :
> cd->reset = gpio_to_desc(gpio);
> 
> and cd->switch reset to struct gpio_desc *reset
> 
> to use the gpiod calls afterward. The flags are no more needed.

Hi Neil

I really wanted to use gpiod, since as you said, it takes care of
active low/active high. I tried all sorts of combinations. The problem
with this one is that desc->flags is set in gpiod_parse_flags(), which
is only called from gpiod_get_index(), which is limited to gpios in
the root of the devices subtree. I was 'lucky' in that my reset is
active low, so i noticed the problem when my switch failed to probe,
being held in reset, because the ACTIVE_LOW flag in DT is being ignored.

It seems like gpiod is backwards compatible to gpio, but gpio is not
forward compatible to gpiod.

	Andrew
