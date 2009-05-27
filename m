From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next] bonding: allow bond in mode balance-alb to
	work properly in bridge -try4.1
Date: Wed, 27 May 2009 10:25:14 +0200
Message-ID: <20090527082513.GA1652@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090526151717.GB11147@psychotron.englab.brq.redhat.com> <20090526163242.GE6608@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34051 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758622AbZE0I36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 04:29:58 -0400
Content-Disposition: inline
In-Reply-To: <20090526163242.GE6608@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 26, 2009 at 06:32:42PM CEST, andy@greyhouse.net wrote:
>On Tue, May 26, 2009 at 05:17:17PM +0200, Jiri Pirko wrote:
>> [PATCH net-next] bonding: allow bond in mode balance-alb to work properly in bridge -try4.1
>> 
>> Hi all.
>> 
>> The problem is described in following bugzilla:
>> https://bugzilla.redhat.com/show_bug.cgi?id=487763
>> 
>> Basically here's what's going on. In every mode, bonding interface uses the same
>> mac address for all enslaved devices (except fail_over_mac). Only balance-alb
>> will simultaneously use multiple MAC addresses across different slaves. When you
>> put this kind of bond device into a bridge it will only add one of mac adresses
>> into a hash list of mac addresses, say X. This mac address is marked as local.
>> But this bonding interface also has mac address Y. Now then packet arrives with
>> destination address Y, this address is not marked as local and the packed looks
>> like it needs to be forwarded. This packet is then lost which is wrong.
>> 
>> Notice that interfaces can be added and removed from bond while it is in bridge.
>> 
>> ***
>> When the multiple addresses for bridge port approach failed to solve this issue
>> due to STP I started to think other way to solve this. I returned to previous
>> solution but tweaked one.
>> 
>> This patch solves the situation in the bonding without touching bridge code.
>> For every incoming frame to bonding the destination address is compared to
>> current address of the slave device from which tha packet came. If these two
>> match destination address is replaced by mac address of the master. This address
>> is known by bridge so it is delivered properly.
>
>Did you test this with a bond with more than 2 ports?  I ask because I
>might also expect a check against all the members of the bond (rather
>than simply the receiving device).

Yes, my testing machine has 3 interfaces for bond. Works fine.
>
>That check would be quite expensive for every frame and I think the
>scenario is quite unlikely based on the frequency of 'learning frames'
>sent by the alb code (so the switch connected to the host should have
>it's forwarding database correct), but it might be something to think
>about in the future.

As you can see, my previous patch did the checking vs all slaves. I tried this
experimentally and searched address from the list and dev->dev_addr differs only
when I unplug cable and mac swap occurs. Then one packet is lost. But there are
many lost packet during the unplug anyway so....

>
>> I experimentally tried that this works as good as searching through the slave
>> list (v4 of this patch).
>> 
>> I was forced to create a new header because I need to use
>> compare_ether_addr_64bits() (defined in linux/etherdevice.h) in
>> linux/netdevice.h. I've hit some cross include issues. I think that it's good
>> to have skb_bond_should_drop() in a separate file anyway.
>> 
>> Jirka
>> 
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> 
>
>This certainly won't cure all of the problems that arise with bonding
>and bridging interactions, but it's a step in the right direction.
>
>Acked-by: Andy Gospodarek <andy@greyhouse.net>
>
