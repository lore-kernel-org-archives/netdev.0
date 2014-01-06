From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] bridge: Fix crash with vlan filtering and tcpdump
Date: Mon, 06 Jan 2014 11:02:34 -0500
Message-ID: <52CAD39A.7040607@redhat.com>
References: <1388765553-12965-1-git-send-email-vyasevic@redhat.com> <1388934147.1906.17.camel@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbaAFQCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 11:02:40 -0500
In-Reply-To: <1388934147.1906.17.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2014 10:02 AM, Toshiaki Makita wrote:
> On Fri, 2014-01-03 at 11:12 -0500, Vlad Yasevich wrote:
>> When the vlan filtering is enabled on the bridge, but
>> the filter is not configured on the bridge device itself,
>> running tcpdump on the bridge device will result in a
>> an Ooops with NULL pointer dereference.  The reason
>     ^^^^^
> Oops?
> 
>> is that br_pass_frame_up() will bypass the vlan
>> check because promisc flag is set.  It will then try
>> to get the table pointer and process the packet based
>> on the table.  Since the table pointer is NULL, we oops.
>> Catch this special condition in br_handle_vlan().
>>
>> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
> ...
>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>> index af5ebd1..ea0c29b 100644
>> --- a/net/bridge/br_vlan.c
>> +++ b/net/bridge/br_vlan.c
>> @@ -144,6 +144,18 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>>  	if (!br->vlan_enabled)
>>  		goto out;
>>  
>> +	/* Vlan filter table must be configrured at this point.  The
>> +	 * only exception is the bridge is set in promisc mode and the
>> +	 * packet is destined for the bridge device.  In this case
>> +	 * pass the packet as is.
>> +	 */
>> +	if (!pv) {
>> +       		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev)
>> +			goto out;
> 
> Currently this function is calling __vlan_put_tag() if port_idx==0.
> You are going to bypass it only if br is promisc mode.
> 
> However it doesn't seem to lead any problem because
> __netif_receive_skb_core() can handle hw accel vlan tag.
> 
> Instead, I doubt if __vlan_put_tag() is necessary in br_handle_vlan()...

I'll need to re-test, but I remember having had to add that code to make
it work on the bridge...

Looking at it again, I agree that special handling for forwarding to the
bridge doesn't seem to be needed.

-vlad

> 
> Thanks,
> Toshiaki Makita
> 
> 
