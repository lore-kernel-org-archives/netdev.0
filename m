From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Mon, 30 Mar 2015 09:06:18 -0700
Message-ID: <CAGVrzcYam=zd+9DpKjhX8o+P_iksz+xOJWh0M45-GASMZbsBXA@mail.gmail.com>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru>
 <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com>
 <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com>
 <551587D1.5070408@list.ru> <5515904A.1060600@gmail.com> <55196011.7080502@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55196011.7080502@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-03-30 7:39 GMT-07:00 Stas Sergeev <stsp@list.ru>:
> 27.03.2015 20:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> I think your concerns are valid, but I don't think there is going to=
 be
>> any problem with the approach I suggested because there is a contrac=
t
>> that the fixed PHYs and regular PHYs need to
> Hello Florian.
>
> As promised, today I tried to resurrect my first implementation
> and do things as you suggested: install the link_update callback
> for mvneta privately.
> I feel SGMII setup is very common and deserves the separate API,
> not the per-driver handling, but in any case, I'd like to show
> the implementation first, then discuss.
>
> Unfortunately, it didn't work quite right.
> The problem is that mvneta calls phy_disconnect() on .ndo_stop
> callback. After that, phy->attached_dev becomes NULL, and so the
> link_update callback gets called with net_dev=3D=3DNULL! And crashs.
> Of course I can easily work around that, but IMHO its a bug -
> the one that actually gets fixed by the patches I posted previously.

I actually submitted some patches a while ago that allow you to
unregister the fixed_link_update callback before in case you need to,
precisely for that. Since this is specific to dealing with a fixed
PHY, it is the driver responsibility to know that is has registered a
fixed_link_update callback and then unregister it by passing a NULL
callback as the new callback.

So yes, it is a bug in the sense that it is not transparently handled,
but at the same time, the PHY library has no way to know whether a
fixed_link_update callback is being invoked since it is not poking
into the fixed PHY driver.


> They were changing the callback to receive phy_device instead of
> net_device, and so NULL will never be passed.

Ok, but then you may still poll a PHY which has no network device
attached to it, so that leads to worse drivers which might not be
doing the right thing wrt. power management or other things.

> I am attaching the new patch so that you can take a look and decide.
> If you still think its fine, even despite the NULL passing w/a, then
> I'll mail it with the proper boilerplate. But if you agree that
> passing NULL to link_update is a bug, then maybe you'll decide to
> get the whole surgery thing. :)

[snip]

> @@ -304,6 +310,7 @@ struct mvneta_port {
>         unsigned int link;
>         unsigned int duplex;
>         unsigned int speed;
> +       int inband_status;

Since you are essentially using this variable as a boolean to indicate
whether in-band status should be queried or not, maybe you should name
that "needs_inband_status" or "wants_inband_status", inband_status
would suggest that this is the data-structure holding all the in-band
status information, but that's pure nitpicking.
--
=46lorian
