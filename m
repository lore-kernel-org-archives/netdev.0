From: Tom Herbert <tom@herbertland.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 11:05:59 -0800
Message-ID: <CALx6S35DCyi_2z1pqCLaB1bVyNykP_J3YaYEXUT8xxmuzyBDwA@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201135508.GB24547@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33933 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752264AbcLATGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:06:00 -0500
Received: by mail-qt0-f182.google.com with SMTP id n6so230492266qtd.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 11:06:00 -0800 (PST)
In-Reply-To: <20161201135508.GB24547@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 5:55 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (11/30/16 14:54), Tom Herbert wrote:
>>
>> Posting for discussion....
>    :
>> One simplifying assumption we might make is that TXDP is primarily for
>> optimizing latency, specifically request/response type operations
>> (think HPC, HFT, flash server, or other tightly coupled communications
>> within the datacenter). Notably, I don't think that saving CPU is as
>> relevant to TXDP, in fact we have already seen that CPU utilization
>> can be traded off for lower latency via spin polling. Similar to XDP
>> though, we might assume that single CPU performance is relevant (i.e.
>> on a cache server we'd like to spin as few CPUs as needed and no more
>> to handle the load an maintain throughput and latency requirements).
>> High throughput (ops/sec) and low variance should be side effects of
>> any design.
>
> I'm sending this with some hesitation (esp as the flamebait threads
> are starting up - I have no interest in getting into food-fights!!),
> because it sounds like the HPC/request-response use-case you have in mind
> (HTTP based?) is very likely different than the one the DB use-cases in
> my environment (RDBMS, Cluster req/responses). But to provide some
> perspective from the latter use-case..
>
> We also have request-response transactions, but CPU utilization
> is extremely critical- many DB operations are highly CPU bound,
> so it's not acceptable for the network to hog CPU util by polling.
> In that sense, the DB req/resp model has a lot of overlap with the
> Suricata use-case.
>
Hi Sowmini,

Polling does not necessarily imply that networking monopolizes the CPU
except when the CPU is otherwise idle. Presumably the application
drives the polling when it is ready to receive work.

> Also we need a select()able socket, because we have to deal with
> input from several sources- network I/O, but also disk, and
> file-system I/O. So need to make sure there is no starvation,
> and that we multiplex between  I/O sources efficiently
>
Yes, that is a requirement.

> and one other critical difference from the hot-potato-forwarding
> model (the sort of OVS model that DPDK etc might aruguably be a fit for)
> does not apply: in order to figure out the ethernet and IP headers
> in the response correctly at all times (in the face of things like VRRP,
> gw changes, gw's mac addr changes etc) the application should really
> be listening on NETLINK sockets for modifications to the networking
> state - again points to needing a select() socket set where you can
> have both the I/O fds and the netlink socket,
>
I would think that that is management would not be implemented in a
fast path processing thread for an application.

> For all of these reasons, we are investigating approaches similar ot
> Suricata- PF_PACKET with TPACKETV2 (since we need both Tx and Rx,
> and so far, tpacketv2 seems "good enough"). FWIW, we also took
> a look at netmap and so far have not seen any significant benefits
> to netmap over pf_packet.. investigation still ongoing.
>
>>   - Call into TCP/IP stack with page data directly from driver-- no
>> skbuff allocation or interface. This is essentially provided by the
>
> I'm curious- one thing that came out of the IPsec evaluation
> is that TSO is very valuable for performance, and this is most easily
> accessed via the sk_buff interfaces.  I have not had a chance
> to review your patches yet, but isnt that an issue if you bypass
> sk_buff usage? But I should probably go and review your patchset..
>
The *SOs are always an interesting question. They make for great
benchmarks, but in real life the amount of benefit is somewhat
unclear. Under the wrong conditions, like all cwnds have collapsed or
received packets for flows are small or so mixed that we can't get
much aggregation, SO provides no benefit and in fact becomes
overhead. Relying on any amount of segmentation offload in real
deployment is risky; for instance we've seen some video servers
deployed that were able to serve line rate at 90% CPU in testing (SO
was effective) but ended up needing 110% CPU in deployment when a
hiccup caused all cwnds to collapse. Moral of the story is provision
your servers assuming the worse case conditions that would render
opportunistic offloads unless.

For the GSO and GRO the rationale is that performing the extra SW
processing to do the offloads is significantly less expensive than
running each packet through the full stack. This is true in a
multi-layered generalized stack. In TXDP, however, we should be able
to optimize the stack data path such that that would no longer be
true. For instance, if we can process the packets received on a
connection quickly enough so that it's about the same or just a little
more costly than GRO processing then we might bypass GRO entirely.
TSO is probably still relevant in TXDP since it reduces overheads
processing TX in the device itself.

Tom

> --Sowmini
