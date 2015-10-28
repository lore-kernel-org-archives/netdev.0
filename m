From: Wang Nan <wangnan0@huawei.com>
Subject: [RFC PATCH net-next 2/4] perf tools: Introduce bpf-output event
Date: Wed, 28 Oct 2015 10:55:03 +0000
Message-ID: <1446029705-199659-3-git-send-email-wangnan0@huawei.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lizefan@huawei.com>, <pi3orama@163.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>
To: <acme@kernel.org>, <ast@kernel.org>, <brendan.d.gregg@gmail.com>,
	<jolsa@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit a43eec304259a6c637f4014a6d4767159b6a3aa3 (bpf: introduce
bpf_perf_event_output() helper) add a helper to enable BPF program
output data to perf ring buffer through a new type of perf event
PERF_COUNT_SW_BPF_OUTPUT. This patch enable perf to create perf
event of that type. Now perf user can use following cmdline to
receive output data from BPF programs:

 # perf record -a -e evt=bpf-output/no-inherit/ \
                  -e ./test_bpf_output.c/maps.bpf-output.event=evt/ ls

 # perf script
	perf 12927 [004] 355971.129276:          0 evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write
	perf 12927 [004] 355971.129279:          0 evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write
	...

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
 tools/perf/util/evsel.c        | 6 ++++++
 tools/perf/util/parse-events.c | 4 ++++
 tools/perf/util/parse-events.l | 1 +
 3 files changed, 11 insertions(+)

diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index 397fb4e..f01defb 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -224,6 +224,12 @@ struct perf_evsel *perf_evsel__new_idx(struct perf_event_attr *attr, int idx)
 	if (evsel != NULL)
 		perf_evsel__init(evsel, attr, idx);
 
+	if ((evsel->attr.type == PERF_TYPE_SOFTWARE) &&
+	    (evsel->attr.config == PERF_COUNT_SW_BPF_OUTPUT)) {
+		evsel->attr.sample_type |= PERF_SAMPLE_RAW;
+		evsel->attr.sample_period = 1;
+	}
+
 	return evsel;
 }
 
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index b98a82c..6ac39d6 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -124,6 +124,10 @@ struct event_symbol event_symbols_sw[PERF_COUNT_SW_MAX] = {
 		.symbol = "dummy",
 		.alias  = "",
 	},
+	[PERF_COUNT_SW_BPF_OUTPUT] = {
+		.symbol = "bpf-output",
+		.alias  = "",
+	},
 };
 
 #define __PERF_EVENT_FIELD(config, name) \
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 1fa8e0b..f4ed79b 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -249,6 +249,7 @@ cpu-migrations|migrations			{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COU
 alignment-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_ALIGNMENT_FAULTS); }
 emulation-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_EMULATION_FAULTS); }
 dummy						{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
+bpf-output					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_BPF_OUTPUT); }
 
 	/*
 	 * We have to handle the kernel PMU event cycles-ct/cycles-t/mem-loads/mem-stores separately.
-- 
1.8.3.4
