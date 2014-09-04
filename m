From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] core: Untag packets after rx_handler has run.
Date: Thu, 04 Sep 2014 15:29:00 -0400
Message-ID: <5408BD7C.7030805@gmail.com>
References: <1409856043-21840-1-git-send-email-vyasevic@redhat.com> <20140904190524.GA1938@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>,
	Florian Zumbiehl <florz@florz.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:51912 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbaIDT3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 15:29:07 -0400
Received: by mail-qc0-f179.google.com with SMTP id l6so11158670qcy.10
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 12:29:02 -0700 (PDT)
In-Reply-To: <20140904190524.GA1938@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2014 03:05 PM, Jiri Pirko wrote:
> Thu, Sep 04, 2014 at 08:40:43PM CEST, vyasevich@gmail.com wrote:
>> Currently, we attempt to remove the vlan informaion from the packet
>> before passing it to the rx_handler.  In most situations this works
>> just fine since the rx_handlers are usually installed for the
>> lower device and thus vlan device isn't found.  However, macvtap
>> device is a bit different as it installs an rx_handler on top
>> of a macvlan device.  As a result, if someone was define a vlan
>> device on top of a macvap (for the purposes of enabling a VM
>> to use vlans with macvtap), then the current code will result
>> in passing an untagged packet to the macvtap rx_handler and the
>> VM will not receive tagged traffic.
> 
> skb->vlan_tci is set. macvlan should work with that to pass the frame
> correctly. This should be handled in macvtap code.

OK.  Consider a configuration.

               vlan10
vlan10           |
  |         VM1:eth0
  v          |
macvtap0 <---+
  |
  V
eth0

On the host, vlan10 can't really send and receive traffic.  It's only
there to add a vlan filter to eth0 so that packets marked with vlan10
can be received.

When traffic is processed by __netif_receive_skb_core(), skb->dev is eth0 and we
have the tci, so that when vlan_do_receive() is called, we can't find the vlan
device and call the rx_handler macvlan_handle_frame().
That handler calls netif_rx() with skb->dev set to macvtap0.

This time through the receive path, vlan_tci is still set and we
do find the vlan device which is on top of macvtap0, so we set the tci to 0
and then pass it to the rx_handler macvtap_handle_frame().

As a result, we pass an untagged frame to the VM.

> 
> btw can you give me an example of setup where rx_handler is set for
> macvlan device? I wonder what is could be.
> 
>>
>> This patch moves the untaggin code to after the rx_handler for
>> the current device has been called.  This still works for the
>> existing rx_handlers (like bonding/teaming/bridging/etc) and
>> also makes vlans on top of macvtap work as before.
>>
>> Fixes: 6acf54f1cf (macvtap: Add support of packet capture on macvtap device)
>> Reported-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> ---
>> net/core/dev.c | 22 +++++++++++-----------
>> 1 file changed, 11 insertions(+), 11 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index ab9a165..54691d1 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3642,17 +3642,6 @@ ncls:
>> 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
>> 		goto drop;
>>
>> -	if (vlan_tx_tag_present(skb)) {
>> -		if (pt_prev) {
>> -			ret = deliver_skb(skb, pt_prev, orig_dev);
>> -			pt_prev = NULL;
>> -		}
>> -		if (vlan_do_receive(&skb))
>> -			goto another_round;
>> -		else if (unlikely(!skb))
>> -			goto unlock;
>> -	}
>> -
>> 	rx_handler = rcu_dereference(skb->dev->rx_handler);
>> 	if (rx_handler) {
>> 		if (pt_prev) {
>> @@ -3674,6 +3663,17 @@ ncls:
>> 		}
>> 	}
>>
>> +	if (vlan_tx_tag_present(skb)) {
>> +		if (pt_prev) {
>> +			ret = deliver_skb(skb, pt_prev, orig_dev);
>> +			pt_prev = NULL;
>> +		}
>> +		if (vlan_do_receive(&skb))
>> +			goto another_round;
>> +		else if (unlikely(!skb))
>> +			goto unlock;
>> +	}
>> +
> 
> nack. This will definitelly break several stacked setups.

Which ones?  The only thing I can see that would behave differently
is something like:

    vlan0      bridge0
     |           |
     +-------- eth0

In this case, the old code would give an untagged packet to the bridge
and the new code would give a tagged packet.

This set-up is a bit ambiguous.  Remove the vlan, and bridge gets a tagged
traffic even though the vlan has no relationship to the bridge.

I've tested a couple of different stacked setups and they all seem to work.

Thanks
-vlad

> 
> 
>> 	if (unlikely(vlan_tx_tag_present(skb))) {
>> 		if (vlan_tx_tag_get_id(skb))
>> 			skb->pkt_type = PACKET_OTHERHOST;
>> -- 
>> 1.9.3
>>
