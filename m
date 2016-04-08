From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 8 Apr 2016 16:25:42 -0700
Message-ID: <20160408232542.GL391@tuxbot>
References: <20151231231039.GA8886@rob-hp-laptop>
 <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
 <5706B4EF.2050600@codeaurora.org>
 <20160407201009.GA16136@lunn.ch>
 <5706D493.8020700@codeaurora.org>
 <20160408005317.GA28125@lunn.ch>
 <5708013F.90207@codeaurora.org>
 <CAOCOHw5R=PnkafRqx2eGKKm10eLgD4H3u7TjbbhdZMbqVR7LrA@mail.gmail.com>
 <57083834.2060102@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh@kernel.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org, Christopher Covington <cov@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57083834.2060102@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 08 Apr 16:01 PDT 2016, Timur Tabi wrote:

> Bjorn Andersson wrote:
> 
> >It sounds like you're trying to say that the pins used can be are
> >muxed as GPIO or MDIO, in the TLMM.
> 
> I'm not 100% sure, but I think that's correct.  If you don't want to have
> normal networking, you could connect those external pins to some GPIO device
> (like an LED or whatever), and then configure the pin muxing for GPIO
> purposes.  But if that's true, it's only true on the FSM9900. On the
> QDF2432, those lines are not connected to the TLMM.  They are instead
> hard-wired to the Emac.
> 

Then through proper use of the pinctrl framework you should configure
the FSM9900 to mux these pins appropriately and the two solutions are
equivalent.

> >In the downstream kernel this is often seen with the drivers calling
> >gpio_request() to "reserve" said pins, but all you should do is
> >described the desired configuration and muxing in the pinctrl node,
> >reference that from your driver and simply ignore the fact that those
> >pins could have been used as GPIO pins.
> 
> That makes sense, but I think the driver already does that.
> 
> https://patchwork.ozlabs.org/patch/561667/
> 
> Function emac_probe_resources() has a call to of_get_named_gpio().  And then
> emac_mac_up() calls gpio_request().  As far as I can tell, that's it.
> 
> I'm guessing that the of_get_named_gpio() call needs to be changed somehow,
> but I'm not sure how.
> 

Thanks for the link.

In short those call to the gpio framework should just be removed. They
should only be there if you're using the gpiolib to control the state of
those pins, and you're not as far as I can see.


The general outline of what you should have in your dts instead is:

soc {
	tlmm {
		compatible = "qcom,pinctrl-xyz";

		mdio_pins_a: mdio {
			state {
				pins = "gpio0", "gpio1";
				function = "mdio";
			};
		};
	};

	emac {
		compatible = "qcom,somthing-emac";

		pinctrl-names = "default";
		pinctrl-0 = <&mdio_pins_a>;
	};
};

Regards,
Bjorn
