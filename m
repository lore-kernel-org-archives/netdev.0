From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 18:06:32 -0700
Message-ID: <87ip4b5813.fsf@xmission.com>
References: <20130328150410.GA22789@sergelap>
	<CD7A1D9A.78BA%blourdel@juniper.net>
	<20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	<87zjxn84ks.fsf@xmission.com>
	<1364516016.15753.59.camel@edumazet-glaptop>
	<87ppyj6ohh.fsf@xmission.com>
	<1364517837.15753.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38618 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab3C2BGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 21:06:44 -0400
In-Reply-To: <1364517837.15753.61.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 28 Mar 2013 17:43:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2013-03-28 at 17:25 -0700, Eric W. Biederman wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> 
>> > On Thu, 2013-03-28 at 16:52 -0700, Eric W. Biederman wrote:
>> >
>> >> On my microbenchmark of just creating 5000 veth pairs this takes pairs
>> >> 16s instead of 13s of my earlier hacks but that is well down in the
>> >> usable range.
>> >
>> > I guess most of the time is taken by sysctl_check_table()
>> 
>> All of the significant sysctl slowdowns were fixed in 3.4.  If you see
>> something of sysctl show up in a trace I would be happy to talk about
>> it.  The kernel side seems to be creating N network devices seems to
>> take NlogN time now.  Both sysfs and sysctl store directories as
>> rbtrees removing their previous bottlenecks.
>> 
>> The loop I timed at 16s was just:
>> 
>> time for i in $(seq 1 5000) ; do ip link add a$i type veth peer name b$i; done
>> 
>> There is plenty of room for inefficiencies in 10000 network devices and
>> 5000 forks+execs.
>
> Ah right, the sysctl part is fixed ;)
>
> In batch mode, I can create these veth pairs in 4 seconds
>
> for i in $(seq 1 5000) ; do echo link add a$i type veth peer name b$i;
> done | ip -batch -

Yes.  The interesting story here is that the bottleneck before these
patches was the ll_init_map function of iproute2.   Which resulted in an
over an order of magnitude slowdown of when starting iproute on a system
with lots of network devices.

It is still unclear where iproute comes into the picture in the original
problem scenario of creating 2000 containers each with 2 veth pairs.
But apparently it was.

As the fundamental use case here was taking 2000 separate independent
actions it turns out to be important for things to not slowdown
unreasonably outside of batch mode.  So I was explicitly testing the
non-batch mode performance.

On the flip side it might be interesting to see if we can get batch mode
deletes to batch in the kernel, so we don't have to wait for through
syncrhonize_rcu_expidited for each of them.  Although for the container
case I can just drop the last reference to the network namespace and all
of the network device removals will batch.

Ultimately shrug.  Except in the previous O(N^2) userspace behavior
there don't seem to be any practical performance problems with this many
network devices.  What is interesting is that this many network devices
is becoming interesting on inexpensive COTS servers, for cases that are
not purely network focused.

Eric
