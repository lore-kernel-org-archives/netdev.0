From: Nandita Dukkipati <nanditad@google.com>
Subject: [PATCH 1/1] TCP: Bug fix in initialization of receive window.
Date: Fri,  3 Dec 2010 15:33:44 -0800
Message-ID: <1291419224-20853-1-git-send-email-nanditad@google.com>
Cc: Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org,
	Nandita Dukkipati <nanditad@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:39000 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896Ab0LCXeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 18:34:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bug has to do with boundary checks on the initial receive window.
If the initial receive window falls between init_cwnd and the
receive window specified by the user, the initial window is incorrectly
brought down to init_cwnd. The correct behavior is to allow it to
remain unchanged.

Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
 net/ipv4/tcp_output.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 749b649..31fd0bd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -231,11 +231,10 @@ void tcp_select_initial_window(int __space, __u32 mss,
 		/* when initializing use the value from init_rcv_wnd
 		 * rather than the default from above
 		 */
-		if (init_rcv_wnd &&
-		    (*rcv_wnd > init_rcv_wnd * mss))
-			*rcv_wnd = init_rcv_wnd * mss;
-		else if (*rcv_wnd > init_cwnd * mss)
-			*rcv_wnd = init_cwnd * mss;
+		if (init_rcv_wnd)
+			*rcv_wnd = min(*rcv_wnd, init_rcv_wnd * mss);
+		else
+			*rcv_wnd = min(*rcv_wnd, init_cwnd * mss);
 	}
 
 	/* Set the clamp no higher than max representable value */
-- 
1.7.3.1

