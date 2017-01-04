From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 2/2] tools: psock_tpacket: block Rx until socket filter has been added and socket has been bound to loopback.
Date: Wed,  4 Jan 2017 09:33:04 -0800
Message-ID: <e140c3a25aa95ed97f4ad4058b89fb5e788b46fd.1483549208.git.sowmini.varadhan@oracle.com>
References: <cover.1483549208.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        shuah@kernel.org
To: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18281 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761355AbdADRfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 12:35:24 -0500
In-Reply-To: <cover.1483549208.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1483549208.git.sowmini.varadhan@oracle.com>
References: <cover.1483549208.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets from any/all interfaces may be queued up on the PF_PACKET socket
before it is bound to the loopback interface by psock_tpacket, and
when these are passed up by the kernel, they could interfere
with the Rx tests.

Avoid interference from spurious packet by blocking Rx until the
socket filter has been set up, and the packet has been bound to the
desired (lo) interface. The effective sequence is

	socket(PF_PACKET, SOCK_RAW, 0)
	set up ring
	Invoke SO_ATTACH_FILTER
	bind to sll_protocol set to ETH_P_ALL, sll_ifindex for lo

After this sequence, the only packets that will be passed up are
those received on loopback that pass the attached filter.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: patch reworked based on comments from Willem de Bruijn

 tools/testing/selftests/net/psock_tpacket.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 4a1bc64..7f6cd9f 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -110,7 +110,7 @@ struct block_desc {
 
 static int pfsocket(int ver)
 {
-	int ret, sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
+	int ret, sock = socket(PF_PACKET, SOCK_RAW, 0);
 	if (sock == -1) {
 		perror("socket");
 		exit(1);
@@ -239,7 +239,6 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 	bug_on(ring->type != PACKET_RX_RING);
 
 	pair_udp_open(udp_sock, PORT_BASE);
-	pair_udp_setfilter(sock);
 
 	memset(&pfd, 0, sizeof(pfd));
 	pfd.fd = sock;
@@ -601,7 +600,6 @@ static void walk_v3_rx(int sock, struct ring *ring)
 	bug_on(ring->type != PACKET_RX_RING);
 
 	pair_udp_open(udp_sock, PORT_BASE);
-	pair_udp_setfilter(sock);
 
 	memset(&pfd, 0, sizeof(pfd));
 	pfd.fd = sock;
@@ -741,6 +739,8 @@ static void bind_ring(int sock, struct ring *ring)
 {
 	int ret;
 
+	pair_udp_setfilter(sock);
+
 	ring->ll.sll_family = PF_PACKET;
 	ring->ll.sll_protocol = htons(ETH_P_ALL);
 	ring->ll.sll_ifindex = if_nametoindex("lo");
-- 
1.7.1
