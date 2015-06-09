From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 9 Jun 2015 12:15:50 +0200
Message-ID: <20150609101550.GA10411@pox.localdomain>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35329 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbbFIKPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 06:15:54 -0400
Received: by wiga1 with SMTP id a1so11428158wig.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 03:15:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/15 at 11:35am, Shrijeet Mukherjee wrote:
[...]
> model with some performance paths that need optimization. (Specifically
> the output route selector that Roopa, Robert, Thomas and EricB are
> currently discussing on the MPLS thread)

Thanks for posting these patches just in time. This explains how
you intent to deploy Roopa's patches in a scalable manner.

> High Level points
> 
> 1. Simple overlay driver (minimal changes to current stack)
>    * uses the existing fib tables and fib rules infrastructure
> 2. Modelled closely after the ipvlan driver
> 3. Uses current API and infrastructure.
>    * Applications can use SO_BINDTODEVICE or cmsg device indentifiers
>      to pick VRF (ping, traceroute just work)

I like the aspect of reusing existing user interfaces. We might
need to introduce a more fine grained capability than CAP_NET_RAW
to give containers the privileges to bind to a VRF without
allowing them to inject raw frames.

Given I understand this correctly: If my intent was to run a
process in multiple VRFs, then I would need to run that process
in the host network namespace which contains the VRF devices
which would also contain the physical devices. While I might want
to grant my process the ability to bind to VRFs, I may not want
to give it the privileges to bind to any device. So we could
consider introducing CAP_NET_VRF which would allow to bind to
VRF devices.

>    * Standard IP Rules work, and since they are aggregated against the
>      device, scale is manageable
> 4. Completely orthogonal to Namespaces and only provides separation in
>    the routing plane (and ARP)
> 5. Debugging is built-in as tcpdump and counters on the VRF device
>    works as is.
> 
>                                                  N2
>            N1 (all configs here)          +---------------+
>     +--------------+                      |               |
>     |swp1 :10.0.1.1+----------------------+swp1 :10.0.1.2 |
>     |              |                      |               |
>     |swp2 :10.0.2.1+----------------------+swp2 :10.0.2.2 |
>     |              |                      +---------------+
>     | VRF 0        |
>     | table 5      |
>     |              |
>     +---------------+
>     |              |
>     | VRF 1        |                             N3
>     | table 6      |                      +---------------+
>     |              |                      |               |
>     |swp3 :10.0.2.1+----------------------+swp1 :10.0.2.2 |
>     |              |                      |               |
>     |swp4 :10.0.3.1+----------------------+swp2 :10.0.3.2 |
>     +--------------+                      +---------------+

Do I understand this correctly that swp* represent veth pairs?
Why do you have distinct addresses on each peer of the pair?
Are the addresses in N2 and N3 considered private and NATed?

[...]

> # Install the lookup rules that map table to VRF domain
> ip rule add pref 200 oif vrf0 lookup 5
> ip rule add pref 200 iif vrf0 lookup 5
> ip rule add pref 200 oif vrf1 lookup 6
> ip rule add pref 200 iif vrf1 lookup 6

I think this is a good start but we all know the scalability
constraints of this. Depending on the number of L3 domains,
an eBPF classifier utilizing a map to translate origin to
routing table and vice versa might address the scale requirement
long term.

[...]

I will comment on the implementation specifics once I have a
good understanding of your desired end state looks like.
