From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] tools: psock_tpacket bug fixes
Date: Tue,  3 Jan 2017 15:27:37 -0800
Message-ID: <cover.1483482971.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        shuah@kernel.org
To: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32540 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761975AbdACX2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 18:28:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset includes fixes to psock_tpacket for false-negatives
sporadically reported by the test when it was run concurrently with
other heavy network traffic (e.g., over an ssh session, as opposed
to running the test from the console of the test machine). The
test sometimes failed with errors reporting more recvd packets than 
expected (e.g., "walk_v0_rx: received 201 out of 100 pkts") or
the reception of non-IP packets (e.g., ARP packets).

There are 2 problems with the test:

1. set_sockfilter() has many bugs (e.g. it will allow TCP packets
   that may happen to match on the length field and happen to have
   the 'a' or 'b' at the location tested by the filter). In addition,
   it is very hard to read, making these bugs harder to find.

2. There is a race-window between packet_create() and packet_do_bind()
   in which packets from any interface (e.g., eth0) will get queued
   for Rx on the test socket. These packets should not be counted
   toward the test.

Patch 1 fixes the first issue by cleaing up set_sockfilter() and
hardening it to make sure that it only permits UDP/IPv4 packets.

Patch 2 fixes the second issue by checking the Rx ifindex passed up
with the tpacket rx frame and making sure that packets counted
toward the test are those received on lo.



Sowmini Varadhan (2):
  tools: tighten conditions checked in sock_setfilter
  tools: psock_tpacket: verify that packet was received on lo before
    counting it

 tools/testing/selftests/net/psock_lib.h     |   28 ++++++++++++++++++++------
 tools/testing/selftests/net/psock_tpacket.c |   25 +++++++++++++++++++----
 2 files changed, 41 insertions(+), 12 deletions(-)
