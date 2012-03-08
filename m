From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH v2 1/2] sctp: Export sctp_do_peeloff
Date: Thu,  8 Mar 2012 10:55:58 -0500
Message-ID: <1331222159-28980-1-git-send-email-bpoirier@suse.de>
References: <20120308.002447.1062706659978103072.davem@davemloft.net>
Cc: Christine Caulfield <ccaulfie@redhat.com>,
	David Teigland <teigland@redhat.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>, cluster-devel@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60132 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839Ab2CHP5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 10:57:02 -0500
In-Reply-To: <20120308.002447.1062706659978103072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lookup sctp_association within sctp_do_peeloff() to enable its use outside of
the sctp code with minimal knowledge of the former.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

---
Changes from v1:
* make sctp_do_peeloff() take the assoc id as argument so that the dlm code
  doesn't need to do the id to struct lookup itself
* split those sctp changes to their own patch

 include/net/sctp/sctp.h |    1 +
 net/sctp/socket.c       |   24 +++++++++---------------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d368561..6ee44b2 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -413,6 +413,7 @@ static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
 /* Look up the association by its id.  */
 struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id);
 
+int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp);
 
 /* A macro to walk a list of skbs.  */
 #define sctp_skb_for_each(pos, head, tmp) \
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 408ebd0..06b42b7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4170,14 +4170,16 @@ static int sctp_getsockopt_autoclose(struct sock *sk, int len, char __user *optv
 }
 
 /* Helper routine to branch off an association to a new socket.  */
-SCTP_STATIC int sctp_do_peeloff(struct sctp_association *asoc,
-				struct socket **sockp)
+int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 {
-	struct sock *sk = asoc->base.sk;
+	struct sctp_association *asoc = sctp_id2assoc(sk, id);
 	struct socket *sock;
 	struct sctp_af *af;
 	int err = 0;
 
+	if (!asoc)
+		return -EINVAL;
+
 	/* An association cannot be branched off from an already peeled-off
 	 * socket, nor is this supported for tcp style sockets.
 	 */
@@ -4206,13 +4208,13 @@ SCTP_STATIC int sctp_do_peeloff(struct sctp_association *asoc,
 
 	return err;
 }
+EXPORT_SYMBOL(sctp_do_peeloff);
 
 static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval, int __user *optlen)
 {
 	sctp_peeloff_arg_t peeloff;
 	struct socket *newsock;
 	int retval = 0;
-	struct sctp_association *asoc;
 
 	if (len < sizeof(sctp_peeloff_arg_t))
 		return -EINVAL;
@@ -4220,15 +4222,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 	if (copy_from_user(&peeloff, optval, len))
 		return -EFAULT;
 
-	asoc = sctp_id2assoc(sk, peeloff.associd);
-	if (!asoc) {
-		retval = -EINVAL;
-		goto out;
-	}
-
-	SCTP_DEBUG_PRINTK("%s: sk: %p asoc: %p\n", __func__, sk, asoc);
-
-	retval = sctp_do_peeloff(asoc, &newsock);
+	retval = sctp_do_peeloff(sk, peeloff.associd, &newsock);
 	if (retval < 0)
 		goto out;
 
@@ -4239,8 +4233,8 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
 		goto out;
 	}
 
-	SCTP_DEBUG_PRINTK("%s: sk: %p asoc: %p newsk: %p sd: %d\n",
-			  __func__, sk, asoc, newsock->sk, retval);
+	SCTP_DEBUG_PRINTK("%s: sk: %p newsk: %p sd: %d\n",
+			  __func__, sk, newsock->sk, retval);
 
 	/* Return the fd mapped to the new socket.  */
 	peeloff.sd = retval;
-- 
1.7.7
