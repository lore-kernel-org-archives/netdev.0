From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] netlink: Only check file credentials for implicit destinations
Date: Sat, 24 May 2014 22:38:59 -0700
Message-ID: <87zji6v2mk.fsf_-_@x220.int.ebiederm.org>
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
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: "Jorge Boncompte \[DTI2\]" <jorge@dti2.net>,
	Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58251 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbaEYFj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 01:39:56 -0400
In-Reply-To: <CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 23 May 2014 16:51:17 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It was possible to get a setuid root or setcap executable to write to
it's stdout or stderr (which has been set made a netlink socket) and
inadvertently reconfigure the networking stack.

To prevent this we check that both the creator of the socket and
the currentl applications has permission to reconfigure the network
stack.

Unfortunately this breaks Zebra which always uses sendto/sendmsg
and creates it's socket without any privileges.

To keep Zebra working don't bother checking if the creator of the
socket has privilege when a destination address is specified.  Instead
rely exclusively on the privileges of the sender of the socket.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

Could someone please test and see if this fixes the Zebra case?

So far I have only compile tested this, but the code should work,
unless Zebra is doing something that is so absolutely weird that
there is no way to close the security holes and keep Zebra working.

 include/linux/netlink.h  | 1 +
 net/netlink/af_netlink.c | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 7a28115dd396..f289d085f87f 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -19,6 +19,7 @@ enum netlink_skb_flags {
 	NETLINK_SKB_MMAPED	= 0x1,		/* Packet data is mmaped */
 	NETLINK_SKB_TX		= 0x2,		/* Packet was sent by userspace */
 	NETLINK_SKB_DELIVERED	= 0x4,		/* Packet was delivered */
+	NETLINK_SKB_DST		= 0x8,		/* Packet not socket destination */
 };
 
 struct netlink_skb_parms {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e0ccd84d4d67..15c731f03fa6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1377,7 +1377,9 @@ retry:
 bool __netlink_ns_capable(const struct netlink_skb_parms *nsp,
 			struct user_namespace *user_ns, int cap)
 {
-	return sk_ns_capable(nsp->sk, user_ns, cap);
+	return ((nsp->flags & NETLINK_SKB_DST) ||
+		file_ns_capable(nsp->sk->sk_socket->file, user_ns, cap)) &&
+		ns_capable(user_ns, cap);
 }
 EXPORT_SYMBOL(__netlink_ns_capable);
 
@@ -2323,6 +2325,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 	struct scm_cookie scm;
+	u32 netlink_skb_flags = 0;
 
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
@@ -2344,6 +2347,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if ((dst_group || dst_portid) &&
 		    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
 			goto out;
+		netlink_skb_flags |= NETLINK_SKB_DST;
 	} else {
 		dst_portid = nlk->dst_portid;
 		dst_group = nlk->dst_group;
@@ -2373,6 +2377,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).portid	= nlk->portid;
 	NETLINK_CB(skb).dst_group = dst_group;
 	NETLINK_CB(skb).creds	= siocb->scm->creds;
+	NETLINK_CB(skb).flags	= netlink_skb_flags;
 
 	err = -EFAULT;
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
-- 
1.9.1
