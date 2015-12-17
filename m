From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: check both type and procotol for tcp sockets
Date: Wed, 16 Dec 2015 23:39:04 -0800
Message-ID: <1450337944-22834-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33974 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbbLQHjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 02:39:31 -0500
Received: by mail-pa0-f50.google.com with SMTP id wq6so37859625pac.1
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 23:39:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry reported the following out-of-bound access:

Call Trace:
 [<ffffffff816cec2e>] __asan_report_load4_noabort+0x3e/0x40
mm/kasan/report.c:294
 [<ffffffff84affb14>] sock_setsockopt+0x1284/0x13d0 net/core/sock.c:880
 [<     inline     >] SYSC_setsockopt net/socket.c:1746
 [<ffffffff84aed7ee>] SyS_setsockopt+0x1fe/0x240 net/socket.c:1729
 [<ffffffff85c18c76>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

This is because we mistake a raw socket as a tcp socket.
We should check both sk->sk_type and sk->sk_protocol to ensure
it is a tcp socket.

Willem points out __skb_complete_tx_timestamp() needs to fix as well.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/skbuff.c | 3 ++-
 net/core/sock.c   | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5cc43d37..b2df375 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3643,7 +3643,8 @@ static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 	serr->ee.ee_info = tstype;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
 		serr->ee.ee_data = skb_shinfo(skb)->tskey;
-		if (sk->sk_protocol == IPPROTO_TCP)
+		if (sk->sk_protocol == IPPROTO_TCP &&
+		    sk->sk_type == SOCK_STREAM)
 			serr->ee.ee_data -= sk->sk_tskey;
 	}
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 765be83..0d91f7d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -872,7 +872,8 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 
 		if (val & SOF_TIMESTAMPING_OPT_ID &&
 		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
-			if (sk->sk_protocol == IPPROTO_TCP) {
+			if (sk->sk_protocol == IPPROTO_TCP &&
+			    sk->sk_type == SOCK_STREAM) {
 				if (sk->sk_state != TCP_ESTABLISHED) {
 					ret = -EINVAL;
 					break;
-- 
1.8.3.1
