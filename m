From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] ipv4/ip_sockglue.c: copy msg_control optval from user to kernel space
Date: Fri, 15 Jan 2010 10:24:59 -0700
Message-ID: <201001151024.59482.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757900Ab0AORZG@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv4/ip_sockglue.c: copy msg_control optval from user to kernel space

In do_ip_getsockopt the char __user *optval is used directly in
IP_PKTOPTIONS for the msg.msg_control and not copied from
user to kernel address space. This produces a sparse warning:

warning: incorrect type in assignment (different address spaces)
   expected void *msg_control
   got char [noderef] <asn:1>*optval

Fix this by using copy _from_user to set msg.msg_control.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>

---

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index cafad9b..8065456 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1173,7 +1173,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		if (sk->sk_type != SOCK_STREAM)
 			return -ENOPROTOOPT;
 
-		msg.msg_control = optval;
+		if (copy_from_user(msg.msg_control, optval, len))
+			return -EFAULT;
 		msg.msg_controllen = len;
 		msg.msg_flags = 0;
 
