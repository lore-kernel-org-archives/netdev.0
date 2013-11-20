From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH] macvtap: Add packet capture support
Date: Wed, 20 Nov 2013 14:52:33 -0500 (EST)
Message-ID: <20131120.145233.1158930529349207237.davem@davemloft.net>
References: <1384970649-29839-1-git-send-email-vyasevic@redhat.com>
	<20131120181949.GB25569@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab3KTTwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 14:52:35 -0500
In-Reply-To: <20131120181949.GB25569@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 20 Nov 2013 20:19:49 +0200

> On Wed, Nov 20, 2013 at 01:04:09PM -0500, Vlad Yasevich wrote:
>> Currently it is impossible to capture traffic when using a macvtap
>> device.  The reason is that all capture handling is done either in
>> dev_hard_start_xmit() or in __netif_receive_skb_core().  Macvtap
>> currenlty doesn't use dev_hard_start_xmit(), and at the time the
>> packet traverses __netif_receive_skb_core, the skb->dev is set to
>> the lower-level device that doesn't end up matching macvtap.
>> 
>> To solve the issue, use dev_hard_start_xmit() on the output path.
>> On the input path, it is toughter to solve since macvtap ends up
>> consuming the skb so there is nothing more left for
>> __netif_receive_skb_core() to do.  A simple solution is to
>> pull the code that delivers things to the taps/captures into
>> its own function and allow macvtap to call it from its receive
>> routine.
>> 
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>> This is only an RFC.  I'd like to solicit comments on this simple
>> approach.
> 
> I'm kind of worried about this. What worries me is that normally
> if you have a packet socket bound to all interfaces, what it shows is
> traffic to/from the box.
> 
> This might be a bug for someone, but I suspect at this point this
> is part of the ABI.

Tunnel decapsulations on input are shown for other types of devices,
such as IP tunnels.  It is because they feed packets back into the
stack via netif_receive_skb() upon decapsulation.

Then we have all of this sideways code for VLANs and "rx_handler"s
in order to perform decapsulation via direct iteration instead of
recursion inside of __netif_receive_skb_core().

I suspect that Vlad's suggested rx_handler alternative approach is
going to be much better.
