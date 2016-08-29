From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ethernet: renesas: sh_eth: do not access POST
 registers if not exist
Date: Tue, 30 Aug 2016 00:17:28 +0300
Message-ID: <f456cca3-289c-67dc-f15c-5b475553cdde@cogentembedded.com>
References: <20160826200107.20681-1-chris.brandt@renesas.com>
 <87690577-4526-ce66-6ce3-68ac8b20e737@cogentembedded.com>
 <SG2PR06MB11653F9E20F38972CA11EF328AE10@SG2PR06MB1165.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>
To: Chris Brandt <Chris.Brandt@renesas.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33521 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbcH2VRy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 17:17:54 -0400
Received: by mail-lf0-f53.google.com with SMTP id b199so99711lfe.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 14:17:31 -0700 (PDT)
In-Reply-To: <SG2PR06MB11653F9E20F38972CA11EF328AE10@SG2PR06MB1165.apcprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/29/2016 05:41 PM, Chris Brandt wrote:

>>> The RZ/A1 has a TSU, but since it only has one Ethernet port, it does
>>> not have POST registers.
>>
>>    I'm not sure the reason is having one port... do you have the old SH manuals somewhere? :-)
>
> Yes, I used to support the SH7757.

    Good to have someone with the old SH manuals. :-)

> It had dual ETHER and dual GETHER (but only the GETHER had a TSU).
> Since the GETHER had 2 ports, and the same TSU is used for both, there is an option where as you put in CAM entries for multicast frame and such, you can select if you would like CAM entry packets received on one port to be automatically relayed over to the other port for processing (ie, bridge network).
> The POST1-POST4 registers are what you use to select what CAM entries you want relayed.

    SH7757 is not the only platform with TSU, there's e.g. R8A7740 ARM SoC 
which only has 1 GETHER channel...

> For example:
>
>    Register: CAM Entry Table POST1 Register (TSU_POST1)
>        Bits: 31 to 28
>    Bit name: POST0[3:0]
> Description: These bits set the conditions for referring to CAM entry table 0. By
>              setting multiple bits to 1, multiple conditions can be selected.
>
>              POST0[3]: CAM entry table 0 is referred to in port 0 reception
>              POST0[2]: CAM entry table 0 is referred to in port 0 to 1 relay.
>              POST0[1]: CAM entry table 0 is referred to in port 1 reception.
>              POST0[0]: CAM entry table 0 is referred to in port 1 to 0 relay
>
>
> So, as you can see, having the POST registers means nothing if you only have 1 Ethernet port
> attached to the TSU.

    That probably means we have more issues on other SoCs having TSU...

> Note, if you look at function sh_eth_tsu_get_post_bit, the relay functionality is never used
> anyway because each entry will only ever be set to "port 0 reception" or "port 1 reception".

    Yes, seeing this...

>>>  	.shift_rd0	= 1,
>>>  };
>>>
>>> @@ -2460,6 +2461,9 @@ static void sh_eth_tsu_enable_cam_entry_post(struct net_device *ndev,
>>>  	u32 tmp;
>>>  	void *reg_offset;
>>>
>>> +	if (mdp->cd->tsu_no_post)
>>> +		return;
>>> +
>>>  	reg_offset = sh_eth_tsu_get_post_reg_offset(mdp, entry);
>>
>>    I'd check check for SH_ETH_OFFSET_INVALID in the above function and return NULL if so; then
>> we can check for NULL here...

    I hadn't thought it thru it seems... I meant that the check includes 
WARN_ON() but we generally should avoid hitting this code, so another check is 
needed beforehand, like that one you added...

> That was similar to my first fix. But, then I got to thinking that if a new RZ comes out
> with dual Ethernet, the designers might add in the POST registers back in the TSU. And in
> that case, it would be nice to reuse the sh_eth_is_rz_fast_ether array (just add in the
> extra registers).

    It seems having something like 'dual_ch' flag would fit...

> But...maybe checking for SH_ETH_OFFSET_INVALID is good for now instead of worrying about that.

    We just need 2 patches, I think...

>> Oh, and I'll have to correct your language and terminology. :-/ Should be
>> "if they don't exist" in the subject.
>
> Ya, my first subject line was too long,

    For what?

> so I kept trying to shorten it....and then it turn into bad grammer.
>
> I think a more clear subject is "Fix TSU without relay feature accesses"

    Or a "single channel TSU".

> Chris

MBR, Sergei
