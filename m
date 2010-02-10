From: Andy Fleming <afleming@freescale.com>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 13:46:06 -0600
Message-ID: <99A0D59F-3DAA-4ACD-899B-7D139E286D6D@freescale.com>
References: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>  <fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>  <7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>  <fa686aa41002101014s43682e3cra55854b82a40bb5f@mail.gmail.com>  <AE7D03BA-0763-42F3-A27B-A6214CE7249E@freescale.com> <fa686aa41002101120v56ef5e7cm64e5505cc7bedc1d@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: John Linn <John.Linn@xilinx.com>,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43400 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184Ab0BJTqN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:46:13 -0500
In-Reply-To: <fa686aa41002101120v56ef5e7cm64e5505cc7bedc1d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 10, 2010, at 1:20 PM, Grant Likely wrote:

> On Wed, Feb 10, 2010 at 11:40 AM, Fleming Andy-AFLEMING
> <afleming@freescale.com> wrote:
>> 
>> 
>> On Feb 10, 2010, at 12:15, "Grant Likely" <grant.likely@secretlab.ca> wrote:
>> 
>>> On Wed, Feb 10, 2010 at 9:52 AM, John Linn <John.Linn@xilinx.com> wrote:
>>>>> 
>>>>> -----Original Message-----
>>>>> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of
>>>>> Grant Likely
>>>>> Sent: Wednesday, February 10, 2010 9:44 AM
>>>>> To: John Linn; devicetree-discuss; netdev
>>>>> Subject: Re: phy address in the device tree, vs auto probing
>>>>> 
>>>>> (cc'ing devicetree-discuss and netdev mailing lists)
>>>>> 
>>>>> On Tue, Feb 9, 2010 at 4:23 PM, John Linn <John.Linn@xilinx.com> wrote:
>>>>>> 
>>>>>> Hi Grant,
>>>>>> 
>>>>>> I notice that the OF driver for the mdio bus is not doing auto probing.
>>>>>> 
>>>>>> As we start putting in the phy layer in the emac drivers, the device
>>>>>> trees tend to have the phy address in them, but we're not sure we
>>>>>> really
>>>>>> like that.
>>>>>> 
>>>>>> We really think that being able to let the kernel find the phy address
>>>>>> is a big benefit, otherwise this is one other piece of info the user
>>>>>> has
>>>>>> to know and get right.
>>>>>> 
>>>>>> Am I missing something here?
>>>>> 
>>>>> No, you're not really missing something, but there is an inherent
>>>>> complexity in what you're wanting to do.  Like i2c, MDIO is one of
>>>>> those busses that is hard to probe reliable.  Some PHYs respond on
>>>>> more than one address, and there is no way to determine which MAC a
>>>>> PHY is wired up to.  Many PHYs can live on a single MDIO bus.  MACs
>>>>> with their own MDIO busses may still get wired to a PHY on a different
>>>>> bus.
>>>>> 
>>>>> In the simple case where there is a one:one:one relationship between
>>>>> MAC, MDIO bus and PHY, then it should be okay to probe the PHY,
>>>>> correct?  The question then must be asked; how does the kernel
>>>>> determine that it can use the simple case?  Nobody has yet defined a
>>>>> way to describe that in the device tree; mostly because nobody has
>>>>> needed to yet.
>>>>> 
>>>>> So, it is possible to do what you want, but you need a way to
>>>>> *explicitly* ask for that behaviour.  ie, some way to indicate in a
>>>>> MAC node which MDIO bus the phy is on, and that the phy needs to be
>>>>> probed for.  I think this should only be an option when the MDIO bus
>>>>> has only one PHY.  Come up with a proposal and post it to the
>>>>> devicetree-discuss mailing list.
>>>> 
>>>> Here's a couple ideas. See what everyone thinks as I'm not stuck on
>>>> either.
>>>> 
>>>> Thanks,
>>>> John
>>>> 
>>>> 1. What if we just don't specific a phy address with a reg property which
>>>> would specify to auto probe it and find the phy as illustrated below?
>>>> 
>>>> 
>>>>               Ethernet_MAC: ethernet@81000000 {
>>>>                       #address-cells = <1>;
>>>>                       #size-cells = <1>;
>>>>                       phy-handle = <&phy0>;
>>>>                       mdio {
>>>>                               #address-cells = <1>;
>>>>                               #size-cells = <0>;
>>>>                               phy0: phy@7 {
>>>>                               } ;
>>>>                       } ;
>>>> 
>>>> 2. Or a special value (-1 or something not 0 - 31) in the phy address
>>>> that specifies to auto probe as illustrated below.
>>>>                               phy0: phy@7 {
>>>>                                       reg = <-1>;
>>>>                               } ;
>>> 
>>> I don't like abusing the reg property in this way.  I wonder if a new
>>> empty property would be a better way to indicate this.  Maybe
>>> "phy-probe-address;"?  It would also be important to specify in the
>>> binding that only one phy node is allowed when phy-probe-address is
>>> used.
>> 
>> I don't think it's necessary that only one phy node is there.  I don't think
>> the of mdio layer should set policy, here.  Some drivers hard code their
>> addresses.  Some drivers assume (foolishly, I think) that the PHYs are in
>> order.  Many assume there's only one PHY.  I think the mdio driver should
>> set policy, so of_mdio should just allow for PHYs to be probed.  I'm
>> actually not sure that requires any changes.  Quite possibly this just means
>> that of_mdio is not appropriate for such a driver.   The standard PHY code
>> supports this sort of thing.
> 
> That still doesn't solve the problem of matching PHYs to MACs.
> 
> Consider this example:  2 MACs, 2 PHYs.  mac_a--> phy_a and mac_b -->
> phy_b.  Both phys on the same mdio bus, described thus:
> 
>               eth_a: ethernet@81000000 {
>                       #address-cells = <1>;
>                       #size-cells = <1>;
>                       phy-handle = <&phy_a>;
>                       mdio {
>                               #address-cells = <1>;
>                               #size-cells = <0>;
>                               phy_a: phy_a {
>                               } ;
>                               phy_b: phy_b {
>                               } ;
>                       } ;
>               } ;
>               eth_b: ethernet@82000000 {
>                       #address-cells = <1>;
>                       #size-cells = <1>;
>                       phy-handle = <&phy_b>;
>               } ;
> 
> In this example, the kernel knows it has two phys, and probing
> confirms this (say at phy addresses 3 and 7).  How does the kernel
> know which address phy_a responds to?


There's no way to know.  That's what I'm saying.  We shouldn't modify the of_mdio code to say which PHY is which.  Instead, we have the MDIO/ethernet code do that.  And maybe this means that they can't use of_mdio.  Or maybe we need to devise a scheme so you can specify those PHYs, but delay associating them with an address until later.

Andy