From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Checking for MDIO phy address 0
Date: Mon, 28 Nov 2016 12:25:54 -0800
Message-ID: <acbf27e0-48d3-736c-2ff4-69969ced9da7@gmail.com>
References: <1480359230293@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Phil Endecott <spam_from_netdev@chezphil.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36083 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753088AbcK1UZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:25:56 -0500
Received: by mail-pg0-f43.google.com with SMTP id f188so60192074pgc.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 12:25:56 -0800 (PST)
In-Reply-To: <1480359230293@dmwebmail.dmwebmail.chezphil.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 10:53 AM, Phil Endecott wrote:
> Dear Experts,
> 
> Is it true that phy address 0 is special, and should not be used?

It is special in that it can be made special, or not (very helpful, I
know). AFAIR, address 0 was defined a while ago (by Cisco) to be a
special broadcast address which could be used to e.g: blast the same
write to several devices. As you may imagine this can be helpful in a
switch environment where you may have to reset e.g: 48-ports.

In practice, the behavior varies a lot depending on:

- whether address 0 is potentially used to access a built-in PHY within
e.g: an Ethernet switch

- what kind of strapping options/configurations are selected for the
PHY, and whether address 0 is going to be snooped by the PHY devices's
MDIO block and how it

> I have this in my device tree (edited for brevity):
> 
>         mdio@17020000 {
>             compatible = "apm,xgene-mdio-rgmii";
>             #address-cells = <0x00000001>;
>             #size-cells = <0x00000000>;
>             phy@4 {
>                 reg = <0x00000000>;

Nit: why not make the unit address and the actual reg property match, e.g:

	phy@0 {
		reg = <0>;
	};

	phy@1 {
		reg = <1>;
	};

>                 linux,phandle = <0x00000021>;
>                 phandle = <0x00000021>;
>             };
>             phy@5 {
>                 reg = <0x00000001>;
>                 linux,phandle = <0x00000022>;
>                 phandle = <0x00000022>;
>             };
>         };
>         ethernet@1f210000 {
>             compatible = "apm,xgene1-sgenet";
>             phy-connection-type = "sgmii";
>             phy-handle = <0x00000021>;
>         };
>         ethernet@1f210030 {
>             compatible = "apm,xgene1-sgenet";
>             phy-connection-type = "sgmii";
>             phy-handle = <0x00000022>;
>         };
> 
> (This is on a Gigabyte MP30-AR1, which has an X-Gene ARM64 processor.)
> 
> I've spent a long time trying to get the two gigabit ethernet ports to 
> correctly auto-negotiate down to 100 Mbit, and it's possible that the 
> underlying problem is that one of the phys is using address 0.  Does 
> that make sense?

Maybe, but you are not exactly describing the problems you are seeing.

If the issue is that both PHYs are configured to respond to MDIO address
0, what could happen is that the Ethernet instance which references this
address 0 may end-up clobbering the other PHY's settings as well because
of the broadcast properties applied to this special address.

Few things for you to check:

- can you scan the entire bus range and see which addresses are valid,
outside of address 0 and 1, there is possibly another address at which
one of the two PHYs should respond, if not, check the next recommendation

- if you have access to the MV88E1512 datasheet, can you check if the
PHY is configured to respond to MDIO address 0, and what this implies
for reads and writes towards that address? Can you disable this and just
have address 0 be a normal (non-broadcast) address?

> 
> Anyway, my reason for this message is to suggest a runtime diagnostic 
> message somewhere if address 0 is used - this could have saved me a lot of 
> work! If someone can suggest the right place to add this I can prepare a 
> patch.

Address 0 can be made special or not, but there is no programmatic way
to tell without scanning the MDIO bus for devices, so I don't think a
warning is going to help at all to warn about that. There are also tons
of cases where the address is just treated like any other address, which
is typical with MDIO connected Ethernet switches where PHY@0 is just the
switch's port 0 built-in PHY for instance.
-- 
Florian
