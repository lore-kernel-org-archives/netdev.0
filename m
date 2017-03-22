From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: provide stronger user input validation in
 nl_fib_input()
Date: Tue, 21 Mar 2017 19:22:28 -0700
Message-ID: <1490149348.16816.135.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexander Potapenko <glider@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33683 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756654AbdCVCbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 22:31:23 -0400
Received: by mail-pf0-f193.google.com with SMTP id p189so19033126pfp.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 19:30:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Alexander reported a KMSAN splat caused by reads of uninitialized
field (tb_id_in) from user provided struct fib_result_nl

It turns out nl_fib_input() sanity tests on user input is a bit
wrong :

User can pretend nlh->nlmsg_len is big enough, but provide
at sendmsg() time a too small buffer.

Reported-by: Alexander Potapenko <glider@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/fib_frontend.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 42bfd08109dd78ab509493e8d2205d72845bb3eb..8f2133ffc2ff1b94871408a5f934cb938d3462b5 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1083,7 +1083,8 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	net = sock_net(skb->sk);
 	nlh = nlmsg_hdr(skb);
-	if (skb->len < NLMSG_HDRLEN || skb->len < nlh->nlmsg_len ||
+	if (skb->len < nlmsg_total_size(sizeof(*frn)) ||
+	    skb->len < nlh->nlmsg_len ||
 	    nlmsg_len(nlh) < sizeof(*frn))
 		return;
 
