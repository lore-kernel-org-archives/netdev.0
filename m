From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/6] misc: replace NIP6_FMT with %p6 format specifier
Date: Tue, 28 Oct 2008 12:53:49 -0700
Message-ID: <1225223629.11483.41.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:47380 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbYJ1Txx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 15:53:53 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2778520wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 12:53:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iscsi_ibft.c changes are almost certainly a bugfix as the
pointer 'ip' is a u8 *, so they never print the last 8 bytes
of the IPv6 address, and the eight bytes they do print have
a zero byte with them in each 16-bit word.

Other than that, this should cause no difference in functionality.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/firmware/iscsi_ibft.c |    4 +---
 drivers/scsi/iscsi_tcp.c      |    2 +-
 fs/lockd/host.c               |    2 +-
 fs/nfs/super.c                |    3 +--
 security/selinux/avc.c        |    2 +-
 5 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/firmware/iscsi_ibft.c b/drivers/firmware/iscsi_ibft.c
index 4353414..0a64720 100644
--- a/drivers/firmware/iscsi_ibft.c
+++ b/drivers/firmware/iscsi_ibft.c
@@ -290,9 +290,7 @@ static ssize_t sprintf_ipaddr(char *buf, u8 *ip)
 		/*
 		 * IPv6
 		 */
-		str += sprintf(str, NIP6_FMT, ntohs(ip[0]), ntohs(ip[1]),
-			       ntohs(ip[2]), ntohs(ip[3]), ntohs(ip[4]),
-			       ntohs(ip[5]), ntohs(ip[6]), ntohs(ip[7]));
+		str += sprintf(str, "%p6", ip);
 	}
 	str += sprintf(str, "\n");
 	return str - buf;
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index ed6c54c..ef929ae 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -1608,7 +1608,7 @@ static int iscsi_tcp_get_addr(struct iscsi_conn *conn, struct socket *sock,
 	case AF_INET6:
 		sin6 = (struct sockaddr_in6 *)addr;
 		spin_lock_bh(&conn->session->lock);
-		sprintf(buf, NIP6_FMT, NIP6(sin6->sin6_addr));
+		sprintf(buf, "%p6", &sin6->sin6_addr);
 		*port = be16_to_cpu(sin6->sin6_port);
 		spin_unlock_bh(&conn->session->lock);
 		break;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 9fd8889..344e6b4 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -122,7 +122,7 @@ static void nlm_display_address(const struct sockaddr *sap,
 			snprintf(buf, len, NIPQUAD_FMT,
 				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
 		else
-			snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
+			snprintf(buf, len, "%p6", &sin6->sin6_addr);
 		break;
 	default:
 		snprintf(buf, len, "unsupported address family");
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f48db67..5fe7721 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -468,8 +468,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	}
 	case AF_INET6: {
 		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-		seq_printf(m, ",mountaddr=" NIP6_FMT,
-				NIP6(sin6->sin6_addr));
+		seq_printf(m, ",mountaddr=%p6", &sin6->sin6_addr);
 		break;
 	}
 	default:
diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index cb30c7e..c91008f 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -495,7 +495,7 @@ static inline void avc_print_ipv6_addr(struct audit_buffer *ab,
 				       char *name1, char *name2)
 {
 	if (!ipv6_addr_any(addr))
-		audit_log_format(ab, " %s=" NIP6_FMT, name1, NIP6(*addr));
+		audit_log_format(ab, " %s=%p6", name1, addr);
 	if (port)
 		audit_log_format(ab, " %s=%d", name2, ntohs(port));
 }
-- 
1.6.0.3.729.g6ea410


