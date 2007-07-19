From: Patrick McHardy <kaber@trash.net>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 16:00:19 +0200
Message-ID: <469F6E73.30904@trash.net>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>	<469E9AC8.3090603@trash.net>	<m3zm1sbjzl.fsf@maximus.localdomain> <20070719144131.0c230c8f@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35137 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937018AbXGSOBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 10:01:16 -0400
In-Reply-To: <20070719144131.0c230c8f@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 19 Jul 2007 15:28:46 +0200
> Krzysztof Halasa <khc@pm.waw.pl> wrote:
> 
>>>Your suggestion of disabling VLAN acceleration in promiscous
>>>mode sounds like a reasonable solution until then ..
>>
>>From a user perspective:
>>
>>I'm not sure promiscous mode is related to the problem.
>>Tcpdump without promiscous mode makes perfect sense.


Good point.

>>I don't know very well VLAN code internals, but I think
>>the VLAN # is used for looking up the interface, so
>>presenting the "original" packet on the trunk device
>>would IMHO involve some skb cloning, and perhaps some
>>ethtool option could probably control that.
>>
>>Not sure about untagged frames vs. tagged frames with
>>the default VLAN id - can the hardware at all differentiate
>>between them?
>>
>>
>>Or, perhaps it should be left (almost) as is - with "software"
>>VLANs the traffic always goes through the master interface,
>>but with "accelerated" mode it only goes through logical
>>interfaces and doesn't show up on master? Probably with
>>exception of invalid VLANs, which could be injected back to
>>master (because no logical device exists)?


The last case is the problematic one, the tag might be gone.

> I don't claim to be a VLAN expert but there are really three cases
> for handling tagged frames
> 
> 1) non-accelerated device 
>     * all frames show in promiscious mode
>     * tag is part of the frame that shows up
>        in tcpdump, and then gets stripped by the 8021q module.
> 2) rx tag stripping device
>      * all frames show in promiscious mode
>      * tag is in skb but NOT passed to tcpdump
> 3) rx vlan acceleration
>      * only frames that for vlan's that are registered show up
>         in promisicous mode
>      * tag is in skb but NOT passed to tcpdump
> 
> Unfortunately, the tag is lost as part of the VLAN acceleration process
> so it is not a simple matter of changing code in AF_PACKET receive
> to restore the tag.


I think case 2) is not correct, the tag is stripped and is not in the
skb. Check out sky2 for example :)

        if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
                vlan_hwaccel_receive_skb(skb,

                                         sky2->vlgrp,
                                         be16_to_cpu(sky2->rx_tag));


The tag it uses for the lookup comes from the descriptor. I don't
know any examples for case 3), but I would expect that the header
is also removed.

Anyway, I think what we should do is store the VLAN tag in the skb
meta data. That would not only allow tcpdump to reconstruct it, it
would also fix the invalid use of skb->cb on the TX path. It would
also fix the bridge eating VLAN headers case (bridge on eth0 + eth1,
additionally eth0.1 on eth0 using vlan RX accerlation with header
stripping) and would allow to simply forward the vlan tag to the
outgoing device in case it supports hardware accererated vlan tagging.

