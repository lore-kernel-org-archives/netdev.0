From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about
 RGMII
Date: Mon, 28 Nov 2016 11:34:27 +0100
Message-ID: <4c71a69c-2942-f177-ef25-04686f5e4149@laposte.net>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz27.laposte.net ([194.117.213.102]:47237 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754525AbcK1Keb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 05:34:31 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout015 (Postfix) with ESMTP id A0B751C943C
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:34:28 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout015 (Postfix) with ESMTP id 90AEF1C9400
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:34:28 +0100 (CET)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.prosodie [10.128.63.3])
        by lpn-prd-vrout015 (Postfix) with ESMTP id 8BDAF1C9473
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:34:28 +0100 (CET)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
        by lpn-prd-vrin002 (Postfix) with ESMTP id 800735BF5A0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:34:28 +0100 (CET)
In-Reply-To: <20161127184449.12351-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/11/16 19:44, Florian Fainelli wrote:
> RGMII is a recurring source of pain for people with Gigabit Ethernet
> hardware since it may require PHY driver and MAC driver level
> configuration hints. Document what are the expectations from PHYLIB and
> what options exist.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  Documentation/networking/phy.txt | 76 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 76 insertions(+)
> 
> diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
> index 9a42a9414cea..7a0cb1212b9e 100644
> --- a/Documentation/networking/phy.txt
> +++ b/Documentation/networking/phy.txt
> @@ -65,6 +65,82 @@ The MDIO bus
>   drivers/net/ethernet/freescale/fsl_pq_mdio.c and an associated DTS file
>   for one of the users. (e.g. "git grep fsl,.*-mdio arch/powerpc/boot/dts/")
>  
> +(RG)MII/electrical interface considerations
> +
> + The Reduced Gigabit Medium Independent Interface (RGMII) is a 12 pins
> + electrical signal interface using a synchronous 125Mhz clock signal and several
> + data lines. Due to this design decision, a 1.5ns to 2ns delay must be added
> + between the clock line (RXC or TXC) and the data lines to let the PHY (clock
> + sink) have enough setup and hold times to sample the data lines correctly. The
> + PHY library offers different types of PHY_INTERFACE_MODE_RGMII* values to let
> + the PHY driver and optionaly the MAC driver implement the required delay. The
> + values of phy_interface_t must be understood from the perspective of the PHY
> + device itself, leading to the following:
> +
> + * PHY_INTERFACE_MODE_RGMII: the PHY is not responsible for inserting any
> +   internal delay by itself, it assumes that either the Ethernet MAC (if capable
> +   or the PCB traces) insert the correct 1.5-2ns delay

For what is worth, the Atheros at803x driver comes with RX delay enabled as per HW
reset.
I understand that enforcing this documentation as is would result in changing the
driver to disable RX delay, but it could break existing DTs, so I don't know if that
path will be pursued.

Would explicit "versioning" the DT nodes be something worth exploring? So far it
seems the versioning is implicit: driver probably check the presence of some property
and conclude that it has to behave in a way or another.

> +
> + * PHY_INTERFACE_MODE_RGMII_TXID: the PHY should be inserting an internal delay
> +   for the transmit data lines (TXD[3:0]) processed by the PHY device
> +
> + * PHY_INTERFACE_MODE_RGMII_RXID: the PHY should be inserting an internal delay
> +   for the receive data lines (RXD[3:0]) processed by the PHY device
> +
> + * PHY_INTERFACE_MODE_RGMII_ID: the PHY should be inserting internal delays for
> +   both transmit AND receive data lines from/to the PHY device
> +
> + Whenever it is possible, it is preferrable to utilize the PHY side RGMII delay
> + for several reasons:
> +
> + * PHY devices may offer sub-nanosecond granularity in how they allow a
> +   receiver/transmitter side delay (e.g: 0.5, 1.0, 1.5ns) to be specified. Such
> +   precision may be required to account for differences in PCB trace lengths
> +
> + * PHY devices are typically qualified for a large range of applications
> +   (industrial, medical, automotive...), and they provide a constant and
> +   reliable delay across temperature/pressure/voltage ranges
> +
> + * PHY device drivers in PHYLIB being reusable by nature, being able to
> +   configure correctly a specified delay enables more designs with similar delay
> +   requirements to be operate correctly
> +
> + For cases where the PHY is not capable of providing this delay, but the
> + Ethernet MAC driver is capable of doing it, the correct phy_interface_t value
> + should be PHY_INTERFACE_MODE_RGMII, and the Ethernet MAC driver should be
> + configured correctly in order to provide the required transmit and/or receive
> + side delay from the perspective of the PHY device. 

While this clarifies the current situation very well, wouldn't the proposed approach
require that a property such as "txid-delay-ns" on the PHY's DT node to be duplicated
for the MAC?

>Conversely, if the Ethernet
> + MAC driver looks at the phy_interface_t value, for any other mode but
> + PHY_INTERFACE_MODE_RGMII, it should make sure that the MAC-level delays are
> + disabled.
> +
> + In case neither the Ethernet MAC, nor the PHY are capable of providing the
> + required delays, as defined per the RGMII standard, several options may be
> + available:
> +
> + * Some SoCs may offer a pin pad/mux/controller capable of configuring a given
> +   set of pins' drive strength, delays and voltage, and it may be a suitable
> +   option to insert the expected 2ns RGMII delay
> +
> + * Modifying the PCB design to include a fixed delay (e.g: using a specifically
> +   designed serpentine), which may not require software configuration at all
> +
> +Common problems with RGMII delay mismatch
> +
> + When there is a RGMII delay mismatch between the Ethernet MAC and the PHY, this
> + will most likely result in the clock and data line sampling to capture unstable
> + signals, typical symptoms include:
> +
> + * Transmission/reception partially works, and there is frequent or occasional
> +   packet loss observed
> +
> + * Ethernet MAC may report some, or all packets ingressing with a FCS/CRC error,
> +   or just discard them all
> +
> + * Switching to lower speeds such as 10/100Mbits/sec makes the problem go away
> +   (since there is enough setup/hold time in that case)
> +
> +
>  Connecting to a PHY
>  
>   Sometime during startup, the network driver needs to establish a connection
> 
