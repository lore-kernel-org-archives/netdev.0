From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next V2 PATCH 5/5] samples/bpf: add cpumap sample program
 xdp_redirect_cpu
Date: Fri, 29 Sep 2017 20:06:09 -0700
Message-ID: <20170930030607.sk2wzjxxlbhkkt7k@ast-mbp>
References: <150670281423.23765.8984643281418950330.stgit@firesoul>
 <150670287254.23765.608477053861949304.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33358 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbdI3DGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 23:06:13 -0400
Received: by mail-pg0-f65.google.com with SMTP id u136so903576pgc.0
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 20:06:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150670287254.23765.608477053861949304.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 06:34:32PM +0200, Jesper Dangaard Brouer wrote:
> +
> +static __always_inline
> +u16 get_dest_port_ipv4_udp(struct xdp_md *ctx, u64 nh_off)
> +{
> +	void *data_end = (void *)(long)ctx->data_end;
> +	void *data     = (void *)(long)ctx->data;
> +        struct iphdr *iph = data + nh_off;
> +	struct udphdr *udph;
> +	u16 dport;

formatting is off in the above.

> +
> +        if (iph + 1 > data_end)
> +                return 0;
> +	if (!(iph->protocol == IPPROTO_UDP))
> +		return 0;
> +
> +	udph = (void *)(iph + 1);
> +	if (udph + 1 > data_end)
> +		return 0;
> +
> +	dport = ntohs(udph->dest);
> +	return dport;
> +}
> +
> +static __always_inline
> +int get_proto_ipv4(struct xdp_md *ctx, u64 nh_off)
> +{
> +	void *data_end = (void *)(long)ctx->data_end;
> +	void *data     = (void *)(long)ctx->data;
> +        struct iphdr *iph = data + nh_off;
> +
> +        if (iph + 1 > data_end)
> +                return 0;
> +        return iph->protocol;

and here

> +}
> +
> +static __always_inline
> +int get_proto_ipv6(struct xdp_md *ctx, u64 nh_off)
> +{
> +	void *data_end = (void *)(long)ctx->data_end;
> +	void *data     = (void *)(long)ctx->data;
> +        struct ipv6hdr *ip6h = data + nh_off;
> +
> +        if (ip6h + 1 > data_end)
> +                return 0;

and here

> +/*** Trace point code ***/
> +
> +/* Tracepoint format: /sys/kernel/debug/tracing/events/xdp/xdp_redirect/format
> + * Code in:                kernel/include/trace/events/xdp.h
> + */
> +struct xdp_redirect_ctx {
> +	unsigned short common_type;	//	offset:0;  size:2; signed:0;
> +	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
> +	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
> +	int common_pid;			//	offset:4;  size:4; signed:1;

this part is not right. First 8 bytes are not accessible by bpf code.
Please use __u64 pad; or similar here.
Just noticed that samples/bpf/xdp_monitor_kern.c has the same problem.

> +
> +	int prog_id;			//	offset:8;  size:4; signed:1;
> +	u32 act;			//	offset:12  size:4; signed:0;
> +	int ifindex;			//	offset:16  size:4; signed:1;
> +	int err;			//	offset:20  size:4; signed:1;
> +	int to_ifindex;			//	offset:24  size:4; signed:1;
> +	u32 map_id;			//	offset:28  size:4; signed:0;
> +	int map_index;			//	offset:32  size:4; signed:1;
> +};					//	offset:36

the second part of fields is correct.

> +/* Tracepoint format: /sys/kernel/debug/tracing/events/xdp/xdp_exception/format
> + * Code in:                kernel/include/trace/events/xdp.h
> + */
> +struct xdp_exception_ctx {
> +	unsigned short common_type;	//	offset:0;  size:2; signed:0;
> +	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
> +	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
> +	int common_pid;			//	offset:4;  size:4; signed:1;

same problem here.

> +	int prog_id;			//	offset:8;  size:4; signed:1;
> +	u32 act;			//	offset:12; size:4; signed:0;
> +	int ifindex;			//	offset:16; size:4; signed:1;
> +};
> +
> +SEC("tracepoint/xdp/xdp_exception")
> +int trace_xdp_exception(struct xdp_exception_ctx *ctx)
> +{
> +	struct datarec *rec;
> +	u32 key = 0;
> +
> +	rec = bpf_map_lookup_elem(&exception_cnt, &key);
> +	if (!rec)
> +		return 1;
> +	rec->dropped += 1;
> +
> +	return 0;
> +}
> +
> +/* Tracepoint: /sys/kernel/debug/tracing/events/xdp/xdp_cpumap_enqueue/format
> + * Code in:         kernel/include/trace/events/xdp.h
> + */
> +struct cpumap_enqueue_ctx {
> +	unsigned short common_type;	//	offset:0;  size:2; signed:0;
> +	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
> +	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
> +	int common_pid;			//	offset:4;  size:4; signed:1;

and here

> +/* Tracepoint: /sys/kernel/debug/tracing/events/xdp/xdp_cpumap_kthread/format
> + * Code in:         kernel/include/trace/events/xdp.h
> + */
> +struct cpumap_kthread_ctx {
> +	unsigned short common_type;	//	offset:0;  size:2; signed:0;
> +	unsigned char common_flags;	//	offset:2;  size:1; signed:0;
> +	unsigned char common_preempt_count;//	offset:3;  size:1; signed:0;
> +	int common_pid;			//	offset:4;  size:4; signed:1;

and here.

> +int main(int argc, char **argv)
> +{
> +	struct rlimit r = {10 * 1024*1024, RLIM_INFINITY};

extra spaces around * wouldn't hurt

> +	/* Parse commands line args */
> +	while ((opt = getopt_long(argc, argv, "hSd:",
> +				  long_options, &longindex)) != -1) {
> +		switch (opt) {
> +		case 'd':
> +			if (strlen(optarg) >= IF_NAMESIZE) {
> +				fprintf(stderr, "ERR: --dev name too long\n");
> +				goto error;
> +			}
> +			ifname = (char *)&ifname_buf;
> +			strncpy(ifname, optarg, IF_NAMESIZE);
> +			ifindex = if_nametoindex(ifname);
> +			if (ifindex == 0) {
> +				fprintf(stderr,
> +					"ERR: --dev name unknown err(%d):%s\n",
> +					errno, strerror(errno));
> +				goto error;
> +			}
> +			break;
> +		case 's':
> +			interval = atoi(optarg);
> +			break;
> +		case 'S':
> +			xdp_flags |= XDP_FLAGS_SKB_MODE;
> +			break;
> +		case 'D':
> +			debug = true;
> +			break;
> +		case 'z':
> +			use_separators = false;
> +			break;
> +		case 'p':
> +			/* Selecting eBPF prog to load */
> +			prog_num = atoi(optarg);
> +			if (prog_num < 0 || prog_num >= MAX_PROG) {
> +				fprintf(stderr,
> +					"--prognum too large err(%d):%s\n",
> +					errno, strerror(errno));
> +				goto error;
> +			}
> +			break;
> +		case 'c':
> +			/* Add multiple CPUs */
> +			add_cpu = strtoul(optarg, NULL, 0);
> +			if (add_cpu > MAX_CPUS) {
> +				fprintf(stderr,
> +				"--cpu nr too large for cpumap err(%d):%s\n",
> +					errno, strerror(errno));
> +				goto error;
> +			}
> +			create_cpu_entry(add_cpu, qsize, added_cpus, true);
> +			added_cpus++;
> +			break;
> +		case 'q':
> +			qsize = atoi(optarg);
> +			break;
> +		case 'h':
> +		error:
> +		default:
> +			usage(argv);
> +			return EXIT_FAIL_OPTION;

the rest looks good. Nice that it parses cmdline properly
and even has -h flag :)
