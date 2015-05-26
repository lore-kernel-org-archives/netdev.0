From: Ido Yariv <ido@wizery.com>
Subject: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 10:25:58 -0400
Message-ID: <1432650358-11470-1-git-send-email-ido@wizery.com>
Cc: Ido Yariv <ido@wizery.com>, Ido Yariv <idox.yariv@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Tail Loss Probe RFC specifies that the PTO value should be set to
max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.

The PTO value is converted to jiffies, so the timer might expire
prematurely. This is especially problematic on systems in which HZ=100.

To work around this issue, increase the number of jiffies by one,
ensuring that the timeout won't expire in less than 10ms.

Signed-off-by: Ido Yariv <idox.yariv@intel.com>
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 534e5fd..6f57d3d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2207,7 +2207,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	if (tp->packets_out == 1)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
-	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
+	timeout = max_t(u32, timeout, msecs_to_jiffies(10) + 1);
 
 	/* If RTO is shorter, just schedule TLP in its place. */
 	tlp_time_stamp = tcp_time_stamp + timeout;
-- 
2.1.0
