From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: [PATCH] af_iucv: Move sockaddr length checks to before accessing sa_family in bind and connect handlers
Date: Tue, 13 Jun 2017 19:42:28 +0200
Message-ID: <20170613174228.9218-1-mjurczyk@google.com>
To: Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Verify that the caller-provided sockaddr structure is large enough to
contain the sa_family field, before accessing it in bind() and connect()
handlers of the AF_IUCV socket. Since neither syscall enforces a minimum
size of the corresponding memory region, very short sockaddrs (zero or
one byte long) result in operating on uninitialized memory while
referencing .sa_family.

Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
---
 net/iucv/af_iucv.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 84de7b6326dc..1f63e704ab50 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -716,10 +716,8 @@ static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
 	char uid[9];
 
 	/* Verify the input sockaddr */
-	if (!addr || addr->sa_family != AF_IUCV)
-		return -EINVAL;
-
-	if (addr_len < sizeof(struct sockaddr_iucv))
+	if (!addr || addr_len < sizeof(struct sockaddr_iucv) ||
+	    addr->sa_family != AF_IUCV)
 		return -EINVAL;
 
 	lock_sock(sk);
@@ -863,7 +861,7 @@ static int iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
 	struct iucv_sock *iucv = iucv_sk(sk);
 	int err;
 
-	if (addr->sa_family != AF_IUCV || alen < sizeof(struct sockaddr_iucv))
+	if (alen < sizeof(struct sockaddr_iucv) || addr->sa_family != AF_IUCV)
 		return -EINVAL;
 
 	if (sk->sk_state != IUCV_OPEN && sk->sk_state != IUCV_BOUND)
-- 
2.13.1.508.gb3defc5cc-goog
