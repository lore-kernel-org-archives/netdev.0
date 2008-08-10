From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sat, 09 Aug 2008 22:12:07 -0700
Message-ID: <adazlnlzc60.fsf@cisco.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>
	<aday73jxdfs.fsf@cisco.com> <200807311752.00911.divy@chelsio.com>
	<200808071145.03848.divy@chelsio.com>
	<489C8BEB.8060001@opengridcomputing.com> <489CC58D.4010606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net,
	Divy Le Ray <divy@chelsio.com>, Karen Xie <kxie@chelsio.com>,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:8053 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbYHJFML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 01:12:11 -0400
In-Reply-To: <489CC58D.4010606@pobox.com> (Jeff Garzik's message of "Fri, 08
	Aug 2008 18:15:41 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > * however, giving the user the ability to co-manage IP addresses means
 > hacking up the kernel TCP code and userland tools for this new
 > concept, something that I think DaveM would rightly be a bit reluctant
 > to do? You are essentially adding a bunch of special case code
 > whenever TCP ports are used:
 > 
 > 	if (port in list of "magic" TCP ports with special,
 > 	    hardware-specific behavior)
 > 		...
 > 	else
 > 		do what we've been doing for decades

I think you're arguing against something that no one is actually
pushing.  What I'm sure Chelsio and probably other iSCSI offload vendors
would like is a way to make iSCSI (and other) offloads not steal magic
ports but actually hook into the normal infrastructure so that the
offloaded connections show up in netstat, etc.  Having this solution
would be nice not just for TCP offload but also for things like in-band
system management, which currently lead to the same hard-to-diagnose
issues when someone hits the stolen port.  And it also would seem to
help "classifier NICs" (Sun Neptune, Solarflare, etc) where some traffic
might be steered to a userspace TCP stack.

I don't think the proposal of just using a separate MAC and IP for the
iSCSI HBA really works, for two reasons:

 - It doesn't work in theory, because the suggestion (I guess) is that
   the iSCSI HBA has its own MAC and IP and behaves like a separate
   system.  But this means that to start with the HBA needs its own ARP,
   ICMP, routing, etc interface, which means we need some (probably new)
   interface to configure all of this.  And then it doesn't work in lots
   of networks; for example the ethernet jack in my office doesn't work
   without 802.1x authentication, and putting all of that in an iSCSI
   HBA's firmware clearly is crazy (not to mention creating the
   interface to pass 802.1x credentials into the kernel to pass to the
   HBA).

 - It doesn't work in practice because most of the existing NICs that
   are capable of iSCSI offload, eg Chelsio and Broadcom as well as 3 or
   4 other vendors, don't handle ARP, ICMP, etc in the device -- they
   need the host system to do it.  Which means that either we have a
   separate ARP/ICMP stack for offload adapters (obviously untenable) or
   a separate implemention in each driver (even more untenable), or we
   use the normal stack for the adapter, which seems to force us into
   creating a normal netdev for the iSCSI offload interface, which in
   turn seems to force us to figure out a way for offload adapters to
   coexist with the host stack (assuming of course that we care about
   iSCSI HBAs and/or stuff like NFS/RDMA).

A long time ago, DaveM pointed me at the paper "TCP offload is a dumb
idea whose time has come" (<http://www.usenix.org/events/hotos03/tech/full_papers/mogul/mogul_html/index.html>)
which is an interesting paper that argues that this time really is
different, and OS developers need to figure out how transport offload
fits in.  As a side note, funnily enough back in the thread where DaveM
mentioned that paper, Alan Cox said "Take a look at who holds the
official internet land speed record. Its not a TOE using system" but at
least as of now the current record for IPv4
(http://www.internet2.edu/lsr/) *is* held by a TOE.

I think there are two ways to proceed:

 - Start trying to figure out the best way to support the iSCSI offload
   hardware that's out there.  I don't know the perfect answer but I'm
   sure we can figure something out if we make an honest effort.

 - Ignore the issue and let users of iSCSI offload hardware (and iWARP
   and NFS/RDMA etc) stick to hacky out-of-tree solutions.  This pays
   off if stuff like the Intel CRC32C instruction plus faster CPUs (or
   "multithreaded" NICs that use multicore better) makes offload
   irrelevant.  However this ignores the fundamental 3X memory bandwidth
   cost of not doing direct placement in the NIC, and risks us being in
   a "well Solaris has support" situation down the road.

To be honest I think the best thing to do is just to get support for
these iSCSI offload adapters upstream in whatever form we can all agree
on, so that we can see a) whether anyone cares and b) if someone does
care, whether there's some better way to do things.

 > ISTR Roland(?) pointing out code that already does a bit of this in
 > the IB space...  but the point is

Not me... and I don't think that there would be anything like this for
InfiniBand, since IB is a completely different animal that has nothing
to do with TCP/IP.  You may be thinking of iWARP (RDMA over TCP/IP), but
actually the current Linux iWARP support completely punts on the issue
of coexisting with the native stack (basically because of a lack of
interest in solving the problems from the netdev side of things), which
leads to nasty issues that show up when things happen to collide.  So
far people seem to be coping by using nasty out-of-tree hacks.

 - R.
