From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 5/5] net: tcp: add DCTCP congestion control algorithm
Date: Mon, 12 May 2014 22:59:44 +0200
Message-ID: <1399928384-24143-6-git-send-email-fw@strlen.de>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56539 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756141AbaELVfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:35:53 -0400
In-Reply-To: <1399928384-24143-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

This work adds the DataCenter TCP (DCTCP) congestion control
algorithm [1], which has been first published at SIGCOMM 2010 [2],
resp. follow-up analysis at SIGMETRICS 2011 [3]. Also, as an
informational IETF draft available at [5].

DCTCP is an enhancement to the TCP congestion control algorithm for
data center networks. Typical data center workloads are e.g.
i) partition/aggregate (queries; bursty, delay sensitive), ii) short
messages e.g. 50KB-1MB (for coordination and control state; delay
sensitive), and iii) large flows e.g. 1MB-100MB (data update;
throughput sensitive). DCTCP has therefore been designed for such
environments to provide/achieve the following three requirements:

  * High burst tolerance (incast due to partition/aggregate)
  * Low latency (short flows, queries)
  * High throughput (continuous data updates, large file
    transfers) with commodity, shallow buffered switches

The basic idea of its design consists of two fundamentals: i) on
the switch side, packets are being marked when its internal queue
length > K; ii) the sender side maintains a moving average of the
fraction of marked packets, so each RTT, F is being updated as
follows:

 F := X / Y, where X is # of marked ACKs, Y is total # of ACKs
 alpha := (1 - g) * alpha + g * F, where g is a smoothing constant

The resulting alpha is then being used in order to adaptively
decrease the congestion window W:

 W := (1 - (alpha / 2)) * W

The means for receiving marked packets resp. marking them on switch
side in DCTCP is the use of ECN. RFC3168 describes a mechanism for
using Explicit Congestion Notification from the switch for early
detection of congestion, rather than waiting for segment loss to
occur. However, this method only detects the presence of congestion,
not the extent. In the presence of mild congestion, it reduces the
TCP congestion window too aggressively and unnecessarily affects
the throughput of long flows [5]. DCTCP, as mentioned, enhances
Explicit Congestion Notification (ECN) processing to estimate the
fraction of bytes that encounter congestion, rather than simply
detecting that some congestion has occurred. DCTCP then scales the
TCP congestion window based on this estimate [5], thus it can derive
multibit feedback from the information present in the single-bit
sequence of marks in its control law and act in *proportion* to
the extent of congestion, not its *presence*. Switches therefore set
the Congestion Experienced (CE) codepoint in packets when internal
queue lengths exceed threshold K. Resulting, DCTCP delivers the same
or better throughput than normal TCP, while using 90% less buffer
space. From the Stanford paper, it says that in handling workloads
derived from operational measurements [2], it was found that DCTCP
enables the applications to handle 10x the current background traffic,
without impacting foreground traffic. Moreover, a 10x increase in
foreground traffic did not cause any timeouts, and thus largely
eliminates incast problems [2].

The algorithm itself has already seen deployments in large production
data centers. We have carefully implemented this patch set and did a
long-term stress-test and analysis in a data center and have found
similar results that we have noted down into a documentation section.
Details can be found there, in short, summary of our TCP incast tests
with iperf compared to cubic:

1) Timeouts (total over all flows, and per flow summaries):

          CUBIC            DCTCP
Total     3227             25
Mean       169.8421053      1.315789474
Median     183              1
Max        207              5
Min        123              0
Stddev      28.99092417     1.600438536

2) Throughput (per flow in Mbps):

         CUBIC          DCTCP
Mean     521.6842105    521.8947368
Median   464            523
Max      776            527
Min      403            519
Stddev   105.8909568      2.601169328
Fairness   0.962434227    0.999976467

3) Latency (in ms):

         CUBIC       DCTCP
Mean     4.0088      0.04219
Median   4.055       0.0395
Max      4.2         0.085
Min      3.32        0.028
Stddev   0.166692604 0.010640778

4) Convergence and stability test:

