From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec [Updated #2]
Date: Tue, 27 Jun 2006 03:16:37 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606270315130.30073@d.namei>
References: <20060627052255.GA1311@jiayuguan.watson.ibm.com>
 <Pine.LNX.4.64.0606270311210.30073@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	jmorris@redhat.com, chrisw@osdl.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Smalley <sds@tycho.nsa.gov>, tjaeger@cse.psu.edu,
	Andrew Morton <akpm@osdl.org>, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:65475 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030684AbWF0HQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 03:16:40 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0606270311210.30073@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2006, James Morris wrote:

> I'll address that in a patch to follow.  Could you please test these 
> updated patches?  Thanks.
> 


Below is a relative patch which only compiles this stuff into the core 
networking code when appropriate kernel config is selected.

Please review.


---

diff -purN -X dontdiff linux-2.6.p/include/net/scm.h linux-2.6.w/include/net/scm.h
--- linux-2.6.p/include/net/scm.h	2006-06-27 02:26:02.000000000 -0400
+++ linux-2.6.w/include/net/scm.h	2006-06-27 03:03:30.000000000 -0400
@@ -19,7 +19,9 @@ struct scm_cookie
 {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+#ifdef CONFIG_SECURITY_NETWORK	
 	char			*secdata;	/* Security context	*/
+#endif	
 	unsigned long		seq;		/* Connection seqno	*/
 };
 
@@ -49,6 +51,17 @@ static __inline__ int scm_send(struct so
 	return __scm_send(sock, msg, scm);
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
+{
+	if (test_bit(SOCK_PASSSEC, &sock->flags) && scm->secdata != NULL)
+		put_cmsg(msg, SOL_SOCKET, SCM_SECURITY, strlen(scm->secdata)+1, scm->secdata);
+}
+#else
+static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
+{ }
+#endif	/* CONFIG_SECURITY_NETWORK */
+
 static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 				struct scm_cookie *scm, int flags)
 {
@@ -63,8 +76,7 @@ static __inline__ void scm_recv(struct s
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
-	if (test_bit(SOCK_PASSSEC, &sock->flags) && scm->secdata != NULL)
-		put_cmsg(msg, SOL_SOCKET, SCM_SECURITY, strlen(scm->secdata)+1, scm->secdata);
+	scm_passec(sock, msg, scm);
 
 	if (!scm->fp)
 		return;
diff -purN -X dontdiff linux-2.6.p/net/unix/af_unix.c linux-2.6.w/net/unix/af_unix.c
--- linux-2.6.p/net/unix/af_unix.c	2006-06-27 02:26:02.000000000 -0400
+++ linux-2.6.w/net/unix/af_unix.c	2006-06-27 03:03:29.000000000 -0400
@@ -128,6 +128,28 @@ static atomic_t unix_nr_socks = ATOMIC_I
 
 #define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
 
+#ifdef CONFIG_SECURITY_NETWORKING
+static void unix_get_peersec_dgram(struct sk_buff *skb)
+{
+	int tmp = 0;
+	
+	err = security_socket_getpeersec_dgram(skb, UNIXSEC(skb), &tmp);
+	if (err)
+		*(UNIXSEC(skb)) = NULL;
+}
+
+static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
+{
+	scm->secdata = *UNIXSEC(skb);
+}
+#else
+static void unix_get_peersec_dgram(struct sk_buff *skb)
+{ }
+
+static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
+{ }
+#endif /* CONFIG_SECURITY_NETWORKING */
+
 /*
  *  SMP locking strategy:
  *    hash table is protected with spinlock unix_table_lock
@@ -1251,7 +1273,6 @@ static int unix_dgram_sendmsg(struct kio
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
-	int seclen = 0;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1291,9 +1312,8 @@ static int unix_dgram_sendmsg(struct kio
 	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 	if (siocb->scm->fp)
 		unix_attach_fds(siocb->scm, skb);
-	err = security_socket_getpeersec_dgram(skb, UNIXSEC(skb), &seclen);
-	if (err)
-		*(UNIXSEC(skb)) = NULL;
+
+	unix_get_peersec_dgram(skb);
 
 	skb->h.raw = skb->data;
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
@@ -1574,7 +1594,7 @@ static int unix_dgram_recvmsg(struct kio
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	siocb->scm->creds = *UNIXCREDS(skb);
-	siocb->scm->secdata = *UNIXSEC(skb);
+	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK))
 	{
