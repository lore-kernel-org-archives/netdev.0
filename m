From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] unclamp tcp receive window if doing dynamic receive
 sizing
Date: Thu, 10 Jun 2004 21:54:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610215412.09f0a457.davem@redhat.com>
References: <20040607133056.5ab9e72d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040607133056.5ab9e72d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


As a followup I've put the following into my tree after discussing
some things with Stephen.  He will do some of his tests to make
sure this fixes things as it should.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/10 21:53:15-07:00 davem@nuts.davemloft.net 
#   [TCP]: Receive buffer moderation fixes.
#   
#   1) Make window clamp follow receive buffer growth so it
#      does not limit window advertisements.  Noticed by John
#      Heffner and Stephen Hemminger.
#   2) Fix rcvmem calculation such that tcp_adv_win_scale is
#      taken into account.
# 
# net/ipv4/tcp_input.c
#   2004/06/10 21:52:43-07:00 davem@nuts.davemloft.net +9 -1
#   [TCP]: Receive buffer moderation fixes.
#   
#   1) Make window clamp follow receive buffer growth so it
#      does not limit window advertisements.  Noticed by John
#      Heffner and Stephen Hemminger.
#   
#   2) Fix rcvmem calculation such that tcp_adv_win_scale is
#      taken into account.
# 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-06-10 21:55:14 -07:00
+++ b/net/ipv4/tcp_input.c	2004-06-10 21:55:14 -07:00
@@ -463,6 +463,8 @@
 		tp->rcvq_space.space = space;
 
 		if (sysctl_tcp_moderate_rcvbuf) {
+			int new_clamp = space;
+
 			/* Receive space grows, normalize in order to
 			 * take into account packet headers and sk_buff
 			 * structure overhead.
@@ -472,10 +474,16 @@
 				space = 1;
 			rcvmem = (tp->advmss + MAX_TCP_HEADER +
 				  16 + sizeof(struct sk_buff));
+			while (tcp_win_from_space(rcvmem) < tp->advmss)
+				rcvmem += 128;
 			space *= rcvmem;
 			space = min(space, sysctl_tcp_rmem[2]);
-			if (space > sk->sk_rcvbuf)
+			if (space > sk->sk_rcvbuf) {
 				sk->sk_rcvbuf = space;
+
+				/* Make the window clamp follow along.  */
+				tp->window_clamp = new_clamp;
+			}
 		}
 	}
 	
