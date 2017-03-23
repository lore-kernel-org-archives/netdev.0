From: gfree.wind@foxmail.com
Subject: [PATCH net-next 1/1] tcp: sysctl: Fix a race to avoid unexpected 0 window from space
Date: Fri, 24 Mar 2017 07:05:12 +0800
Message-ID: <1490310312-20661-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, netdev@vger.kernel.org, gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:42451 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752008AbdCWXF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 19:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Because sysctl_tcp_adv_win_scale could be changed any time, so there
is one race in tcp_win_from_space.
For example,
1.sysctl_tcp_adv_win_scale<=0 (sysctl_tcp_adv_win_scale is negative now)
2.space>>(-sysctl_tcp_adv_win_scale) (sysctl_tcp_adv_win_scale is postive now)

As a result, tcp_win_from_space returns 0. It is unexpected.

Certainly if the compiler put the sysctl_tcp_adv_win_scale into one
register firstly, then use the register directly, it would be ok.
But we could not depend on the compiler behavior.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 include/net/tcp.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6ec4ea6..119b592 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1252,9 +1252,11 @@ void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
 
 static inline int tcp_win_from_space(int space)
 {
-	return sysctl_tcp_adv_win_scale<=0 ?
-		(space>>(-sysctl_tcp_adv_win_scale)) :
-		space - (space>>sysctl_tcp_adv_win_scale);
+	int tcp_adv_win_scale = sysctl_tcp_adv_win_scale;
+
+	return tcp_adv_win_scale <= 0 ?
+		(space>>(-tcp_adv_win_scale)) :
+		space - (space>>tcp_adv_win_scale);
 }
 
 /* Note: caller must be prepared to deal with negative returns */
-- 
1.9.1
