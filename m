From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/2] samples/bpf: fix XDP_FLAGS_SKB_MODE detach for
 xdp_tx_iptunnel
Date: Mon, 01 May 2017 11:26:20 +0200
Message-ID: <149363078062.17600.11958698183756401134.stgit@firesoul>
References: <149363073213.17600.4480290736818479957.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: dsa@cumulusnetworks.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51818 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S376629AbdEAJ0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 05:26:25 -0400
In-Reply-To: <149363073213.17600.4480290736818479957.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xdp_tx_iptunnel program can be terminated in two ways, after
N-seconds or via Ctrl-C SIGINT.  The SIGINT code path does not
handle detatching the correct XDP program, in-case the program
was attached with XDP_FLAGS_SKB_MODE.

Fix this by storing the XDP flags as a global variable, which is
available for the SIGINT handler function.

Fixes: 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/xdp_tx_iptunnel_user.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index 880dd4aebfa4..92b8bde9337c 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -25,11 +25,12 @@
 #define STATS_INTERVAL_S 2U
 
 static int ifindex = -1;
+static __u32 xdp_flags = 0;
 
 static void int_exit(int sig)
 {
 	if (ifindex > -1)
-		set_link_xdp_fd(ifindex, -1, 0);
+		set_link_xdp_fd(ifindex, -1, xdp_flags);
 	exit(0);
 }
 
@@ -142,7 +143,6 @@ int main(int argc, char **argv)
 	struct iptnl_info tnl = {};
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	struct vip vip = {};
-	__u32 xdp_flags = 0;
 	char filename[256];
 	int opt;
 	int i;
