From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: [PATCH] caif: Add sockaddr length check before accessing sa_family in connect handler
Date: Tue, 13 Jun 2017 20:06:12 +0200
Message-ID: <20170613180612.11630-1-mjurczyk@google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Verify that the caller-provided sockaddr structure is large enough to
contain the sa_family field, before accessing it in the connect()
handler of the AF_CAIF socket. Since the syscall doesn't enforce a minimum
size of the corresponding memory region, very short sockaddrs (zero or one
byte long) result in operating on uninitialized memory while referencing
sa_family.

Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
---
 net/caif/caif_socket.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index adcad344c843..21f18ea2fce4 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -754,6 +754,10 @@ static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	lock_sock(sk);
 
+	err = -EINVAL;
+	if (addr_len < offsetofend(struct sockaddr, sa_family))
+		goto out;
+
 	err = -EAFNOSUPPORT;
 	if (uaddr->sa_family != AF_CAIF)
 		goto out;
-- 
2.13.1.508.gb3defc5cc-goog
