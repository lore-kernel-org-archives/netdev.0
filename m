From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 22:47:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414DF05E.7020601@eurodev.net>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060100000600040505040403"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060100000600040505040403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Herbert,

Herbert Xu wrote:

>Unfortunately it is still wrong.  You missed the exit path at the
>very top.
>  
>

if netlink_broadcast_deliver returns 0, you decrease sock_put. On the 
other hand if it returns 1, refcount will be decreased by the workqueue 
handler or after calling the callback. I don't see that exit path.

>And I think rather than adding all these new sock_put's, it's much
>better to do what you mean and add a sock_hold on the new path that
>you introduced.
>  
>

yes, it's true that all those sock_put pollutes the source code, I like 
your idea of add a sock_hold, please could you have a look at the patch 
attached? it's basically your patch plus netlink_broadcast_deliver 
revised return value. If you are ok with it, let me know.

>Yes but your patch does a lot more than that wake_up_process.  Have you
>reverted just the wake_up_process and seen a difference?
>  
>

Yes, it works as well so we could remove it, but I got some extra 
throughput with the wake_up_process call if I send something up to 500 
consecutive messages from kernel to user space. For more than 1000 I 
notice that throughput is similar without wake_up_process, I'll study 
the performance without wake_up_process if it's not a good idea using it 
as you think.

>That's not what I meant.  If you have a thread group where everybody's
>got the same pid, your code will probably wake up the wrong thread.
>  
>

no, my patch doesn't wake up the user process with broadcast sockets, 
snipped from broadcast_deliver:

        if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
            !test_bit(0, &nlk->state)) {
             [...]
       }
       return 0;

it returns zero then socket overruns.

>Besides, for any netlink socket but the first for a process, they'll
>all have negative pid's which have nothing to do with the real pid.
>So I really think that the wake_up_process hunk is bogus.
>  
>

same reply as above, we don't wake up the user process with broadcast 
sockets.

regards,
Pablo

--------------060100000600040505040403
Content-Type: text/x-patch;
 name="nl-fix-2.6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nl-fix-2.6.patch"

diff -u -r1.3 af_netlink.c
--- a/net/netlink/af_netlink.c	19 Sep 2004 19:46:20 -0000	1.3
+++ b/net/netlink/af_netlink.c	19 Sep 2004 20:04:44 -0000
@@ -629,8 +629,9 @@
 				kmalloc(sizeof(struct netlink_work), GFP_KERNEL);
 
 			if (!nlwork)
-				return -1;
-		
+				return 0;
+
+			sock_hold(sk);
 			INIT_WORK(&nlwork->work, netlink_wq_handler, nlwork);
 			nlwork->sk = sk;
 			nlwork->len = skb->len;
@@ -638,9 +639,9 @@
 		} else 
 			sk->sk_data_ready(sk, skb->len);
 
-		return 0;
+		return 1;
 	}
-	return -1;
+	return 0;
 }
 
 int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
@@ -683,14 +684,13 @@
 			netlink_overrun(sk);
 			/* Clone failed. Notify ALL listeners. */
 			failure = 1;
-			sock_put(sk);
 		} else if (netlink_broadcast_deliver(sk, skb2)) {
-			netlink_overrun(sk);
-			sock_put(sk);
-		} else {
 			delivered = 1;
 			skb2 = NULL;
-		}
+		} else 
+			netlink_overrun(sk);
+
+		sock_put(sk);
 	}
 
 	netlink_unlock_table();

--------------060100000600040505040403--
