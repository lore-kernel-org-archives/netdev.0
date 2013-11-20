From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC net-next PATCH] macvtap: Add packet capture support
Date: Wed, 20 Nov 2013 15:10:39 -0500
Message-ID: <528D173F.2060102@redhat.com>
References: <1384970649-29839-1-git-send-email-vyasevic@redhat.com>	<20131120181949.GB25569@redhat.com> <20131120.145233.1158930529349207237.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754809Ab3KTUKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 15:10:41 -0500
In-Reply-To: <20131120.145233.1158930529349207237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 02:52 PM, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 20 Nov 2013 20:19:49 +0200
> 
>> On Wed, Nov 20, 2013 at 01:04:09PM -0500, Vlad Yasevich wrote:
>>> Currently it is impossible to capture traffic when using a macvtap
>>> device.  The reason is that all capture handling is done either in
>>> dev_hard_start_xmit() or in __netif_receive_skb_core().  Macvtap
>>> currenlty doesn't use dev_hard_start_xmit(), and at the time the
>>> packet traverses __netif_receive_skb_core, the skb->dev is set to
>>> the lower-level device that doesn't end up matching macvtap.
>>>
>>> To solve the issue, use dev_hard_start_xmit() on the output path.
>>> On the input path, it is toughter to solve since macvtap ends up
>>> consuming the skb so there is nothing more left for
>>> __netif_receive_skb_core() to do.  A simple solution is to
>>> pull the code that delivers things to the taps/captures into
>>> its own function and allow macvtap to call it from its receive
>>> routine.
>>>
>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>> ---
>>> This is only an RFC.  I'd like to solicit comments on this simple
>>> approach.
>>
>> I'm kind of worried about this. What worries me is that normally
>> if you have a packet socket bound to all interfaces, what it shows is
>> traffic to/from the box.
>>
>> This might be a bug for someone, but I suspect at this point this
>> is part of the ABI.
> 
> Tunnel decapsulations on input are shown for other types of devices,
> such as IP tunnels.  It is because they feed packets back into the
> stack via netif_receive_skb() upon decapsulation.
> 
> Then we have all of this sideways code for VLANs and "rx_handler"s
> in order to perform decapsulation via direct iteration instead of
> recursion inside of __netif_receive_skb_core().
> 
> I suspect that Vlad's suggested rx_handler alternative approach is
> going to be much better.
> 

Hi David

I don't know if "better" is what I'd say here.  With the current code,
if no-one is capturing, the cost is that of "if list_empty".  If
I switch to rx_handler approach, the cost goes up on every packet even
if no-one is capture.  The call stack ends up beeing really silly:
  _netif_receive_skb_core()
     macvlan_handle_frame()
       macvtap_receive()
         return RX_HANDLER_ANOTHER;
     macvtap_handle_frame()
         consume.

Yes, this approach seems to fit in better with the architecture of the
stack, but boy, it looks inefficient.

Where as we were able to steal frames before in macvtap_receive, we now
have to go around one more time.

I am going to prototype this and see what the numbers look like, but it
seems such an overkill.

Thanks
-vlad
