From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 4/6] stmmac: Update stmmac descriptor checks for stmmac
 core prior to Rev-3.5.
Date: Wed, 07 Mar 2012 09:45:37 +0100
Message-ID: <4F572031.3030006@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <1330692928-30330-5-git-send-email-deepak.sikri@st.com> <4F55B864.7030104@st.com> <4F571B68.1050508@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:60755 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751040Ab2CGIrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:47:09 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5CA7F26D
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 08:47:05 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DA91F1AA1
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 08:47:04 +0000 (GMT)
In-Reply-To: <4F571B68.1050508@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2012 9:25 AM, Deepak SIKRI wrote:
> Hi Peppe,
> 
> 
>> Type 2 has been introduced starting from the 3.30a and Type 1 maintained
>> for back-ward compatibility because only available in 3.30.
>>
>> If we want to actually support Type 1 (I've no HW where test) I guess we
>> need to review this patch.
>>
>> First problem I can see in the patch is that, in case of type 1, we have
>> to properly set the device hw features because full IPC offload is not
>> supported (e.g. IPv6). This only is true for type 2.
>>
>> I've just looked at all the MAC data-books starting from the 3.30a to
>> 3.60a and I have seen that all the MACs treat the Receive Checksum
>> Offload Engine in the same way. I mean, the cores don't append any
>> payload csum bytes in case of type 2. This is always done for type 1!
>>
>> Frankly, I prefer to have no define like GMAC_VERSION_35.
>> I always tried to avoid it :-)... unless there is some critical reason
>> and we actually need it. Pls, see my comments comments inline below.
> There are two issues to be addresses.
> 1. Issue-1 : For the Type-1 Rx COE, the frame length has to be adjusted
> by 2.

agree but this could directly be done in get_rx_frame_len

> 2. The two frame status conditions that have been marked as csum_none
> for the versions 3.3a and
> earlier.

Earlier MACs have no Type 2 and the status condition  enh_desc_coe_rdes0
only is for MAC that has Type 2
> 
> I would take them along the review comments below
> 
> 
> 
>>>       } else if (status == 0x1) {
>>>           CHIP_DBG(KERN_ERR
>>>               "RX Des0 status: IPv4/6 unsupported IP PAYLOAD.\n");
>>> -        ret = discard_frame;
>>> +        ret = (mac_id>= GMAC_VERSION_35) ? discard_frame : csum_none;
>>>       } else if (status == 0x3) {
>>>           CHIP_DBG(KERN_ERR "RX Des0 status: No IPv4, IPv6 frame.\n");
>>> -        ret = discard_frame;
>>> +        ret = (mac_id>= GMAC_VERSION_35) ? discard_frame : csum_none;
>>>       }
>>>       return ret;
>>>   }
>> The enh_desc_coe_rdes0 parses the Receive Descriptor 0 When COE (Type
>> 2). It should be onlyinvoked on full csum case.
>> We also should discard the frames on the latest two cases I mean when:
>>
>> - IPv4/IPv6 Type frame with no IP header checksum error and the payload
>> check bypassed, due to an unsupported payload
>>
>> - A Type frame that is neither IPv4 or IPv6 (the Checksum Offload engine
>> bypasses checksum completely.)
>>
>> Also from all the Synopsys databooks I cannot see any difference in the
>> Table 7.2 when treat the RDES0 bits 0, 5, 7.
>>
>> So I expect to have no check for the GMAC_VERSION_35 inside the enh desc
>> file.
> 
> I can cross verify this on the SPEAr test platform which we had been
> using. We had faced some issue
> related to this before also.
> 
>>>   static int enh_desc_get_rx_status(void *data, struct
>>> stmmac_extra_stats *x,
>>> -                  struct dma_desc *p)
>>> +                  struct dma_desc *p, u32 mac_id)
>>>   {
>>>       int ret = good_frame;
>>>       struct net_device_stats *stats = (struct net_device_stats *)data;
>>> @@ -195,9 +198,11 @@ static int enh_desc_get_rx_status(void *data,
>>> struct stmmac_extra_stats *x,
>>>       /* After a payload csum error, the ES bit is set.
>>>        * It doesn't match with the information reported into the
>>> databook.
>>>        * At any rate, we need to understand if the CSUM hw
>>> computation is ok
>>> -     * and report this info to the upper layers. */
>>> +     * and report this info to the upper layers.
>>> +     */
>> This is useless change in the patch that should be removed in the final
>> version.
> 
> ok
> 
>>       if (priv->rx_coe)
>>           pr_info(" Checksum Offload Engine supported\n");
>> +
>> do not add useless spaces.
> 
> ok
> 
>>>       if (priv->plat->tx_coe)
>>>           pr_info(" Checksum insertion supported\n");
>> Here I expect to see more information about the RX COE ;-)
>>
>> I'd like to see:
>>    pr_info(" Checksum Offload Engine supported (type %d)\n", ....);
> 
> Sure, will do that

:-)

> 
>>>
>>> @@ -1436,7 +1437,8 @@ static int stmmac_rx(struct stmmac_priv *priv,
>>> int limit)
>>>
>>>           /* read the status of the incoming frame */
>>>           status = (priv->hw->desc->rx_status(&priv->dev->stats,
>>> -                        &priv->xstats, p));
>>> +                    &priv->xstats, p,
>>> +                    priv->hw->synopsys_uid&  0xff));
>>>           if (unlikely(status == discard_frame))
>>>               priv->dev->stats.rx_errors++;
>>>           else {
>>> @@ -1444,6 +1446,16 @@ static int stmmac_rx(struct stmmac_priv *priv,
>>> int limit)
>>>               int frame_len;
>>>
>>>               frame_len = priv->hw->desc->get_rx_frame_len(p);
>>> +            /*
>>> +             * The type-1 checksume offload engines append
>>> +             * the checksum at the end of frame, and the
>>> +             * the two bytes of checksum are added in
>>> +             * length.
>>> +             * Adjust for that in the framelen for type-1
>>> +             * checksum offload engines.
>>> +             */
>>> +            if (priv->plat->csum_off_engine_type == STMMAC_CSUM_T1)
>>> +                frame_len -= 2;
>> I'd like to have this inside the core. I mean, get_rx_frame_len returns
>> the len - 2 in case of type 1.
> 
> Thats fine. Will do that

Thanks so much

peppe

> 
> Regards
> Deepak
> 
