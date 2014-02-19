From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Wed, 19 Feb 2014 09:20:12 -0800
Message-ID: <CAB=NE6VpUqwNNY4pgbS6du2VsZ6dH0TzQYXmiw6GGN-EiOsV6g@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
 <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com>
 <1392668638.21106.5.camel@dcbw.local> <CAB=NE6XGBp1RwO63W0ac6tTr9JcRM9TB9sap4pa+8PMWwjxu6g@mail.gmail.com>
 <1392828325.21976.6.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Dan Williams <dcbw@redhat.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392828325.21976.6.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 19, 2014 at 8:45 AM, Dan Williams <dcbw@redhat.com> wrote:
> On Tue, 2014-02-18 at 13:19 -0800, Luis R. Rodriguez wrote:
>> On Mon, Feb 17, 2014 at 12:23 PM, Dan Williams <dcbw@redhat.com> wrote:
>> > On Fri, 2014-02-14 at 18:59 -0800, Luis R. Rodriguez wrote:
>> >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>> >>
>> >> Some interfaces do not need to have any IPv4 or IPv6
>> >> addresses, so enable an option to specify this. One
>> >> example where this is observed are virtualization
>> >> backend interfaces which just use the net_device
>> >> constructs to help with their respective frontends.
>> >>
>> >> This should optimize boot time and complexity on
>> >> virtualization environments for each backend interface
>> >> while also avoiding triggering SLAAC and DAD, which is
>> >> simply pointless for these type of interfaces.
>> >
>> > Would it not be better/cleaner to use disable_ipv6 and then add a
>> > disable_ipv4 sysctl, then use those with that interface?
>>
>> Sure, but note that the both disable_ipv6 and accept_dada sysctl
>> parameters are global. ipv4 and ipv6 interfaces are created upon
>> NETDEVICE_REGISTER, which will get triggered when a driver calls
>> register_netdev(). The goal of this patch was to enable an early
>> optimization for drivers that have no need ever for ipv4 or ipv6
>> interfaces.
>
> Each interface gets override sysctls too though, eg:
>
> /proc/sys/net/ipv6/conf/enp0s25/disable_ipv6

I hadn't seen those, thanks!

> which is the one I meant; you're obviously right that the global ones
> aren't what you want here.  But the specific ones should be suitable?

Under the approach Stephen mentioned by first ensuring the interface
is down yes. There's one use case I can consider to still want the
patch though, more on that below.

> If you set that on a per-interface basis, then you'll get EPERM or
> something whenever you try to add IPv6 addresses or do IPv6 routing.

Neat, thanks.

>> Zoltan has noted though some use cases of IPv4 or IPv6 addresses on
>> backends though, as such this is no longer applicable as a
>> requirement. The ipv4 sysctl however still seems like a reasonable
>> approach to enable optimizations of the network in topologies where
>> its known we won't need them but -- we'd need to consider a much more
>> granular solution, not just global as it is now for disable_ipv6, and
>> we'd also have to figure out a clean way to do this to not incur the
>> cost of early address interface addition upon register_netdev().
>>
>> Given that we have a use case for ipv4 and ipv6 addresses on
>> xen-netback we no longer have an immediate use case for such early
>> optimization primitives though, so I'll drop this.
>>
>> > The IFF_SKIP_IP seems to duplicate at least part of what disable_ipv6 is
>> > already doing.
>>
>> disable_ipv6 is global, the goal was to make this granular and skip
>> the cost upon early boot, but its been clarified we don't need this.
>
> Like Stephen says, you need to make sure you set them before IFF_UP, but
> beyond that, wouldn't the interface-specific sysctls work?

Yeah that'll do it, unless there is a measurable run time benefit cost
to never even add these in the first place. Consider a host with tons
of guests, not sure how many is 'a lot' these days. One would have to
measure the cost of reducing the amount of time it takes to boot these
up. As discussed in the other threads though there *is* some use cases
of assigning IPv4 or IPv6 addresses to the backend interfaces though:
routing them (although its unclear to me if iptables can be used
instead, Zoltan?). So at least now there no clear requirement to
remove these interfaces or not have them at all. The boot time cost
savings should be considered though if this is ultimately desirable. I
saw tons of timers and events that'd get triggered with any IPv4 or
IPv6 interface laying around.

  Luis
