From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 07:18:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414D16AC.1070905@eurodev.net>
References: <E1C8cPd-0006K8-00@gondolin.me.apana.org.au> <414D0CCD.90209@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010200050301050308060704"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <414D0CCD.90209@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010200050301050308060704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Pablo Neira wrote:

> you are right, I missed that, but I prefer the patches attached to 
> this email. 


wrong 2.6 patch, consider this instead

regards,
Pablo

--------------010200050301050308060704
Content-Type: text/x-patch;
 name="netlink-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-fix.patch"

diff -u -r1.1.1.2 af_netlink.c
--- a/net/netlink/af_netlink.c	4 Sep 2004 17:34:06 -0000	1.1.1.2
+++ b/net/netlink/af_netlink.c	19 Sep 2004 03:57:20 -0000
@@ -629,18 +629,20 @@
 				kmalloc(sizeof(struct netlink_work), GFP_KERNEL);
 
 			if (!nlwork)
-				return -1;
+				return 0;
 		
 			INIT_WORK(&nlwork->work, netlink_wq_handler, nlwork);
 			nlwork->sk = sk;
 			nlwork->len = skb->len;
 			queue_work(netlink_wq, &nlwork->work);
-		} else 
+		} else {
 			sk->sk_data_ready(sk, skb->len);
+			sock_put(sk);
+		}
 
-		return 0;
+		return 1;
 	}
-	return -1;
+	return 0;
 }
 
 int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
@@ -685,11 +687,11 @@
 			failure = 1;
 			sock_put(sk);
 		} else if (netlink_broadcast_deliver(sk, skb2)) {
-			netlink_overrun(sk);
-			sock_put(sk);
-		} else {
 			delivered = 1;
 			skb2 = NULL;
+		} else {
+			netlink_overrun(sk);
+			sock_put(sk);
 		}
 	}
 

--------------010200050301050308060704--
