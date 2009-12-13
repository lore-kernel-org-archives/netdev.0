From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] Staging: dst: fix 'Client is not allowed' on sparc
Date: Sun, 13 Dec 2009 17:55:47 +0300
Message-ID: <1260716147-1569-1-git-send-email-a.beregalov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sparclinux@vger.kernel.org,
	Alexander Beregalov <a.beregalov@gmail.com>
To: zbr@ioremap.net
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Not for applying, only describe the problem.


There is a warning on sparc
 Kernel unaligned access at TPC[6c0dec] inet_getname+0x4c/0xc0
which goes from
	net/ipv4/af_inet.c:
	int inet_getname(
		...
		*uaddr_len = sizeof(*sin);

sizeof(*sin) is 16, but inet_getname sets sa_data_len to 0.
That is why client is denied to access the device.
inet_getname() does not read uaddr_len, only
writes, so move initialization of sa_data_len after it.
Make struct saddr aligned similar to
struct __kernel_sockaddr_storage. This fixes the warning.

---
 drivers/staging/dst/export.c |    2 +-
 include/linux/dst.h          |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/dst/export.c b/drivers/staging/dst/export.c
index c324230..4644804 100644
--- a/drivers/staging/dst/export.c
+++ b/drivers/staging/dst/export.c
@@ -166,12 +166,12 @@ static struct dst_state *dst_accept_client(struct dst_state *st)
 	}
 	new->socket = sock;
 
-	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);
 	err = kernel_getpeername(sock, (struct sockaddr *)&new->ctl.addr,
 			(int *)&new->ctl.addr.sa_data_len);
 	if (err)
 		goto err_out_put;
 
+	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);	
 	new->permissions = dst_check_permissions(st, new);
 	if (new->permissions == 0) {
 		err = -EPERM;
diff --git a/include/linux/dst.h b/include/linux/dst.h
index e26fed8..454b15a 100644
--- a/include/linux/dst.h
+++ b/include/linux/dst.h
@@ -74,10 +74,10 @@ struct saddr {
 	/* address family, AF_xxx	*/
 	unsigned short		sa_family;
 	/* 14 bytes of protocol address	*/
-	char			sa_data[SADDR_MAX_DATA];
+	char			sa_data[SADDR_MAX_DATA - sizeof(unsigned short)];
 	/* Number of bytes used in sa_data */
 	unsigned short		sa_data_len;
-};
+} __attribute__((aligned(16)));	/* sizeof(struct sockaddr) */
 
 /* Address structure */
 struct dst_network_ctl
-- 
1.6.5.6

