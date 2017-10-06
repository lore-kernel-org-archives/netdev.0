From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] samples/bpf: xdp_monitor first 8 bytes are not
 accessible by bpf
Date: Fri, 06 Oct 2017 10:41:41 +0200
Message-ID: <150727930151.4460.3117254071267380300.stgit@firesoul>
References: <150727927390.4460.3200093291677318710.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48118 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751811AbdJFIlq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 04:41:46 -0400
In-Reply-To: <150727927390.4460.3200093291677318710.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first 8 bytes of the tracepoint context struct are not accessible
by the bpf code.  This is a choice that dates back to the original
inclusion of this code.

See explaination in:
 commit 98b5c2c65c29 ("perf, bpf: allow bpf programs attach to tracepoints")

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/xdp_monitor_kern.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/samples/bpf/xdp_monitor_kern.c b/samples/bpf/xdp_monitor_kern.c
index 74f3fd8ed729..cc7e19d2ad76 100644
--- a/samples/bpf/xdp_monitor_kern.c
+++ b/samples/bpf/xdp_monitor_kern.c
@@ -17,19 +17,15 @@ struct bpf_map_def SEC("maps") redirect_err_cnt = {
  * Code in:                kernel/include/trace/events/xdp.h
  */
 struct xdp_redirect_ctx {
-	unsigned short common_type;	//	offset:0;  size:2; signed:0;
-	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
-	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
-	int common_pid;			//	offset:4;  size:4; signed:1;
-
-	int prog_id;			//	offset:8;  size:4; signed:1;
-	u32 act;			//	offset:12  size:4; signed:0;
-	int ifindex;			//	offset:16  size:4; signed:1;
-	int err;			//	offset:20  size:4; signed:1;
-	int to_ifindex;			//	offset:24  size:4; signed:1;
-	u32 map_id;			//	offset:28  size:4; signed:0;
-	int map_index;			//	offset:32  size:4; signed:1;
-};					//	offset:36
+	u64 __pad;		// First 8 bytes are not accessible by bpf code
+	int prog_id;		//	offset:8;  size:4; signed:1;
+	u32 act;		//	offset:12  size:4; signed:0;
+	int ifindex;		//	offset:16  size:4; signed:1;
+	int err;		//	offset:20  size:4; signed:1;
+	int to_ifindex;		//	offset:24  size:4; signed:1;
+	u32 map_id;		//	offset:28  size:4; signed:0;
+	int map_index;		//	offset:32  size:4; signed:1;
+};				//	offset:36
 
 enum {
 	XDP_REDIRECT_SUCCESS = 0,
