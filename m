From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/3] perf: pad raw data samples automatically
Date: Tue, 20 Oct 2015 20:02:33 -0700
Message-ID: <1445396556-4854-2-git-send-email-ast@kernel.org>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445396556-4854-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of WARN_ON in perf_event_output() on unpaded raw samples,
pad them automatically.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/events/core.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index b11756f9b6dc..64754bfecd70 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5286,9 +5286,15 @@ void perf_output_sample(struct perf_output_handle *handle,
 
 	if (sample_type & PERF_SAMPLE_RAW) {
 		if (data->raw) {
-			perf_output_put(handle, data->raw->size);
-			__output_copy(handle, data->raw->data,
-					   data->raw->size);
+			u32 raw_size = data->raw->size;
+			u32 real_size = round_up(raw_size + sizeof(u32),
+						 sizeof(u64)) - sizeof(u32);
+			u64 zero = 0;
+
+			perf_output_put(handle, real_size);
+			__output_copy(handle, data->raw->data, raw_size);
+			if (real_size - raw_size)
+				__output_copy(handle, &zero, real_size - raw_size);
 		} else {
 			struct {
 				u32	size;
@@ -5420,8 +5426,7 @@ void perf_prepare_sample(struct perf_event_header *header,
 		else
 			size += sizeof(u32);
 
-		WARN_ON_ONCE(size & (sizeof(u64)-1));
-		header->size += size;
+		header->size += round_up(size, sizeof(u64));
 	}
 
 	if (sample_type & PERF_SAMPLE_BRANCH_STACK) {
-- 
1.7.9.5
