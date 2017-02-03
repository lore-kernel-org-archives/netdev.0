From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netlabel: out of bound access in cipso_v4_validate()
Date: Fri, 03 Feb 2017 00:03:26 -0800
Message-ID: <1486109006.21871.79.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paul Moore <paul@paul-moore.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33218 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752449AbdBCID3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 03:03:29 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so1075942pfg.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 00:03:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller found another out of bound access in ip_options_compile(),
or more exactly in cipso_v4_validate()

Fixes: 20e2a8648596 ("cipso: handle CIPSO options correctly when NetLabel is disabled")
Fixes: 446fda4f2682 ("[NetLabel]: CIPSOv4 engine")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov  <dvyukov@google.com>
Cc: Paul Moore <paul@paul-moore.com>
---
 include/net/cipso_ipv4.h |    4 ++++
 net/ipv4/cipso_ipv4.c    |    4 ++++
 2 files changed, 8 insertions(+)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index 3ebb168b9afc68ad639b5d32f6182a845c83d759..a34b141f125f0032662f147b598c9fef4fb4bcef 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -309,6 +309,10 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
 	}
 
 	for (opt_iter = 6; opt_iter < opt_len;) {
+		if (opt_iter + 1 == opt_len) {
+			err_offset = opt_iter;
+			goto out;
+		}
 		tag_len = opt[opt_iter + 1];
 		if ((tag_len == 0) || (tag_len > (opt_len - opt_iter))) {
 			err_offset = opt_iter + 1;
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 72d6f056d863603c959e1d04b9f863909a37c758..ae206163c273381ba6e8bd8a24fa050619a4a6ae 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1587,6 +1587,10 @@ int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option)
 				goto validate_return_locked;
 			}
 
+		if (opt_iter + 1 == opt_len) {
+			err_offset = opt_iter;
+			goto validate_return_locked;
+		}
 		tag_len = tag[1];
 		if (tag_len > (opt_len - opt_iter)) {
 			err_offset = opt_iter + 1;
