From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Sat, 21 Feb 2004 13:08:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040221130853.4c98bad6.davem@redhat.com>
References: <20040217121726.GD8554@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040217121726.GD8554@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2004 13:17:26 +0100
Olaf Kirch <okir@suse.de> wrote:

> I'm currently investigating a problem in udp recvmsg. In short, a test
> program selects on the socket, gets woken up as a packet arrives, but
> recvmsg return EAGAIN because the UDP checksum was wrong.
> 
> This broke one real-life application, and reportedly this violates POSIX,
> as operations on a blocking socket must never return EAGAIN.

Well, first things first, using blocking sockets with select/poll is kind
of stupid programming.

Nonetheless, udp_recvmsg() can't return -EAGAIN on a blocking socket.

Andi, TCP does not have this issue, it simply goes back to sleep waiting
for more data to arrive if the prequeue delayed checksumming fails.

I think we should fix it like the following, which is basically the last
part of Olaf's original patch in this thread.  Just wait for another packet
if a blocking socket and checksum fails, else if non-blocking -EAGAIN is OK.

To be honest, I believe this was Alexey's original intention when he wrote this
code.

===== net/ipv4/udp.c 1.56 vs edited =====
--- 1.56/net/ipv4/udp.c	Fri Jan  9 01:50:23 2004
+++ edited/net/ipv4/udp.c	Sat Feb 21 13:03:05 2004
@@ -787,6 +787,7 @@
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len);
 
+try_again:
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
 		goto out;
@@ -852,7 +853,9 @@
 
 	skb_free_datagram(sk, skb);
 
-	return -EAGAIN;	
+	if (noblock)
+		return -EAGAIN;	
+	goto try_again;
 }
 
 int udp_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
