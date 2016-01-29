From: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 net] nfc: close a race condition in llcp_sock_getname()
Date: Fri, 29 Jan 2016 11:37:40 -0800
Message-ID: <1454096260-20396-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

llcp_sock_getname() checks llcp_sock->dev to make sure
llcp_sock is already connected or bound, however, we could
be in the middle of llcp_sock_bind() where llcp_sock->dev
is bound and llcp_sock->service_name_len is set,
but llcp_sock->service_name is not, in this case we would
lead to copy some bytes from a NULL pointer.

Just lock the sock since this is not a hot path anyway.

Reported-by: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
Cc: Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Signed-off-by: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/nfc/llcp_sock.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index ecf0a01..b9edf5f 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -509,6 +509,11 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
 	memset(llcp_addr, 0, sizeof(*llcp_addr));
 	*len = sizeof(struct sockaddr_nfc_llcp);
 
+	lock_sock(sk);
+	if (!llcp_sock->dev) {
+		release_sock(sk);
+		return -EBADFD;
+	}
 	llcp_addr->sa_family = AF_NFC;
 	llcp_addr->dev_idx = llcp_sock->dev->idx;
 	llcp_addr->target_idx = llcp_sock->target_idx;
@@ -518,6 +523,7 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
 	llcp_addr->service_name_len = llcp_sock->service_name_len;
 	memcpy(llcp_addr->service_name, llcp_sock->service_name,
 	       llcp_addr->service_name_len);
+	release_sock(sk);
 
 	return 0;
 }
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
