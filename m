From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: wireless vs. network namespaces (part II)
Date: Sun, 28 Sep 2008 22:44:14 -0700
Message-ID: <m1y71b8q1d.fsf@frodo.ebiederm.org>
References: <1222509685.3798.59.camel@johannes.berg>
	<m1r675aw0l.fsf@frodo.ebiederm.org>
	<1222587651.3798.72.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59673 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbYI2Fpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 01:45:40 -0400
In-Reply-To: <1222587651.3798.72.camel@johannes.berg> (Johannes Berg's message
	of "Sun, 28 Sep 2008 09:40:51 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> >  * ensure that all netdevs created for this wiphy will have the right
>> >    netns.
>> >
>> > The latter part I'm unsure on, alloc_netdev_mq seems to always use
>> > init_net so I can't put them into the right namespace to start with, but
>> > because they're all "in there together" I can't allow switching
>> > namespaces either.. Ideas?
>> 
>> alloc_netdev_mq doesn't register the device, so it is a matter of simply
>> changing the network device pointer after allocation and before registration.
>> 
>> We do this by default when we dynamically create network devices using
>> netlink.  see rtnl_create_link for an example.
>
> Ok. So I guess I'd want to write a wrapper for registering the netdev
> that puts it into the right namespace for the wireless hardware and sets
> the NETIF_F_NETNS_LOCAL flag.

> I'll have to experiment a bit I guess.

So you are looking at using NETIF_F_NETNS_LOCAL to indicate that you can't move
one of the devices?

There is an UNREGISTER_NETDEV event and a REGISTER_NETDEV event sent when a device
is moved between namespaces.  See:  dev_change_net_namespace.

I think you would want to look onto those and move one network device when you
move the other, without using NETIF_F_NETNS_LOCAL.

Deletion and creation we have definitely done with paired veth devices.  I haven't
looked at the migration case, but I with a little bit of guarding against recursion
it looks like it probably can be handled.  

Say trigger when your parnter device calls REGISTER_NETDEV in a different network
namespace?

Eric

