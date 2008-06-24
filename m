From: David Miller <davem@davemloft.net>
Subject: current work on net-tx-2.6
Date: Mon, 23 Jun 2008 21:04:38 -0700 (PDT)
Message-ID: <20080623.210438.237685652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40940
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753831AbYFXEEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 00:04:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 97A3DC8C1B6
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 21:04:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So after the patches I've posted so far and checked into
the net-tx-2.6 tree, here is what I have coming up next.

Basically, the generic netdev struct TX lock dies.

The largest part of this work is pushing the locking
down into the individual driver ->hard_start_xmit()
routines.

To be honest, this is what should have happened when
we first added SMP locking, but at that time the easiest
thing to do was to hide this stuff from the drivers :-)

So at that point, LLTX behavior is essentially the default
and all of the LLTX related flags etc. can just be killed
off.

A device with multiple TX queues can then implement their
backlog and TX locking in a per-queue manner.

There are some holes, semantic wise, that I haven't come
to a full resolution of yet.  Rate measurements et al.
in the packet scheduler will be inaccurate because the
device isn't saying "I queued that packet into my TX
backlog" or similar.  The rate measurement mechanisms
of the packet scheduler depended firmly upon knowing
when the driver actually gave packet X to the hardware.

Another hole is pktgen.  It wants to know when all packets
have been queued up to the device.  Or, at the very least, it
would want to know when a packet got dropped from the backlog.
So I will have to consider how to help provide the semantics
pktgen wants as well.

Even at this point, the qdisc lock will single thread all TX activity.
So in the subsequent step I have to do something to address that.
My basic current plan revolves around simply using a noqueue
qdisc by default, so the qdisc doesn't get used at all.

At that point we can get real multiqueue locking seperation on
capable devices.  And furthermore the generic TX flow hashing
layer can be implemented.

