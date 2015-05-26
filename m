From: Ido Yariv <ido@wizery.com>
Subject: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 16:17:17 -0400
Message-ID: <1432671437-19140-1-git-send-email-ido@wizery.com>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Ido Yariv <ido@wizery.com>, Ido Yariv <idox.yariv@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36049 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbEZUUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 16:20:11 -0400
Received: by qkx62 with SMTP id 62so99402192qkx.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 13:20:10 -0700 (PDT)
In-Reply-To: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Tail Loss Probe RFC specifies that the PTO value should be set to
max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.

The PTO value is converted to jiffies, so the timer may expire
prematurely.

This is especially problematic on systems in which HZ <= 100, so work
around this by setting the timeout to at least 2 jiffies on such
systems.

The 10ms figure was originally selected based on tests performed with
the current implementation and HZ = 1000. Thus, leave the behavior on
systems with HZ > 100 unchanged.

Signed-off-by: Ido Yariv <idox.yariv@intel.com>
---
 net/ipv4/tcp_output.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 534e5fd..5321df8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2208,6 +2208,9 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
 	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
+#if HZ <= 100
+	timeout = max_t(u32, timeout, 2);
+#endif
 
 	/* If RTO is shorter, just schedule TLP in its place. */
 	tlp_time_stamp = tcp_time_stamp + timeout;
-- 
2.1.0
