From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] extend sch_mqprio to distribute traffic not only by ETS TC
Date: Sun,  6 May 2012 10:05:08 +0300
Message-ID: <1336287910-12010-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Oren Duer <oren@mellanox.com>,
	Liran Liss <liranl@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:36440 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751406Ab2EFHFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 03:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series comes to revive the discussion initiated on the thread "net:
support tx_ring per UP in HW based QoS mechanism" (see
http://marc.info/?t=133165957200004&r=1&w=2) with the major issue to be address
is - how should sk_prio<=>  TC be done, for both, tagged and untagged traffic.
Following is a staged description addressing the background, problem
description, current situation, suggestion for the change and implementation of
it.

Background
----------
Egress traffic has 3 layers of management to configure QoS attributes:
* Application - sets sk_prio
  * setsockopt() - application may set sk_prio using SO_PRIORITY or IP_TOS
* Host admin - sets sk_prio <=> UP
  * net_prio cgroup
  * Egress map for tagged traffic
* Net admin - sets UP <=> TC + TC QoS attributes
  * lldpad
Commit 4f57c087de9 "net: implement mechanism for HW based QOS" introduced a
mechanism for lower layer devices to steer traffic using skb->priority to tx
queues.

Problem
-------
How should sk_prio <=> TC be done, for both, tagged and untagged traffic?

Current situation
-----------------
* The network priority cgroup infrastructure commit 5bc1421e, introduced implicit
  assumption that sk_prio == UP.
* tc tool is used to map UP <=> TC for both tagged and untagged traffic.
* egress map and lldptool and ignored when tc tool is being used.
* HW queue is per TC.

Suggestion
----------
* sk_prio is an attribute controlled by the Application or cgroup.
  As used to be in tagged traffic
* tc tool is used by the Host admin and sets sk_prio <=> UP for untagged
  traffic. The rest of the chain is UP <=> TC mapped by the Net admin (using
  DCBx netlink).
  To keep backward compatibility, will have an option to set tc tool to
  compatabilty mode, in which, the old sk_prio <=> TC will be kept.
* Depending on HW, queue selection is by UP or by TC.

Implementation
--------------
Extended mqprio hw attribute:
* Bit 1: is queue offset/count owned by HW
* Bits 2-7: HW queueing type. 
  * 0 - by ETS TC
  * 1 - by UP

__skb_tx_hash() is now aware to the HW queuing type (pg_type): for pg_type
being ETS TC, traffic is distributed as it was before - tagged and untagged
packets are distributed by netdev_get_prio_tc_map. For pg_type being UP, tagged
and untagged packets are distributed by UP (taken from egress map for tagged
traffic, or netdev_get_prio_tc_map for untagged).

Amir Vadai (2):
  net_sched/mqprio: add support for different pgroup types
  net/mlx4_en: num cores tx rings for every UP

 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   42 ++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   12 -------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    9 ++---
 include/linux/netdevice.h                      |   27 +++++++++++++++
 include/linux/pkt_sched.h                      |    3 +-
 net/core/dev.c                                 |   12 +++++--
 net/sched/sch_mqprio.c                         |   11 +++++-
 8 files changed, 88 insertions(+), 34 deletions(-)

-- 
1.7.8.2
