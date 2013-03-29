From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 18:29:05 -0700
Message-ID: <87wqsr3sf2.fsf@xmission.com>
References: <20130328150410.GA22789@sergelap>
	<CD7A1D9A.78BA%blourdel@juniper.net>
	<20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	<87zjxn84ks.fsf@xmission.com>
	<1364516016.15753.59.camel@edumazet-glaptop>
	<87ppyj6ohh.fsf@xmission.com>
	<1364517837.15753.61.camel@edumazet-glaptop>
	<1364519448.15753.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42056 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623Ab3C2B3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 21:29:17 -0400
In-Reply-To: <1364519448.15753.63.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 28 Mar 2013 18:10:48 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2013-03-28 at 17:43 -0700, Eric Dumazet wrote:
>
>> In batch mode, I can create these veth pairs in 4 seconds
>> 
>> for i in $(seq 1 5000) ; do echo link add a$i type veth peer name b$i;
>> done | ip -batch -
>
>
> At rmmod time, 30% of cpu is spent in packet_notifier()
>
> Maybe we can do something about this.

An interesting thought.  I had a patch I never got around to pushing a
while back that would have had an effect.

It is my observation that the vast majority of packet filters apply not
to the entire machine but to an individual interface.  In fact you have
to work pretty hard to get tools like tcpdump to dump all of the
interfaces at once.

So to speed things up for machines that have a lot of these things the
idea was to create per device lists for the filters that only needed to
be run on a single device.  In this case it looks like we could
potentially create per device lists for of the listening sockets as well.

In general these lists should be short so the search can also be short.

But I am curious do you actually have a tcpdump or something similar
running on your box that is using AF_PACKET sockets?  Perhaps a dhcp
client?

I am a little surprised that your default case has anything on the lists
to trigger any work in the packet_notifier notifier.

>    30.85%         rmmod  [kernel.kallsyms]     [k]
> packet_notifier                                                                                 
>                    |
>                    --- packet_notifier
>                        notifier_call_chain
>                        raw_notifier_call_chain
>                        call_netdevice_notifiers
>                        rollback_registered_many
>                        unregister_netdevice_many
>                        __rtnl_link_unregister
>                        rtnl_link_unregister
>                        0xffffffffa0044868
>                        sys_delete_module
>                        sysenter_dispatch

Eric
