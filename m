From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/2] xdp: add flag to enforce driver mode
Date: Wed, 10 May 2017 03:31:30 +0200
Message-ID: <967d58e9c674d85a743bf47661db1570737ef14e.1494379046.git.daniel@iogearbox.net>
References: <cover.1494379046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54347 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdEJBbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 21:31:36 -0400
In-Reply-To: <cover.1494379046.git.daniel@iogearbox.net>
In-Reply-To: <cover.1494379046.git.daniel@iogearbox.net>
References: <cover.1494379046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit b5cdae3291f7 ("net: Generic XDP") we automatically fall
back to a generic XDP variant if the driver does not support native
XDP. Allow for an option where the user can specify that always the
native XDP variant should be selected and in case it's not supported
by a driver, just bail out.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/if_link.h       | 6 ++++--
 net/core/dev.c                     | 2 ++
 net/core/rtnetlink.c               | 5 +++++
 samples/bpf/xdp1_user.c            | 8 ++++++--
 samples/bpf/xdp_tx_iptunnel_user.c | 7 ++++++-
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8e56ac7..549ac8a 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -888,9 +888,11 @@ enum {
 /* XDP section */
 
 #define XDP_FLAGS_UPDATE_IF_NOEXIST	(1U << 0)
-#define XDP_FLAGS_SKB_MODE		(2U << 0)
+#define XDP_FLAGS_SKB_MODE		(1U << 1)
+#define XDP_FLAGS_DRV_MODE		(1U << 2)
 #define XDP_FLAGS_MASK			(XDP_FLAGS_UPDATE_IF_NOEXIST | \
-					 XDP_FLAGS_SKB_MODE)
+					 XDP_FLAGS_SKB_MODE | \
+					 XDP_FLAGS_DRV_MODE)
 
 enum {
 	IFLA_XDP_UNSPEC,
diff --git a/net/core/dev.c b/net/core/dev.c
index d07aa5f..61443f0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6872,6 +6872,8 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 	ASSERT_RTNL();
 
 	xdp_op = ops->ndo_xdp;
+	if (!xdp_op && (flags & XDP_FLAGS_DRV_MODE))
+		return -EOPNOTSUPP;
 	if (!xdp_op || (flags & XDP_FLAGS_SKB_MODE))
 		xdp_op = generic_xdp_install;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bcb0f610..dda9f16 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2199,6 +2199,11 @@ static int do_setlink(const struct sk_buff *skb,
 				err = -EINVAL;
 				goto errout;
 			}
+			if ((xdp_flags & XDP_FLAGS_SKB_MODE) &&
+			    (xdp_flags & XDP_FLAGS_DRV_MODE)) {
+				err = -EINVAL;
+				goto errout;
+			}
 		}
 
 		if (xdp[IFLA_XDP_FD]) {
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index 378850c..17be9ea 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -62,13 +62,14 @@ static void usage(const char *prog)
 	fprintf(stderr,
 		"usage: %s [OPTS] IFINDEX\n\n"
 		"OPTS:\n"
-		"    -S    use skb-mode\n",
+		"    -S    use skb-mode\n"
+		"    -N    enforce native mode\n",
 		prog);
 }
 
 int main(int argc, char **argv)
 {
-	const char *optstr = "S";
+	const char *optstr = "SN";
 	char filename[256];
 	int opt;
 
@@ -77,6 +78,9 @@ int main(int argc, char **argv)
 		case 'S':
 			xdp_flags |= XDP_FLAGS_SKB_MODE;
 			break;
+		case 'N':
+			xdp_flags |= XDP_FLAGS_DRV_MODE;
+			break;
 		default:
 			usage(basename(argv[0]));
 			return 1;
diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index 92b8bde..631cdcc 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -79,6 +79,8 @@ static void usage(const char *cmd)
 	printf("    -m <dest-MAC> Used in sending the IP Tunneled pkt\n");
 	printf("    -T <stop-after-X-seconds> Default: 0 (forever)\n");
 	printf("    -P <IP-Protocol> Default is TCP\n");
+	printf("    -S use skb-mode\n");
+	printf("    -N enforce native mode\n");
 	printf("    -h Display this help\n");
 }
 
@@ -138,7 +140,7 @@ int main(int argc, char **argv)
 {
 	unsigned char opt_flags[256] = {};
 	unsigned int kill_after_s = 0;
-	const char *optstr = "i:a:p:s:d:m:T:P:Sh";
+	const char *optstr = "i:a:p:s:d:m:T:P:SNh";
 	int min_port = 0, max_port = 0;
 	struct iptnl_info tnl = {};
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
@@ -206,6 +208,9 @@ int main(int argc, char **argv)
 		case 'S':
 			xdp_flags |= XDP_FLAGS_SKB_MODE;
 			break;
+		case 'N':
+			xdp_flags |= XDP_FLAGS_DRV_MODE;
+			break;
 		default:
 			usage(argv[0]);
 			return 1;
-- 
1.9.3
