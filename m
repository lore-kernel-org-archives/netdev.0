From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable memory mapped
 netlink i/o
Date: Wed, 4 Dec 2013 10:08:18 -0800
Message-ID: <20131204180818.GB16940@nicira.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
 <20131204163328.GE30874@nicira.com>
 <529F6475.3090903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:45376 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932990Ab3LDSI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 13:08:26 -0500
Received: by mail-qc0-f176.google.com with SMTP id i8so3704732qcq.21
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 10:08:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <529F6475.3090903@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 06:20:53PM +0100, Thomas Graf wrote:
> On 12/04/2013 05:33 PM, Ben Pfaff wrote:
> >If I'm doing the calculations correctly, this mmaps 8 MB per ring-based
> >Netlink socket on a system with 4 kB pages.  OVS currently creates one
> >Netlink socket for each datapath port.  With 1000 ports (a moderate
> >number; we sometimes test with more), that is 8 GB of address space.  On
> >a 32-bit architecture that is impossible.  On a 64-bit architecture it
> >is possible but it may reserve an actual 8 GB of RAM: OVS often runs
> >with mlockall() since it is something of a soft real-time system (users
> >don't want their packet delivery delayed to page data back in).
> >
> >Do you have any thoughts about this issue?
> 
> That's certainly a problem. I had the impression that the changes that
> allow to consolidate multiple bridges to a single DP would minimize the
> number of DPs used.

Only one datapath is used, but OVS currently creates one Netlink
socket for each port within that datapath.

> How about we limit the number of mmaped sockets to a configurable
> maximum that defaults to 16 or 32?

Maybe you mean that we should only mmap some of the sockets that we
create.  If so, this approach is reasonable, if one can come up with a
good heuristic to decide which sockets should be mmaped.  One place
one could start would be to mmap the sockets that correspond to
physical ports.

Maybe you mean that we should only create 16 or 32 Netlink sockets,
and divide the datapath ports among those sockets.  OVS once used this
approach.  We stopped using it because it has problems with fairness:
if two ports are assigned to one socket, and one of those ports has a
huge volume of new flows (or otherwise sends a lot of packets to
userspace), then it can drown out the occasional packet from the other
port.  We keep talking about new, more flexible approaches to
achieving fairness, though, and maybe some of those approaches would
allow us to reduce the number of sockets we need, which would make
mmaping all of them feasible.

Any further thoughts?
