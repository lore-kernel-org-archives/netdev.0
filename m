From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 0/2] tools: psock_tpacket bug fixes
Date: Wed,  4 Jan 2017 09:33:02 -0800
Message-ID: <cover.1483549208.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        shuah@kernel.org
To: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18229 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751997AbdADRfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 12:35:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset includes fixes to psock_tpacket for false-negatives
sporadically reported by the test when it was run concurrently with
other heavy network traffic (e.g., over an ssh session, as opposed
to running the test from the console of the test machine). The
test sometimes failed with errors reporting more recvd packets than 
expected (e.g., "walk_v0_rx: received 201 out of 100 pkts") or
the reception of non-IP packets (e.g., ARP packets).

There are 2 sources of network interference that can disrupt the test:

1. set_sockfilter() can use some hardening (currently passes up packets
   based on ip length field, and payload signature but this may potentially
   match other network traffic on the test machine) 

2. There is a race-window between packet_create() and packet_do_bind()
   in which packets from any interface (e.g., eth0) will get queued
   for Rx on the test socket.

Patch 1 fixes the first issue by cleaing up set_sockfilter() and
hardening it to make sure that it only permits UDP/IPv4 packets.

Patch 2 fixes the second issue by making sure we open the PF_PACKET
socket with protocol 0 to reject all packets, and make sure the
BPF filter is set up before binding the socket to ETH_P_ALL and lo.

Changes from v2: patch 2 reworked based on review comments.

Sowmini Varadhan (2):
  tools: tighten conditions checked in sock_setfilter
  tools: psock_tpacket: block Rx until socket filter has been added and
    socket has been bound to loopback.

 tools/testing/selftests/net/psock_lib.h     |   28 ++++++++++++++++++++------
 tools/testing/selftests/net/psock_tpacket.c |    6 ++--
 2 files changed, 24 insertions(+), 10 deletions(-)
