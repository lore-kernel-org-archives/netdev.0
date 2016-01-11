From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 26/53] perf data: Support converting data from bpf_perf_event_output()
Date: Mon, 11 Jan 2016 13:48:17 +0000
Message-ID: <1452520124-2073-27-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_perf_event_output() outputs data through sample->raw_data. This
patch adds support to convert those data into CTF. A python script
then can be used to process output data from BPF programs.

Test result:

 # cat ./test_bpf_output_2.c
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

 static inline int __attribute__((always_inline))
 func(void *ctx, int type)
 {
 	struct {
 		u64 ktime;
 		int type;
 	} __attribute__((packed)) output_data;
 	char error_data[] = "Error: failed to output\n";
 	int err;

 	output_data.type = type;
 	output_data.ktime = ktime_get_ns();
 	err = perf_event_output(ctx, &channel, get_smp_processor_id(),
 				&output_data, sizeof(output_data));
 	if (err)
 		trace_printk(error_data, sizeof(error_data));
 	return 0;
 }
 SEC("func_begin=sys_nanosleep")
 int func_begin(void *ctx) {return func(ctx, 1);}
 SEC("func_end=sys_nanosleep%return")
 int func_end(void *ctx) { return func(ctx, 2);}
 char _license[] SEC("license") = "GPL";
 int _version SEC("version") = LINUX_VERSION_CODE;
 /************************* END ***************************/

 # ./perf record -e evt=bpf-output/no-inherit/ \
                 -e ./test_bpf_output_2.c/maps:channel.event=evt/ \
                 usleep 100000
 [ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.012 MB perf.data (2 samples) ]

 # ./perf script
          usleep 14942 92503.198504: evt=bpf-output/no-inherit/:  ffffffff810e0ba1 sys_nanosleep (/lib/modules/4.3.0....
          usleep 14942 92503.298562: evt=bpf-output/no-inherit/:  ffffffff810585e9 kretprobe_trampoline_holder (/lib....

 # ./perf data convert --to-ctf ./out.ctf
 [ perf data convert: Converted 'perf.data' into CTF data './out.ctf' ]
 [ perf data convert: Converted and wrote 0.000 MB (2 samples) ]

 # babeltrace ./out.ctf
 [01:41:43.198504134] (+?.?????????) evt=bpf-output/no-inherit/: { cpu_id = 0 }, { perf_ip = 0xFFFFFFFF810E0BA1, perf_tid = 14942, perf_pid = 14942, perf_id = 1044, raw_len = 3, raw_data = [ [0] = 0x32C0C07B, [1] = 0x5421, [2] = 0x1 ] }
 [01:41:43.298562257] (+0.100058123) evt=bpf-output/no-inherit/: { cpu_id = 0 }, { perf_ip = 0xFFFFFFFF810585E9, perf_tid = 14942, perf_pid = 14942, perf_id = 1044, raw_len = 3, raw_data = [ [0] = 0x38B77FAA, [1] = 0x5421, [2] = 0x2 ] }

 # cat ./test_bpf_output_2.py
 from babeltrace import TraceCollection
 tc = TraceCollection(
 tc.add_trace('./out.ctf', 'ctf')
 d = {1:[], 2:[]}
 for event in tc.events:
     if not event.name.startswith('evt=bpf-output/no-inherit/'):
         continue
     raw_data = event['raw_data']
     (time, type) = ((raw_data[0] + (raw_data[1] << 32)), raw_data[2])
     d[type].append(time)
 print(list(map(lambda i: d[2][i] - d[1][i], range(len(d[1]))))));

 # python3 ./test_bpf_output_2.py
 [100056879]

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/data-convert-bt.c | 112 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 111 insertions(+), 1 deletion(-)

diff --git a/tools/perf/util/data-convert-bt.c b/tools/perf/util/data-convert-bt.c
index 34cd1e4..62ccf8d 100644
--- a/tools/perf/util/data-convert-bt.c
+++ b/tools/perf/util/data-convert-bt.c
@@ -352,6 +352,84 @@ static int add_tracepoint_values(struct ctf_writer *cw,
 	return ret;
 }
 
+static int
+add_bpf_output_values(struct bt_ctf_event_class *event_class,
+		      struct bt_ctf_event *event,
+		      struct perf_sample *sample)
+{
+	struct bt_ctf_field_type *len_type, *seq_type;
+	struct bt_ctf_field *len_field, *seq_field;
+	unsigned int raw_size = sample->raw_size;
+	unsigned int nr_elements = raw_size / sizeof(u32);
+	unsigned int i;
+	int ret;
+
+	if (nr_elements * sizeof(u32) != raw_size)
+		pr_warning("Incorrect raw_size (%u) in bpf output event, skip %lu bytes\n",
+			   raw_size, nr_elements * sizeof(u32) - raw_size);
+
+	len_type = bt_ctf_event_class_get_field_by_name(event_class, "raw_len");
+	len_field = bt_ctf_field_create(len_type);
+	if (!len_field) {
+		pr_err("failed to create 'raw_len' for bpf output event\n");
+		ret = -1;
+		goto put_len_type;
+	}
+
+	ret = bt_ctf_field_unsigned_integer_set_value(len_field, nr_elements);
+	if (ret) {
+		pr_err("failed to set field value for raw_len\n");
+		goto put_len_field;
+	}
+	ret = bt_ctf_event_set_payload(event, "raw_len", len_field);
+	if (ret) {
+		pr_err("failed to set payload to raw_len\n");
+		goto put_len_field;
+	}
+
+	seq_type = bt_ctf_event_class_get_field_by_name(event_class, "raw_data");
+	seq_field = bt_ctf_field_create(seq_type);
+	if (!seq_field) {
+		pr_err("failed to create 'raw_data' for bpf output event\n");
+		ret = -1;
+		goto put_seq_type;
+	}
+
+	ret = bt_ctf_field_sequence_set_length(seq_field, len_field);
+	if (ret) {
+		pr_err("failed to set length of 'raw_data'\n");
+		goto put_seq_field;
+	}
+
+	for (i = 0; i < nr_elements; i++) {
+		struct bt_ctf_field *elem_field =
+			bt_ctf_field_sequence_get_field(seq_field, i);
+
+		ret = bt_ctf_field_unsigned_integer_set_value(elem_field,
+				((u32 *)(sample->raw_data))[i]);
+
+		bt_ctf_field_put(elem_field);
+		if (ret) {
+			pr_err("failed to set raw_data[%d]\n", i);
+			goto put_seq_field;
+		}
+	}
+
+	ret = bt_ctf_event_set_payload(event, "raw_data", seq_field);
+	if (ret)
+		pr_err("failed to set payload for raw_data\n");
+
+put_seq_field:
+	bt_ctf_field_put(seq_field);
+put_seq_type:
+	bt_ctf_field_type_put(seq_type);
+put_len_field:
+	bt_ctf_field_put(len_field);
+put_len_type:
+	bt_ctf_field_type_put(len_type);
+	return ret;
+}
+
 static int add_generic_values(struct ctf_writer *cw,
 			      struct bt_ctf_event *event,
 			      struct perf_evsel *evsel,
@@ -597,6 +675,12 @@ static int process_sample_event(struct perf_tool *tool,
 			return -1;
 	}
 
+	if (perf_evsel__is_bpf_output(evsel)) {
+		ret = add_bpf_output_values(event_class, event, sample);
+		if (ret)
+			return -1;
+	}
+
 	cs = ctf_stream(cw, get_sample_cpu(cw, sample, evsel));
 	if (cs) {
 		if (is_flush_needed(cs))
@@ -744,6 +828,25 @@ static int add_tracepoint_types(struct ctf_writer *cw,
 	return ret;
 }
 
+static int add_bpf_output_types(struct ctf_writer *cw,
+				struct bt_ctf_event_class *class)
+{
+	struct bt_ctf_field_type *len_type = cw->data.u32;
+	struct bt_ctf_field_type *seq_base_type = cw->data.u32_hex;
+	struct bt_ctf_field_type *seq_type;
+	int ret;
+
+	ret = bt_ctf_event_class_add_field(class, len_type, "raw_len");
+	if (ret)
+		return ret;
+
+	seq_type = bt_ctf_field_type_sequence_create(seq_base_type, "raw_len");
+	if (!seq_type)
+		return -1;
+
+	return bt_ctf_event_class_add_field(class, seq_type, "raw_data");
+}
+
 static int add_generic_types(struct ctf_writer *cw, struct perf_evsel *evsel,
 			     struct bt_ctf_event_class *event_class)
 {
@@ -755,7 +858,8 @@ static int add_generic_types(struct ctf_writer *cw, struct perf_evsel *evsel,
 	 *                              ctf event header
 	 *   PERF_SAMPLE_READ         - TODO
 	 *   PERF_SAMPLE_CALLCHAIN    - TODO
-	 *   PERF_SAMPLE_RAW          - tracepoint fields are handled separately
+	 *   PERF_SAMPLE_RAW          - tracepoint fields and BPF output
+	 *                              are handled separately
 	 *   PERF_SAMPLE_BRANCH_STACK - TODO
 	 *   PERF_SAMPLE_REGS_USER    - TODO
 	 *   PERF_SAMPLE_STACK_USER   - TODO
@@ -824,6 +928,12 @@ static int add_event(struct ctf_writer *cw, struct perf_evsel *evsel)
 			goto err;
 	}
 
+	if (perf_evsel__is_bpf_output(evsel)) {
+		ret = add_bpf_output_types(cw, event_class);
+		if (ret)
+			goto err;
+	}
+
 	ret = bt_ctf_stream_class_add_event_class(cw->stream_class, event_class);
 	if (ret) {
 		pr("Failed to add event class into stream.\n");
-- 
1.8.3.4
