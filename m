From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH net v2 2/3] drivers: net: cpsw: fix error messages when
 using phy-handle DT property
Date: Tue, 26 Apr 2016 10:50:08 +0300
Message-ID: <571F1DB0.9060609@ti.com>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
 <1461263172-10428-1-git-send-email-drivshin.allworx@gmail.com>
 <571A2126.2060708@ti.com>
 <20160422114545.57b477ad.drivshin.allworx@gmail.com>
 <571E6C14.8060007@ti.com>
 <20160425175542.3654cc33.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:57211 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbcDZHum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 03:50:42 -0400
In-Reply-To: <20160425175542.3654cc33.drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2016 12:55 AM, David Rivshin (Allworx) wrote:
> On Mon, 25 Apr 2016 22:12:20 +0300
> Grygorii Strashko <grygorii.strashko@ti.com> wrote:
>
>> On 04/22/2016 06:45 PM, David Rivshin (Allworx) wrote:
>>> On Fri, 22 Apr 2016 16:03:34 +0300
>>> Grygorii Strashko <grygorii.strashko@ti.com> wrote:
>>>
>>>> On 04/21/2016 09:26 PM, David Rivshin (Allworx) wrote:
>>>>> From: David Rivshin <drivshin@allworx.com>
>>>>>
>>>>> The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
>>>>> and only one need be specified. However if phy-handle was specified, an
>>>>> error message would complain about the lack of phy_id or fixed-link.
>>
>> I think, commit message need to be updated.
>> You not only fix log messages - you also fix the issue with
>> of_get_phy_mode(slave_node); which will not be called if phy-handle is used.
>
> You are correct, and that is probably the more important fix compared
> to the error messages.
>
> Because the content is becoming less coherent, what I may do is split
> this patch into 3 small patches:
> A) devicetree binding documentation changes
> B) cpsw_probe_dt changes, with the fixes for of_get_phy_mode() and
>     related error message
> C) cpsw_slave_open changes, with the fixes for crash if of_phy_connect
>     returns NULL, and related error message
>
> Does that sound reasonable?

Sounds reasonable for me.
Hope patch 1 from this series could be merged separately.

