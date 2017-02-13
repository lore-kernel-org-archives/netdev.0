From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 14 Feb 2017 09:12:50 +1100
Message-ID: <20170214091250.57d054b2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:39591 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750975AbdBMWMy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 17:12:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

After merging the net tree, today's linux-next build (powerpc64le perf)
failed like this:

Warning: tools/include/uapi/linux/bpf.h differs from kernel
bpf.c: In function 'bpf_prog_attach':
bpf.c:180:6: error: 'union bpf_attr' has no member named 'attach_flags'; did you mean 'map_flags'?
  attr.attach_flags  = flags;
      ^

Caused by commit

  7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE flag")

Unfortunately, the perf header files are kept separate from the kernel
header files proper and are not automatically copied over :-(

I have applied the following build fix patch for today.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 14 Feb 2017 08:22:20 +1100
Subject: [PATCH] bpf: kernel header files need to be copied into the tools directory

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 tools/include/uapi/linux/bpf.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 0eb0e87dbe9f..d2b0ac799d03 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -116,6 +116,12 @@ enum bpf_attach_type {
 
 #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
 
+/* If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
+ * to the given target_fd cgroup the descendent cgroup will be able to
+ * override effective bpf program that was inherited from this cgroup
+ */
+#define BPF_F_ALLOW_OVERRIDE	(1U << 0)
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -171,6 +177,7 @@ union bpf_attr {
 		__u32		target_fd;	/* container object to attach to */
 		__u32		attach_bpf_fd;	/* eBPF program to attach */
 		__u32		attach_type;
+		__u32		attach_flags;
 	};
 } __attribute__((aligned(8)));
 
-- 
2.10.2

-- 
Cheers,
Stephen Rothwell
