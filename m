From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: restore fastopen with no data in SYN packet
Date: Wed, 16 Dec 2015 13:53:10 -0800
Message-ID: <1450302790.8474.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36165 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966654AbbLPVxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 16:53:12 -0500
Received: by mail-pf0-f177.google.com with SMTP id o64so18637752pfb.3
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 13:53:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Yuchung tracked a regression caused by commit 57be5bdad759 ("ip: convert
tcp_sendmsg() to iov_iter primitives") for TCP Fast Open.

Some Fast Open users do not actually add any data in the SYN packet.

Fixes: 57be5bdad759 ("ip: convert tcp_sendmsg() to iov_iter primitives")
Reported-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv4/tcp_output.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb7ca569052c..9bfc39ff2285 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3150,7 +3150,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_fastopen_request *fo = tp->fastopen_req;
-	int syn_loss = 0, space, err = 0, copied;
+	int syn_loss = 0, space, err = 0;
 	unsigned long last_syn_loss = 0;
 	struct sk_buff *syn_data;
 
@@ -3188,17 +3188,18 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 		goto fallback;
 	syn_data->ip_summed = CHECKSUM_PARTIAL;
 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
-	copied = copy_from_iter(skb_put(syn_data, space), space,
-				&fo->data->msg_iter);
-	if (unlikely(!copied)) {
-		kfree_skb(syn_data);
-		goto fallback;
-	}
-	if (copied != space) {
-		skb_trim(syn_data, copied);
-		space = copied;
+	if (space) {
+		int copied = copy_from_iter(skb_put(syn_data, space), space,
+					    &fo->data->msg_iter);
+		if (unlikely(!copied)) {
+			kfree_skb(syn_data);
+			goto fallback;
+		}
+		if (copied != space) {
+			skb_trim(syn_data, copied);
+			space = copied;
+		}
 	}
-
 	/* No more data pending in inet_wait_for_connect() */
 	if (space == fo->size)
 		fo->data = NULL;
