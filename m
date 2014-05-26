From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH 2/1] netlink: Use the credential at the time the destination address was set.
Date: Sun, 25 May 2014 22:36:24 -0700
Message-ID: <87ppj1qexz.fsf_-_@x220.int.ebiederm.org>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
	<20140522170505.64ef87a2@griffin>
	<87ioow6pt6.fsf@x220.int.ebiederm.org>
	<CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
	<87zji6v2mk.fsf_-_@x220.int.ebiederm.org>
	<CALCETrVezgCY61wSO_5kTJz-tX5HdYwbEPpS-HAy8bg7KEqibA@mail.gmail.com>
	<874n0ds9sk.fsf@x220.int.ebiederm.org>
	<CA+55aFwsomt04G8MTJBU2YEn4XLuRw14C4yU1b2sWDmk5HWrcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto@amacapital.net>,
	"Jorge Boncompte \[DTI2\]" <jorge@dti2.net>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50891 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaEZFhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 01:37:21 -0400
In-Reply-To: <CA+55aFwsomt04G8MTJBU2YEn4XLuRw14C4yU1b2sWDmk5HWrcw@mail.gmail.com>
	(Linus Torvalds's message of "Sun, 25 May 2014 17:32:55 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When sending a message over a netlink socket and then checking to see if
the person is authorized to send the message it is important that we verify
both the sender of the message and the whoever it is that set the destination
of the message both have permission.  Otherwise it becomes possible for an
unpriivleged user to set the message destination and trick an suid process
to write to the socket and change the network connection.

For netlink sockets socket() sets the default destination address to 0 (the kernel)
so we need to remember the credentials when a socket is created.

For netlink sockets connect() changes the default destination address so
we need to remember the credentials of the last changer of the default destination
with connect.

This results is there always being a valid remembered credential on the socket
and so that credential is unconditionally freed in netlink_release().

This change makes the semantics of the permission checks of netlink sockets
make sense,and removes the possibility of an unprivileged user getting access
to a root own socket and changing the destination address with connect.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

This winds up continuig to grab credentials when socket() is called
because we actually set the destination address in socket() for netlink
sockets, but now we update those credentials when connect() is called.

 include/linux/netlink.h  |  2 +-
 net/netlink/af_netlink.c | 27 ++++++++++++++++++++++++---
 net/netlink/af_netlink.h |  1 +
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f289d085f87f..4f4607c0a1a1 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -19,7 +19,7 @@ enum netlink_skb_flags {
 	NETLINK_SKB_MMAPED	= 0x1,		/* Packet data is mmaped */
 	NETLINK_SKB_TX		= 0x2,		/* Packet was sent by userspace */
 	NETLINK_SKB_DELIVERED	= 0x4,		/* Packet was delivered */
-	NETLINK_SKB_DST		= 0x8,		/* Packet not socket destination */
+	NETLINK_SKB_DST		= 0x8,		/* Dst set in sendto or sendmsg */
 };
 
 struct netlink_skb_parms {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 15c731f03fa6..5b886ed6a648 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1191,6 +1191,7 @@ static int __netlink_create(struct net *net, struct socket *sock,
 		mutex_init(nlk->cb_mutex);
 	}
 	init_waitqueue_head(&nlk->wait);
+	nlk->cred = get_current_cred();
 #ifdef CONFIG_NETLINK_MMAP
 	mutex_init(&nlk->pg_vec_lock);
 #endif
@@ -1291,6 +1292,7 @@ static int netlink_release(struct socket *sock)
 				NETLINK_URELEASE, &n);
 	}
 
+	put_cred(nlk->cred);
 	module_put(nlk->module);
 
 	netlink_table_grab();
@@ -1377,9 +1379,17 @@ retry:
 bool __netlink_ns_capable(const struct netlink_skb_parms *nsp,
 			struct user_namespace *user_ns, int cap)
 {
-	return ((nsp->flags & NETLINK_SKB_DST) ||
-		file_ns_capable(nsp->sk->sk_socket->file, user_ns, cap)) &&
-		ns_capable(user_ns, cap);
+	const struct cred *cred;
+	bool capable;
+
+	rcu_read_lock();
+	cred = nlk_sk(nsp->sk)->cred;
+	capable = ((nsp->flags & NETLINK_SKB_DST) ||
+		   security_capable(cred, user_ns, cap)) &&
+			ns_capable(user_ns, cap);
+	rcu_read_unlock();
+
+	return capable;
 }
 EXPORT_SYMBOL(__netlink_ns_capable);
 
@@ -1569,14 +1579,20 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
+	const struct cred *old_cred;
 
 	if (alen < sizeof(addr->sa_family))
 		return -EINVAL;
 
 	if (addr->sa_family == AF_UNSPEC) {
+		lock_sock(sk);
 		sk->sk_state	= NETLINK_UNCONNECTED;
 		nlk->dst_portid	= 0;
 		nlk->dst_group  = 0;
+		old_cred = nlk->cred;
+		nlk->cred = get_current_cred();
+		put_cred(old_cred);
+		release_sock(sk);
 		return 0;
 	}
 	if (addr->sa_family != AF_NETLINK)
@@ -1590,9 +1606,14 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
+		lock_sock(sk);
 		sk->sk_state	= NETLINK_CONNECTED;
 		nlk->dst_portid = nladdr->nl_pid;
 		nlk->dst_group  = ffs(nladdr->nl_groups);
+		old_cred = nlk->cred;
+		nlk->cred = get_current_cred();
+		put_cred(old_cred);
+		release_sock(sk);
 	}
 
 	return err;
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 0b59d441f5b6..d3c9d319e9e6 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -40,6 +40,7 @@ struct netlink_sock {
 	void			(*netlink_rcv)(struct sk_buff *skb);
 	int			(*netlink_bind)(int group);
 	void			(*netlink_unbind)(int group);
+	const struct cred	*cred;
 	struct module		*module;
 #ifdef CONFIG_NETLINK_MMAP
 	struct mutex		pg_vec_lock;
-- 
1.9.1
