From: Kovacs Krisztian <hidden@balabit.hu>
Subject: [PATCH] ipv4 tcp autobind problem
Date: Mon, 29 Sep 2003 15:05:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F782E1F.4030500@balabit.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060207040000040509080909"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060207040000040509080909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


   Hi,

   While testing the tproxy (transparent proxying) patch for linux-2.4
(http://www.balabit.com/downloads/tproxy/linux-2.4), Stas Grabois has
found a quite strange aspect of Linux 2.4 TCP. Imagine the following
scenario: you create a new socket (AF_INET, SOCK_STREAM), bind it to local
port 0, and try to connect() to a closed port. Of course, the peer sends
back an RST, indicating no one is listening on that port. However, if your
application does not care about the return value of connect(), and calls
send() on the not connected socket, inet_autobind() is called and a new
local port is allocated for the socket. So, besides returning an error,
there is also a side effect of the send(). The same thing happens with an
established TCP session if the peer sends an RST between two send() calls,
the second call will autobind the socket, and then return error.

   Is this behaviour intentional? Isn't rebinding a TCP socket to a new
local port a bug? I mean, possibly inet_sendmsg() should check if the
socket is SOCK_STREAM before calling inet_autobind() if sk->num is zero. 
The attached patch adds this check to inet_sendmsg(). We've been using it 
for a while, and it looks it did not break anything.

-- 
   Regards,
     Krisztian KOVACS


--------------060207040000040509080909
Content-Type: text/plain;
 name="inet_tcp_autobind_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inet_tcp_autobind_fix.diff"

--- linux-2.4.22/net/ipv4/af_inet.c.orig	Thu Sep 18 10:02:49 2003
+++ linux-2.4.22/net/ipv4/af_inet.c	Thu Sep 18 10:03:56 2003
@@ -751,7 +751,7 @@
 	struct sock *sk = sock->sk;
 
 	/* We may need to bind the socket. */
-	if (sk->num==0 && inet_autobind(sk) != 0)
+	if (sk->num==0 && sock->type != SOCK_STREAM && inet_autobind(sk) != 0)
 		return -EAGAIN;
 
 	return sk->prot->sendmsg(sk, msg, size);

--------------060207040000040509080909--
