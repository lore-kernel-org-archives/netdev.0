From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 1/3] [INET_CONNECTION_SOCK]: Pack struct inet_connection_sock_af_ops
Date: Mon, 27 Nov 2006 18:04:49 -0200
Message-ID: <20061127200449.GX11605@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:33411 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1758546AbWK0UFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 15:05:05 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have a hole in:

[acme@newtoy net-2.6.20]$ pahole net/ipv6/tcp_ipv6.o inet_connection_sock_af_ops
/* /pub/scm/linux/kernel/git/acme/net-2.6.20/include/net/inet_connection_sock.h:38 */
struct inet_connection_sock_af_ops {
        int                        (*queue_xmit)();      /*     0     4 */
        void                       (*send_check)();      /*     4     4 */
        int                        (*rebuild_header)();  /*     8     4 */
        int                        (*conn_request)();    /*    12     4 */
        struct sock *              (*syn_recv_sock)();   /*    16     4 */
        int                        (*remember_stamp)();  /*    20     4 */
        __u16                      net_header_len;       /*    24     2 */

        /* XXX 2 bytes hole, try to pack */

        int                        (*setsockopt)();      /*    28     4 */
        int                        (*getsockopt)();      /*    32     4 */
        int                        (*compat_setsockopt)(); /*    36     4 */
        int                        (*compat_getsockopt)(); /*    40     4 */
        void                       (*addr2sockaddr)();   /*    44     4 */
        int                        sockaddr_len;         /*    48     4 */
}; /* size: 52, sum members: 50, holes: 1, sum holes: 2 */

But we don't need sockaddr_len to be an int:

[acme@newtoy net-2.6.20]$ find net -name "*.[ch]" | xargs grep '\.sockaddr_len.\+=' | sort -u
net/dccp/ipv4.c:        .sockaddr_len      = sizeof(struct sockaddr_in),
net/dccp/ipv6.c:        .sockaddr_len      = sizeof(struct sockaddr_in6),
net/ipv4/tcp_ipv4.c:    .sockaddr_len      = sizeof(struct sockaddr_in),
net/ipv6/tcp_ipv6.c:    .sockaddr_len      = sizeof(struct sockaddr_in6),
net/sctp/ipv6.c:        .sockaddr_len      = sizeof(struct sockaddr_in6),
net/sctp/protocol.c:    .sockaddr_len      = sizeof(struct sockaddr_in),

[acme@newtoy net-2.6.20]$ pahole --sizes net/ipv6/tcp_ipv6.o | grep sockaddr_in
struct sockaddr_in: 16 0
struct sockaddr_in6: 28 0
[acme@newtoy net-2.6.20]$

So I turned sockaddr_len a 'u16', and now:

[acme@newtoy net-2.6.20]$ pahole net/ipv6/tcp_ipv6.o inet_connection_sock_af_ops
/* /pub/scm/linux/kernel/git/acme/net-2.6.20/include/net/inet_connection_sock.h:38 */
struct inet_connection_sock_af_ops {
        int            (*queue_xmit)();        /*     0   4 */
        void           (*send_check)();        /*     4   4 */
        int            (*rebuild_header)();    /*     8   4 */
        int            (*conn_request)();      /*    12   4 */
        struct sock *  (*syn_recv_sock)();     /*    16   4 */
        int            (*remember_stamp)();    /*    20   4 */
        u16            net_header_len;         /*    24   2 */
        u16            sockaddr_len;           /*    26   2 */
        int            (*setsockopt)();        /*    28   4 */
        int            (*getsockopt)();        /*    32   4 */
        int            (*compat_setsockopt)(); /*    36   4 */
        int            (*compat_getsockopt)(); /*    40   4 */
        void           (*addr2sockaddr)();     /*    44   4 */
}; /* size: 48 */

So we've saved 4 bytes:

[acme@newtoy net-2.6.20]$ codiff -sV /tmp/tcp_ipv6.o.before net/ipv6/tcp_ipv6.o
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv6/tcp_ipv6.c:
  struct inet_connection_sock_af_ops |   -4
    net_header_len;
     from: __u16                 /*    24(0)     2(0) */
     to:   u16                   /*    24(0)     2(0) */
    sockaddr_len;
     from: int                   /*    48(0)     4(0) */
     to:   u16                   /*    26(0)     2(0) */
 1 struct changed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/net/inet_connection_sock.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index fd3f1d8..cccea05 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -46,7 +46,8 @@ struct inet_connection_sock_af_ops {
 				      struct request_sock *req,
 				      struct dst_entry *dst);
 	int	    (*remember_stamp)(struct sock *sk);
-	__u16	    net_header_len;
+	u16	    net_header_len;
+	u16	    sockaddr_len;
 	int	    (*setsockopt)(struct sock *sk, int level, int optname, 
 				  char __user *optval, int optlen);
 	int	    (*getsockopt)(struct sock *sk, int level, int optname, 
@@ -58,7 +59,6 @@ struct inet_connection_sock_af_ops {
 				int level, int optname,
 				char __user *optval, int __user *optlen);
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
-	int sockaddr_len;
 };
 
 /** inet_connection_sock - INET connection oriented sock
-- 
1.4.2.1.g3d5c

