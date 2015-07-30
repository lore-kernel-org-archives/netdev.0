From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next 0/3] RDS-TCP: Network namespace support
Date: Thu, 30 Jul 2015 04:55:44 -0400
Message-ID: <cover.1438245718.git.sowmini.varadhan@oracle.com>
Cc: cwang@twopensource.com, ajaykumar.hotchandani@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38087 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970AbbG3I4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 04:56:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series contains the set of changes to correctly set up 
the infra for PF_RDS sockets that use TCP as the transport in multiple
network namespaces.

Patch 1 in the series is the minimal set of changes to allow
a single instance of RDS-TCP to run in any (i.e init_net or other) 
namespace. The changes in this patch set ensure that the
execution of 'modprobe [-r] rds_tcp' correctly sets up the kernel
TCP sockets relative to the current netns. 

Patch 2 of the series further allows multiple RDS-TCP instances,
one per network namespace. The changes in this patch allows dynamic
creation/tear-down of RDS-TCP client and server sockets  across all
current and future namespaces. 

Comments are specifically invited about the following:

   There is some question in my mind as to whether Patch 2 should
   use register_pernet_subsys() or register_pernet_device(): due
   to the nature of the architecture, RDS/TCP is not a network device,
   but more accurately a subsystem that encapsulates an RDS packet into
   a TCP/IP header at the ksocket layer. However, the listen socket
   is created as part of the ->init in the pernet_operations, and the 
   connect/accept sockets get created in the kernel dynamically, with the
   intention that all of these sockets should be cleaned as part of ->exit.

   Based on the comments in net_namespace.h, sockets would need
   to be cleaned up as part of a pernet operation, else they would
   hold up lo cleanup.  In the current version of patch2,  that cleanup is
   achieved after the ethernet devices, by the socket keepalive timeout,
   after which the ->exit will get called. I'm not sure there is a clean
   way to avoid this.  As thing stand, doing "ip netns delete <name>"
   would result in syslogd messages about "unregister_netdevice: waiting
   for lo to become free. Usage count .." being seen in the interval between
   ethernet device migration to init_net and the keepalive timeout
 
Patch 3 in this set is independant of the above two changes, and is 
a bugfix/follow up to eeb1bd5c encountered while testing the above.

Sowmini Varadhan (3):
  Make RDS-TCP work correctly when it is set up in a netns other than
    init_net
  Support multiple RDS-TCP listen endpoints, one per netns.
  sk_clone_lock() should only do get_net() if the parent is not a
    kernel socket

 net/core/sock.c       |    3 +-
 net/rds/bind.c        |    3 +-
 net/rds/connection.c  |   16 ++++---
 net/rds/ib.c          |    2 +-
 net/rds/ib_cm.c       |    4 +-
 net/rds/iw.c          |    2 +-
 net/rds/iw_cm.c       |    4 +-
 net/rds/rds.h         |   11 +++--
 net/rds/send.c        |    3 +-
 net/rds/tcp.c         |  116 ++++++++++++++++++++++++++++++++++++++++++-------
 net/rds/tcp.h         |    7 ++-
 net/rds/tcp_connect.c |    9 +++-
 net/rds/tcp_listen.c  |   40 ++++++-----------
 net/rds/transport.c   |    4 +-
 14 files changed, 155 insertions(+), 69 deletions(-)
