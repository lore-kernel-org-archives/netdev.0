From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 7 Feb 2013 09:52:40 -0800
Message-ID: <20130207175240.GA12520@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is based on Willy Tarreau's patch from 2008[1]. The goal is to
close a corner-case of TCP that isn't used and poses a small DoS risk.
For systems that do not want to take any risk at all, this is a desirable
configuration knob.

It is possible for two clients to connect with crossed SYNs without
checking sequence numbers. As such, it might be possible to guess a source
port number to block a system from making connections to well-known
ports and IP addresses (e.g. auto-update checks) without requiring a
MiTM position.

The feature can now be disabled via sysctl:

$ echo 0 > /proc/sys/net/ipv4/tcp_simult_connect
$ echo ohai | nc -w 1 -p 50000 localhost 50000 -v -v -v
nc: connect to localhost port 50000 (tcp) timed out: Operation now in progress
nc: connect to localhost port 50000 (tcp) timed out: Operation now in progress

$ echo 1 > /proc/sys/net/ipv4/tcp_simult_connect
$ echo ohai | nc -w 1 -p 50000 localhost 50000 -v -v -v
Connection to localhost 50000 port [tcp/*] succeeded!
ohai

[1] http://thread.gmane.org/gmane.linux.network/107971

Cc: Willy Tarreau <w@1wt.eu>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 Documentation/networking/ip-sysctl.txt |   17 +++++++++++++++++
 include/net/tcp.h                      |    1 +
 net/ipv4/sysctl_net_ipv4.c             |    9 +++++++++
 net/ipv4/tcp_input.c                   |    3 ++-
 4 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index dbca661..2e5bd51 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -431,6 +431,23 @@ tcp_rmem - vector of 3 INTEGERs: min, default, max
 tcp_sack - BOOLEAN
 	Enable select acknowledgments (SACKS).
 
+tcp_simult_connect - BOOLEAN
+	Enables TCP simultaneous connect feature conforming to RFC793.
+	Strict implementation of RFC793 (TCP) requires support for a
+	feature called "simultaneous connect", which allows two clients to
+	connect to each other without anyone entering a listening state.
+	While almost never used, and supported by few OSes, Linux supports
+	this feature.
+
+	However, it introduces a weakness in the protocol which makes it
+	very easy for an attacker to prevent a client from connecting to
+	a known server. The attacker only has to guess the source port
+	to shut down the client connection during its establishment. The
+	impact is limited, but it may be used to prevent an antivirus
+	or IPS from fetching updates and not detecting an attack, or to
+	prevent an SSL gateway or browser from fetching a CRL.
+	Default: TRUE
+
 tcp_slow_start_after_idle - BOOLEAN
 	If set, provide RFC2861 behavior and time out the congestion
 	window after an idle period.  An idle period is defined at
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aed42c7..ecd55d0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -292,6 +292,7 @@ extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
+extern int sysctl_tcp_simult_connect;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d84400b..01e475f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -774,6 +774,15 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &two,
 	},
 	{
+		.procname	= "tcp_simult_connect",
+		.data		= &sysctl_tcp_simult_connect,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &two,
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 18f97ca..c71f8bb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -102,6 +102,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 int sysctl_tcp_early_retrans __read_mostly = 2;
+int sysctl_tcp_simult_connect __read_mostly = 1;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -5846,7 +5847,7 @@ discard:
 	    tcp_paws_reject(&tp->rx_opt, 0))
 		goto discard_and_undo;
 
-	if (th->syn) {
+	if (th->syn && sysctl_tcp_simult_connect) {
 		/* We see SYN without ACK. It is attempt of
 		 * simultaneous connect with crossed SYNs.
 		 * Particularly, it can be connect to self.
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
