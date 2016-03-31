From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
Date: Thu, 31 Mar 2016 11:59:14 +1000
Message-ID: <56FC8472.6010005@uclinux.org>
References: <56FB46EA.7050401@uclinux.org>
 <CAOMZO5B79aHocuqT4jgEU9gGcFYD5ZSDZh8PrGeXYAcLHW1x5Q@mail.gmail.com>
 <VI1PR0401MB1855458E0B31502D1C112AF6FF990@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fugang Duan <fugang.duan@nxp.com>,
	Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out7.external.iinet.net.au ([203.59.1.107]:4713
	"EHLO icp-osb-irony-out7.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754759AbcCaB7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 21:59:07 -0400
In-Reply-To: <VI1PR0401MB1855458E0B31502D1C112AF6FF990@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On 31/03/16 11:41, Fugang Duan wrote:
> From: Fabio Estevam <festevam@gmail.com> Sent: Thursday, March 31, 2016 2:37 AM
>> To: Greg Ungerer <gerg@uclinux.org>
>> Cc: Troy Kisky <troy.kisky@boundarydevices.com>; netdev@vger.kernel.org
>> Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
>>
>> Hi Greg,
>>
>> On Wed, Mar 30, 2016 at 12:24 AM, Greg Ungerer <gerg@uclinux.org> wrote:
>>> Hi Troy,
>>>
>>> Commit 55cd48c8 ('net: fec: stop the "rcv is not +last, " error
>>> messages') adds a write to a register that is not present in all
>>> implementations of the FEC hardware module. None of the ColdFire SoC
>>> parts with the FEC module have the FTRL (0x1b0) register.
>>>
>>> Does this need a quirk flag to key access to this register of?
>>> Or can you piggyback on the FEC_QUIRK_HAS_RACC flag?
>>
>> Would the change below work on Coldfire?
>>
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -943,8 +943,8 @@ fec_restart(struct net_device *ndev)
>>                 else
>>                         val &= ~FEC_RACC_OPTIONS;
>>                 writel(val, fep->hwp + FEC_RACC);
>> -       }
>>         writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
>> +       }
>>  #endif
>>
>>         /*
> 
> Fabio, we cannot do it like this that may cause confused for the quirk flag "FEC_QUIRK_HAS_RACC".
> 
> 
> Hi, Greg,
> 
> The header file fec.h define the FEC_FTRL as below,  if ColdFire SoC has no this register,  we may remove the define in here and define the register according to SOC type. For example, it is ColdFire Soc, define it as 0xFFF. Is it  feasible ?
> 
> #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
>     defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
> ...
> #define FEC_FTRL                0x1b0
> ...
> #else
> ...
> #endif

Sure you could do that. But... you still have to be careful
with references to it in fec_main.c. They will need be conditional
on existence of FEC_FTRL, otherwise you break compilation.

Even if you define it to some bogus value we still don't 
want the code actually writing to it.

Regards
Greg
