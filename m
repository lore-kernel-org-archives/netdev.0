From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 09:00:03 -0700
Message-ID: <1408118403.6804.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
	 <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
	 <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38321 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaHOQAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 12:00:08 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so3668551pab.6
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 09:00:07 -0700 (PDT)
In-Reply-To: <0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 22:02 -0700, Guy Harris wrote:
> On Aug 14, 2014, at 7:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > I believe I am going to implement 2)  (clamp the snaplen)
> 
> If you mean "a packet that's too big to fit into a single block will be cut off at the size of the block, even if the user-requested snaplen is bigger than that", I, at least, have no problem whatsoever with that from libpcap's point of view.  We, the libpcap developers, could just boost the maximum snaplen if necessary.  (Disclaimer: I don't speak for all developers or users of libpcap.)--


Note that libpcap has no problem as far as I know.

Following patch can demonstrate the problem using the
tools/testing/selftests/net/psock_tpacket included in linux kernel
sources.

Running it even on a non debug enabled kernel gave me :

# ./psock_tpacket 
test: TPACKET_V3 with PACKET_RX_RING ............
prev_block_seq_num:116, expected seq:117 != actual seq:7016996765293437281
# [78853.093626] general protection fault: 0000 [#1] SMP 
[78853.098634] Modules linked in: ...
[78853.111390] CPU: 8 PID: 1867 Comm: kworker/8:1 Not tainted 3.16.0-smp-DEV #722
[78853.118615] Hardware name: ...
[78853.125511] Workqueue: events cache_reap
[78853.129448] task: ffff8810565a6a70 ti: ffff881055c30000 task.ti: ffff881055c30000
[78853.136936] RIP: 0010:[<ffffffff811b9b3e>]  [<ffffffff811b9b3e>] cache_reap+0x10e/0x240
[78853.144980] RSP: 0018:ffff881055c33d98  EFLAGS: 00010202
[78853.150303] RAX: ffff881056a2f140 RBX: ffff8810569ee740 RCX: 0000000000000000
[78853.157434] RDX: 0000000000000000 RSI: ffff881057975b40 RDI: ffff880856afc040
[78853.164567] RBP: ffff881055c33de8 R08: 0000000000000001 R09: 0000000000000000
[78853.171715] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000001
[78853.178846] R13: 0000000000000008 R14: 6161616161616161 R15: ffff881056e5d580
[78853.185979] FS:  0000000000000000(0000) GS:ffff88107fc00000(0000) knlGS:0000000000000000
[78853.194073] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[78853.199819] CR2: 000000000aeff000 CR3: 0000000001a14000 CR4: 00000000000407e0
[78853.206944] Stack:
[78853.208970]  0000000000000000 ffff88107fc0f120 ffff88107fc12080 ffff88107fc0f040
[78853.216423]  ffff881055c33dd8 ffff881057a53d00 ffff88107fc12080 ffff88107fc0f120
[78853.223875]  0000000000000000 0000000000000200 ffff881055c33e38 ffffffff810b2c3c
[78853.231334] Call Trace:
[78853.233805]  [<ffffffff810b2c3c>] process_one_work+0x18c/0x3f0
[78853.239626]  [<ffffffff810b32b3>] worker_thread+0x123/0x440
[78853.245198]  [<ffffffff810b3190>] ? rescuer_thread+0x2b0/0x2b0
[78853.251047]  [<ffffffff810b89d9>] kthread+0xc9/0xe0
[78853.255926]  [<ffffffff810b8910>] ? kthread_worker_fn+0x150/0x150
[78853.262036]  [<ffffffff8159d06c>] ret_from_fork+0x7c/0xb0
[78853.267433]  [<ffffffff810b8910>] ? kthread_worker_fn+0x150/0x150
[78853.273524] Code: 00 65 48 8b 14 25 a0 f1 00 00 48 63 ca 4a 8b 1c 28 48 8b 43 50 48 85 c0 0f 84 5f ff ff ff 4c 8b 34 c8 4d 85 f6 0f 84 52 ff ff ff <45> 8b 5e 08 45 85 db 0f 84 45 ff ff ff fa 4
c 89 f7 48 89 55 b0 
[78853.293487] RIP  [<ffffffff811b9b3e>] cache_reap+0x10e/0x240
[78853.299153]  RSP <ffff881055c33d98>



 tools/testing/selftests/net/psock_lib.h     |   11 ++---------
 tools/testing/selftests/net/psock_tpacket.c |   10 ++--------
 2 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
index 37da54ac85a9..40197779868f 100644
--- a/tools/testing/selftests/net/psock_lib.h
+++ b/tools/testing/selftests/net/psock_lib.h
@@ -28,7 +28,7 @@
 #include <arpa/inet.h>
 #include <unistd.h>
 
-#define DATA_LEN			100
+#define DATA_LEN			5000
 #define DATA_CHAR			'a'
 
 #define PORT_BASE			8000
@@ -40,14 +40,7 @@
 static __maybe_unused void pair_udp_setfilter(int fd)
 {
 	struct sock_filter bpf_filter[] = {
-		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
-		{ 0x35, 0, 5, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
-		{ 0x15, 0, 3, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000051 },  /* LD  ip[81]		      */
-		{ 0x15, 0, 1, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
-		{ 0x06, 0, 0, 0x00000060 },  /* RET match	              */
-		{ 0x06, 0, 0, 0x00000000 },  /* RET no match		      */
+		{ 0x06, 0, 0, 0x0000ffff },  /* RET match	              */
 	};
 	struct sock_fprog bpf_prog;
 
diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 24adf709bd9d..f87f86f574f7 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -354,7 +354,7 @@ static void walk_v1_v2_tx(int sock, struct ring *ring)
 	int rcv_sock, ret;
 	size_t packet_len;
 	union frame_map ppd;
-	char packet[1024];
+	char packet[65536];
 	unsigned int frame_num = 0, got = 0;
 	struct sockaddr_ll ll = {
 		.sll_family = PF_PACKET,
@@ -608,7 +608,7 @@ static void __v3_fill(struct ring *ring, unsigned int blocks)
 	ring->req3.tp_sizeof_priv = 0;
 	ring->req3.tp_feature_req_word = TP_FT_REQ_FILL_RXHASH;
 
-	ring->req3.tp_block_size = getpagesize() << 2;
+	ring->req3.tp_block_size = getpagesize();
 	ring->req3.tp_frame_size = TPACKET_ALIGNMENT << 7;
 	ring->req3.tp_block_nr = blocks;
 
@@ -789,12 +789,6 @@ int main(void)
 {
 	int ret = 0;
 
-	ret |= test_tpacket(TPACKET_V1, PACKET_RX_RING);
-	ret |= test_tpacket(TPACKET_V1, PACKET_TX_RING);
-
-	ret |= test_tpacket(TPACKET_V2, PACKET_RX_RING);
-	ret |= test_tpacket(TPACKET_V2, PACKET_TX_RING);
-
 	ret |= test_tpacket(TPACKET_V3, PACKET_RX_RING);
 
 	if (ret)
