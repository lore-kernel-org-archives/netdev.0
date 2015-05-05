From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 0/2] net/rds: RDS-TCP robustness fixes
Date: Tue,  5 May 2015 15:20:50 -0400
Message-ID: <cover.1430843646.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42572 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbbEETVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 15:21:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch-set contains bug fixes for state-recovery at the RDS 
layer when the underlying transport is TCP and the TCP state at one 
of the endpoints is reset

V2 changes: DaveM comments to reduce memory footprint, follow 
            NFS/RPC model where possible. Added test-case #3

Without the changes in this set, when one of the endpoints is reset,
the existing code does not correctly clean up RDS socket state for stale
connections, resulting in some unstable, timing-dependant behavior on
the wire, including an infinite exchange of 3WHs back-and-forth, and a
resulting potential to never converge RDS state. 

Test cases used to verify the changes in this set are:

1. Start rds client/server applications on two participating nodes,
   node1 and node2. After at least one packet has been sent (to establish
   the TCP connection), restart the rds_tcp module on the client, and
   now resend packets. Tcpdump should show server sending a FIN for the
   "old" client port, and clean connection establishment/exchange for
   the new client port.

2. At the end of step 1, restart rds srever on node2, and start client on 
   node1, make sure using tcpdump, 'netstat -an|grep 16385' that 
   packets flow correctly.

3. start RDS client/server application on two participating nodes, and 
   repeat steps 1 and 2, but this time, simulate node failure by doing
   "ifconfig <intf> down", so no FIN is sent. 

Sowmini Varadhan (2):
  RDS-TCP: Always create a new rds_sock for an incoming connection.
  RDS-TCP: only initiate reconnect attempt on outgoing TCP socket.

 net/rds/connection.c  |   17 +++++++++++++++--
 net/rds/tcp_connect.c |    1 +
 net/rds/tcp_listen.c  |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 2 deletions(-)
