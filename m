From: Anmol Sarma <me@anmolsarma.in>
Subject: [PATCH] net: Update TCP congestion control documentation
Date: Sat,  3 Jun 2017 17:40:54 +0530
Message-ID: <1496491854-17977-1-git-send-email-me@anmolsarma.in>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Anmol Sarma <me@anmolsarma.in>
To: davem@davemloft.net
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update tcp.txt to fix mandatory congestion control ops and default
CCA selection. Also, fix comment in tcp.h for undo_cwnd.

Signed-off-by: Anmol Sarma <me@anmolsarma.in>
---
 Documentation/networking/tcp.txt | 31 +++++++++++++------------------
 include/net/tcp.h                |  2 +-
 2 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/Documentation/networking/tcp.txt b/Documentation/networking/tcp.txt
index bdc4c0d..9c7139d 100644
--- a/Documentation/networking/tcp.txt
+++ b/Documentation/networking/tcp.txt
@@ -1,7 +1,7 @@
 TCP protocol
 ============
 
-Last updated: 9 February 2008
+Last updated: 3 June 2017
 
 Contents
 ========
@@ -29,18 +29,19 @@ As of 2.6.13, Linux supports pluggable congestion control algorithms.
 A congestion control mechanism can be registered through functions in
 tcp_cong.c. The functions used by the congestion control mechanism are
 registered via passing a tcp_congestion_ops struct to
-tcp_register_congestion_control. As a minimum name, ssthresh,
-cong_avoid must be valid.
+tcp_register_congestion_control. As a minimum, the congestion control
+mechanism must provide a valid name and must implement either ssthresh,
+cong_avoid and undo_cwnd hooks or the "omnipotent" cong_control hook.
 
 Private data for a congestion control mechanism is stored in tp->ca_priv.
 tcp_ca(tp) returns a pointer to this space.  This is preallocated space - it
 is important to check the size of your private data will fit this space, or
-alternatively space could be allocated elsewhere and a pointer to it could
+alternatively, space could be allocated elsewhere and a pointer to it could
 be stored here.
 
 There are three kinds of congestion control algorithms currently: The
 simplest ones are derived from TCP reno (highspeed, scalable) and just
-provide an alternative the congestion window calculation. More complex
+provide an alternative congestion window calculation. More complex
 ones like BIC try to look at other events to provide better
 heuristics.  There are also round trip time based algorithms like
 Vegas and Westwood+.
@@ -49,21 +50,15 @@ Good TCP congestion control is a complex problem because the algorithm
 needs to maintain fairness and performance. Please review current
 research and RFC's before developing new modules.
 
-The method that is used to determine which congestion control mechanism is
-determined by the setting of the sysctl net.ipv4.tcp_congestion_control.
-The default congestion control will be the last one registered (LIFO);
-so if you built everything as modules, the default will be reno. If you
-build with the defaults from Kconfig, then CUBIC will be builtin (not a
-module) and it will end up the default.
+The default congestion control mechanism is chosen based on the
+DEFAULT_TCP_CONG Kconfig parameter. If you really want a particular default
+value then you can set it using sysctl net.ipv4.tcp_congestion_control. The
+module will be autoloaded if needed and you will get the expected protocol. If
+you ask for an unknown congestion method, then the sysctl attempt will fail.
 
-If you really want a particular default value then you will need
-to set it with the sysctl.  If you use a sysctl, the module will be autoloaded
-if needed and you will get the expected protocol. If you ask for an
-unknown congestion method, then the sysctl attempt will fail.
-
-If you remove a tcp congestion control module, then you will get the next
+If you remove a TCP congestion control module, then you will get the next
 available one. Since reno cannot be built as a module, and cannot be
-deleted, it will always be available.
+removed, it will always be available.
 
 How the new TCP output machine [nyi] works.
 ===========================================
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 82462db..28b577a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -969,7 +969,7 @@ struct tcp_congestion_ops {
 	void (*cwnd_event)(struct sock *sk, enum tcp_ca_event ev);
 	/* call when ack arrives (optional) */
 	void (*in_ack_event)(struct sock *sk, u32 flags);
-	/* new value of cwnd after loss (optional) */
+	/* new value of cwnd after loss (required) */
 	u32  (*undo_cwnd)(struct sock *sk);
 	/* hook for packet ack accounting (optional) */
 	void (*pkts_acked)(struct sock *sk, const struct ack_sample *sample);
-- 
2.7.4

