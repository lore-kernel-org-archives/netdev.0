From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 08 Dec 2010 11:26:08 -0800
Message-ID: <4CFFDBD0.9050801@chelsio.com>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>	 <4C48BD1A.4060409@chelsio.com>	 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>	 <1291825443.31064.193.camel@lb-tlvb-vladz>	 <1291828940.2560.17.camel@bwh-desktop>  <4CFFD470.5090407@chelsio.com> <1291835644.2560.52.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11682 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab0LHT0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 14:26:17 -0500
In-Reply-To: <1291835644.2560.52.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Wed, 2010-12-08 at 10:54 -0800, Dimitris Michailidis wrote:
>> Ben Hutchings wrote:
>>> On Wed, 2010-12-08 at 18:24 +0200, Vladislav Zolotarov wrote:
>>>>>> It's a bit worse than that.  Currently one can only append filters, not
>>>>>> insert at a given position, as ethtool_rx_ntuple doesn't have an index
>>>>>> field.  For devices that use TCAMs, where position matters, it's quite an
>>>>>> obstacle.  It also means one cannot modify an existing filter by specifying
>>>>>> a new filter for the same index.
>>>>> It looks like drivers for devices that use TCAMs should implement the
>>>>> RXNFC interface instead.
>>>>>
>>>> Ben, from ethtool manpage it sounds like RXNFC option defines the way
>>>> the RSS hash should be calculated, while SRXNTUPLE is meant to control
>>>> the destination Rx queue for a stream specified by a filter/filters.
>>> By 'RXNFC interface' I mean ETHTOOL_{G,S}RXCLS* and not
>>> ETHTOOL_{G,S}RXFH which wrongly share (part of) the same structure..
>>>
>>>> The
>>>> semantics for a specification of the steam is also quite different. For
>>>> instance, how do u define a rule to drop all packets with source IP
>>>> address 192.168.10.200 by means of RXNFC?
>>> Something like this, I think:
>>>
>>> struct ethtool_rxnfc insert_rule = {
>>> 	.cmd = ETHTOOL_SRXCLSRLINS,
>>> 	.flow_type = IP_USER_SPEC,
>>> 	.fs = {
>>> 		.flow_type = IP_USER_SPEC,
>>> 		.h_u.usr_ip4_spec = {
>>> 			.ip4src = inet_aton("192.168.10.200"),
>>> 			.ip_ver = ETH_RX_NFC_IP4
>>> 		},
>>> 		.m_u.usr_ip4_spec = {
>>> 			.ip4dst = 0xffffffff,
>>> 			.l4_4_bytes = 0xffffffff,
>>> 			.tos = 0xff,
>>> 			.proto = 0xff
>>> 		},
>>> 		.ring_cookie = RX_CLS_FLOW_DISC,
>>> 		.location = 0,
>>> 	}
>>> };
>> I think the mask would be 0 for don't care fields and 1 for care, so
>>
>> 	.m_u.usr_ip4_spec.ip4src = htonl(0xffffffff)
>> 	.m_u.usr_ip4_spec.ip4dst = htonl(0)
>> etc
> 
> That is definitely the opposite of what ixgbe and sfc do for
> ethtool_ntuple_rx_flow_spec, and I believe it is the opposite of what
> niu does for ethtool_rx_flow_spec.

These are the values as our HW at least wants them.  The care bits are 1 in 
the mask.  It's not a huge deal, the driver can complement the masks.

> 
> [...]
>>>> It's also unclear what is the relation between RXNFC and SRXNTUPLE. The
>>>> last in general may override the decision made based on the hash result.
>>>> So, it sounds like applying rules of SRXNTUPLE should come before
>>>> applying the RSS logic and only if there was no match RSS should be
>>>> applied to that frame. Do I get it right?
>>> That's right.
>> It can be more involved than this.  Our HW allows a rule to select a 
>> different part of the RSS table so you get a filter hit and still do RSS 
>> afterwards if you want.  Current ethtool interfaces do not support this, 
>> basically it would be a different action for either SRXNTUPLE or SRXCLSRLINS.
> 
> So does the rule specify an offset added to the output of the RSS hash
> and indirection table, or can it also select a different indirection
> table?  Our current hardware also has a filter flag for the former
> behaviour...  There are still plenty of bits to spare in 'action' and
> 'ring_cookie' so perhaps we could define a flag for this?

You can partition the indirection table and then a rule can specify that 
matching packets should consult region X of the table.  The hash value is 
not altered, just the part of the overall table it indexes into.

> 
> Ben.
> 

