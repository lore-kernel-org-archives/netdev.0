From: Mason <slash.tmp@free.fr>
Subject: Quirks of the Atheros 8035 PHY
Date: Fri, 14 Jul 2017 23:08:03 +0200
Message-ID: <06a3ad40-ad88-c456-b643-901ea964b5aa@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:6321 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750917AbdGNVIi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 17:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've discussed this subject in the past, but we never reached
a conclusion, AFAIR.

The Atheros 8035 GigE PHY has IMO 2 quirks wrt to clock delays.

https://www.redeszone.net/app/uploads/2014/04/AR8035.pdf


1) RX clock delay

Commit 2e5f9f281ee8369f56d403b4a52942f19b6978f8

In fact, RX clock delay is *ENABLED* by default at
reset. So if a board actually required it *disabled*
then we actually need to set the bit to 0.

Reference:
4.2.25 rgmii rx clock delay control


2) TX clock delay

Commit 1ca6d1b1aef4628ff0fe458135ddb008d134ad8f

TX clock delay is DISABLED by default, so no surprises
there... except that it is only DISABLED after *HW reset*.

After a SW reset, such as that performed in Linux IIUC,
the PHY retains the value previously set.

So if a bootloader such a Uboot enabled TX delay, then
Linux would "inherit" the setting, even if it performs
a reset. If the PHY setting calls for no TX clock delay,
the Linux driver would have to actively disable it.

Reference:
4.2.26 rgmii tx clock delay control


I can (of course) send a patch fixing both issues, but
what was said last time was that "it's too late to
fix it now, since the fix risks breaking working
setups". Is that an accurate paraphrase?


3) There's also a RGMII GTX_CLK documented as
"RGMII transmit clock, 125 MHz digital. Adding a 22 ohm
damping  resistor is recommended for EMI design near MAC side"
=> Is that TX_CLK?
There's a 2-bit related field called Gtx_dly_val
which allows tweaking the delay

Select the delay of gtx_clk.
00: 0.25ns
01: 1.3ns
10: 2.4ns
11: 3.4ns
(DEFAULT 10b = 2.4 ns, BUT Retain val on SW reset,
so inherit bootloader value)
I'm not sure the current DT allows such fine-grained
tweaking? Should we enhance it?


4) There's the whole mess of having clock delays
supported both by the PHY *AND* the MAC. If both
add a delay, things won't work as expected.
What's the recommended approach there?


Regards.
