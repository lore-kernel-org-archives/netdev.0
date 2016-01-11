From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 25/53] perf tools: Introduce bpf-output event
Date: Mon, 11 Jan 2016 13:48:16 +0000
Message-ID: <1452520124-2073-26-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit a43eec304259a6c637f4014a6d4767159b6a3aa3 (bpf: introduce
bpf_perf_event_output() helper) add a helper to enable BPF program
output data to perf ring buffer through a new type of perf event
PERF_COUNT_SW_BPF_OUTPUT. This patch enable perf to create perf
event of that type. Now perf user can use following cmdline to
receive output data from BPF programs:

 # ./perf record -a -e evt=bpf-output/no-inherit/ \
                    -e ./test_bpf_output.c/maps:channel.event=evt/ ls /
 # ./perf script
	perf 12927 [004] 355971.129276:          0 evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write
	perf 12927 [004] 355971.129279:          0 evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write
	...

Test result:
 # cat ./test_bpf_output.c
 /************************ BEGIN **************************/
 #include <uapi/linux/bpf.h>
 struct bpf_map_def {
 	unsigned int type;
 	unsigned int key_size;
 	unsigned int value_size;
 	unsigned int max_entries;
 };

 #define SEC(NAME) __attribute__((section(NAME), used))
 static u64 (*ktime_get_ns)(void) =
 	(void *)BPF_FUNC_ktime_get_ns;
 static int (*trace_printk)(const char *fmt, int fmt_size, ...) =
 	(void *)BPF_FUNC_trace_printk;
 static int (*get_smp_processor_id)(void) =
 	(void *)BPF_FUNC_get_smp_processor_id;
 static int (*perf_event_output)(void *, struct bpf_map_def *, int, void *, unsigned long) =
 	(void *)BPF_FUNC_perf_event_output;

 struct bpf_map_def SEC("maps") channel = {
 	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
 	.key_size = sizeof(int),
 	.value_size = sizeof(u32),
 	.max_entries = __NR_CPUS__,
 };

 SEC("func_write=sys_write")
 int func_write(void *ctx)
 {
 	struct {
 		u64 ktime;
 		int cpuid;
 	} __attribute__((packed)) output_data;
 	char error_data[] = "Error: failed to output: %d\n";

 	output_data.cpuid = get_smp_processor_id();
 	output_data.ktime = ktime_get_ns();
 	int err = perf_event_output(ctx, &channel, get_smp_processor_id(),
 				    &output_data, sizeof(output_data));
 	if (err)
 		trace_printk(error_data, sizeof(error_data), err);
 	return 0;
 }
 char _license[] SEC("license") = "GPL";
 int _version SEC("version") = LINUX_VERSION_CODE;
 /************************ END ***************************/

 # ./perf record -a -e evt=bpf-output/no-inherit/ \
                    -e ./test_bpf_output.c/maps:channel.event=evt/ ls /
 # ./perf script | grep ls
              ls  4085 [000] 2746114.230215: evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write (/lib/modules/4.3.0-rc4+/build/vmlinux)
              ls  4085 [000] 2746114.230244: evt=bpf-output/no-inherit/:  ffffffff811ed5f1 sys_write (/lib/modules/4.3.0-rc4+/build/vmlinux)

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/bpf-loader.c   | 5 ++---
 tools/perf/util/evsel.c        | 5 +++++
 tools/perf/util/evsel.h        | 8 ++++++++
 tools/perf/util/parse-events.l | 1 +
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/tools/perf/util/bpf-loader.c b/tools/perf/util/bpf-loader.c
index 6c25de8..92b815e 100644
--- a/tools/perf/util/bpf-loader.c
+++ b/tools/perf/util/bpf-loader.c
@@ -1312,13 +1312,12 @@ apply_config_evsel_for_key(const char *name, int map_fd, void *pkey,
 		return -BPF_LOADER_ERRNO__OBJCONF_MAP_EVTINH;
 	}
 
+	if (perf_evsel__is_bpf_output(evsel))
+		check_pass = true;
 	if (attr->type == PERF_TYPE_RAW)
 		check_pass = true;
 	if (attr->type == PERF_TYPE_HARDWARE)
 		check_pass = true;
-	if (attr->type == PERF_TYPE_SOFTWARE &&
-			attr->config == PERF_COUNT_SW_BPF_OUTPUT)
-		check_pass = true;
 	if (!check_pass) {
 		pr_debug("ERROR: Event type is wrong for map %s\n", name);
 		return -BPF_LOADER_ERRNO__OBJCONF_MAP_EVTTYPE;
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index a6b3b07..f1b633e 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -225,6 +225,11 @@ struct perf_evsel *perf_evsel__new_idx(struct perf_event_attr *attr, int idx)
 	if (evsel != NULL)
 		perf_evsel__init(evsel, attr, idx);
 
+	if (perf_evsel__is_bpf_output(evsel)) {
+		evsel->attr.sample_type |= PERF_SAMPLE_RAW;
+		evsel->attr.sample_period = 1;
+	}
+
 	return evsel;
 }
 
diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
index 19885fb..022fcff 100644
--- a/tools/perf/util/evsel.h
+++ b/tools/perf/util/evsel.h
@@ -365,6 +365,14 @@ static inline bool perf_evsel__is_function_event(struct perf_evsel *evsel)
 #undef FUNCTION_EVENT
 }
 
+static inline bool perf_evsel__is_bpf_output(struct perf_evsel *evsel)
+{
+	struct perf_event_attr *attr = &evsel->attr;
+
+	return (attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
+		(attr->type == PERF_TYPE_SOFTWARE);
+}
+
 struct perf_attr_details {
 	bool freq;
 	bool verbose;
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 8bb3437..27d567f 100644
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
