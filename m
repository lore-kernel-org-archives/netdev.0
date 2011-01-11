From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 01:49:26 +0100
Message-ID: <20110111004926.GA1604@nuttenaction>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

find_dest() via new_dest() may return NULL

* stefani@seibold.net | 2010-12-31 10:29:45 [+0100]:

>+static int udpcp_sendmsg(struct kiocb *iocb, struct sock *sk,
>+			 struct msghdr *msg, size_t len)
>+{
>+	struct inet_sock *inet = inet_sk(sk);
>+	struct udpcp_sock *usk = udpcp_sk(sk);
>+	struct ipcm_cookie *ipc;
>+	struct rtable *rt = NULL;
>+	int free = 0;
>+	int connected = 0;
>+	__be32 daddr, faddr, saddr;
>+	__be16 dport;
>+	u8 tos;
>+	int err = 0;
>+	int corkreq = usk->udpsock.corkflag || msg->msg_flags & MSG_MORE;
>+	int (*getfrag) (void *, char *, int, int, int, struct sk_buff *);
>+	struct udpcp_dest *dest;
>+
>+	if (len > UDPCP_MAX_MSGSIZE)
>+		return -EMSGSIZE;
>+
>+	/*
>+	 * Check the flags.
>+	 */
>+	if (msg->msg_flags & MSG_OOB)
>+		return -EOPNOTSUPP;
>+
>+	/*
>+	 * check if socket is binded to a port
>+	 */
>+	if (!(sk->sk_userlocks & SOCK_BINDPORT_LOCK) || !inet->inet_num)
>+		return -ENOTCONN;
>+
>+	/*
>+	 * Get and verify the address.
>+	 */
>+	if (msg->msg_name) {
>+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
>+		if (msg->msg_namelen < sizeof(*usin))
>+			return -EINVAL;
>+		if (usin->sin_family != AF_INET) {
>+			if (usin->sin_family != AF_UNSPEC)
>+				return -EAFNOSUPPORT;
>+		}
>+
>+		daddr = usin->sin_addr.s_addr;
>+		dport = usin->sin_port;
>+	} else {
>+		if (sk->sk_state != TCP_ESTABLISHED)
>+			return -EDESTADDRREQ;
>+		daddr = inet->inet_daddr;
>+		dport = inet->inet_dport;
>+		/* Open fast path for connected socket.
>+		   Route will not be used, if at least one option is set.
>+		 */
>+		connected = 1;
>+	}
>+
>+	if (dport == 0)
>+		return -EINVAL;
>+
>+	dest = find_dest(sk, daddr, dport);
    if (!dest)
			return -ENOBUFS;