CUBIC                        DCTCP

Seconds  Flow 1  Flow 2      Seconds  Flow 1  Flow 2
 0       9.93    0            0       9.92    0
 0.5     9.87    0            0.5     9.86    0
 1       8.73    2.25         1       6.46    4.88
 1.5     7.29    2.8          1.5     4.9     4.99
 2       6.96    3.1          2       4.92    4.94
 2.5     6.67    3.34         2.5     4.93    5
 3       6.39    3.57         3       4.92    4.99
 3.5     6.24    3.75         3.5     4.94    4.74
 4       6       3.94         4       5.34    4.71
 4.5     5.88    4.09         4.5     4.99    4.97
 5       5.27    4.98         5       4.83    5.01
 5.5     4.93    5.04         5.5     4.89    4.99
 6       4.9     4.99         6       4.92    5.04
 6.5     4.93    5.1          6.5     4.91    4.97
 7       4.28    5.8          7       4.97    4.97
 7.5     4.62    4.91         7.5     4.99    4.82
 8       5.05    4.45         8       5.16    4.76
 8.5     5.93    4.09         8.5     4.94    4.98
 9       5.73    4.2          9       4.92    5.02
 9.5     5.62    4.32         9.5     4.87    5.03
10       6.12    3.2         10       4.91    5.01
10.5     6.91    3.11        10.5     4.87    5.04
11       8.48    0           11       8.49    4.94
11.5     9.87    0           11.5     9.9     0

Enabling DCTCP with this patch requires the following steps: DCTCP
must be running both on the sender and receiver side in your data
center, i.e.:

  sysctl -w net.ipv4.tcp_congestion_control=dctcp

Also, ECN functionality must be enabled at all switches in your
data center for DCTCP to work. The default ECN marking threshold (K)
heuristic on the switch for DCTCP is e.g., 20 packets (30KB) at 1Gbps,
and 65 packets (~100KB) at 10Gbps (K > 1/7 * C * RTT, [4]).

There are no code changes required to applications running in user
space. DCTCP has been implemented in full *isolation* of the rest of
the TCP code as its own congestion control module, so that it can run
without a need to expose code to the core of the TCP stack, and thus
nothing changes for non-DCTCP users.

Changes in the CA framework code are minimal, and DCTCP algorithm
operates on mechanisms that are already available in Silicon. The
gain (dctcp_shift_g) is currently a fixed constant (1/16) from the
paper, but we leave the option that it can be chosen carefully to
a different value by the user.

In case DCTCP is being used and ECN support on peer site is off,
DCTCP falls back after 3WHS to operate in normal TCP Reno mode.
The implementation itself is only around 300 loc of changes, the
rest is mainly documentation and our results in detail.

The implementation is heavily modified from an initial DCTCP patch
from [1] written by Abdul Kabbani, Masato Yasuda and Mohammad Alizadeh
from Stanford University. More information about DCTCP can be found
in [1-5].

  [1] http://simula.stanford.edu/~alizade/Site/DCTCP.html
  [2] http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
  [3] http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp_analysis-full.pdf
  [4] http://www.ietf.org/proceedings/80/slides/iccrg-3.pdf
  [5] http://tools.ietf.org/html/draft-bensley-tcpm-dctcp-00

Joint work with Florian Westphal and Glenn Judd.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/dctcp.txt | 232 +++++++++++++++++++++++++++
 net/ipv4/Kconfig                   |  28 +++-
 net/ipv4/Makefile                  |   1 +
 net/ipv4/tcp_dctcp.c               | 311 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c              |   1 +
 5 files changed, 572 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/dctcp.txt
 create mode 100644 net/ipv4/tcp_dctcp.c

