From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about
 RGMII
Date: Mon, 28 Nov 2016 09:43:42 -0800
Message-ID: <60473447-423c-7dff-6647-cce7cf2d4ab2@gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
 <4c71a69c-2942-f177-ef25-04686f5e4149@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        mason <slash.tmp@free.fr>
To: Sebastian Frias <sf84@laposte.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33639 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbcK1Rnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:43:47 -0500
Received: by mail-pf0-f195.google.com with SMTP id 144so6815498pfv.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:43:46 -0800 (PST)
In-Reply-To: <4c71a69c-2942-f177-ef25-04686f5e4149@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 02:34 AM, Sebastian Frias wrote:
> On 27/11/16 19:44, Florian Fainelli wrote:
>> RGMII is a recurring source of pain for people with Gigabit Ethernet
>> hardware since it may require PHY driver and MAC driver level
>> configuration hints. Document what are the expectations from PHYLIB and
>> what options exist.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  Documentation/networking/phy.txt | 76 ++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 76 insertions(+)
>>
>> diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
>> index 9a42a9414cea..7a0cb1212b9e 100644
>> --- a/Documentation/networking/phy.txt
>> +++ b/Documentation/networking/phy.txt
>> @@ -65,6 +65,82 @@ The MDIO bus
>>   drivers/net/ethernet/freescale/fsl_pq_mdio.c and an associated DTS file
>>   for one of the users. (e.g. "git grep fsl,.*-mdio arch/powerpc/boot/dts/")
>>  
>> +(RG)MII/electrical interface considerations
>> +
>> + The Reduced Gigabit Medium Independent Interface (RGMII) is a 12 pins
>> + electrical signal interface using a synchronous 125Mhz clock signal and several
>> + data lines. Due to this design decision, a 1.5ns to 2ns delay must be added
>> + between the clock line (RXC or TXC) and the data lines to let the PHY (clock
>> + sink) have enough setup and hold times to sample the data lines correctly. The
>> + PHY library offers different types of PHY_INTERFACE_MODE_RGMII* values to let
>> + the PHY driver and optionaly the MAC driver implement the required delay. The
>> + values of phy_interface_t must be understood from the perspective of the PHY
>> + device itself, leading to the following:
>> +
>> + * PHY_INTERFACE_MODE_RGMII: the PHY is not responsible for inserting any
>> +   internal delay by itself, it assumes that either the Ethernet MAC (if capable
>> +   or the PCB traces) insert the correct 1.5-2ns delay
> 
> For what is worth, the Atheros at803x driver comes with RX delay enabled as per HW
> reset.

Always, or is this a behavior possibly defined via a stra-pin that can
be changed?

> I understand that enforcing this documentation as is would result in changing the
> driver to disable RX delay, but it could break existing DTs, so I don't know if that
> path will be pursued.

Which is why the documentation update proposed indicates preferred vs.
mandatory.

> 
> Would explicit "versioning" the DT nodes be something worth exploring? So far it
> seems the versioning is implicit: driver probably check the presence of some property
> and conclude that it has to behave in a way or another.

I would not go that route, can of worms.

> 
>> +
>> + * PHY_INTERFACE_MODE_RGMII_TXID: the PHY should be inserting an internal delay
>> +   for the transmit data lines (TXD[3:0]) processed by the PHY device
>> +
>> + * PHY_INTERFACE_MODE_RGMII_RXID: the PHY should be inserting an internal delay
>> +   for the receive data lines (RXD[3:0]) processed by the PHY device
>> +
>> + * PHY_INTERFACE_MODE_RGMII_ID: the PHY should be inserting internal delays for
>> +   both transmit AND receive data lines from/to the PHY device
>> +
>> + Whenever it is possible, it is preferrable to utilize the PHY side RGMII delay
>> + for several reasons:
>> +
>> + * PHY devices may offer sub-nanosecond granularity in how they allow a
>> +   receiver/transmitter side delay (e.g: 0.5, 1.0, 1.5ns) to be specified. Such
>> +   precision may be required to account for differences in PCB trace lengths
>> +
>> + * PHY devices are typically qualified for a large range of applications
>> +   (industrial, medical, automotive...), and they provide a constant and
>> +   reliable delay across temperature/pressure/voltage ranges
>> +
>> + * PHY device drivers in PHYLIB being reusable by nature, being able to
>> +   configure correctly a specified delay enables more designs with similar delay
>> +   requirements to be operate correctly
>> +
>> + For cases where the PHY is not capable of providing this delay, but the
>> + Ethernet MAC driver is capable of doing it, the correct phy_interface_t value
>> + should be PHY_INTERFACE_MODE_RGMII, and the Ethernet MAC driver should be
>> + configured correctly in order to provide the required transmit and/or receive
>> + side delay from the perspective of the PHY device. 
> 
> While this clarifies the current situation very well, wouldn't the proposed approach
> require that a property such as "txid-delay-ns" on the PHY's DT node to be duplicated
> for the MAC?

The property name can be identical and represent essentially the same
things, but as as described, if the delay is implemented by the PHY,
then the MAC should disable it, conversely if the MAC needs to implement
it, the PHY should not contain any delay property. If both are found,
because the DTS is miswritten, then, the drivers should ignore/error out.

Or are you thinking about the case you described earlier with delays
that are neither 0 or 2, but e.g: 1 and 3 and you still want to have the
end-result be somewhere around 2ns?
-- 
Florian
