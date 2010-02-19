From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Fri, 19 Feb 2010 14:40:33 -0500
Message-ID: <20100219194033.GA28743@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58855 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544Ab0BSTkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 14:40:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix TIPC to disallow sending to remote addresses prior to entering NET_MODE

user programs can oops the kernel by sending datagrams via AF_TIPC prior to
entering networked mode.  The following backtrace has been observed:

ID: 13459  TASK: ffff810014640040  CPU: 0   COMMAND: "tipc-client"
#0 [ffff81002d9a5810] crash_kexec at ffffffff800ac5b9
#1 [ffff81002d9a58d0] __die at ffffffff80065127
#2 [ffff81002d9a5910] do_page_fault at ffffffff80066da7
#3 [ffff81002d9a5a00] error_exit at ffffffff8005dde9
[exception RIP: tipc_node_select_next_hop+90]
RIP: ffffffff8869d3c3  RSP: ffff81002d9a5ab8  RFLAGS: 00010202
RAX: 0000000000000001  RBX: 0000000000000001  RCX: 0000000000000001
RDX: 0000000000000000  RSI: 0000000000000001  RDI: 0000000001001001
RBP: 0000000001001001   R8: 0074736575716552   R9: 0000000000000000
R10: ffff81003fbd0680  R11: 00000000000000c8  R12: 0000000000000008
R13: 0000000000000001  R14: 0000000000000001  R15: ffff810015c6ca00
ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#4 [ffff81002d9a5ab0] tipc_node_select_next_hop at ffffffff8869d3b1
#5 [ffff81002d9a5ae0] tipc_link_send_sections_fast at ffffffff88698558
#6 [ffff81002d9a5be0] tipc_forward2port at ffffffff8869eb1d
#7 [ffff81002d9a5c10] tipc_send2port at ffffffff8869eb79
#8 [ffff81002d9a5c30] send_msg at ffffffff886a1d0b
#9 [ffff81002d9a5cb0] sock_sendmsg at ffffffff80055261
RIP: 0000003cbd8d49a3  RSP: 00007fffc84e0be8  RFLAGS: 00010206
RAX: 000000000000002c  RBX: ffffffff8005d116  RCX: 0000000000000000
RDX: 0000000000000008  RSI: 00007fffc84e0c00  RDI: 0000000000000003
RBP: 0000000000000000   R8: 00007fffc84e0c10   R9: 0000000000000010
R10: 0000000000000000  R11: 0000000000000246  R12: 0000000000000000
R13: 00007fffc84e0d10  R14: 0000000000000000  R15: 00007fffc84e0c30
ORIG_RAX: 000000000000002c  CS: 0033  SS: 002b

What happens is that, when the tipc module in inserted it enters a standalone
node mode in which communication to its own address is allowed <0.0.0> but not
to other addresses, since the appropriate data structures have not been
allocated yet (specifically the tipc_net pointer).  There is nothing stopping a
client from trying to send such a message however, and if that happens, we
attempt to dereference tipc_net.zones while the pointer is still NULL, and
explode.  The fix is to add a check at the start of the send_msg path to ensure
that we've allocated the tipc_net pointers and entered networked mode prior to
allowing a send to any destination other than our loopback address.

This patch has received minimal testing, but fixes the issue.  Through reviews
are appreciated.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

CC: Per Liden <per.liden@ericsson.com>
CC: Jon Maloy <jon.maloy@ericsson.com>
CC: Allan Stephens <allan.stephens@windriver.com>
CC: David S. Miller <davem@davemloft.net>
CC: Neil Horman <nhorman@tuxdriver.com>
CC: tipc-discussion@lists.sourceforge.net


 net.c    |    2 +-
 socket.c |    4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7906608..512b33c 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -278,7 +278,6 @@ int tipc_net_start(u32 addr)
 	tipc_cfg_stop();
 
 	tipc_own_addr = addr;
-	tipc_mode = TIPC_NET_MODE;
 	tipc_named_reinit();
 	tipc_port_reinit();
 
@@ -289,6 +288,7 @@ int tipc_net_start(u32 addr)
 		return res;
 	}
 
+	tipc_mode = TIPC_NET_MODE;
 	tipc_k_signal((Handler)tipc_subscr_start, 0);
 	tipc_k_signal((Handler)tipc_cfg_init, 0);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1ea64f0..45229fd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -526,6 +526,10 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 	if (iocb)
 		lock_sock(sk);
 
+	if ((tipc_mode != TIPC_NET_MODE) &&
+	    (dest->addr.name.domain != tipc_own_addr))
+		return -EHOSTUNREACH;
+
 	needs_conn = (sock->state != SS_READY);
 	if (unlikely(needs_conn)) {
 		if (sock->state == SS_LISTENING) {