diff --git a/Documentation/networking/dctcp.txt b/Documentation/networking/dctcp.txt
new file mode 100644
index 0000000..b64d27f
--- /dev/null
+++ b/Documentation/networking/dctcp.txt
@@ -0,0 +1,232 @@
+DCTCP (DataCenter TCP)
+----------------------
+
+The below description provides an deployment example for people
+interested in running DCTCP in their data center network.
+
+1) Deployment scenario/example:
+
+The configuration for your data center is two-fold, it consists
+of a configuration of all switches and configuration on host
+side.
+
+1.1) Switch configuration:
+
+For each switch port, traffic was segregated into two queues.
+For any packet with a DSCP of 0x01 - or equivalently a TOS of
+0x04 - the packet was placed into the DCTCP queue. All other
+packets were placed into the default drop-tail queue. For the
+DCTCP queue, RED/ECN marking was enabled here with a marking
+threshold of 75 KB.
+
+1.2) Server configuration:
+
+The following configuration examples were used on the servers:
+
+1.2.1) DCTCP:
+
+# Set congestion control algorithm to DCTCP
+sysctl net.ipv4.tcp_congestion_control=dctcp
+# Set DSCP bits so that the switch can apply RED/ECN AQM to DCTCP traffic
+iptables -A OUTPUT -t mangle -p tcp -j TOS --or-tos 0x04
+
+1.2.2) CUBIC:
+
+# Set congestion control algorithm to CUBIC
+sysctl net.ipv4.tcp_congestion_control=cubic
+# Clear DSCP rule so that the switch applies drop-tail to CUBIC traffic
+iptables -D OUTPUT -t mangle -p tcp -j TOS --or-tos 0x04
+
+2) Example results:
+
+2.1) Incast test:
+
+This test measured DCTCP throughput and latency and compared
+it with CUBIC throughput and latency for an incast scenario.
+In this test, 19 senders sent at maximum rate to a single
+receiver. The receiver simply ran iperf -s.
+
+The senders ran iperf -c <receiver> -t 30. All senders started
+simultaneously (using local clocks synchronized by ntp).
+
+This test was repeated multiple times. Below shows the results
+from a single test. Other tests are similar. (DCTCP results were
+extremely consistent. CUBIC results show some variance induced
+by the TCP timeouts that CUBIC encountered.)
+
+For this test, we report statistics on the number of TCP timeouts,
+flow throughput, and traffic latency.
+
+2.1.1) Timeouts (total over all flows, and per flow summaries):
+
+          CUBIC            DCTCP
+Total     3227             25
+Mean       169.8421053      1.315789474
+Median     183              1
+Max        207              5
+Min        123              0
+Stddev      28.99092417     1.600438536
+
+Timeout data is taken by measuring the net change in netstat -s
+"other TCP timeouts" reported. As a result, the timeout
+measurements above are not restricted to the test traffic, and
+we believe that it is likely that all of the "DCTCP timeouts" are
+actually timeouts for non-test traffic. We report them
+nevertheless. CUBIC will also include some non-test timeouts, but
+they are drawfed by bona fide test traffic timeouts for CUBIC.
+Clearly DCTCP does an excellent job of preventing TCP timeouts.
+DCTCP reduces timeouts by at least two orders of magnitude and
+may well have eliminated them in this scenario.
+
+2.1.2) Throughput (per flow in Mbps):
+
+         CUBIC          DCTCP
+Mean     521.6842105    521.8947368
+Median   464            523
+Max      776            527
+Min      403            519
+Stddev   105.8909568      2.601169328
+Fairness   0.962434227    0.999976467
+
+Throughput data was simply the average throughput for each flow
+reported by iperf. By avoiding TCP timeouts, DCTCP is able to
+achieve much better per-flow results. In CUBIC, many flows
+experience TCP timeouts which makes flow throughput
+unpredictable and unfair. DCTCP, on the other hand, provides
+very clean predictable throughput without incurring TCP timeouts.
+Thus, the standard deviation of CUBIC throughput is dramatically
+higher than the standard deviation of DCTCP throughput.
+
+Mean throughput is nearly identical because even though cubic
+flows suffer TCP timeouts, other flows will step in and fill
+the unused bandwidth. Note that this test is something of a
+best case scenario for incast under CUBIC: it allows other flows
+to fill in for flows experiencing a timeout. Under situations
+where the receiver is issuing requests and then waiting for all
+flows to complete, flows cannot fill in for timed out flows and
+throughput will drop dramatically.
+
+2.1.3) Latency (in ms):
+
+         CUBIC       DCTCP
+Mean     4.0088      0.04219
+Median   4.055       0.0395
+Max      4.2         0.085
+Min      3.32        0.028
+Stddev   0.166692604 0.010640778
+
+Latency for each protocol was computed by running "ping -i 0.2
+<receiver>" from a single sender to the receiver during the
+incast test. For DCTCP, "ping -Q 0x6 -i 0.2 <receiver>" was used
+to ensure that traffic traversed the DCTCP queue and was not
+dropped when the queue size was greater than the marking
+threshold. The summary statistics above are over all ping
+metrics measured between the single sender, receiver pair.
+
+The latency results for this test show a dramatic difference
+between CUBIC and DCTCP. CUBIC intentionally overflows the
+switch buffer which incurs the maximum queue latency (more
+buffer memory will lead to high latency.) DCTCP, on the other
+hand, deliberately attempts to keep queue occupancy low. The
+result is a two orders of magnitude reduction of latency with
+DCTCP - even with a switch with relatively little RAM. Switches
+with larger amounts of RAM will incur increasing amounts of
+latency for CUBIC, but not for DCTCP.
+
+2.2) Convergence and stability test:
+
+This test measured the time that DCTCP took to fairly
+redistribute bandwidth when a new flow commences. It also
+measured DCTCP's ability to remain stable at a fair
+bandwidth distribution. DCTCP is compared with CUBIC for
+this test.
+
+At the commencement of this test, a single flow is sending at
+maximum rate (near 10 Gbps) to a single receiver. One second
+after that first flow commences, a new flow from a distinct
+server begins sending to the same receiver as the first flow.
+After the second flow has sent data for 10 seconds, the second
+flow is terminated. The first flow sends for an additional
+second. Ideally, the bandwidth would be evenly shared as soon
+as the second flow starts, and recover as soon as it stops.
+
+The results of this test are shown below. Note that the flow
+bandwidth for the two flows was measured near the same time,
+but not simultaneously.
+
+DCTCP performs nearly perfectly within the measurement
+limitations of this test: bandwidth is quickly distributed
+fairly between the two flows, remains stable throughout the
+duration of the test, and recovers quickly. CUBIC, in contrast,
+is slow to divide the bandwidth fairly, and has trouble
+remaining stable.
+
+CUBIC                        DCTCP
+
+Seconds  Flow 1  Flow 2      Seconds  Flow 1  Flow 2
+ 0       9.93    0            0       9.92    0
+ 0.5     9.87    0            0.5     9.86    0
+ 1       8.73    2.25         1       6.46    4.88
+ 1.5     7.29    2.8          1.5     4.9     4.99
+ 2       6.96    3.1          2       4.92    4.94
+ 2.5     6.67    3.34         2.5     4.93    5
+ 3       6.39    3.57         3       4.92    4.99
+ 3.5     6.24    3.75         3.5     4.94    4.74
+ 4       6       3.94         4       5.34    4.71
+ 4.5     5.88    4.09         4.5     4.99    4.97
+ 5       5.27    4.98         5       4.83    5.01
+ 5.5     4.93    5.04         5.5     4.89    4.99
+ 6       4.9     4.99         6       4.92    5.04
+ 6.5     4.93    5.1          6.5     4.91    4.97
+ 7       4.28    5.8          7       4.97    4.97
+ 7.5     4.62    4.91         7.5     4.99    4.82
+ 8       5.05    4.45         8       5.16    4.76
+ 8.5     5.93    4.09         8.5     4.94    4.98
+ 9       5.73    4.2          9       4.92    5.02
+ 9.5     5.62    4.32         9.5     4.87    5.03
+10       6.12    3.2         10       4.91    5.01
+10.5     6.91    3.11        10.5     4.87    5.04
+11       8.48    0           11       8.49    4.94
+11.5     9.87    0           11.5     9.9     0
+
+2.3) SYN/ACK ECT test:
+
+This test demonstrates the importance of ECT on SYN and
+SYN-ACK packets by measuring the connection probability in
+the presence of competing flows for a DCTCP connection
+attempt *without* ECT in the SYN packet. The test was
+repeated five times for each number of competing flows.
+
+              Competing Flows  1 |    2 |    4 |    8 |   16
+                               ------------------------------
+Mean Connection Probability    1 | 0.67 | 0.45 | 0.28 |    0
+Median Connection Probability  1 | 0.65 | 0.45 | 0.25 |    0
+
+As the number of competing flows moves beyond 1, the
+connection probability drops rapidly.
+
+3) Further reading:
+
+3.1) DCTCP paper:
+
+The algorithm is further described in detail in the following two
+SIGCOMM/SIGMETRICS papers:
+
+ i) Mohammad Alizadeh, Albert Greenberg, David A. Maltz, Jitendra Padhye,
+    Parveen Patel, Balaji Prabhakar, Sudipta Sengupta, and Murari Sridharan:
+      "Data Center TCP (DCTCP)", Data Center Networks session
+      Proc. ACM SIGCOMM, New Delhi, 2010.
+    http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
+
+ii) Mohammad Alizadeh, Adel Javanmard, and Balaji Prabhakar:
+      "Analysis of DCTCP: Stability, Convergence, and Fairness"
+      Proc. ACM SIGMETRICS, San Jose, 2011.
+    http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp_analysis-full.pdf
+
+3.2) IETF informational draft:
+
+    http://tools.ietf.org/html/draft-bensley-tcpm-dctcp-00
+
+3.3) DCTCP site:
+
+    http://simula.stanford.edu/~alizade/Site/DCTCP.html
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 05c57f0..02827bd 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -556,6 +556,29 @@ config TCP_CONG_ILLINOIS
 	For further details see:
 	  http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html
 
