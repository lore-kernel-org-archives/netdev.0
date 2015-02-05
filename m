From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 15:12:57 -0800
Message-ID: <54D3F8F9.2060500@cumulusnetworks.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	hannes@stressinduktion.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:40460 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbBEXM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:12:59 -0500
Received: by pdjy10 with SMTP id y10so10611855pdj.7
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 15:12:58 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/4/15, 5:34 PM, David Ahern wrote:
> Kernel patches are also available here:
>      https://github.com/dsahern/linux.git vrf-3.19
>
> iproute2 patches are also available here:
>      https://github.com/dsahern/iproute2 vrf-3.19
>
>
> Background
> ----------
> The concept of VRFs (Virtual Routing and Forwarding) has been around for over
> 15 years. Support for VRFs in the Linux kernel has been an often requested
> feature for almost as long. For a while support was available via an out of
> tree patch [1]. Since network namespaces came along, the response to queries
> about VRF support for Linux was 'use namespaces'. But as mentioned previously
> [2] network namespaces are not a good match for VRFs. Of the list of problems
> noted the big one is that namespaces do not scale efficiently to the number
> of VRFs supported by networking gear (> 1000 VRFs). Networking vendors that
> want to use Linux as the OS have to carry custom solutions to this problem --
> be it userspace networking stacks, extensive kernel patches (to add VRF
> support or bend the implementation of namespaces), and/or patches to many
> open source components. The recent addition of switchdev support in the
> kernel suggests that people expect the use of Linux as a switch networking
> OS to increase. Hopefully the time is right to re-open the discussion on a
> salable VRF implementation for the Linux kernel.
>
> The intent of this RFC is to get feedback on the overall idea - namely VRFs
> as integer id and the nesting of VRFs within a namespace. This set includes
> changes only to core IPv4 code which shows the concept; changes to the rest
> of the network stack are fairly repetitive.
>
> This patch set has a number of similarities to the original VRF patch - most
> notably VRF ids as an integer index and plumbing through iproute2 and
> netlink. But this set is really a complete re-implementation of the feature,
> integrating VRF within a namespace and leveraging existing support for
> network namespaces.
>
> Design
> ------
> Namespaces provide excellent separation of the networking stack from the
> netdevices and up. The intent of VRFs is to provide an additional,
> logical separation at the L3 layer within a namespace.
>
>     +----------------------------------------------------------+
>     | Namespace foo                                            |
>     |                         +---------------+                |
>     |          +------+       | L3/L4 service |                |
>     |          | lldp |       |   (VRF any)   |                |
>     |          +------+       +---------------+                |
>     |                                                          |
>     |                             +-------------------------+  |
>     |                             | VRF M                   |  |
>     |  +---------------------+  +-------------------------+ |  |
>     |  | VRF 1 (default)     |  | VRF N                   | |  |
>     |  |  +---------------+  |  |    +---------------+    | |  |
>     |  |  | L3/L4 service |  |  |    | L3/L4 service |    | |  |
>     |  |  | (VRF unaware) |  |  |    | (VRF unaware) |    | |  |
>     |  |  +---------------+  |  |    +---------------+    | |  |
>     |  |                     |  |                         | |  |
>     |  |+-----+ +----------+ |  |  +-----+ +----------+   | |  |
>     |  || FIB | | neighbor | |  |  | FIB | | neighbor |   | |  |
>     |  |+-----+ +----------+ |  |  +-----+ +----------+   | |  |
>     |  |                     |  |                         |-+  |
>     |  | {dev 1}  {dev 2}    |  | {dev 3} {dev 4} {dev 5} |    |
>     |  +---------------------+  +-------------------------+    |
>     +----------------------------------------------------------+
>
> This is accomplished by enhancing the current namespace checks to a
> broader network context that is both a namepsace and a VRF id. The VRF
> id is a tag applied to relevant structures, an integer between 1 and 4095
> which allows for 4095 VRFs (could have 0 be the default VRF and then the
> range is 0-4095 = 4096s VRFs). (The limitation is arguably artificial. It
> is based on the genid scheme for versioning networking data which is a
> 32-bit integer. The VRF id is the lower 12 bits of the genid's.)
>
> Netdevices, sk_buffs, sockets, and tasks are all tagged with a VRF id.
> Network lookups (devices, sockets, addresses, routes, neighbors) require a
> match of both network namespace and VRF id (or the special 'vrf any' tag;
> more on that later).
>
>
David,

Wondering if you have thought about some of the the below cases in your 
approach to vrfs ?.
- Leaking routes from one vrf to another
- route lookup in one vrf on failure to fallback to the global vrf (This 
for example can be done using throw if we used ip rules and route tables 
to do the same).
- A route in one vrf pointing to a nexthop in another vrf

We have been playing with ip rules to implement vrfs. And the blocker 
today is that we cannot bind a socket to a vrf (routing tables in this 
case).

Thanks,
Roopa
