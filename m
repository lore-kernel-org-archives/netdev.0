From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: [PATCH] af_unix: Add sockaddr length checks before accessing sa_family in bind and connect handlers
Date: Thu,  8 Jun 2017 11:13:36 +0200
Message-ID: <20170608091336.8274-1-mjurczyk@google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Kees Cook <keescook@chromium.org>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Isaac Boukris <iboukris@gmail.com>,
        Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Verify that the caller-provided sockaddr structure is large enough to
contain the sa_family field, before accessing it in bind() and connect()
handlers of the AF_UNIX socket. Since neither syscall enforces a minimum
size of the corresponding memory region, very short sockaddrs (zero or
one byte long) result in operating on uninitialized memory while
referencing .sa_family.

Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
---
 net/unix/af_unix.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 6a7fe7660551..1a0c961f4ffe 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -999,7 +999,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct path path = { };
 
 	err = -EINVAL;
-	if (sunaddr->sun_family != AF_UNIX)
+	if (addr_len < offsetofend(struct sockaddr_un, sun_family) ||
+	    sunaddr->sun_family != AF_UNIX)
 		goto out;
 
 	if (addr_len == sizeof(short)) {
@@ -1110,6 +1111,10 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	unsigned int hash;
 	int err;
 
+	err = -EINVAL;
+	if (alen < offsetofend(struct sockaddr, sa_family))
+		goto out;
+
 	if (addr->sa_family != AF_UNSPEC) {
 		err = unix_mkname(sunaddr, alen, &hash);
 		if (err < 0)
-- 
2.13.1.508.gb3defc5cc-goog
