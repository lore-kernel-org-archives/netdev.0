From: Malcolm Crossley <malcolm.crossley@citrix.com>
Subject: Re: [Xen-devel] [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed sysctl_tcp_limit_output_bytes
Date: Mon, 13 Apr 2015 16:03:34 +0100
Message-ID: <552BDAC6.2020708@citrix.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
	<1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
	<551555E3.80205@citrix.com> <552BC899.8090300@citrix.com>
 <1428933925.3834.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <jonathan.davies@citrix.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	<netdev@vger.kernel.org>, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	<xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:1858 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753847AbbDMPEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 11:04:20 -0400
In-Reply-To: <1428933925.3834.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/04/15 15:05, Eric Dumazet wrote:
> On Mon, 2015-04-13 at 14:46 +0100, David Vrabel wrote:
> 
>>> And the proof-of-concept patch for idea (b) I used was:
>>>
>>> @@ -552,6 +552,8 @@ static int xennet_start_xmit(struct sk_buff *skb,
>>> struct net_device *dev)
>>>              goto drop;
>>>      }
>>>
>>> +    skb_orphan(skb);
>>> +
>>>      page = virt_to_page(skb->data);
>>>      offset = offset_in_page(skb->data);
>>>      len = skb_headlen(skb);
>>
>> No. This a bunch of allocations and  a full memcpy of all the frags.
> 
> skb_orphan() does nothing like that.

I think David accidently read the skb_orphan_frags() code.

> 
> But the main concern here is it basically breaks back pressure.
> 
> And you do not want this, unless there is no other choice.
> 

virtio_net already use's skb_orphan() in it's transmit path. It seems
only fair that other virtual network drivers behave in the same way.

There are no easy solutions to decrease the transmit latency for
netback/netfront. We map the guest memory through to the backend to
avoid memory copies. The frontend memory can only be freed once the
network driver has completed transmitting the packet in the backend.

Modern network drivers can be quite slow at freeing the skb's once
transmitted (the packet is already on the wire as far as they are
concerned) and this delay is compounded by needing the signal the
completion of the transmit back to the frontend (by IPI in worst case).

>From a networking point of view, the backend is a switch. Is it OK to
consider the packet to have been transmitted from the guest point of
view once the backend is aware of the packet?

This would help justify the skb_orphan() in the frontend.

> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
