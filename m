From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 08:55:08 -0500
Message-ID: <20161201135508.GB24547@oracle.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48417 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755903AbcLANyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 08:54:50 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/30/16 14:54), Tom Herbert wrote:
> 
> Posting for discussion....
   :
> One simplifying assumption we might make is that TXDP is primarily for
> optimizing latency, specifically request/response type operations
> (think HPC, HFT, flash server, or other tightly coupled communications
> within the datacenter). Notably, I don't think that saving CPU is as
> relevant to TXDP, in fact we have already seen that CPU utilization
> can be traded off for lower latency via spin polling. Similar to XDP
> though, we might assume that single CPU performance is relevant (i.e.
> on a cache server we'd like to spin as few CPUs as needed and no more
> to handle the load an maintain throughput and latency requirements).
> High throughput (ops/sec) and low variance should be side effects of
> any design.

I'm sending this with some hesitation (esp as the flamebait threads
are starting up - I have no interest in getting into food-fights!!), 
because it sounds like the HPC/request-response use-case you have in mind
(HTTP based?) is very likely different than the one the DB use-cases in
my environment (RDBMS, Cluster req/responses). But to provide some
perspective from the latter use-case..

We also have request-response transactions, but CPU utilization
is extremely critical- many DB operations are highly CPU bound,
so it's not acceptable for the network to hog CPU util by polling.
In that sense, the DB req/resp model has a lot of overlap with the
Suricata use-case.

Also we need a select()able socket, because we have to deal with
input from several sources- network I/O, but also disk, and 
file-system I/O. So need to make sure there is no starvation,
and that we multiplex between  I/O sources efficiently

and one other critical difference from the hot-potato-forwarding
model (the sort of OVS model that DPDK etc might aruguably be a fit for)
does not apply: in order to figure out the ethernet and IP headers
in the response correctly at all times (in the face of things like VRRP,
gw changes, gw's mac addr changes etc) the application should really
be listening on NETLINK sockets for modifications to the networking
state - again points to needing a select() socket set where you can
have both the I/O fds and the netlink socket, 

For all of these reasons, we are investigating approaches similar ot
Suricata- PF_PACKET with TPACKETV2 (since we need both Tx and Rx,
and so far, tpacketv2 seems "good enough"). FWIW, we also took
a look at netmap and so far have not seen any significant benefits
to netmap over pf_packet.. investigation still ongoing.

>   - Call into TCP/IP stack with page data directly from driver-- no
> skbuff allocation or interface. This is essentially provided by the

I'm curious- one thing that came out of the IPsec evaluation
is that TSO is very valuable for performance, and this is most easily
accessed via the sk_buff interfaces.  I have not had a chance
to review your patches yet, but isnt that an issue if you bypass
sk_buff usage? But I should probably go and review your patchset..

--Sowmini
