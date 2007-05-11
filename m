From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: 11 May 2007 11:05:05 +0200
Message-ID: <p73wszfenni.fsf@bingen.suse.de>
References: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:43912 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090AbXEKIHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 04:07:45 -0400
In-Reply-To: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar <krkumar2@in.ibm.com> writes:

> Doing some measurements, I found that for small packets like 128 bytes,
> the bandwidth is approximately 60% of the line speed. To possibly speed
> up performance of small packet xmits, a method of "linking" skbs was
> thought of - where two pointers (skb_flink/blink) is added to the skb.

You don't need that. You can just use the normal next/prev pointers.
In general it's a good idea to lower lock overhead etc., the VM has
used similar tricks very successfully in the past.

There were some thoughts about this earlier, but in highend
NICs the direction instead seems to go towards LRO (large receive offloading). 
 
LRO is basically like TSO, just for receiving. The NIC aggregates
multiple packets into a single larger one that is then processed by
the stack as one skb. This typically doesn't use linked lists, but an
array of pages.

Your scheme would help old NICs that don't have this optimization.
Might be a worth goal, although people often seem to be more interested
in modern hardware.

Another problem is that this setup typically requires the aggregate
packets to be from the same connection. Otherwise you will only
safe a short trip into the stack until the linked packet would need
to be split again to pass to multiple sockets. With that the scheme
probably helps much less.

The hardware schemes typically use at least some kind of hash to
aggregiate connections You might need to implement something similar
too if it doesn't save enough time.  Don't know if it would be very
efficient in software.

Or you could do this only if multiple packets belong to the same
single connection (basically with a one hit cache); but then it would
smell a bit like a benchmark hack.

-Andi