+config TCP_CONG_DCTCP
+	tristate "DataCenter TCP (DCTCP)"
+	default n
+	---help---
+	DCTCP leverages Explicit Congestion Notification (ECN) in the network to
+	provide multi-bit feedback to the end hosts. It is designed to provide:
+
+	- High burst tolerance (incast due to partition/aggregate),
+	- Low latency (short flows, queries),
+	- High throughput (continuous data updates, large file transfers) with
+	  commodity, shallow-buffered switches.
+
+	All switches in the data center network running DCTCP must support
+	ECN marking and be configured for marking when reaching defined switch
+	buffer thresholds. The default ECN marking threshold heuristic for
+	DCTCP on switches is 20 packets (30KB) at 1Gbps, and 65 packets
+	(~100KB) at 10Gbps.
+
+	If unsure what all that means, say N.
+
+	For further details see:
+	  http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
+
 choice
 	prompt "Default TCP congestion control"
 	default DEFAULT_CUBIC
@@ -584,9 +607,11 @@ choice
 	config DEFAULT_WESTWOOD
 		bool "Westwood" if TCP_CONG_WESTWOOD=y
 
+	config DEFAULT_DCTCP
+		bool "DCTCP" if TCP_CONG_DCTCP=y
+
 	config DEFAULT_RENO
 		bool "Reno"
