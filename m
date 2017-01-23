From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Mon, 23 Jan 2017 23:33:19 +0100
Message-ID: <20170123223319.GH20894@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <CAEA6p_DxVMAry1PCz_idmk=TGpnnTib3WpWso03FB1oMVXN+sg@mail.gmail.com>
 <20170123213732.GF20894@1wt.eu>
 <20170123220121.GG20894@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Wang <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:63087 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751668AbdAWWdh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 17:33:37 -0500
Content-Disposition: inline
In-Reply-To: <20170123220121.GG20894@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 11:01:21PM +0100, Willy Tarreau wrote:
> On Mon, Jan 23, 2017 at 10:37:32PM +0100, Willy Tarreau wrote:
> > On Mon, Jan 23, 2017 at 01:28:53PM -0800, Wei Wang wrote:
> > > Hi Willy,
> > > 
> > > True. If you call connect() multiple times on a socket which already has
> > > cookie without a write(), the second and onward connect() call will return
> > > EINPROGRESS.
> > > It is basically because the following code block in __inet_stream_connect()
> > > can't distinguish if it is the first time connect() is called or not:
> > > 
> > > case SS_CONNECTING:
> > >                 if (inet_sk(sk)->defer_connect)  <----- defer_connect will
> > > be 0 only after a write() is called
> > >                         err = -EINPROGRESS;
> > >                 else
> > >                         err = -EALREADY;
> > >                 /* Fall out of switch with err, set for this state */
> > >                 break;
> > 
> > Ah OK that totally makes sense, thanks for the explanation!
> > 
> > > I guess we can add some extra logic here to address this issue. So the
> > > second connect() and onwards will return EALREADY.
> 
> Thinking about it a bit more, I really think it would make more
> sense to return -EISCONN here if we want to match the semantics
> of a connect() returning zero on the first call. This way the
> caller knows it can write whenever it wants and can disable
> write polling until needed.
> 
> I'm currently rebuilding a kernel with this change to see if it
> behaves any better :
> 
> -                        err = -EINPROGRESS;
> +                        err = -EISCONN;

OK so obviously it didn't work since sendmsg() goes there as well.

But that made me realize that there really are 3 states, not 2 :

  - after connect() and before sendmsg() :
     defer_accept = 1, we want to lie to userland and pretend we're
     connected so that userland can call send(). A connect() must
     return either zero or -EISCONN.

  - during first sendmsg(), still connecting :
     the connection is in progress, EINPROGRESS must be returned to
     the first sendmsg().

  - after the first sendmsg() :
     defer_accept = 0 ; connect() must return -EALREADY. We want to
     return real socket states from now on.

Thus I modified defer_accept to take two bits to represent the extra
state we need to indicate the transition. Now sendmsg() upgrades
defer_accept from 1 to 2 before calling __inet_stream_connect(), which
then knows it must return EINPROGRESS to sendmsg().

This way we correctly cover all these situations. Even if we call
connect() again after the first connect() attempt it still matches
the first result :

