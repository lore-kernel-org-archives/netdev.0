From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Fri, 11 Aug 2017 18:47:04 +0200
Message-ID: <598DDF88.6020809@iogearbox.net>
References: <59897A7C.10009@iogearbox.net> <20170808.094857.245786887664041622.davem@davemloft.net> <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com> <20170808.145433.1287676484744976417.davem@davemloft.net> <20170809073926.GO6973@jhogan-linux.le.imgtec.org> <598B71C9.7090303@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org,
        mingo@redhat.com, netdev@vger.kernel.org
To: James Hogan <james.hogan@imgtec.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <598B71C9.7090303@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

On 08/09/2017 10:34 PM, Daniel Borkmann wrote:
> On 08/09/2017 09:39 AM, James Hogan wrote:
> [...]
>> time (but please consider looking at the other patch which is certainly
>> a more real issue).
>
> Sorry for the delay, started looking into that and whether we
> have some other options, I'll get back to you on this.

Could we solve this more generically (as in: originally intended) in
the sense that we don't need to trust the gcc va_list handling; I feel
this is relying on an implementation detail? Perhaps something like
below poc patch?

Thanks again,
Daniel

 From 71f16544d455abb6bb82f7253c17c14d2a395e91 Mon Sep 17 00:00:00 2001
Message-Id: <71f16544d455abb6bb82f7253c17c14d2a395e91.1502469361.git.daniel@iogearbox.net>
From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 11 Aug 2017 15:56:32 +0200
Subject: [PATCH] bpf: fix bpf_trace_printk on 32 bit

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
  kernel/trace/bpf_trace.c | 31 +++++++++++++++++++++++++++----
  1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3738519..d4cb36f 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -204,10 +204,33 @@ static const struct bpf_func_proto *bpf_get_probe_write_proto(void)
  		fmt_cnt++;
  	}

-	return __trace_printk(1/* fake ip will not be printed */, fmt,
-			      mod[0] == 2 ? arg1 : mod[0] == 1 ? (long) arg1 : (u32) arg1,
-			      mod[1] == 2 ? arg2 : mod[1] == 1 ? (long) arg2 : (u32) arg2,
-			      mod[2] == 2 ? arg3 : mod[2] == 1 ? (long) arg3 : (u32) arg3);
+#define __BPF_TP_EMIT()	__BPF_ARG3_TP()
+#define __BPF_TP(...)							\
+	__trace_printk(1 /* fake ip will not be printed */,		\
+		       fmt, ##__VA_ARGS__)
+
+#define __BPF_ARG1_TP(...)						\
+	((mod[0] == 2 || (mod[0] == 1 && __BITS_PER_LONG == 64))	\
+	  ? __BPF_TP(arg1, ##__VA_ARGS__)				\
+	  : ((mod[0] == 1 || (mod[0] == 0 && __BITS_PER_LONG == 32))	\
+	      ? __BPF_TP((long)arg1, ##__VA_ARGS__)			\
+	      : __BPF_TP((u32)arg1, ##__VA_ARGS__)))
+
+#define __BPF_ARG2_TP(...)						\
+	((mod[1] == 2 || (mod[1] == 1 && __BITS_PER_LONG == 64))	\
+	  ? __BPF_ARG1_TP(arg2, ##__VA_ARGS__)				\
+	  : ((mod[1] == 1 || (mod[1] == 0 && __BITS_PER_LONG == 32))	\
+	      ? __BPF_ARG1_TP((long)arg2, ##__VA_ARGS__)		\
+	      : __BPF_ARG1_TP((u32)arg2, ##__VA_ARGS__)))
+
+#define __BPF_ARG3_TP(...)						\
+	((mod[2] == 2 || (mod[2] == 1 && __BITS_PER_LONG == 64))	\
+	  ? __BPF_ARG2_TP(arg3, ##__VA_ARGS__)				\
+	  : ((mod[2] == 1 || (mod[2] == 0 && __BITS_PER_LONG == 32))	\
+	      ? __BPF_ARG2_TP((long)arg3, ##__VA_ARGS__)		\
+	      : __BPF_ARG2_TP((u32)arg3, ##__VA_ARGS__)))
+
+	return __BPF_TP_EMIT();
  }

  static const struct bpf_func_proto bpf_trace_printk_proto = {
-- 
1.9.3
