From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv9 net-next 2/4] sunvnet: make transmit path zero-copy
 in the kernel
Date: Thu, 02 Oct 2014 07:33:14 -0400
Message-ID: <542D37FA.3050708@oracle.com>
References: <5429EFBB.2090909@oracle.com> <77E6695E-58F8-4D10-8ED7-EEC4A487339E@oracle.com> <063D6719AE5E284EB5DD2968C1650D6D174A2CD2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"'Raghuram Kothakota'" <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34715 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaJBLdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 07:33:23 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174A2CD2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/02/2014 05:06 AM, David Laight wrote:

>>> 	len = skb->len;
>>> -	if (len < ETH_ZLEN) {
>>> +	if (len < ETH_ZLEN)
>>> 		len = ETH_ZLEN;
>>> -		memset(tx_buf+VNET_PACKET_SKIP+skb->len, 0, len - skb->len);
>>> +
> 
> Aren't you transmitting 'random' bytes from the end of the data?
> Plausibly they might not even be mapped.

	No. The checks to decide whether to copy or not make sure the
extra 6-14 bytes in the beginning and 0-8 bytes (for large frames, more
for small) at the end are part of the particular skb's headroom and
tailroom respectively. So, they aren't random bytes-- they are what
was allocated as part of the frame. For TCP streams, the trailing bytes
are likely part of the next packet. They definitely exist and are mapped,
but I don't zero them because they are usually COW and that forces a copy
every time.

> 
> Also, for short frames the copy could well be faster - especially on systems
> with non-trivial iommu.
> It is also worth checking whether the original copy was aligned.

For the short frames, sure. I'm not sure what you mean by that last sentence--
the point of the checks that determine whether to copy or not are to enforce
alignment and length restrictions; if they aren't met in the original buffer,
we copy.

						+-DLS