accept4(7, {sa_family=AF_INET, sin_port=htons(36860), sin_addr=inet_addr("192.168.0.176")}, [128->16], SOCK_NONBLOCK) = 1
setsockopt(1, SOL_TCP, TCP_NODELAY, [1], 4) = 0
accept4(7, 0x7ffc2282fcb0, [128], SOCK_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
recvfrom(1, 0x7b53a4, 7006, 0, NULL, NULL) = -1 EAGAIN (Resource temporarily unavailable)
socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 2
fcntl(2, F_SETFL, O_RDONLY|O_NONBLOCK)  = 0
setsockopt(2, SOL_TCP, TCP_NODELAY, [1], 4) = 0
setsockopt(2, SOL_TCP, 0x1e /* TCP_??? */, [1], 4) = 0
connect(2, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
epoll_ctl(0, EPOLL_CTL_ADD, 1, {EPOLLIN|EPOLLRDHUP, {u32=1, u64=1}}) = 0
epoll_wait(0, [], 200, 0)               = 0
connect(2, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EISCONN (Transport endpoint is already connected)
epoll_wait(0, [], 200, 0)               = 0
recvfrom(2, 0x7b53a4, 8030, 0, NULL, NULL) = -1 EAGAIN (Resource temporarily unavailable)
epoll_ctl(0, EPOLL_CTL_ADD, 2, {EPOLLIN|EPOLLRDHUP, {u32=2, u64=2}}) = 0
epoll_wait(0, [], 200, 1000)            = 0
epoll_wait(0, [], 200, 1000)            = 0
epoll_wait(0, [], 200, 1000)            = 0
epoll_wait(0, [{EPOLLIN, {u32=1, u64=1}}], 200, 1000) = 1
recvfrom(1, "GET / HTTP/1.1\r\n", 8030, 0, NULL, NULL) = 16
sendto(2, "GET / HTTP/1.1\r\n", 16, MSG_DONTWAIT|MSG_NOSIGNAL, NULL, 0) = 16
epoll_wait(0, [{EPOLLIN, {u32=1, u64=1}}], 200, 1000) = 1
recvfrom(1, "\r\n", 8030, 0, NULL, NULL) = 2
sendto(2, "\r\n", 2, MSG_DONTWAIT|MSG_NOSIGNAL, NULL, 0) = 2
epoll_wait(0, [{EPOLLIN|EPOLLRDHUP, {u32=2, u64=2}}], 200, 1000) = 1
recvfrom(2, "HTTP/1.1 302 Found\r\nCache-Contro"..., 8030, 0, NULL, NULL) = 98
sendto(1, "HTTP/1.1 302 Found\r\nCache-Contro"..., 98, MSG_DONTWAIT|MSG_NOSIGNAL|MSG_MORE, NULL, 0) = 98
shutdown(1, SHUT_WR)                    = 0
epoll_ctl(0, EPOLL_CTL_DEL, 2, 0x6ff55c) = 0
epoll_wait(0, [{EPOLLIN|EPOLLHUP|EPOLLRDHUP, {u32=1, u64=1}}], 200, 1000) = 1
recvfrom(1, "", 8030, 0, NULL, NULL)    = 0
close(1)                                = 0
shutdown(2, SHUT_WR)                    = 0
close(2)                                = 0

Here's what I changed on top of your patchset :

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 0042fed..dc53f7f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -207,9 +207,10 @@ struct inet_sock {
 				mc_all:1,
 				nodefrag:1;
 	__u8			bind_address_no_port:1,
-				defer_connect:1; /* Indicates that fastopen_connect is set
+				defer_connect:2; /* Indicates that fastopen_connect is set
 						  * and cookie exists so we defer connect
-						  * until first data frame is written
+						  * until first data frame is written.
+						  * Switches from 1 to 2 during first write()
 						  */
 	__u8			rcv_tos;
 	__u8			convert_csum;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e67d572..6dda9d5a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -594,8 +594,10 @@ int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 		err = -EISCONN;
 		goto out;
 	case SS_CONNECTING:
-		if (inet_sk(sk)->defer_connect)
-			err = -EINPROGRESS;
+		if (inet_sk(sk)->defer_connect == 2)
+			err = -EINPROGRESS; /* sendmsg started */
+		else if (inet_sk(sk)->defer_connect == 1)
+			err = -EISCONN;     /* suggest to send now */
 		else
 			err = -EALREADY;
 		/* Fall out of switch with err, set for this state */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3c8938d..bd71f60 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1103,6 +1103,10 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 			inet->inet_dport = 0;
 			sk->sk_route_caps = 0;
 		}
+		/* tell __inet_stream_connect() that we're doing the
+		 * first write.
+		 */
+		inet->defer_connect = 2;
 	}
 	flags = (msg->msg_flags & MSG_DONTWAIT) ? O_NONBLOCK : 0;
 	err = __inet_stream_connect(sk->sk_socket, msg->msg_name,


Is this also what you had in mind ?

thanks,
Willy
