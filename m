From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Question on the use of ETH_P_CONTROL
Date: Mon, 29 Apr 2013 13:55:33 -0700
Message-ID: <517EDE45.6050505@intel.com>
References: <517821CE.207@intel.com> <20130429.134244.1920449745404305505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5809 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754931Ab3D2Uzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 16:55:35 -0400
In-Reply-To: <20130429.134244.1920449745404305505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2013 10:42 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 24 Apr 2013 11:17:50 -0700
>
>> I have a wired Ethernet driver that will need to support a user space
>> application with UIO access and a network device.  The network device
>> will need a way to send raw frames with some descriptor data to and from
>> the user space application.  The frames are not meant to be routed and
>> are not meant for this host, only for the user space application.  After
>> doing some digging I came across the definition for ETH_P_CONTROL, which
>> seems to be a good solution for my current issue.
>>
>> My thought is to do something like this for Rx control frames:
>> 	eth_type_trans(skb);
>> 	skb->protocol = htons(ETH_P_CONTROL);
>> 	skb->mac_header -= sizeof(struct desc_hdr);
>> 	desc_hdr = (struct desc_hdr *)skb_mac_header(skb);
>> 	desc_hdr->val = val;
>>
>> For frames received from the user space application I would essentially
>> just leave the descriptor header on and notify the hardware that it is
>> present for any frames received that have ETH_P_CONTROL as their protocol.
>>
>> Then all that is left is for the user space to allocate a raw packet
>> socket and bind it to our interface specifying the control protocol so
>> that it can send and receive just the control frames.
>>
>> I'm looking for any thoughts, issues, or concerns with this approach.
> I looked this over briefly a few nights ago, and the only other place I
> see this used is the hostap driver.  hostap is a big body of code that
> does lot of things in unique and rather ad-hoc ways.
>
> hostap was written in an environment where interfaces and
> infrastructure for what it wanted to do didn't exist, so the author
> just did his own thing in each and every such instance.
>
> I want to encourage you to steer away from that kind of approach.
>
> Although I'm cautiously skeptical, you may not end up being the only
> other person trying to push descriptors into the kernel from userspace
> and then trigger device TX/RX.  If every driver makes it's own control
> plane for this, wait for troubles...

Actually I have already steered somewhat away from the original idea I
had.  I am now looking at putting the control traffic on a separate
non-Ethernet netdev that would have a custom header that includes the
control information for the frame.  It would would use the same approach
where the custom header would come before the Ethernet header as I was
doing above.  That addresses several issues since I realized I cannot
mix Ethernet and non-Ethernet protocols on the same device.

For the transmit side I can just generate dummy control data for any
non-raw packets that are routed to the interface.  That should let me
just open a standard raw socket and have everything work as expected.

Thanks,

Alex
