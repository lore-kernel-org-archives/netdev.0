From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Fri, 04 Sep 2009 18:42:31 +0200
Message-ID: <4AA14377.9020200@trash.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020707090800010304030102"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35573 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbZIDQmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 12:42:31 -0400
Received: from [IPv6:2001:6f8:974:0:215:f2ff:fe24:91f8] (unknown [IPv6:2001:6f8:974:0:215:f2ff:fe24:91f8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTPSA id 5A8EEB2C4B
	for <netdev@vger.kernel.org>; Fri,  4 Sep 2009 18:42:33 +0200 (MEST)
In-Reply-To: <20090904164111.27300.29929.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020707090800010304030102
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> These patches contain a classful multiqueue ("mq") dummy scheduler to fix a
> couple of problems with the current multiqueue TC API integration. The
> changelogs of patch 05 and 07 contain more details.
> 
> The mq scheduler does two things:
> 
> - present device TX queues as classes, allowing to attach different qdiscs
>   to them, which are grafted to the TX queues
> 
> - present accumulated statistics of all device queue root qdiscs
> 
> Its used by default for multiqueue devices instead of the regular pfifo_fast
> qdisc, but can also be attached manually to restore multiqueue behaviour
> after attaching a non-multiqueue (shared) qdisc.
> 
> Patches 1-4 contain some preparatory cleanups because I was getting tired
> of copying unnecessary checks and dummy functions :)
> 
> Patch 5 introduces a dev->qdisc pointer, which points to the root qdisc from
> userspace's point of view. This is later used for the mq qdisc, which isn't
> actually attached to any device queues. Patch 7 contains the mq scheduler.
> 
> I've tested the scheduler with a hacked macvlan version which uses 4 queues,
> but since I don't own a multiqueue capable device I couldn't test this on
> real hardware.

And for reference, this is the script I used for testing:


--------------020707090800010304030102
Content-Type: application/x-sh;
 name="test.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test.sh"

#! /bin/sh
#

#
# manually created hierarchy
#

ip link add link eth0 type macvlan
ip link set macvlan0 up

tc qdisc del dev macvlan0 root
tc qdisc replace dev macvlan0 handle 1: root mq
for i in $(seq 1 4); do
	tc qdisc add dev macvlan0 parent 1:$i pfifo
done

# ENOENT - parent class doesn't exist
tc qdisc add dev macvlan0 parent 1:5 pfifo

# EEXIST - class already exists
tc class add dev macvlan0 parent 1: classid 1:4

# EOPNOTSUPP - class creation not supported
tc class add dev macvlan0 parent 1: classid 1:5

# EOPNOTSUPP - filters not supported
tc filter add dev macvlan0 parent 1: handle 1 fw classid 1:1

# EOPNOTSUPP - parent not root qdisc
tc qdisc add dev macvlan0 parent 1:1 mq

tc -s -d qdisc show dev macvlan0
tc -d -s class show dev macvlan0

#
# default mq qdisc
#

ip link add link eth0 txqueuelen 1000 type macvlan
ip link set macvlan1 up

tc -s -d qdisc show dev macvlan1
tc -d -s class show dev macvlan1

--------------020707090800010304030102--
