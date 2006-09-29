From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] IPv6/DCCP: Fix memory leak in dccp_v6_do_rcv()
Date: Fri, 29 Sep 2006 02:45:33 +0200
Message-ID: <200609290245.33618.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@coreworks.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161239AbWI2AoQ@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Coverity found what looks like a real leak in net/dccp/ipv6.c::dccp_v6_do_rcv()

We may leave via the return inside "if (sk->sk_state == DCCP_OPEN) {"
but at that point we may have allocated opt_skb, but we never free it
in that path before the return.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 net/dccp/ipv6.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.18-git10-orig/net/dccp/ipv6.c	2006-09-28 22:40:07.000000000 +0200
+++ linux-2.6.18-git10/net/dccp/ipv6.c	2006-09-29 02:35:15.000000000 +0200
@@ -997,6 +997,8 @@ static int dccp_v6_do_rcv(struct sock *s
 	if (sk->sk_state == DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
 			goto reset;
+		if (opt_skb)
+			__kfree_skb(opt_skb);
 		return 0;
 	}
 





PS. Please keep me on Cc:

-- 
Jesper Juhl <jesper.juhl@gmail.com>
