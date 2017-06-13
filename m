From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: [PATCH] nfc: Add sockaddr length checks before accessing sa_family in bind handlers
Date: Tue, 13 Jun 2017 18:44:28 +0200
Message-ID: <20170613164428.3643-1-mjurczyk@google.com>
To: Samuel Ortiz <sameo@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Verify that the caller-provided sockaddr structure is large enough to
contain the sa_family field, before accessing it in bind() handlers of the
AF_NFC socket. Since the syscall doesn't enforce a minimum size of the
corresponding memory region, very short sockaddrs (zero or one byte long)
result in operating on uninitialized memory while referencing .sa_family.

Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
---
 net/nfc/llcp_sock.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 2ffb18e73df6..80cf35ed320a 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -77,7 +77,8 @@ static int llcp_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
 	struct sockaddr_nfc_llcp llcp_addr;
 	int len, ret = 0;
 
-	if (!addr || addr->sa_family != AF_NFC)
+	if (!addr || alen < offsetofend(struct sockaddr, sa_family) ||
+	    addr->sa_family != AF_NFC)
 		return -EINVAL;
 
 	pr_debug("sk %p addr %p family %d\n", sk, addr, addr->sa_family);
@@ -151,7 +152,8 @@ static int llcp_raw_sock_bind(struct socket *sock, struct sockaddr *addr,
 	struct sockaddr_nfc_llcp llcp_addr;
 	int len, ret = 0;
 
-	if (!addr || addr->sa_family != AF_NFC)
+	if (!addr || alen < offsetofend(struct sockaddr, sa_family) ||
+	    addr->sa_family != AF_NFC)
 		return -EINVAL;
 
 	pr_debug("sk %p addr %p family %d\n", sk, addr, addr->sa_family);
-- 
2.13.1.508.gb3defc5cc-goog
