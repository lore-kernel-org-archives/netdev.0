From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Mon, 14 Mar 2016 09:51:47 -0700
Message-ID: <56E6EC23.9080301@gmail.com>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <56E35432.2010300@gmail.com> <20160311233610.GB23969@lunn.ch>
 <56E35712.5080508@gmail.com> <20160312001224.GE23969@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36636 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764AbcCNQxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 12:53:23 -0400
Received: by mail-pa0-f43.google.com with SMTP id tt10so161412114pab.3
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 09:53:23 -0700 (PDT)
In-Reply-To: <20160312001224.GE23969@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 16:12, Andrew Lunn wrote:
>>>> Humm, if that's the problem we want to solve, we could introduce a
>>>> helper function which tries to locate the phy using a 'phy-handle'
>>>> property
>>>
>>> I don't follow you. Where do you get a phandle from to use with
>>> phy-handle?
>>
>> >From the caller of the function: the consumer of that phy-handle and/or
>> fixed-link property which is either an Ethernet MAC driver or a DSA's
>> switch port node.
> 
> I still don't get it. Lets take a real example. I currently have this
> in one of my dts files:
> 
> &fec1 {
>        phy-mode = "rmii";
>        pinctrl-names = "default";
>        pinctrl-0 = <&pinctrl_fec1>;
>        status = "okay";
> 
>        fixed-link {
>                   speed = <100>;
>                   full-duplex;
>        };
> };

All drivers have this exact same structure:

&fec1 {
	phy-handle = <XYZ>;
	or
	fixed-link {
		speed = <100>;
		full-duplex;
	};
};

In both cases, the argument that this proposed helper function would
take is a struct device_node pointing to &fec1 here. You could therefore
imagine having something along these lines:

struct device_node *of_get_phy_by_phandle(struct device_node *dn, bool
try_fixed_link)
{
	struct device_node *phy_dn;
	int ret;

	phy_dn = of_parse_phandle(dn, "phy-handle", 0);
	if (!phy_dn && !try_fixed_link)
		return -ENODEV;

	if (of_phy_is_fixed_link(dn)) {
		ret  = of_phy_register_fixed_link(dn);
		if (ret)
			return PTR_ERR(-ret);

		phy_dn = of_node_get(dn);
	}

	return phy_dn;		
}

In fact, we could even remove the "try_fixed_link" argument and just see
if of_phy_is_fixed_link() returns true. Yes, this is not a proper
device_node pointing to the emulated PHY, but without introducing
binding changes, that is probably the best we can do.

I mistakenly used the term 'phandle' when I actually meant 'struct
device_node' reference.
-- 
Florian
