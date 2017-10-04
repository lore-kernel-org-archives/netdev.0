From: =?UTF-8?Q?J=c3=b6rg_Willmann?= <joe@clnt.de>
Subject: Re: etsec2 attached to sgmii phy
Date: Wed, 4 Oct 2017 18:40:00 +0200
Message-ID: <a0213d7a-20f3-579d-cd42-f4d06c6ff64e@clnt.de>
References: <alpine.DEB.2.20.1710040756160.31757@brian.int1.clnt.de>
 <20171004133642.GM30045@lunn.ch>
 <alpine.DEB.2.20.1710041613320.9785@brian.int1.clnt.de>
 <20171004153422.GC3435@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: timur@tabi.org
To: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay01.ispgateway.de ([80.67.29.23]:30959 "EHLO
        smtprelay01.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdJDQkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 12:40:06 -0400
In-Reply-To: <20171004153422.GC3435@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 04.10.2017 um 17:34 schrieb Andrew Lunn:
> On Wed, Oct 04, 2017 at 04:19:23PM +0200, Jörg Willmann wrote:
>> On Wed, 4 Oct 2017, Andrew Lunn wrote:
>>
>>> On Wed, Oct 04, 2017 at 07:56:53AM +0200, Jörg Willmann wrote:
>>>> Hi,
>>>>
>>>> we use a QorIQ P1011 connected via SGMII to a switch (Marvell 88E6352).
>>>> Currently we still use a really old linux kernel (2.6.33) successfully.
>>>>
>>>> For configuration of the MDIO Bus attached to the corresponding eTSEC/TBI
>>>> Phy we use the following settings in the device tree:
>>>>
>>>>                         mdio@25000 {
>>>>                                    #address-cells = <0x1>;
>>>>                                    #size-cells = <0x0>;
>>>>                                    compatible = "fsl,etsec2-tbi";
>>>>                                    reg = <0x25000 0x1000 0xb1030 0x4>;
>>> Hi Joerg
>>>
>>> Is 0xb1030 0x4 fixed by the silicon? Can it be expressed as an offset from
>>> 0x25000?
>>>
>>> It seems like the idea behind the patch is to hard code some
>>> things. If you can hard code the offset into get_etsec_tbipa(), i
>>> think that would be an O.K. solution to your problem.
>>>
>>>      Andrew
>>>
>> Yes, the adress 0xb1030 is fixed but it's something totally different than
>> the address range of 0x25000. 0xb0000, 0xb1000 and 0xb2000 are base
>> addresses of the eTSEC MAC (TPIPA is a register within the MAC) and 0x24000,
>> 0x25000 and 0x26000 are the base registers of the corresponding MDIO
>> controllers. So I wouldn't add a dependency between these two things.
>> >From my point of view, the implementation in the old kernel where
>> get_gfar_tbipa() got the device tree node pointer as argument was not soo
>> bad ;-)
> I took a quick look at the current device tree files. They all seem to
> have the 0xb1030 0x4. So reading it inside of get_etsec_tbipa() is
> O.K.
>
> Looks like you need to modify all the get_tbipa() functions to take a
> device_node *, and this code looks like it needs to change:
>
>                          /*
>                           * Add consistency check to make sure TBI is contained
>                           * within the mapped range (not because we would get a
>                           * segfault, rather to catch bugs in computing TBI
>                           * address). Print error message but continue anyway.
>                           */
>                          if ((void *)tbipa > priv->map + resource_size(&res) - 4)
>                                  dev_err(&pdev->dev, "invalid register map (should be at least 0x%04zx to contain TBI address)\n",
>                                          ((void *)tbipa - priv->map) + 4);
>
>                          iowrite32be(be32_to_cpup(prop), tbipa);
>
> 	Andrew
>
Yes, exactly - I already stumbled over these lines, too. Are there any 
suggestions how to implement this the best way?
