From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/21] net/atm/ioctl.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:07 -0800
Message-ID: <bb3fb996c810e40d2ce7a248c91e51bb1e51dfae.1264541549.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1484 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab0AZVkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:24 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spacing cleanups
Moved EXPORT_SYMBOL
Mostly 80 column wrapped.
switch/case cleanups

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/ioctl.c |  195 +++++++++++++++++++++++++++----------------------------
 1 files changed, 97 insertions(+), 98 deletions(-)

diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index b75afba..62dc8bf 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -37,6 +37,7 @@ void register_atm_ioctl(struct atm_ioctl *ioctl)
 	list_add_tail(&ioctl->list, &ioctl_list);
 	mutex_unlock(&ioctl_mutex);
 }
+EXPORT_SYMBOL(register_atm_ioctl);
 
 void deregister_atm_ioctl(struct atm_ioctl *ioctl)
 {
@@ -44,129 +45,128 @@ void deregister_atm_ioctl(struct atm_ioctl *ioctl)
 	list_del(&ioctl->list);
 	mutex_unlock(&ioctl_mutex);
 }
-
-EXPORT_SYMBOL(register_atm_ioctl);
 EXPORT_SYMBOL(deregister_atm_ioctl);
 
-static int do_vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg, int compat)
+static int do_vcc_ioctl(struct socket *sock, unsigned int cmd,
+			unsigned long arg, int compat)
 {
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 	int error;
-	struct list_head * pos;
+	struct list_head *pos;
 	void __user *argp = (void __user *)arg;
 
 	vcc = ATM_SD(sock);
 	switch (cmd) {
-		case SIOCOUTQ:
-			if (sock->state != SS_CONNECTED ||
-			    !test_bit(ATM_VF_READY, &vcc->flags)) {
-				error =  -EINVAL;
-				goto done;
-			}
-			error = put_user(sk->sk_sndbuf - sk_wmem_alloc_get(sk),
-					 (int __user *) argp) ? -EFAULT : 0;
+	case SIOCOUTQ:
+		if (sock->state != SS_CONNECTED ||
+		    !test_bit(ATM_VF_READY, &vcc->flags)) {
+			error =  -EINVAL;
+			goto done;
+		}
+		error = put_user(sk->sk_sndbuf - sk_wmem_alloc_get(sk),
+				 (int __user *)argp) ? -EFAULT : 0;
+		goto done;
+	case SIOCINQ:
+	{
+		struct sk_buff *skb;
+
+		if (sock->state != SS_CONNECTED) {
+			error = -EINVAL;
 			goto done;
-		case SIOCINQ:
-			{
-				struct sk_buff *skb;
-
-				if (sock->state != SS_CONNECTED) {
-					error = -EINVAL;
-					goto done;
-				}
-				skb = skb_peek(&sk->sk_receive_queue);
-				error = put_user(skb ? skb->len : 0,
-						 (int __user *)argp) ? -EFAULT : 0;
-				goto done;
-			}
-		case SIOCGSTAMP: /* borrowed from IP */
+		}
+		skb = skb_peek(&sk->sk_receive_queue);
+		error = put_user(skb ? skb->len : 0,
+				 (int __user *)argp) ? -EFAULT : 0;
+		goto done;
+	}
+	case SIOCGSTAMP: /* borrowed from IP */
 #ifdef CONFIG_COMPAT
-			if (compat)
-				error = compat_sock_get_timestamp(sk, argp);
-			else
+		if (compat)
+			error = compat_sock_get_timestamp(sk, argp);
+		else
 #endif
-				error = sock_get_timestamp(sk, argp);
-			goto done;
-		case SIOCGSTAMPNS: /* borrowed from IP */
+			error = sock_get_timestamp(sk, argp);
+		goto done;
+	case SIOCGSTAMPNS: /* borrowed from IP */
 #ifdef CONFIG_COMPAT
-			if (compat)
-				error = compat_sock_get_timestampns(sk, argp);
-			else
+		if (compat)
+			error = compat_sock_get_timestampns(sk, argp);
+		else
 #endif
-				error = sock_get_timestampns(sk, argp);
+			error = sock_get_timestampns(sk, argp);
+		goto done;
+	case ATM_SETSC:
+		if (net_ratelimit())
+			pr_warning("ATM_SETSC is obsolete; used by %s:%d\n",
+				   current->comm, task_pid_nr(current));
+		error = 0;
+		goto done;
+	case ATMSIGD_CTRL:
+		if (!capable(CAP_NET_ADMIN)) {
+			error = -EPERM;
 			goto done;
-		case ATM_SETSC:
-			if (net_ratelimit())
-				pr_warning("ATM_SETSC is obsolete; used by %s:%d\n",
-					   current->comm, task_pid_nr(current));
-			error = 0;
+		}
+		/*
+		 * The user/kernel protocol for exchanging signalling
+		 * info uses kernel pointers as opaque references,
+		 * so the holder of the file descriptor can scribble
+		 * on the kernel... so we should make sure that we
+		 * have the same privileges that /proc/kcore needs
+		 */
+		if (!capable(CAP_SYS_RAWIO)) {
+			error = -EPERM;
 			goto done;
-		case ATMSIGD_CTRL:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			/*
-			 * The user/kernel protocol for exchanging signalling
-			 * info uses kernel pointers as opaque references,
-			 * so the holder of the file descriptor can scribble
-			 * on the kernel... so we should make sure that we
-			 * have the same privileges that /proc/kcore needs
-			 */
-			if (!capable(CAP_SYS_RAWIO)) {
-				error = -EPERM;
-				goto done;
-			}
+		}
 #ifdef CONFIG_COMPAT
-			/* WTF? I don't even want to _think_ about making this
-			   work for 32-bit userspace. TBH I don't really want
-			   to think about it at all. dwmw2. */
-			if (compat) {
-				if (net_ratelimit())
-					pr_warning("32-bit task cannot be atmsigd\n");
-				error = -EINVAL;
-				goto done;
-			}
+		/* WTF? I don't even want to _think_ about making this
+		   work for 32-bit userspace. TBH I don't really want
+		   to think about it at all. dwmw2. */
+		if (compat) {
+			if (net_ratelimit())
+				pr_warning("32-bit task cannot be atmsigd\n");
+			error = -EINVAL;
+			goto done;
+		}
 #endif
-			error = sigd_attach(vcc);
-			if (!error)
-				sock->state = SS_CONNECTED;
+		error = sigd_attach(vcc);
+		if (!error)
+			sock->state = SS_CONNECTED;
+		goto done;
+	case ATM_SETBACKEND:
+	case ATM_NEWBACKENDIF:
+	{
+		atm_backend_t backend;
+		error = get_user(backend, (atm_backend_t __user *)argp);
+		if (error)
 			goto done;
-		case ATM_SETBACKEND:
-		case ATM_NEWBACKENDIF:
-			{
-				atm_backend_t backend;
-				error = get_user(backend, (atm_backend_t __user *) argp);
-				if (error)
-					goto done;
-				switch (backend) {
-					case ATM_BACKEND_PPP:
-						request_module("pppoatm");
-						break;
-					case ATM_BACKEND_BR2684:
-						request_module("br2684");
-						break;
-				}
-			}
-			break;
-		case ATMMPC_CTRL:
-		case ATMMPC_DATA:
-			request_module("mpoa");
-			break;
-		case ATMARPD_CTRL:
-			request_module("clip");
+		switch (backend) {
+		case ATM_BACKEND_PPP:
+			request_module("pppoatm");
 			break;
-		case ATMLEC_CTRL:
-			request_module("lec");
+		case ATM_BACKEND_BR2684:
+			request_module("br2684");
 			break;
+		}
+		break;
+	}
+	case ATMMPC_CTRL:
+	case ATMMPC_DATA:
+		request_module("mpoa");
+		break;
+	case ATMARPD_CTRL:
+		request_module("clip");
+		break;
+	case ATMLEC_CTRL:
+		request_module("lec");
+		break;
 	}
 
 	error = -ENOIOCTLCMD;
 
 	mutex_lock(&ioctl_mutex);
 	list_for_each(pos, &ioctl_list) {
-		struct atm_ioctl * ic = list_entry(pos, struct atm_ioctl, list);
+		struct atm_ioctl *ic = list_entry(pos, struct atm_ioctl, list);
 		if (try_module_get(ic->owner)) {
 			error = ic->ioctl(sock, cmd, arg);
 			module_put(ic->owner);
@@ -185,7 +185,6 @@ done:
 	return error;
 }
 
-
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	return do_vcc_ioctl(sock, cmd, arg, 0);
@@ -288,8 +287,8 @@ static int do_atmif_sioc(struct socket *sock, unsigned int cmd,
 	sioc = compat_alloc_user_space(sizeof(*sioc));
 	sioc32 = compat_ptr(arg);
 
-	if (copy_in_user(&sioc->number, &sioc32->number, 2 * sizeof(int))
-	    || get_user(data, &sioc32->arg))
+	if (copy_in_user(&sioc->number, &sioc32->number, 2 * sizeof(int)) ||
+	    get_user(data, &sioc32->arg))
 		return -EFAULT;
 	datap = compat_ptr(data);
 	if (put_user(datap, &sioc->arg))
-- 
1.6.6.rc0.57.gad7a

