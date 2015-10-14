From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: fix potential NULL deref in
 __inet_inherit_port()
Date: Wed, 14 Oct 2015 05:58:38 -0700
Message-ID: <1444827518.4166.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33541 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562AbbJNM6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:58:40 -0400
Received: by pabrc13 with SMTP id rc13so54185834pab.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 05:58:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As we no longer hold listener lock in fast path, it is possible that a
child is created right after listener freed its bound port, if a close()
is done while incoming packets are processed.

__inet_inherit_port() must detect this and return an error,
so that caller can free the child earlier.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_hashtables.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 08643a3616af..958728a22001 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -137,6 +137,10 @@ int __inet_inherit_port(const struct sock *sk, struct sock *child)
 
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
+	if (unlikely(!tb)) {
+		spin_unlock(&head->lock);
+		return -ENOENT;
+	}
 	if (tb->port != port) {
 		/* NOTE: using tproxy and redirecting skbs to a proxy
 		 * on a different listener port breaks the assumption
