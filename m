From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 06:36:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414D0CCD.90209@eurodev.net>
References: <E1C8cPd-0006K8-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080005010406010301040701"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C8cPd-0006K8-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080005010406010301040701
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Herbert,

Herbert Xu wrote:

>Firstly there is a sock leak there.  The following patch fixes it.
>The white space damage is not mine :)
>
>Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>  
>

you are right, I missed that, but I prefer the patches attached to this 
email. Now if netlink_broadcast_deliver function delivers correctly the 
packet, you decrease sock refcount and function returns 1. I think that 
I got confused because netlink_broadcast_deliver returns 0/-1.

>Secondly, I'm dubious about the patch as a whole.  For instance, what
>exactly is the wake_up_process() bit trying to do? Surely that process
>would've been woken up multiple times already if its queue is full.
>

This is what I theorically expected, but in practice if you stress a 
netlink socket sending a big bunch of information in a short period of 
time from kernel space to user space, socket overruns easily. That's why 
I wake up the user process to make it process information stored in the 
queue. Socket doesn't overrun anymore with my patch.

>And what is it going to do with thread groups?
>  
>

currently broadcast sockets can still overrun. I have a set of patches 
that I'll submit as soon as I test them and I finish my boring exams.

regards,
Pablo

--------------080005010406010301040701
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
+			sock_put(sock);
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
 

--------------080005010406010301040701
Content-Type: text/x-patch;
 name="netlink-fix-2.4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-fix-2.4.patch"

--- a/net/netlink/af_netlink.c	2004-09-19 06:23:22.000000000 +0200
+++ b/net/netlink/af_netlink.c	2004-09-19 06:24:48.000000000 +0200
@@ -548,19 +548,21 @@
 				kmalloc(sizeof(struct netlink_work), GFP_KERNEL);
 		
 			if  (!nlwork) 
-				return -EAGAIN;
+				return 0;
 		
 			INIT_TQUEUE(&nlwork->work, netlink_tq_handler, nlwork);
 			nlwork->sk = sk;
 			nlwork->len = skb->len;
 			queue_task(&nlwork->work, &tq_netlink);
 			wake_up(&netlink_thread_wait);
-		} else 
+		} else {
 			sk->data_ready(sk, skb->len);
+			sock_put(sk);
+		}
 
-		return 0;
+		return 1;
 	}
-	return -1;
+	return 0;
 }
 
 void netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
@@ -602,11 +604,12 @@
 			/* Clone failed. Notify ALL listeners. */
 			failure = 1;
 			sock_put(sk);
-		} else if (netlink_broadcast_deliver(sk, skb2)) {
+		} else if (netlink_broadcast_deliver(sk, skb2))
+			skb2 = NULL;
+		else {
 			netlink_overrun(sk);
 			sock_put(sk);
-		} else
-			skb2 = NULL;
+		}
 	}
 
 	netlink_unlock_table();

--------------080005010406010301040701--
