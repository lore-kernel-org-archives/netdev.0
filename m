From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [Linux-kernel] [net-next, 2/5] sh_eth: WARN on access to a register
 not implemented in a particular chip
Date: Mon, 09 Mar 2015 08:50:24 +0000
Message-ID: <54FD5ED0.6070208@codethink.co.uk>
References: <1424982854.4444.73.camel@xylophone.i.decadent.org.uk> <alpine.DEB.2.10.1503050958520.8385@ayla.of.borg> <1425561532.4288.34.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@lists.codethink.co.uk,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	netdev@vger.kernel.org,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:51017 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbbCIIuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 04:50:40 -0400
In-Reply-To: <1425561532.4288.34.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/15 13:18, Ben Hutchings wrote:
> On Thu, 2015-03-05 at 10:02 +0100, Geert Uytterhoeven wrote:
>> Replying to a patchwork mbox, as I noticed this is in net-next.
>>
>> On Thu, 26 Feb 2015, Ben Hutchings wrote:
>>> Currently we may silently read/write a register at offset 0.  Change
>>> this to WARN and then ignore the write or read-back all-ones.
>>>
>>> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
>>> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> While this may be a good idea for debugging...
>>
>>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>>> @@ -543,19 +543,29 @@ static inline void sh_eth_soft_swap(char *src, int len)
>>>  #endif
>>>  }
>>>  
>>> +#define SH_ETH_OFFSET_INVALID	((u16) ~0)
>>> +
>>>  static inline void sh_eth_write(struct net_device *ndev, u32 data,
>>>  				int enum_index)
>>>  {
>>>  	struct sh_eth_private *mdp = netdev_priv(ndev);

does de-referencing this each time make a difference? Looks like
it would have been easier to pass an "struct sh_eth_private" instead
of the "struct net_device *ndev"

>>> +	u16 offset = mdp->reg_offset[enum_index];
>>> +
>>> +	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
>>> +		return;

You could cange the mdp->reg_offset to an mdp->reg_pointer and make
any invalid registers a NULL. This would at-least make it fail on an
invalid access.

>> ... adding WARN_ON() to static inline functions increases code size a lot:
>>
>> $ size drivers/net/ethernet/renesas/sh_eth.o{.orig,}
>>    text	   data	    bss	    dec	    hex	filename
>>   23352	   1136	      0	  24488	   5fa8	drivers/net/ethernet/renesas/sh_eth.o.orig
>>   27225	   1136	      0	  28361	   6ec9	drivers/net/ethernet/renesas/sh_eth.o
>> $
> 
> Time to un-inline it, maybe?
> 
> Ben.
> 
> 
> _______________________________________________
> linux-kernel mailing list
> linux-kernel@lists.codethink.co.uk
> https://ducie-dc1.codethink.co.uk/cgi-bin/mailman/listinfo/linux-kernel
> 


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
