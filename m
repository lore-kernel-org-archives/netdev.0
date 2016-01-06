From: Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] rfcomm: fix information leak in rfcomm_sock_bind
Date: Tue,  5 Jan 2016 23:36:33 -0500
Message-ID: <1452054993-76111-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, yeongjin.jang-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, insu-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org,
	changwoo-/4noJB3qBVQ3uPMLIKxrzw@public.gmane.org, Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, peter-WaGBZJeGNqdsbIuE7sb01tBPR1lH4CV8@public.gmane.org,
	jaganath.k-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

if addr_len < sizeof(sa), sa.rc_bdaddr(4bytes) can be leaked 
by using rfcomm_sock_getname()

Signed-off-by: Insu Yun <wuninsu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/bluetooth/rfcomm/sock.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 7511df7..d61dfdc 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -336,14 +336,15 @@ static int rfcomm_sock_bind(struct socket *sock, struct sockaddr *addr, int addr
 {
 	struct sockaddr_rc sa;
 	struct sock *sk = sock->sk;
-	int len, err = 0;
+	int err = 0;
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
-	memset(&sa, 0, sizeof(sa));
-	len = min_t(unsigned int, sizeof(sa), addr_len);
-	memcpy(&sa, addr, len);
+	if (addr_len != sizeof(sa))
+		return -EINVAL;
+
+	memcpy(&sa, addr, addr_len);
 
 	BT_DBG("sk %p %pMR", sk, &sa.rc_bdaddr);
 
-- 
1.9.1
