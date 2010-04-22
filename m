From: Andrew May <acmay@acmay.org>
Subject: setsockopt with cmsghdr needs COMPAT support?
Date: Wed, 21 Apr 2010 21:45:09 -0700
Message-ID: <20100421214509.48d3764e@mud>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/IZ9rtv+tcV9tEESShFM8LfL"
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from biz61.inmotionhosting.com ([74.124.219.59]:39071 "EHLO
	biz61.inmotionhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab0DVGDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:03:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/IZ9rtv+tcV9tEESShFM8LfL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have a userspace app that is doing an IPv6 IPV6_2292PKTOPTIONS
setsockopt to add an Extension header in a mixed 64 bit/32 bit setup.

It is failing with an EINVAL because it seems the cmsghdr doesn't get
the proper fixup.
This isn't stuff I really look at much but I came up with this hack to
at least get past the error. All my userspace is 32 bits so I just
put in the "#if 1" rather than attempting a runtime check on the socket.

I am not sure if the userspace app is doing something wrong, but it
seems like this is a real problem. The "on the stack" assumption by
the fixup helper seems like it really should be reworked, but I have no
idea how it should be done. And I didn't bother to handle the the
getsockopt function.
Doing a grep I didn't find any other offenders, but I can't say for
sure.

Does anyone have any ideas on the "right" way to fix this, or point out
my flaw?

Thanks.
--MP_/IZ9rtv+tcV9tEESShFM8LfL
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=compat.patch

diff --git a/net/compat.c b/net/compat.c
index ec24d9e..1a6fcb1 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -213,6 +213,7 @@ Efault:
 		sock_kfree_s(sk, kcmsg_base, kcmlen);
 	return err;
 }
+EXPORT_SYMBOL(cmsghdr_from_user_compat_to_kern);
 
 int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *data)
 {
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 33f60fc..3907ce4 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -422,6 +422,11 @@ sticky_done:
 		struct msghdr msg;
 		struct flowi fl;
 		int junk;
+#if 1
+		int compat_alloc = optlen;
+#else
+		int compat_alloc = 0;
+#endif
 
 		fl.fl6_flowlabel = 0;
 		fl.oif = sk->sk_bound_dev_if;
@@ -436,13 +441,29 @@ sticky_done:
 		retv = -EINVAL;
 		if (optlen > 64*1024)
 			break;
-
-		opt = sock_kmalloc(sk, sizeof(*opt) + optlen, GFP_KERNEL);
+		opt = sock_kmalloc(sk, sizeof(*opt) + optlen + compat_alloc,
+				   GFP_KERNEL);
 		retv = -ENOBUFS;
 		if (opt == NULL)
 			break;
 
 		memset(opt, 0, sizeof(*opt));
+#if 1
+		msg.msg_controllen = optlen;
+		msg.msg_control = optval;
+		retv = cmsghdr_from_user_compat_to_kern(&msg, sk, (void*)(opt+1),
+							optlen + compat_alloc );
+
+		printk( KERN_ERR "Cmsghdr conver ret %d len from %d to %d\n",
+			retv, (int)optlen, (int)msg.msg_controllen );
+		if (retv)
+			goto done;
+		if ( msg.msg_control != (opt+1) ){
+			printk( KERN_ERR "cmsg realloc issue???" );
+			/*Screwed*/
+		}
+		opt->tot_len = sizeof(*opt) + msg.msg_controllen;
+#else
 		opt->tot_len = sizeof(*opt) + optlen;
 		retv = -EFAULT;
 		if (copy_from_user(opt+1, optval, optlen))
@@ -450,6 +471,7 @@ sticky_done:
 
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
+#endif
 
 		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk);
 		if (retv)

--MP_/IZ9rtv+tcV9tEESShFM8LfL--
