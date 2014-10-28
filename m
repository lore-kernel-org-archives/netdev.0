From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Tue, 28 Oct 2014 08:18:17 -0700
Message-ID: <CA+mtBx9=xTyqTXrZODi9dyN1H0W51uqvHR4YT3DhFXpdc4FMbw@mail.gmail.com>
References: <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
	<1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_eQKOkM-0PEXG2WEMosXDtqHgwT3j7NnQpP62KdZeJKQ@mail.gmail.com>
	<20141028.005121.1715627351754245965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:63203 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaJ1PSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 11:18:18 -0400
Received: by mail-ig0-f172.google.com with SMTP id h15so6951332igd.5
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 08:18:17 -0700 (PDT)
In-Reply-To: <20141028.005121.1715627351754245965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2014 at 9:51 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 27 Oct 2014 18:09:25 -0700
>
>> This indicates nothing about the merits of this patch. Nevertheless,
>> in order to avoid further rat-holing and since this patch does change
>> a long standing behavior I'll will respin to make it enabled only by
>> sysctl.
>
> Kind of disappointed on my end that you haven't addressed Eric's
> main point, which is that:
>
> 1) A hash table shared between protocols will perform poorly for
>    mixed workloads which are becomming increasingly common.
>
The major design point of RFS is that it steers L4 flows based on a
hash for the each flow. Preferably, this hash is based on the 5-tuple
of the (innermost) UDP, TCP, SCTP, etc. packet. It is a probabilistic
algorithm whose effectiveness depends on hit rate in the table, hence
the table should be sized to the working set. In RFS, the working set
is defined by the number of simultaneously active flows not by the
number of established flows which could be much greater. We've known
from the beginning that for some servers with large amounts of
non-flow based traffic (particularly DNS servers) RFS may not be
useful. If it's not feasible to size the table to the working set,
then RFS shouldn't be used.

> 2) UDP is fundamentally different from TCP in that the issue of
>    'flow' vs. 'non-flow' packets
>
We are seeing many instances where UDP packets carry flows, and
conversely there are important cases where TCP packets do not
correspond to flows.

UDP tunnels are becoming increasingly common. VXLAN, FOU, GUE, geneve,
l2tp, esp/UDP, GRE/UDP, nvgre, etc. all rely on steering based on the
outer header without deep inspection. When the source port is set to
inner hash RFS works as is and steering is effectively done based
inner TCP connections. If aRFS supports UDP, then this should just
work also for UDP tunnels (another instance where we don't need
protocol specific support in devices for tunneling).

QUIC itself is flow based. It is a transport protocol about as
sophisticated as TCP that is encapsulated in UDP to facilitate
transport. The fact that QUIC might have millions of simultaneously
active connections is a problem of scale, not of the algorithm. If we
have a server with millions of active TCP connections we'd have the
exact same scaling problem.

Under several DOS attacks TCP packets are not flow based. For instance
in a SYN attack once we get into syn cookies, SYNs are steered based
on whatever is in the table and the table is not updated for these
packets. This case exhibits the same characteristics as non-flow UDP.
In fact makes me think we should also be clearing the flow table in
this case.

> I personally do not see you avoiding this conversation by simply
> hiding the new behavior behind a sysctl, I still want you to address
> it before I apply anything.
