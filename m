From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next PATCH] macvlan: resolve ENOENT errors on creation
Date: Tue, 22 Oct 2013 00:05:42 +0200
Message-ID: <20131021220542.GC18170@redhat.com>
References: <20131021212801.19330.69659.stgit@nitbit.x32>
 <20131021213441.GB18170@redhat.com>
 <5265A147.4010501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463Ab3JUWIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 18:08:04 -0400
Content-Disposition: inline
In-Reply-To: <5265A147.4010501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 02:48:55PM -0700, John Fastabend wrote:
>On 10/21/2013 02:34 PM, Veaceslav Falico wrote:
>>On Mon, Oct 21, 2013 at 02:28:02PM -0700, John Fastabend wrote:
>>>After the commit below attempting to create macvlan devices was
>>>resulting in ENOENT errors,
>>>
>>># ip link add link p3p2 type macvlan
>>>RTNETLINK answers: Invalid argument
>>>
>>>This happens because netdev_upper_dev_link() is called before
>>>register_netdevice() in the macvlan code. Through a call chain
>>>this results in a call to __netdev_adjacent_dev_insert() and
>>>finally a sysfs_create_link(). This requires the kobject of
>>>the macvlan to be registered which is done in register_netdevice().
>>>If there is no kobject which is the case here the ENOENT error
>>>is seen on the command line.
>>>
>>>To resolve this move the netdev_upper_dev_link() call below
>>>the register_netdevice() call. This aligns with vlan driver
>>>flow.
>>
>>Yep, changed the vlan code, but didn't see the macvlan. My cscope didn't
>>catch it for some reason :-/.
>>
>>I've also checked - there are no users except bonding, vlan (both are ok),
>>and macvlan.
>>
>
>The openvswitch code uses netdev_master_upper_dev_link() which
>eventually calls __netdev_adjacent_dev_insert() as well. But from
>a quick code inspection I think it should work. Anyways that is one
>other user.

Yep, checked them also now:

team - links two already existing devices (team->dev and port_dev)
batadv - links existing device to another existing device, or creates of if
	 the latter doesn't exist (and calls register_netdev on creation)
bridge - links two already existing devices (bridge->dev and dev)
openvswitch - links two already existing devices (get_dpdev(vport->dp) and
	      the device found by dev_get_by_name()).
bonding - uses netdev_master_upper_dev_link_private(), and is also ok.

Hopefully we're safe.

>
>.John
>
>-- 
>John Fastabend         Intel Corporation
