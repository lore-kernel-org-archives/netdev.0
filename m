From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 0/3] rds: tcp: fix various rds-tcp issues during netns create/delete sequences
Date: Sat,  4 Mar 2017 08:57:32 -0800
Message-ID: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Cc: syzkaller@googlegroups.com, rds-devel@oss.oracle.com
To: sowmini.varadhan@oracle.com, dvyukov@google.com,
        santosh.shilimkar@oracle.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35693 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbdCEMRz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:17:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dmitry Vyukov reported some syszkaller panics during netns deletion.

While I have not been able to reproduce those exact panics, my attempts
to do so uncovered a few other problems, which are fixed patch 2 and
patch 3 of this patch series. In addition, as mentioned in,
 https://www.spinics.net/lists/netdev/msg422997.html
code-inspection points that the rds_connection needs to take an explicit
refcnt on the struct net so that it is held down until all cleanup is
completed for netns removal, and this is fixed by patch1.

The following scripts were run concurrently to uncover/test patch{2, 3}
while simultaneously running rds-ping to 12.0.0.18 from another system:

  # cat del.rds
  while [ 1 ]; do
          modprobe rds_tcp
          modprobe -r rds-tcp
  done

  # cat del.netns
  while [ 1 ]; do
          ip netns delete blue
          ip netns add blue
          ip link add link eth1 address a:b:c:d:e:f blue0 type macvlan
          ip link set blue0 netns blue
          ip netns exec blue ip addr add 12.0.0.18/24 dev blue0
          ip netns exec blue ifconfig blue0 up
          sleep 3;
  done


Sowmini Varadhan (3):
  rds: tcp: Take explicit refcounts on struct net
  rds: tcp: Reorder initialization sequence in rds_tcp_init to avoid
    races
  rds: tcp: Sequence teardown of listen and acceptor sockets to avoid
    races

 net/rds/connection.c |    1 +
 net/rds/rds.h        |    6 +++---
 net/rds/tcp.c        |   38 +++++++++++++++++++++-----------------
 net/rds/tcp.h        |    2 +-
 net/rds/tcp_listen.c |    9 +++++++--
 5 files changed, 33 insertions(+), 23 deletions(-)
