From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH net-next RFC v1 00/27] afnetns: new namespace type for separation on protocol level
Date: Mon, 13 Mar 2017 17:06:21 -0500
Message-ID: <874lywu90i.fsf@xmission.com>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
        <20170312.162613.1105038945335893886.davem@davemloft.net>
        <1489362279.2283.1.camel@stressinduktion.org>
        <CAHO5Pa1s949dohzEEE68Ux=mXA7N7sR-U98Jwjvx1a_A5AhFEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHO5Pa1s949dohzEEE68Ux=mXA7N7sR-U98Jwjvx1a_A5AhFEw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
        (Michael Kerrisk's message of "Mon, 13 Mar 2017 20:56:35 +0100")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Mon, Mar 13, 2017 at 12:44 AM, Hannes Frederic Sowa
> <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org> wrote:
>> Hi,
>>
>> On Sun, 2017-03-12 at 16:26 -0700, David Miller wrote:
>>> From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
>>> Date: Mon, 13 Mar 2017 00:01:24 +0100
>>>
>>> > afnetns behaves like ordinary namespaces: clone, unshare, setns syscalls
>>> > can work with afnetns with one limitation: one cannot cross the realm
>>> > of a network namespace while changing the afnetns compartement. To get
>>> > into a new afnetns in a different net namespace, one must first change
>>> > to the net namespace and afterwards switch to the desired afnetns.
>>>
>>> Please explain why this is useful, who wants this kind of facility,
>>> and how it will be used.
>>
>> Yes, I have to enhance the cover letter:
>>
>> The work behind all this is to provide more dense container hosting.
>> Right now we lose performance, because all packets need to be forwarded
>> through either a bridge or must be routed until they reach the
>> containers. For example, we can't make use of early demuxing for the
>> incoming packets. We basically pass the networking stack twice for
>> every packet.
>>
>> The usage is very much in line with how network namespaces are used
>> nowadays:
>>
>> ip afnetns add afns-1
>> ip address add 192.168.1.1/24 dev eth0 afnetns afns-1
>> ip afnetns exec afns-1 /usr/sbin/httpd
>>
>> this spawns a shell where all child processes will only have access to
>> the specific ip addresses, even though they do a wildcard bind. Source
>> address selection will also use only the ip addresses available to the
>> children.
>>
>> In some sense it has lots of characteristics like ipvlan, allowing a
>> single MAC address to host lots of IP addresses which will end up in
>> different namespaces. Unlink ipvlan however, it will also solve the
>> problem around duplicate address detection and multiplexing packets to
>> the IGMP or MLD state machines.
>>
>> The resource consumption in comparison with ordinary namespaces will be
>> much lower. All in all, we will have far less networking subsystems to
>> cross compared to normal netns solutions.
>>
>> Some more information also in the first patch, which adds a
>> Documentation.

If the goal is one ip address per network namespace with a network
device and mac address on the network I have something that I was
working on that I believe is in the end is a much simpler solution.

Add routes in the routing table between network namespaces.

AKA in the initial network namespace with the network device have
an input route not towards the local loopback device but towards
the network namespaces loopback device.

Before other issues took precedence I made it half way to implementing
that.   The ip input path won't get confused if the destination network
device is not in the same network namespace as the device.  Last I
looked the ip output path still had a few places where confusion was
possible between the network socket and the output device.

As long as installing such routes is conditional upon having
CAP_NET_ADMIN in both network namespaces you should be fine and things
should be very simple and very fast.  Because that won't take a special
case through the network stack.

Given that performance is your primary motive I suspect this will yield
the fastest possible path through the network stack as no extra steps
need to be taken, and can benefit from any routing improvements to the
ordinary network stack.

Eric
