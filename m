From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 0/2] net/rds: RDS-TCP robustness fixes
Date: Sat,  2 May 2015 07:55:07 -0400
Message-ID: <cover.1430421231.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set contains bug fixes for state-recovery at the RDS 
layer when the underlying transport is TCP and the TCP state at one 
of the endpoints is reset, e.g., due to a "modprobe -r rds_tcp" or
a reboot.

When that situation happens, the existing code does not correctly clean
up RDS socket state for stale connections, resulting in some unstable,
timing-dependant behavior on the wire, including an infinite exchange 
of 3WHs back-and-forth, and a resulting potential to never converge 
RDS state. 

Test cases used to verify the changes in this set are:

1. Start rds client/server applications on two participating nodes,
   node1 and node1. After at least one packet has been sent (to establish
   the TCP connection), restart the rds_tcp module on the client, and
   now resend packets. Tcpdump should show server sending a FIN for the
   "old" client port, and clean connection establishment/exchange for
   the new client port.

2. At the end of step 1, restart rds srever on node2, and start client on 
   node1, make sure using tcpdump, 'netstat -an|grep 16385' that 
   packets flow correctly.
  
Sowmini Varadhan (2):
  RDS-TCP: Always create a new rds_sock for an incoming connection.
  RDS-TCP: only initiate reconnect attempt on outgoing TCP socket.

 net/rds/connection.c  |   17 ++++++++++++++-
 net/rds/tcp.c         |   51 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/rds/tcp.h         |    5 +++-
 net/rds/tcp_connect.c |    2 +-
 net/rds/tcp_listen.c  |   13 +++++++++++-
 5 files changed, 82 insertions(+), 6 deletions(-)
