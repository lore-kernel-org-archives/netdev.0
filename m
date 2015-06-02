From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 02 Jun 2015 17:58:22 -0500
Message-ID: <87a8whhg4x.fsf@x220.int.ebiederm.org>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<87h9qqx9n5.fsf@x220.int.ebiederm.org> <556E18BE.8060505@brocade.com>
	<87d21dolyt.fsf@x220.int.ebiederm.org> <556E2B0B.4040100@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:57363 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbbFBXD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 19:03:26 -0400
In-Reply-To: <556E2B0B.4040100@brocade.com> (Robert Shearman's message of
	"Tue, 2 Jun 2015 23:15:39 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 02/06/15 22:10, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> On 02/06/15 19:11, Eric W. Biederman wrote:
>>>> Robert Shearman <rshearma@brocade.com> writes:
>>>>
>>>>> In order to be able to function as a Label Edge Router in an MPLS
>>>>> network, it is necessary to be able to take IP packets and impose an
>>>>> MPLS encap and forward them out. The traditional approach of setting
>>>>> up an interface for each "tunnel" endpoint doesn't scale for the
>>>>> common MPLS use-cases where each IP route tends to be assigned a
>>>>> different label as encap.
>>>>>
>>>>> The solution suggested here for further discussion is to provide the
>>>>> facility to define encap data on a per-nexthop basis using a new
>>>>> netlink attribue, RTA_ENCAP, which would be opaque to the IPv4/IPv6
>>>>> forwarding code, but interpreted by the virtual interface assigned to
>>>>> the nexthop.
>>>>>
>>>>> A new ipmpls interface type is defined to show the use of this
>>>>> facility to allow IP packets to be imposed with an MPLS
>>>>> encap. However, the facility is designed to be general enough to be
>>>>> used by any encapsulation/tunneling mechanism that has similar
>>>>> requirements of high-scale, high-variation-of-encap.
>>>>
>>>> I am still digging into the details but adding a new network device to
>>>> make this possible if very undesirable.
>>>>
>>>> It is a pain point.  Those network devices get to be a major source of
>>>> memory consumption when there are 4K network namespaces in existence.
>>>>
>>>> It is conceptually wrong.  The network device will never be used as an
>>>> ordinary network device.  All the network device gives you is the
>>>> ability to avoid creating an enumeration of different kinds of
>>>> encapsulation.
>>>
>>> This isn't true. The network device also gives some of the things you
>>> take for granted. Things like fragmentation through specifying the mtu
>>> on the shared tunnel device, being able to specify rules using the
>>> shared tunnel output device, IP stats, and the ability specify a
>>> different destination namespace.
>>
>> Granted you get a few more things.  It is still conceptually wrong as
>> the network device will netver be used as an ordinary network device.
>>
>> Fragmentation is already silly because we are talking about multiple
>> tunnels with different properties.  You need per-route mtu to handle
>> that case.
>
> It's unlikely you'll have a huge variation in the mtus across routes,
> unless you're running in an ISP environment. In the example uses we've
> got in hand, it's highly likely they'll only be a handful of different
> mtus, if that.

Did we ever implement an mpls mtu per netdevice (I think so).
Anyway the tunnel mtu is easy enough to calculate in context (base mtu -
tunnel overhead).  So for default we should not need to do much.

>> Further I am not saying you don't need an output device (which is what
>> is needed to specify a different destination namespace) I am saying that
>> having a funny mpls device is wrong as far as I can see.  Certainly it
>> is a lot of bloody unnecessary overhead.
>>
>> If we are going to design for maximum scaling (and 1 million+ routes)
>> sounds like maximum scaling we should see how far we can go without
>> dragging in the horrible heaviness of additional network devices.  35K a
>> piece last I measured it.  Just a small handful of them are already
>> scaling issues for network namespaces.
>
> For the ipmpls interface I've implemented here, you only need one per
> namespace. You could argue the same for the veth interfaces which
> would be much more commonly used in network namespaces.

But if I can avoid the extra 143M (35Kibibytes*4096namespaces) I would like to.

On the drawing board is getting cross namespace routes so with a little
luck I will only need loopback devices in most of my network namespaces
when the dust settles.

Outputing to network devices in another network namespace is
fundamentally simple but I haven't take the time to figure out which
assumptions I may have to purge to make it work reliably.

> BTW, maybe I've missed something, or maybe netdevs have gone on a
> diet, but I count the cost of creating a basic interface at ~2700
> bytes on x86_64:
> sizeof(struct net_device) /* 2112 */ + 1 * sizeof(struct netdev_queue)
> /* 384 */ + 1 * sizeof(struct netdev_rx_queue) /* 128 */ +
> sizeof(struct netdev_hw_addr) /* 80 */ + sizeof(int) * nr_poss_cpus /*
> 4 * n */)

It is a non-trivial thing to measure.  You really have to create a lot
of them and see how much memory is consumed.  But between the per cpu
stats, the sysctl attributes, the sysfs attribute and everything else
an actual working netdevice in an all yes config kernel was consuming
something like 35K not too long ago.

Eric
