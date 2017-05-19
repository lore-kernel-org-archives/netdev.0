From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: fix out of bound writes in __ip6_append_data()
Date: Fri, 19 May 2017 14:17:48 -0700
Message-ID: <1495228668.6465.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <ebd31eba-3675-474a-a3ea-1d91cd31f2df@googlegroups.com>
         <CAAeHK+wet1o-F+-Q5jEh9DigDwouERjvrh1wQ1kFBxA5geGJpg@mail.gmail.com>
         <CANn89iJ4GJfrJvdzpMesGkUvYzJfUnMwbyPOzDxZdQDAJbkptg@mail.gmail.com>
         <CAAeHK+xGCjM8oDCZcNXbaZZNqenREi4DUgHM5=Ab7GKrVEmO4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, idaifish@gmail.com,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32773 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754357AbdESVRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 17:17:50 -0400
Received: by mail-pg0-f67.google.com with SMTP id s62so10879741pgc.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 14:17:50 -0700 (PDT)
In-Reply-To: <CAAeHK+xGCjM8oDCZcNXbaZZNqenREi4DUgHM5=Ab7GKrVEmO4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrey Konovalov and idaifish@gmail.com reported crashes caused by
one skb shared_info being overwritten from __ip6_append_data()

Andrey program lead to following state :

copy -4200 datalen 2000 fraglen 2040 
maxfraglen 2040 alloclen 2048 transhdrlen 0 offset 0 fraggap 6200

The skb_copy_and_csum_bits(skb_prev, maxfraglen, data + transhdrlen,
fraggap, 0); is overwriting skb->head and skb_shared_info

Since we apparently detect this rare condition too late, move the
code earlier to even avoid allocating skb and risking crashes.

Once again, many thanks to Andrey and syzkaller team.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Reported-by: <idaifish@gmail.com>
---
 net/ipv6/ip6_output.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d4a31becbd25dda895d7391e1e65c2de237bf2a3..bf8a58a1c32d83a9605844075da5815be23a6bf1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1466,6 +1466,11 @@ static int __ip6_append_data(struct sock *sk,
 			 */
 			alloclen += sizeof(struct frag_hdr);
 
+			copy = datalen - transhdrlen - fraggap;
+			if (copy < 0) {
+				err = -EINVAL;
+				goto error;
+			}
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
 						alloclen + hh_len,
@@ -1515,13 +1520,9 @@ static int __ip6_append_data(struct sock *sk,
 				data += fraggap;
 				pskb_trim_unique(skb_prev, maxfraglen);
 			}
-			copy = datalen - transhdrlen - fraggap;
-
-			if (copy < 0) {
-				err = -EINVAL;
-				kfree_skb(skb);
-				goto error;
-			} else if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, fraggap, skb) < 0) {
+			if (copy > 0 &&
+			    getfrag(from, data + transhdrlen, offset,
+				    copy, fraggap, skb) < 0) {
 				err = -EFAULT;
 				kfree_skb(skb);
 				goto error;
