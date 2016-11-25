From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 3.12 093/127] net: sctp, forbid negative length
Date: Fri, 25 Nov 2016 09:30:06 +0100
Message-ID: <701a77ec87e209dba3514fb80cfb3e147b9aa56c.1480062521.git.jslaby@suse.cz>
References: <f668f2eee98250a2073a4beafdb7f6d1e21c528e.1480062521.git.jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45240 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752778AbcKYIcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 03:32:25 -0500
In-Reply-To: <f668f2eee98250a2073a4beafdb7f6d1e21c528e.1480062521.git.jslaby@suse.cz>
In-Reply-To: <cover.1480062521.git.jslaby@suse.cz>
References: <cover.1480062521.git.jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.12-stable review patch.  If anyone has any objections, please let me know.

===============

[ Upstream commit a4b8e71b05c27bae6bad3bdecddbc6b68a3ad8cf ]

Most of getsockopt handlers in net/sctp/socket.c check len against
sizeof some structure like:
        if (len < sizeof(int))
                return -EINVAL;

On the first look, the check seems to be correct. But since len is int
and sizeof returns size_t, int gets promoted to unsigned size_t too. So
the test returns false for negative lengths. Yes, (-1 < sizeof(long)) is
false.

Fix this in sctp by explicitly checking len < 0 before any getsockopt
handler is called.

Note that sctp_getsockopt_events already handled the negative case.
Since we added the < 0 check elsewhere, this one can be removed.

If not checked, this is the result:
UBSAN: Undefined behaviour in ../mm/page_alloc.c:2722:19
shift exponent 52 is too large for 32-bit type 'int'
CPU: 1 PID: 24535 Comm: syz-executor Not tainted 4.8.1-0-syzkaller #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 0000000000000000 ffff88006d99f2a8 ffffffffb2f7bdea 0000000041b58ab3
 ffffffffb4363c14 ffffffffb2f7bcde ffff88006d99f2d0 ffff88006d99f270
 0000000000000000 0000000000000000 0000000000000034 ffffffffb5096422
Call Trace:
 [<ffffffffb3051498>] ? __ubsan_handle_shift_out_of_bounds+0x29c/0x300
...
 [<ffffffffb273f0e4>] ? kmalloc_order+0x24/0x90
 [<ffffffffb27416a4>] ? kmalloc_order_trace+0x24/0x220
 [<ffffffffb2819a30>] ? __kmalloc+0x330/0x540
 [<ffffffffc18c25f4>] ? sctp_getsockopt_local_addrs+0x174/0xca0 [sctp]
 [<ffffffffc18d2bcd>] ? sctp_getsockopt+0x10d/0x1b0 [sctp]
 [<ffffffffb37c1219>] ? sock_common_getsockopt+0xb9/0x150
 [<ffffffffb37be2f5>] ? SyS_getsockopt+0x1a5/0x270

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-sctp@vger.kernel.org
Cc: netdev@vger.kernel.org
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 net/sctp/socket.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ead3a8adca08..98cd6606f4a4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4247,7 +4247,7 @@ static int sctp_getsockopt_disable_fragments(struct sock *sk, int len,
 static int sctp_getsockopt_events(struct sock *sk, int len, char __user *optval,
 				  int __user *optlen)
 {
-	if (len <= 0)
+	if (len == 0)
 		return -EINVAL;
 	if (len > sizeof(struct sctp_event_subscribe))
 		len = sizeof(struct sctp_event_subscribe);
@@ -5758,6 +5758,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
+	if (len < 0)
+		return -EINVAL;
+
 	sctp_lock_sock(sk);
 
 	switch (optname) {
-- 
2.10.2
