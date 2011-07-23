From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Sat, 23 Jul 2011 14:20:13 +0900
Message-ID: <201107231420.ADF51026.SOMtFFOLJQFVHO@I-love.SAKURA.ne.jp>
References: <201107222127.GBG51007.FStQFVOHOFOLJM@I-love.SAKURA.ne.jp>
	<201107230012.HED65612.JFVSFOOOMHtFLQ@I-love.SAKURA.ne.jp>
	<20110722.082224.688620059032914637.davem@davemloft.net>
	<201107230242.HJH39096.OSMOVQOLFFFHJt@I-love.SAKURA.ne.jp>
	<201107230331.GHE48423.QFHJMFOLtOOSVF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: casey@schaufler-ca.com, anton@samba.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52100 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab1GWFUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 01:20:33 -0400
In-Reply-To: <201107230331.GHE48423.QFHJMFOLtOOSVF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > David Miller wrote:
> > > Ugh, this takes away a non-trivial part of the performance gain of
> > > sendmmsg().
> > > 
> > > I would instead rather that you check ahead of time whether this
> > > actually is a send to different addresses.  If they are all the
> > > same, keep the nosec code path.
> > > 
> > OK. Something like this? Not tested at all.
> 
> No. We can't compare destination address before entering __sys_sendmsg(), for
> it is copied to kernel memory by verify_iovec()/verify_compat_iovec().
> 
OK. Something like this? Not tested at all.
----------------------------------------
[PATCH] net: Fix security_socket_sendmsg() bypass problem.

The sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
call" is capable of sending to multiple different destinations. However,
security_socket_sendmsg() is called for only once even if multiple different
destination's addresses are passed to sendmmsg().

SMACK is using destination's address for checking sendmsg() permission.
Therefore, we need to call security_socket_sendmsg() for each destination
address rather than the first destination address.

Fix this problem by maintaining a list of already-checked destination address.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [3.0+]
---
 net/socket.c |   84 +++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 79 insertions(+), 5 deletions(-)

--- linux-3.0.orig/net/socket.c
+++ linux-3.0/net/socket.c
@@ -1871,8 +1871,19 @@ SYSCALL_DEFINE2(shutdown, int, fd, int, 
 #define COMPAT_NAMELEN(msg)	COMPAT_MSG(msg, msg_namelen)
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
+/*
+ * Structure for remembering destination's address used by send_mmsg().
+ * This is for calling security_socket_sendms() only once for each destination.
+ */
+struct sendmmsg_dest_info {
+	struct list_head list;
+	unsigned int address_len;
+	struct sockaddr_storage address;
+};
+
 static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned flags,
+			 struct list_head *list)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -1883,6 +1894,7 @@ static int __sys_sendmsg(struct socket *
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
 	int err, ctl_len, iov_size, total_len;
+	bool nosec = false;
 
 	err = -EFAULT;
 	if (MSG_CMSG_COMPAT & flags) {
@@ -1953,6 +1965,58 @@ static int __sys_sendmsg(struct socket *
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		msg_sys->msg_flags |= MSG_DONTWAIT;
+	if (list) {
+		/*
+		 * We need to pass destination address to
+		 * security_socket_sendmsg() since some LSM modules want it.
+		 * But passing already-checked destination address twice is
+		 * waste of time.
+		 *
+		 * Therefore, check for already-checked destination address in
+		 * order to see whether we can omit security_socket_sendmsg()
+		 * call or not.
+		 *
+		 * This optimization assumes that LSM modules use only
+		 * destination address (i.e. "struct msghdr"->msg_name and
+		 * "struct msghdr"->msg_namelen). We can't use this assumption
+		 * if LSM modules want to use other factors (e.g. total_len
+		 * argument below).
+		 */
+		struct sendmmsg_dest_info *ptr;
+		list_for_each_entry(ptr, list, list) {
+			/*
+			 * verify_iovec()/verify_compat_iovec() above assigned
+			 * appropriate values to msg_sys->msg_namelen and
+			 * msg_sys->msg_name.
+			 */
+			if (ptr->address_len != msg_sys->msg_namelen ||
+			    memcmp(&ptr->address, msg_sys->msg_name,
+				   ptr->address_len))
+				continue;
+			nosec = true;
+			break;
+		}
+		if (!nosec) {
+			/*
+			 * Remember the destination address passed to
+			 * sendmmsg() so that we can avoid calling
+			 * security_sendmsg_permission() again for
+			 * already-checked destination address.
+			 *
+			 * Out of memory error is not fatal here because
+			 * calling security_sendmsg_permission() again for
+			 * already-checked destination address should be
+			 * harmless.
+			 */
+			ptr = kmalloc(sizeof(*ptr), GFP_KERNEL);
+			if (ptr) {
+				ptr->address_len = msg_sys->msg_namelen;
+				memcpy(&ptr->address, msg_sys->msg_name,
+				       ptr->address_len);
+				list_add(&ptr->list, list);
+			}
+		}
+	}
 	err = (nosec ? sock_sendmsg_nosec : sock_sendmsg)(sock, msg_sys,
 							  total_len);
 
@@ -1979,7 +2043,7 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 	if (!sock)
 		goto out;
 
-	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
+	err = __sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -1998,6 +2062,7 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	struct mmsghdr __user *entry;
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
+	LIST_HEAD(list); /* List for finding duplicated destination address. */
 
 	datagrams = 0;
 
@@ -2014,18 +2079,19 @@ int __sys_sendmmsg(int fd, struct mmsghd
 
 	while (datagrams < vlen) {
 		/*
-		 * No need to ask LSM for more than the first datagram.
+		 * No need to ask LSM for more than the first datagram for
+		 * each destination.
 		 */
 		if (MSG_CMSG_COMPAT & flags) {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags, &list);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
 			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags, &list);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
@@ -2038,6 +2104,14 @@ int __sys_sendmmsg(int fd, struct mmsghd
 	}
 
 out_put:
+	{ /* Clean up destination addresses. */
+		struct sendmmsg_dest_info *ptr;
+		struct sendmmsg_dest_info *tmp;
+		list_for_each_entry_safe(ptr, tmp, &list, list) {
+			list_del(&ptr->list);
+			kfree(ptr);
+		}
+	}
 	fput_light(sock->file, fput_needed);
 
 	if (err == 0)
