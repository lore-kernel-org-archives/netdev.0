From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Tue, 31 Mar 2015 20:11:31 +0300
Message-ID: <551AD543.1010906@list.ru>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru> <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com> <551587D1.5070408@list.ru> <5515904A.1060600@gmail.com> <55196011.7080502@list.ru> <CAGVrzcYam=zd+9DpKjhX8o+P_iksz+xOJWh0M45-GASMZbsBXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYam=zd+9DpKjhX8o+P_iksz+xOJWh0M45-GASMZbsBXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

30.03.2015 19:06, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> 2015-03-30 7:39 GMT-07:00 Stas Sergeev <stsp@list.ru>:
>> 27.03.2015 20:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> I think your concerns are valid, but I don't think there is going t=
o be
>>> any problem with the approach I suggested because there is a contra=
ct
>>> that the fixed PHYs and regular PHYs need to
>> Hello Florian.
>>
>> As promised, today I tried to resurrect my first implementation
>> and do things as you suggested: install the link_update callback
>> for mvneta privately.
>> I feel SGMII setup is very common and deserves the separate API,
>> not the per-driver handling, but in any case, I'd like to show
>> the implementation first, then discuss.
>>
>> Unfortunately, it didn't work quite right.
>> The problem is that mvneta calls phy_disconnect() on .ndo_stop
>> callback. After that, phy->attached_dev becomes NULL, and so the
>> link_update callback gets called with net_dev=3D=3DNULL! And crashs.
>> Of course I can easily work around that, but IMHO its a bug -
>> the one that actually gets fixed by the patches I posted previously.
>=20
> I actually submitted some patches a while ago that allow you to
> unregister the fixed_link_update callback before in case you need to,
> precisely for that. Since this is specific to dealing with a fixed
> PHY, it is the driver responsibility to know that is has registered a
> fixed_link_update callback and then unregister it by passing a NULL
> callback as the new callback.
Today I posted the patch that does exactly that.
But I already see the problem:
---
[   10.535424] mvneta f1030000.ethernet eth1: Link is Up - Unsupported =
(update phy.c)/Half - flow control off
---

Seems like if I register a callback after of_phy_connect()
(and unregister before disconnect), there is a small window
between connect and setting the callback. If someone at that
time will query phy, he'll get an undefined status (speed).
And before of_phy_connect() the phy_device pointer is not known
to register callback earlier. Of course I can see the possible
work-arounds, but I wonder if something better can be done
than using of_phy_find_device() and related magic right before
of_phy_connect() just for that.
