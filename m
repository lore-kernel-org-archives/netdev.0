From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Timout packets in device's TX queue
Date: Thu, 14 Nov 2013 19:27:16 +0000
Message-ID: <52852414.2070105@citrix.com>
References: <5283E146.5000604@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD0172846@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:65218 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832Ab3KNT1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 14:27:20 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0172846@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Discussing this further with Paul, we came to the conclusion that 
probably the best solution would be to drop these packets in qdisc. 
Netback RX path stop accepting new packets if the target guest doesn't 
have enough room in the ring. Also (AFAIK) NIC drivers do the same if 
they don't have more resource for TX, and this is all good for us. Our 
problem is that the queue in qdisc layer (sorry if my terminology not 
clear!) can still accumulate these packets indefinitely. The drastic 
measure would be to reduce txqueuelen to 0 during setup for every 
affected device, but that's not really nice.
Instead, we should be able to configure qdisc to timeout packets on 
those queues, at least the SKBs where (skb_shinfo(skb)->tx_flags & 
SKBTX_DEV_ZEROCOPY). I'm not that familiar with it to know if that's 
already possible, or if not, then how good idea would it be to implement it.
I've changed the subject and included netdev and Eric, maybe someone can 
shed some more light on this question.

Regards,

Zoli

On 14/11/13 09:42, Paul Durrant wrote:
>> -----Original Message-----
>> From: Zoltan Kiss
>> Sent: 13 November 2013 20:30
>> To: xen-devel@lists.xenproject.org; Ian Campbell; Wei Liu; Paul Durrant;
>> Malcolm Crossley; David Vrabel
>> Cc: Jonathan Davies
>> Subject: netback: Delayed copy alternative
>>
>> Hi,
>>
>> I'm trying to forward port delayed copy to my new grant mapping patches.
>> One important problem I've faced is that classic used
>> gnttab_copy_grant_page to replace the granted page with a local copy and
>> unmap the grant. And this function has never been upstreamed as only
>> netback used it. Unfortunately upstreaming it is not a very easy task,
>> as the kernel's grant table infrastructure doesn't track at the moment
>> whether the page is DMA mapped or not. It is required because we
>> shouldn't proceed with the copy and replace if a device already mapped
>> the page for DMA.
>> David came up with an alternative idea: we do this delayed copy because
>> we don't want the guest's page to get stucked in Dom0 indefinitely. The
>> only realistic case for that would be if the egress interface would be
>> an another guest's vif, where the guest (either due to a bug or as a
>> malicious attempt) doesn't empty its ring. I think it's a safe
>> assumption that Dom0 otherwise doesn't hold on to packets for too long.
>> Or if it does, then that's a bug we should fix instead of doing a copy
>> of the packet.
>> If we accept that only other vif's can keep the skb indefinitely, then
>> an easier solution would be to handle this problem on the RX side: the
>> RX thread can also check whether this skb hanged around for too long and
>> drop it. Actually, xenvif_start_xmit already checks if the guest
>> provided enough slots for us to do the grant copy. If I understand it
>> correctly. What do you think about such an approach?
>>
>
> Well, now that David fixed the DMA unmap tracking thing, I believe that another vif is *generally* the only place an skb can hang around for a long time. The problem is that there is an edge case... If a network driver turns off queue processing (for flow control reasons, and NB that 10G Ethernet requires the driver to do this if the PHY signals flow control and internal buffering is exhausted, 1G is allowed to be an open drain) then the skb can sit in the queue indefinitely and there's no way you can deal with this from the guest RX side of netback. You need to have a copy-aside option to handle this.
>
>    Paul
>
