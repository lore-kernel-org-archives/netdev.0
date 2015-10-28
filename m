From: Wang Nan <wangnan0@huawei.com>
Subject: [RFC PATCH net-next 4/4] perf data: Support converting data from bpf_perf_event_output()
Date: Wed, 28 Oct 2015 10:55:05 +0000
Message-ID: <1446029705-199659-5-git-send-email-wangnan0@huawei.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lizefan@huawei.com>, <pi3orama@163.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: <acme@kernel.org>, <ast@kernel.org>, <brendan.d.gregg@gmail.com>,
	<jolsa@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_perf_event_output() outputs data through sample->raw_data. This
patch adds support to convert those data into CTF. A python script
then can be used to process output data from BPF programs.

Example:

############ BPF program #############
  struct bpf_map_def SEC("maps") map_channel = {
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
      char error_data[] = "Error: failed to output\n";

      output_data.cpuid = bpf_get_smp_processor_id();
      output_data.ktime = bpf_ktime_get_ns();
      int err = perf_event_output(ctx, &map_channel,
                                  bpf_get_smp_processor_id(),
                                  &output_data, sizeof(output_data));
      if (err)
          bpf_trace_printk(error_data, sizeof(error_data));
      return 0;
  }
  char _license[] SEC("license") = "GPL";
  int _version SEC("version") = 0x40300;

############ cmdline ############
 # perf record -g -e evt=bpf-output/no-inherit/ \
                  -e ./test_bpf_output.c/maps.map_channel.event=evt/ -a ls
 # perf data convert --to-ctf ./out.ctf
 # babeltrace ./out.ctf
 [06:34:00.288671496] (+?.?????????) evt=bpf-output/no-inherit/: { cpu_id = 0 }, { perf_ip = 0xFFFFFFFF811ED5F1, perf_tid = 4469, perf_pid = 4469, perf_id = 3685, raw_len = 3, raw_data = [ [0] = 0xB163D948, [1] = 0x19E6E, [2] = 0x0 ] }
 [06:34:00.288677551] (+0.000006055) evt=bpf-output/no-inherit/: { cpu_id = 0 }, { perf_ip = 0xFFFFFFFF811ED5F1, perf_tid = 4469, perf_pid = 4469, perf_id = 3685, raw_len = 3, raw_data = [ [0] = 0xB163F289, [1] = 0x19E6E, [2] = 0x0 ] }

########### python script #######
 from babeltrace import TraceCollection

 tc = TraceCollection(
 tc.add_trace('./out.ctf', 'ctf')

 for event in tc.events:
     if not event.name.startswith('evt='):
         continue
     raw_data = event['raw_data']
     print(raw_data[0] + raw_data[1] << 32, raw_data[2]));

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
Cc: Jiri Olsa <jolsa@kernel.org>
---
 tools/perf/util/data-convert-bt.c | 115 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 114 insertions(+), 1 deletion(-)

diff --git a/tools/perf/util/data-convert-bt.c b/tools/perf/util/data-convert-bt.c
index 34cd1e4..44d6e0d 100644
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
@@ -597,6 +675,13 @@ static int process_sample_event(struct perf_tool *tool,
 			return -1;
 	}
 
+	if ((evsel->attr.type == PERF_TYPE_SOFTWARE) &&
+	    (evsel->attr.config == PERF_COUNT_SW_BPF_OUTPUT)) {
+		ret = add_bpf_output_values(event_class, event, sample);
+		if (ret)
+			return -1;
+	}
+
 	cs = ctf_stream(cw, get_sample_cpu(cw, sample, evsel));
 	if (cs) {
 		if (is_flush_needed(cs))
@@ -744,6 +829,25 @@ static int add_tracepoint_types(struct ctf_writer *cw,
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
@@ -755,7 +859,8 @@ static int add_generic_types(struct ctf_writer *cw, struct perf_evsel *evsel,
 	 *                              ctf event header
 	 *   PERF_SAMPLE_READ         - TODO
 	 *   PERF_SAMPLE_CALLCHAIN    - TODO
-	 *   PERF_SAMPLE_RAW          - tracepoint fields are handled separately
+	 *   PERF_SAMPLE_RAW          - tracepoint fields and BPF output
+	 *                              are handled separately
 	 *   PERF_SAMPLE_BRANCH_STACK - TODO
 	 *   PERF_SAMPLE_REGS_USER    - TODO
 	 *   PERF_SAMPLE_STACK_USER   - TODO
@@ -824,6 +929,14 @@ static int add_event(struct ctf_writer *cw, struct perf_evsel *evsel)
 			goto err;
 	}
 
+	if ((evsel->attr.type == PERF_TYPE_SOFTWARE) &&
+	    (evsel->attr.config == PERF_COUNT_SW_BPF_OUTPUT)) {
+		ret = add_bpf_output_types(cw, event_class);
+		if (ret)
+			goto err;
+
+	}
+
 	ret = bt_ctf_stream_class_add_event_class(cw->stream_class, event_class);
 	if (ret) {
 		pr("Failed to add event class into stream.\n");
-- 
1.8.3.4