>
>>
>>
>> slave_data->phy_if = of_get_phy_mode(slave_node);
>> ^ see below
>>>>>
>>>>> Also, if phy-handle was specified and the subsequent of_phy_connect()
>>>>> failed, the error message still referenced slaved->data->phy_id, which
>>>>> would be empty. Instead, use the name of the device_node as a useful
>>>>> identifier.
>>>>>
>>>>> Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
>>>>> Signed-off-by: David Rivshin <drivshin@allworx.com>
>>>>> Acked-by: Rob Herring <robh@kernel.org>
>>>>> Tested-by: Nicolas Chauvet <kwizart@gmail.com>
>>>>> ---
>>>>> If would like this for -stable it should apply cleanly as far back
>>>>> as 4.5. It failes on 4.4 due to some context differences, but can be
>>>>> applied with 'git am -C2'. Or, I can produce a separate patch against
>>>>> linux-4.4.y if preferred.
>>>>>
>>>>> Changes since v1 [1]:
>>>>> - Rebased (no conflicts)
>>>>> - Added Tested-by from Nicolas Chauvet
>>>>> - Added Acked-by from Rob Herring for the binding change
>>>>>
>>>>> [1] https://patchwork.ozlabs.org/patch/560324/
>>>>>
>>>>>     Documentation/devicetree/bindings/net/cpsw.txt |  4 ++--
>>>>>     drivers/net/ethernet/ti/cpsw.c                 | 17 +++++++++++++----
>>>>>     2 files changed, 15 insertions(+), 6 deletions(-)
>>>>>
>>>>> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>>>>> index 28a4781..3033c0f 100644
>>>>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>>>>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>>>>> @@ -46,16 +46,16 @@ Optional properties:
>>>>>     - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
>>>>>     - mac-address		: See ethernet.txt file in the same directory
>>>>>     - phy_id		: Specifies slave phy id
>>>>
>>>> May be the "phy_id" can be marked as deprecated? (while here)
>>>> The recommended property now is "phy-handle".
>>>
>>> I can certainly do that. Perhaps something like this?
>>>    - phy_id		: Specifies slave phy id (deprecated, use phy-handle)
>>>
>>> Rob, would you have any issues with bundling that?
>>>
>>>>
>>>>>     - phy-handle		: See ethernet.txt file in the same directory
>>>>>
>>>>>     Slave sub-nodes:
>>>>>     - fixed-link		: See fixed-link.txt file in the same directory
>>>>> -			  Either the property phy_id, or the sub-node
>>>>> -			  fixed-link can be specified
>>>>> +
>>>>> +Note: Exactly one of phy_id, phy-handle, or fixed-link must be specified.
>>>>>
>>>>>     Note: "ti,hwmods" field is used to fetch the base address and irq
>>>>>     resources from TI, omap hwmod data base during device registration.
>>>>>     Future plan is to migrate hwmod data base contents into device tree
>>>>>     blob so that, all the required data will be used from device tree dts
>>>>>     file.
>>>>>
>>>>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>>>>> index d69cb3f..3c81413 100644
>>>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>>>> @@ -1150,16 +1150,19 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>>>>>     	if (slave->data->phy_node)
>>>>>     		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
>>>>>     				 &cpsw_adjust_link, 0, slave->data->phy_if);
>>>>>     	else
>>>>>     		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
>>>>>     				 &cpsw_adjust_link, slave->data->phy_if);
>>>>>     	if (IS_ERR(slave->phy)) {
>>>>> -		dev_err(priv->dev, "phy %s not found on slave %d\n",
>>>>> -			slave->data->phy_id, slave->slave_num);
>>>>> +		dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
>>>>> +			slave->data->phy_node ?
>>>>> +				slave->data->phy_node->full_name :
>>>>> +				slave->data->phy_id,
>>>>> +			slave->slave_num);
>>>>
>>>> Unfortunately,  there are some inconsistency between legacy and FDT API :(
>>>> of_phy_connect() will return valid phy_device or NULL, but phy_connect()
>>>> can return valid phy_device or ERR_PTR().
>>>
>>> Good catch, I hadn't noticed that. It looks like that's actually a more
>>> serious (pre-existing) bug: if of_phy_connect() returns NULL, we'd end
>>> up dereferencing it and pagefaulting.
>>>
>>> How about moving the IS_ERR() check into the phy_connect() case like this:
>>> 	if (slave->data->phy_node) {
>>> 		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
>>> 				 &cpsw_adjust_link, 0, slave->data->phy_if);
>>
>> [1]
>>
>>> 	} else {
>>> 		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
>>> 				 &cpsw_adjust_link, slave->data->phy_if);
>>> 		if (IS_ERR(slave->phy))
>>> 			slave->phy = NULL;
>> [2]
>>> 	}
>>> 	if (!slave->phy) {
>>> 		dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
>>> 			slave->data->phy_node ?
>>> 				slave->data->phy_node->full_name :
>>> 				slave->data->phy_id,
>>> 			slave->slave_num);
>>> 	} else {
>>>
>>> Since you say the phy_id case is deprecated anyways, I'm not too concerned
>>> about not printing the error code returned by phy_connect() in that case
>>> (especially since it never did so in the past). That lets us still avoid
>>> duplicating the dev_err() itself.
>>
>> I'm not worry too much about duplicating dev_err() - it's always good to know
>> the reason of failure.
>>
>> So, may be for of_phy_connect() [1]:
>>   dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
>> 	slave->data->phy_node->full_name,
>>   	slave->slave_num);
>>
>> and for phy_connect() [2]:
>>    dev_err(priv->dev, "phy %s not found on slave %d, err %d\n",
>>    	slave->data->phy_id, slave->slave_num, PTR_ERR(slave->phy));
>>
>> Mugunthan, any comments?
>
> If that's the preference, then I can incorporate that into V3.
>

Yes, please, if no other comments.


-- 
regards,
-grygorii
