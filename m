From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 0/2] net: tx scalability works : tx_packets/tx_bytes/tx_dropped
Date: Mon, 18 May 2009 12:33:17 +0200
Message-ID: <4A11396D.50108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51270 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672AbZERKdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 06:33:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

offsetof(struct net_device, features)=0x44
offsetof(struct net_device, stats.tx_packets)=0x54
offsetof(struct net_device, stats.tx_bytes)=0x5c
offsetof(struct net_device, stats.tx_dropped)=0x6c

This means drivers that touch stats.tx_packets/stats.tx_bytes in their
tx path can slow down SMP operations, since they dirty a cache line
that should stay shared (dev->features is needed in rx and tx paths)

We could move away stats field in net_device but it wont help that much.
(Two cache lines dirtied in tx path, we can do one only)

Better solution is to add tx_packets/tx_bytes/tx_dropped in struct netdev_queue
because this structure is already touched in tx path and counters
updates will then be free.

First patch adds the infrastructure, and second one uses this
infrastructure for VLAN devices, for which I spoted the performance
problem on Gigabit links.

rx path has same problem of course, but less prevalent as less
cpus are involved in rx path if IRQ affinities not too dumb.

Thank you
