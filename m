From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] sctp: sctp_close: fix release of bindings for deferred call_rcu's
Date: Thu, 31 Jan 2013 17:51:44 +0100
Message-ID: <13ea81dcf399f935bd8e048ce225411d8f29a792.1359650254.git.dborkman@redhat.com>
References: <cover.1359650254.git.dborkman@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485Ab3AaQvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 11:51:47 -0500
In-Reply-To: <cover.1359650254.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems due to RCU usage, i.e. within SCTP's address binding list,
a, say, ``behavioral change'' was introduced which does actually
not conform to the RFC anymore. In particular consider the following
(fictional) scenario to demonstrate this:

  do:
    Two SOCK_SEQPACKET-style sockets are openend (S1, S2)
    S1 is bound to 127.0.0.1, port 1024 [server]
    S2 is bound to 127.0.0.1, port 1025 [client]
    listen(2) is invoked on S1
    From S2 we call one sendmsg(2) with msg.msg_name and
       msg.msg_namelen parameters set to the server's
       address
    S1, S2 are closed
    goto do

The first pass of this loop passes sucessful, while the second round
fails during binding of S1 (address still in use). What is happening?
In the first round, the initial handshake is being done, and, at the
time close(2) is called on S1, a nongraceful shutdown is performed via
ABORT since in S1's receive queue an unprocessed packet is present,
thus stating an error condition. This can be considered as a correct
behavior.

During close also all bound addresses are freed, thus nothing *must*
be active anymore.

  After checking the Verification Tag, the receiving endpoint shall
  remove the association from its record, and shall report the
  termination to its upper layer. (RFC2960, 9.1 Abort of an Association)

Also, no half-open states are supported, thus after an ungraceful
shutdown, we leave nothing behind. However, this seems not to be
happening though. In a real-world scenario, this is exactly where
it breaks the lksctp-tools functional test suite, *for instance*:

  ./test_sockopt
  test_sockopt.c  1 PASS : getsockopt(SCTP_STATUS) on a socket with no assoc
  test_sockopt.c  2 PASS : getsockopt(SCTP_STATUS)
  test_sockopt.c  3 PASS : getsockopt(SCTP_STATUS) with invalid associd
  test_sockopt.c  4 PASS : getsockopt(SCTP_STATUS) with NULL associd
  test_sockopt.c  5 BROK : bind: Address already in use

With this patch, the example above (which simulates a similar scenario
as in the implementation of this test case) and therefore also this test
runs successfully through.

If one wants to fix this issue, an RCU barrier needs to be introduced
within the sctp_close handler. One could argue that this is quite costly,
which is true, but on the other hand, if an application calls close on
its socket, it likely might be out of its critical path anyway.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/socket.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9e65758..a9c18b4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1536,6 +1536,11 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
 
 	sock_put(sk);
 
+	/* There can still be (non-)TCP-style associations be waiting
+	 * to be processed via deferred RCU.
+	 */
+	rcu_barrier();
+
 	SCTP_DBG_OBJCNT_DEC(sock);
 }
 
-- 
1.7.11.7
