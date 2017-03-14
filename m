From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH net-next RFC v1 00/27] afnetns: new namespace type for separation on protocol level
Date: Tue, 14 Mar 2017 12:46:50 -0500
Message-ID: <87zignlpit.fsf@xmission.com>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
        <20170312.162613.1105038945335893886.davem@davemloft.net>
        <1489362279.2283.1.camel@stressinduktion.org>
        <CAHO5Pa1s949dohzEEE68Ux=mXA7N7sR-U98Jwjvx1a_A5AhFEw@mail.gmail.com>
        <874lywu90i.fsf@xmission.com>
        <cc9229f8-a389-87cc-2512-ee00e200a7c3@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cc9229f8-a389-87cc-2512-ee00e200a7c3-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
        (Hannes Frederic Sowa's message of "Tue, 14 Mar 2017 11:18:13 +0100")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org> writes:

> On 13.03.2017 23:06, Eric W. Biederman wrote:
>> Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> 
>>> On Mon, Mar 13, 2017 at 12:44 AM, Hannes Frederic Sowa
>>> <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org> wrote:
>>>> Hi,
>>>>
>>>> On Sun, 2017-03-12 at 16:26 -0700, David Miller wrote:
>>>>> From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
>>>>> Date: Mon, 13 Mar 2017 00:01:24 +0100
>>>>>
>>>>>> afnetns behaves like ordinary namespaces: clone, unshare, setns syscalls
>>>>>> can work with afnetns with one limitation: one cannot cross the realm
>>>>>> of a network namespace while changing the afnetns compartement. To get
>>>>>> into a new afnetns in a different net namespace, one must first change
>>>>>> to the net namespace and afterwards switch to the desired afnetns.
>>>>>
>>>>> Please explain why this is useful, who wants this kind of facility,
>>>>> and how it will be used.
>>>>
>>>> Yes, I have to enhance the cover letter:
>>>>
>>>> The work behind all this is to provide more dense container hosting.
>>>> Right now we lose performance, because all packets need to be forwarded
>>>> through either a bridge or must be routed until they reach the
>>>> containers. For example, we can't make use of early demuxing for the
>>>> incoming packets. We basically pass the networking stack twice for
>>>> every packet.
>>>>
>>>> The usage is very much in line with how network namespaces are used
>>>> nowadays:
>>>>
>>>> ip afnetns add afns-1
>>>> ip address add 192.168.1.1/24 dev eth0 afnetns afns-1
>>>> ip afnetns exec afns-1 /usr/sbin/httpd
>>>>
>>>> this spawns a shell where all child processes will only have access to
>>>> the specific ip addresses, even though they do a wildcard bind. Source
>>>> address selection will also use only the ip addresses available to the
>>>> children.
>>>>
>>>> In some sense it has lots of characteristics like ipvlan, allowing a
>>>> single MAC address to host lots of IP addresses which will end up in
>>>> different namespaces. Unlink ipvlan however, it will also solve the
>>>> problem around duplicate address detection and multiplexing packets to
>>>> the IGMP or MLD state machines.
>>>>
>>>> The resource consumption in comparison with ordinary namespaces will be
>>>> much lower. All in all, we will have far less networking subsystems to
>>>> cross compared to normal netns solutions.
>>>>
>>>> Some more information also in the first patch, which adds a
>>>> Documentation.
>> 
>> If the goal is one ip address per network namespace with a network
>> device and mac address on the network I have something that I was
>> working on that I believe is in the end is a much simpler solution.
>
> Actually, it should be possible to use more than one IP address per
> namespace, proper source address selection should deal with that and
> also correctly select the higher scored ones, based on output device and
> distance to the remote ip address.

Definitely.  I should have said at least one.  Some people want address
sharing and precludes several kinds of optimizations.

>> Add routes in the routing table between network namespaces.
>> 
>> AKA in the initial network namespace with the network device have
>> an input route not towards the local loopback device but towards
>> the network namespaces loopback device.
>> 
>> Before other issues took precedence I made it half way to implementing
>> that.   The ip input path won't get confused if the destination network
>> device is not in the same network namespace as the device.  Last I
>> looked the ip output path still had a few places where confusion was
>> possible between the network socket and the output device.
>
> The ip afnetns input path is also of no concern to me and will work
> quite easily. Right now, the different semantics and rules for selecting
> a source address are the more problematic ones. I think, that in the
> case of directly routing from one ns into another this will be the same
> and the most complex case to deal with?

With what I am proposing that case should be drop dead simple and cause
no confusion.  The extra routes should look like ordinary routes
for forwarding packets, not local addresses and as such should cause
no confusion.  So source address selection should work perfectly as is.

>> As long as installing such routes is conditional upon having
>> CAP_NET_ADMIN in both network namespaces you should be fine and things
>> should be very simple and very fast.  Because that won't take a special
>> case through the network stack.
>> 
>> Given that performance is your primary motive I suspect this will yield
>> the fastest possible path through the network stack as no extra steps
>> need to be taken, and can benefit from any routing improvements to the
>> ordinary network stack.
>
> The major performance improvements come from socket early demuxing,
> which actually requires the remote netns socket being visible in the
> initial netns esock tables. We need the same for the representations for
> IP addresses to have ARP/NDISC work correctly. As soon as you try to
> just cross one data structure from one netns to another one, it gets
> really difficult to keep track of all the dependencies. It felt way more
> complex than this approach.

So I will grant I don't see how to perform early demuxing to the
namespaces.  Fundamentally that is hard because the general case allows
network addresses to be repeated in different namespaces.

However there should be a very nice performance gain as a second
trip through the network stack is avoided and the code to perform the
input or output work is fundamentally simple.

As for ARP/NDISC to get the the ARP/NDISC replies working you will
need to enable proxy arp/ndisc, which is what you usually have
to do with that kind of routing nothing special there.  On the output
path the ARP/NDISC tables of the outgoing device will be used
so nothing special needs to happen there.  The latter just falls out of
how the code is designed.

Similarly we will need proxying for IGMP and MLD to enable subscribing
to multicast protocols.  But all of that is the ordinary routing.

So I believe it will take a little bit of care to get things going but
fundamentally it really looks to me like the only new case that needs
to be supported by the network stack is adding a route to an existing
routing table that spans network namespaces.  That includes using the
arp/neighbour table from that network device Which is very well defined
and trivial to maintain.

The only downside I see is the loss of early_demux but that is
fundamental as the network addresses may potentially overlap.

So for best performance to containers disabling early_demux looks like
it will be the way to go.  But I will be really surprised if the route
table lookup will be expensive unless there are a huge number of
containers or routes in the system.  Especially as that code uses an
efficient data structure and was seriously optimized about two years
ago.

Eric