-
 endchoice
 
 endif
@@ -606,6 +631,7 @@ config DEFAULT_TCP_CONG
 	default "westwood" if DEFAULT_WESTWOOD
 	default "veno" if DEFAULT_VENO
 	default "reno" if DEFAULT_RENO
+	default "dctcp" if DEFAULT_DCTCP
 	default "cubic"
 
 config TCP_MD5SIG
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f032688..4497d40 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_INET_UDP_DIAG) += udp_diag.o
 obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
+obj-$(CONFIG_TCP_CONG_DCTCP) += tcp_dctcp.o
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
 obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_highspeed.o
 obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
new file mode 100644
index 0000000..bb9d9ef
--- /dev/null
+++ b/net/ipv4/tcp_dctcp.c
@@ -0,0 +1,311 @@
+/* DataCenter TCP (DCTCP) congestion control.
+ *
+ * http://simula.stanford.edu/~alizade/Site/DCTCP.html
+ *
+ * This is an implementation of DCTCP over Reno, an enhancement to the
+ * TCP congestion control algorithm designed for data centers. DCTCP
+ * leverages Explicit Congestion Notification (ECN) in the network to
+ * provide multi-bit feedback to the end hosts. DCTCP's goal is to meet
+ * the following three data center transport requirements:
+ *
+ *  - High burst tolerance (incast due to partition/aggregate)
+ *  - Low latency (short flows, queries)
+ *  - High throughput (continuous data updates, large file transfers)
+ *    with commodity shallow buffered switches
+ *
+ * The algorithm is described in detail in the following two papers:
+ *
+ * 1) Mohammad Alizadeh, Albert Greenberg, David A. Maltz, Jitendra Padhye,
+ *    Parveen Patel, Balaji Prabhakar, Sudipta Sengupta, and Murari Sridharan:
+ *      "Data Center TCP (DCTCP)", Data Center Networks session
+ *      Proc. ACM SIGCOMM, New Delhi, 2010.
+ *   http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
+ *
+ * 2) Mohammad Alizadeh, Adel Javanmard, and Balaji Prabhakar:
+ *      "Analysis of DCTCP: Stability, Convergence, and Fairness"
+ *      Proc. ACM SIGMETRICS, San Jose, 2011.
+ *   http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp_analysis-full.pdf
+ *
+ * Implemented from an initial implementation of DCTCP from Abdul Kabbani,
+ * Masato Yasuda, and Mohammad Alizadeh.
+ *
+ * Authors:
+ *
+ *	Daniel Borkmann <dborkman@redhat.com>
+ *	Florian Westphal <fw@strlen.de>
+ *	Glenn Judd <glenn.judd@morganstanley.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or (at
+ * your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <net/tcp.h>
+
+#define DCTCP_MAX_ALPHA		1024U
+
+struct dctcp {
+	u32 acked_bytes_ecn;
+	u32 acked_bytes_total;
+	u32 prior_snd_una;
+	u32 prior_rcv_nxt;
+	u32 dctcp_alpha;
+	u32 next_seq;
+	/* false: last pkt was non-ce
+	 * true:  last pkt was ce
+	 */
+	bool ce_state;
+	bool delayed_ack_reserved;
+};
+
+static unsigned int dctcp_shift_g __read_mostly = 4; /* g = 1/2^4 */
+module_param(dctcp_shift_g, uint, 0644);
+MODULE_PARM_DESC(dctcp_shift_g, "parameter g for updating dctcp_alpha");
+
+static unsigned int dctcp_alpha_on_init __read_mostly = DCTCP_MAX_ALPHA;
+module_param(dctcp_alpha_on_init, uint, 0644);
+MODULE_PARM_DESC(dctcp_alpha_on_init, "parameter for initial alpha value");
+
+static unsigned int dctcp_clamp_alpha_on_loss __read_mostly = 0;
+module_param(dctcp_clamp_alpha_on_loss, uint, 0644);
+MODULE_PARM_DESC(dctcp_clamp_alpha_on_loss,
+		 "parameter for clamping alpha on loss");
+
+static struct tcp_congestion_ops dctcp_reno;
+
+static void dctcp_reset(const struct tcp_sock *tp, struct dctcp *ca)
+{
+	ca->next_seq = tp->snd_nxt;
+
+	ca->acked_bytes_ecn = 0;
+	ca->acked_bytes_total = 0;
+}
+
+static void dctcp_init(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	if (tp->ecn_flags & TCP_ECN_OK) {
+		struct dctcp *ca = inet_csk_ca(sk);
+
+		ca->prior_snd_una = tp->snd_una;
+		ca->prior_rcv_nxt = tp->rcv_nxt;
+
+		ca->dctcp_alpha = min(dctcp_alpha_on_init, DCTCP_MAX_ALPHA);
+
+		ca->delayed_ack_reserved = false;
+		ca->ce_state = false;
+
+		dctcp_reset(tp, ca);
+		return;
+	}
+
+	/* No ECN support? Fall back to Reno. */
+	inet_csk(sk)->icsk_ca_ops = &dctcp_reno;
+	pr_debug("sk:%p fallback to Reno due to missing ECN support\n", sk);
+}
+
+static u32 dctcp_ssthresh(struct sock *sk)
+{
+	const struct dctcp *ca = inet_csk_ca(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	return max(tp->snd_cwnd - ((tp->snd_cwnd * ca->dctcp_alpha) >> 11U), 2U);
+}
+
+static void dctcp_ce_state_0_to_1(struct sock *sk)
+{
+	struct dctcp *ca = inet_csk_ca(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* State has changed from CE=0 to CE=1 and delayed
+	 * ACK has not sent yet.
+	 */
+	if (!ca->ce_state && ca->delayed_ack_reserved) {
+		u32 tmp_rcv_nxt;
+
+		/* Save current rcv_nxt. */
+		tmp_rcv_nxt = tp->rcv_nxt;
+
+		/* Generate previous ack with CE=0. */
+		tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
+		tp->rcv_nxt = ca->prior_rcv_nxt;
+
+		tcp_send_ack(sk);
+
+		/* Recover current rcv_nxt. */
+		tp->rcv_nxt = tmp_rcv_nxt;
+	}
+
+	ca->prior_rcv_nxt = tp->rcv_nxt;
+	ca->ce_state = true;
+
+	tp->ecn_flags |= TCP_ECN_DEMAND_CWR;
+}
+
+static void dctcp_ce_state_1_to_0(struct sock *sk)
+{
+	struct dctcp *ca = inet_csk_ca(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* State has changed from CE=1 to CE=0 and delayed
+	 * ACK has not sent yet.
+	 */
+	if (ca->ce_state && ca->delayed_ack_reserved) {
+		u32 tmp_rcv_nxt;
+
+		/* Save current rcv_nxt. */
+		tmp_rcv_nxt = tp->rcv_nxt;
+
+		/* Generate previous ack with CE=1. */
+		tp->ecn_flags |= TCP_ECN_DEMAND_CWR;
+		tp->rcv_nxt = ca->prior_rcv_nxt;
+
+		tcp_send_ack(sk);
+
+		/* Recover current rcv_nxt. */
+		tp->rcv_nxt = tmp_rcv_nxt;
+	}
+
+	ca->prior_rcv_nxt = tp->rcv_nxt;
+	ca->ce_state = false;
+
+	tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
+}
+
+static void dctcp_update_alpha(struct sock *sk, u32 flags)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct dctcp *ca = inet_csk_ca(sk);
+	u32 acked_bytes = tp->snd_una - ca->prior_snd_una;
+
+	/* If ack did not advance snd_una, count dupack as MSS size.
+	 * If ack did update window, do not count it at all.
+	 */
+	if (acked_bytes == 0 && !(flags & CA_ACK_WIN_UPDATE))
+		acked_bytes = inet_csk(sk)->icsk_ack.rcv_mss;
+	if (acked_bytes) {
+		ca->acked_bytes_total += acked_bytes;
+		ca->prior_snd_una = tp->snd_una;
+
+		if (flags & CA_ACK_ECE)
+			ca->acked_bytes_ecn += acked_bytes;
+	}
+
+	/* Expired RTT */
+	if (!before(tp->snd_una, ca->next_seq)) {
+		/* For avoiding denominator == 1. */
+		if (ca->acked_bytes_total == 0)
+			ca->acked_bytes_total = 1;
+
+		/* alpha = (1 - g) * alpha + g * F */
+		ca->dctcp_alpha = ca->dctcp_alpha -
+				  (ca->dctcp_alpha >> dctcp_shift_g) +
+				  (ca->acked_bytes_ecn << (10U - dctcp_shift_g)) /
+				  ca->acked_bytes_total;
+
+		if (ca->dctcp_alpha > DCTCP_MAX_ALPHA)
+			/* Clamp dctcp_alpha to max. */
+			ca->dctcp_alpha = DCTCP_MAX_ALPHA;
+
+		dctcp_reset(tp, ca);
+	}
+}
+
+static void dctcp_state(struct sock *sk, u8 new_state)
+{
+	if (dctcp_clamp_alpha_on_loss && new_state == TCP_CA_Loss) {
+		struct dctcp *ca = inet_csk_ca(sk);
+
+		/* If this extension is enabled, we clamp dctcp_alpha to
+		 * max on packet loss; the motivation is that dctcp_alpha
+		 * is an indicator to the extend of congestion and packet
+		 * loss is an indicator of extreme congestion; setting
+		 * this in practice turned out to be beneficial, and
+		 * effectively assumes total congestion which reduces the
+		 * window by half.
+		 */
+		ca->dctcp_alpha = DCTCP_MAX_ALPHA;
+	}
+}
+
+static void dctcp_update_ack_reserved(struct sock *sk, enum tcp_ca_event ev)
+{
+	struct dctcp *ca = inet_csk_ca(sk);
+
+	switch (ev) {
+	case CA_EVENT_DELAYED_ACK:
+		if (!ca->delayed_ack_reserved)
+			ca->delayed_ack_reserved = true;
+		break;
+	case CA_EVENT_NON_DELAYED_ACK:
+		if (ca->delayed_ack_reserved)
+			ca->delayed_ack_reserved = false;
+		break;
+	default:
+		/* Don't care for the rest. */
+		break;
+	}
+}
+
+static void dctcp_cwnd_event(struct sock *sk, enum tcp_ca_event ev)
+{
+	switch (ev) {
+	case CA_EVENT_ECN_IS_CE:
+		dctcp_ce_state_0_to_1(sk);
+		break;
+	case CA_EVENT_ECN_NO_CE:
+		dctcp_ce_state_1_to_0(sk);
+		break;
+	case CA_EVENT_DELAYED_ACK:
+	case CA_EVENT_NON_DELAYED_ACK:
+		dctcp_update_ack_reserved(sk, ev);
+		break;
+	default:
+		/* Don't care for the rest. */
+		break;
+	}
+}
+
+static struct tcp_congestion_ops dctcp __read_mostly = {
+	.init		= dctcp_init,
+	.in_ack_event   = dctcp_update_alpha,
+	.cwnd_event	= dctcp_cwnd_event,
+	.ssthresh	= dctcp_ssthresh,
+	.cong_avoid	= tcp_reno_cong_avoid,
+	.set_state	= dctcp_state,
+	.flags		= TCP_CONG_NEEDS_ECN,
+	.owner		= THIS_MODULE,
+	.name		= "dctcp",
+};
+
+static struct tcp_congestion_ops dctcp_reno __read_mostly = {
+	.ssthresh	= tcp_reno_ssthresh,
+	.cong_avoid	= tcp_reno_cong_avoid,
+	.owner		= THIS_MODULE,
+	.name		= "dctcp-reno",
+};
+
+static int __init dctcp_register(void)
+{
+	BUILD_BUG_ON(sizeof(struct dctcp) > ICSK_CA_PRIV_SIZE);
+	return tcp_register_congestion_control(&dctcp);
+}
+
+static void __exit dctcp_unregister(void)
+{
+	tcp_unregister_congestion_control(&dctcp);
+}
+
+module_init(dctcp_register);
+module_exit(dctcp_unregister);
+
+MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_AUTHOR("Glenn Judd <glenn.judd@morganstanley.com>");
+
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("DataCenter TCP (DCTCP)");
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1f5e04a..d398b88 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3200,6 +3200,7 @@ void tcp_send_ack(struct sock *sk)
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
 	tcp_transmit_skb(sk, buff, 0, sk_gfp_atomic(sk, GFP_ATOMIC));
 }
+EXPORT_SYMBOL_GPL(tcp_send_ack);
 
 /* This routine sends a packet with an out of date sequence
  * number. It assumes the other end will try to ack it.
-- 
1.8.1.5
