From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 12/14] samples/tpacket4: added veth support
Date: Tue, 31 Oct 2017 13:41:43 +0100
Message-ID: <20171031124145.9667-13-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:39598 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753298AbdJaMnN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:43:13 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

This commit adds support for running the benchmark using a veth pair.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 samples/tpacket4/tpbench.c | 189 ++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 163 insertions(+), 26 deletions(-)

diff --git a/samples/tpacket4/tpbench.c b/samples/tpacket4/tpbench.c
index 46fb83009e06..2479f182d1b8 100644
--- a/samples/tpacket4/tpbench.c
+++ b/samples/tpacket4/tpbench.c
@@ -65,8 +65,18 @@ enum benchmark_type {
 static enum tpacket_version opt_tpver = PV4;
 static enum benchmark_type opt_bench = BENCH_RXDROP;
 static const char *opt_if = "";
+static int opt_veth;
 static int opt_zerocopy;
 
+static const char *veth_if1 = "vm1";
+static const char *veth_if2 = "vm2";
+
+/* For process synchronization */
+static int shmid;
+volatile unsigned int *sync_var;
+#define SLEEP_STEP 10
+#define MAX_SLEEP (1000000 / (SLEEP_STEP))
+
 struct tpacket2_queue {
 	void *ring;
 
@@ -296,13 +306,53 @@ static void process_swap_mac(void *queue_pair, unsigned int start,
 	}
 }
 
+static unsigned long get_nsecs(void)
+{
+	struct timespec ts;
+
+	clock_gettime(CLOCK_MONOTONIC, &ts);
+	return ts.tv_sec * 1000000000UL + ts.tv_nsec;
+}
+
 static void run_benchmark(const char *interface_name)
 {
 	unsigned int start, end;
 	struct tp2_queue_pair *qp;
 
+	if (opt_veth) {
+		shmid = shmget(14082017, sizeof(unsigned int),
+			       IPC_CREAT | 666);
+		sync_var = shmat(shmid, 0, 0);
+		if (sync_var == (unsigned int *)-1) {
+			printf("You are probably not running as root\n");
+			exit(EXIT_FAILURE);
+		}
+		*sync_var = 0;
+
+		if (fork() == 0) {
+			opt_if = veth_if2;
+			interface_name = veth_if2;
+		} else {
+			unsigned int i;
+
+			/* Wait for child */
+			for (i = 0; *sync_var == 0 && i < MAX_SLEEP; i++)
+				usleep(SLEEP_STEP);
+			if (i >= MAX_SLEEP) {
+				printf("Wait for vm2 timed out. Exiting.\n");
+				exit(EXIT_FAILURE);
+			}
+		}
+	}
+
 	qp = benchmark.configure(interface_name);
 
+	/* Notify parent that interface configuration completed */
+	if (opt_veth && !strcmp(interface_name, "vm2"))
+		*sync_var = 1;
+
+	start_time = get_nsecs();
+
 	for (;;) {
 		for (;;) {
 			benchmark.rx(qp, &start, &end);
@@ -320,14 +370,6 @@ static void run_benchmark(const char *interface_name)
 	}
 }
 
-static unsigned long get_nsecs(void)
-{
-	struct timespec ts;
-
-	clock_gettime(CLOCK_MONOTONIC, &ts);
-	return ts.tv_sec * 1000000000UL + ts.tv_nsec;
-}
-
 static void *tp2_configure(const char *interface_name)
 {
 	int sfd, noqdisc, ret, ver = TPACKET_V2;
@@ -386,6 +428,36 @@ static void *tp2_configure(const char *interface_name)
 	ret = bind(sfd, (struct sockaddr *)&ll, sizeof(ll));
 	lassert(ret == 0);
 
+	if (opt_veth && !strcmp(interface_name, "vm1"))	{
+		struct tpacket2_queue *txq = &tqp->tx;
+		int i;
+
+		for (i = 0; i < opt_veth; i++) {
+			unsigned int idx = txq->last_used_idx &
+				(txq->ring_size - 1);
+			struct tpacket2_hdr *hdr;
+			unsigned int len;
+
+			hdr = (struct tpacket2_hdr *)(txq->ring +
+					     (idx << txq->frame_size_log2));
+			len = gen_eth_frame((char *)hdr + TPACKET2_HDRLEN -
+					    sizeof(struct sockaddr_ll), i + 1);
+			hdr->tp_snaplen = len;
+			hdr->tp_len = len;
+
+			u_smp_wmb();
+
+			hdr->tp_status = TP_STATUS_SEND_REQUEST;
+			txq->last_used_idx++;
+		}
+
+		ret = sendto(sfd, NULL, 0, MSG_DONTWAIT, NULL, 0);
+		if (!(ret >= 0 || errno == EAGAIN || errno == ENOBUFS))
+			lassert(0);
+
+		tx_npkts += opt_veth;
+	}
+
 	setup_tx_frame();
 
 	return tqp;
@@ -556,6 +628,36 @@ static void *tp3_configure(const char *interface_name)
 	ret = bind(sfd, (struct sockaddr *)&ll, sizeof(ll));
 	lassert(ret == 0);
 
+	if (opt_veth && !strcmp(interface_name, "vm1"))	{
+		struct tpacket2_queue *txq = &tqp->tx;
+		int i;
+
+		for (i = 0; i < opt_veth; i++) {
+			unsigned int idx = txq->last_used_idx &
+				(txq->ring_size - 1);
+			struct tpacket3_hdr *hdr;
+			unsigned int len;
+
+			hdr = (struct tpacket3_hdr *)(txq->ring +
+					     (idx << txq->frame_size_log2));
+			len = gen_eth_frame((char *)hdr + TPACKET3_HDRLEN -
+					    sizeof(struct sockaddr_ll), i + 1);
+			hdr->tp_snaplen = len;
+			hdr->tp_len = len;
+
+			u_smp_wmb();
+
+			hdr->tp_status = TP_STATUS_SEND_REQUEST;
+			txq->last_used_idx++;
+		}
+
+		ret = sendto(sfd, NULL, 0, MSG_DONTWAIT, NULL, 0);
+		if (!(ret >= 0 || errno == EAGAIN || errno == ENOBUFS))
+			lassert(0);
+
+		tx_npkts += opt_veth;
+	}
+
 	setup_tx_frame();
 
 	return tqp;
@@ -783,6 +885,28 @@ static inline int tp4q_enqueue(struct tpacket4_queue *q,
 	return 0;
 }
 
+static inline void *tp4_get_data(void *queue_pair, unsigned int idx,
+				 unsigned int *len)
+{
+	struct tp4_queue_pair *qp = (struct tp4_queue_pair *)queue_pair;
+	struct tp4_umem *umem = qp->umem;
+	struct tpacket4_desc *d;
+
+	d = &qp->rx.ring[idx & qp->rx.ring_mask];
+	*len = d->len;
+
+	return (char *)umem->buffer + (d->idx << umem->frame_size_log2)
+		+ d->offset;
+}
+
+static inline void *tp4_get_buffer(void *queue_pair, unsigned int idx)
+{
+	struct tp4_queue_pair *qp = (struct tp4_queue_pair *)queue_pair;
+	struct tp4_umem *umem = qp->umem;
+
+	return (char *)umem->buffer + (idx << umem->frame_size_log2);
+}
+
 static void *tp4_configure(const char *interface_name)
 {
 	int sfd, noqdisc, ret, ver = TPACKET_V4;
@@ -848,7 +972,27 @@ static void *tp4_configure(const char *interface_name)
 		lassert(ret == 0);
 	}
 
-	for (i = 0; i < (tqp->rx.ring_mask + 1)/4; i++) {
+	if (opt_veth >= (tqp->rx.ring_mask + 1)/4) {
+		printf("Veth batch size too large.\n");
+		exit(EXIT_FAILURE);
+	}
+
+	if (opt_veth && !strcmp(interface_name, "vm1"))	{
+		for (i = 0; i < opt_veth; i++) {
+			struct tpacket4_desc desc = {.idx = i};
+			unsigned int len;
+
+			len = gen_eth_frame(tp4_get_buffer(tqp, i), i + 1);
+
+			desc.len = len;
+			ret = tp4q_enqueue(&tqp->tx, &desc, 1);
+			lassert(ret == 0);
+		}
+		ret = sendto(sfd, NULL, 0, MSG_DONTWAIT, NULL, 0);
+		lassert(ret != -1);
+	}
+
+	for (i = opt_veth; i < (tqp->rx.ring_mask + 1)/4; i++) {
 		struct tpacket4_desc desc = {};
 
 		desc.idx = i;
@@ -902,21 +1046,6 @@ static inline void tp4_rx_release(void *queue_pair, unsigned int start,
 	q->num_free = 0;
 }
 
-static inline void *tp4_get_data(void *queue_pair, unsigned int idx,
-				 unsigned int *len)
-{
-	struct tp4_queue_pair *qp = (struct tp4_queue_pair *)queue_pair;
-	struct tp4_umem *umem = qp->umem;
-	struct tpacket4_desc *d;
-
-	d = &qp->rx.ring[idx & qp->rx.ring_mask];
-	*len = d->len;
-
-	return (char *)umem->buffer + (d->idx << umem->frame_size_log2)
-		+ d->offset;
-}
-
-
 static inline unsigned long tp4_get_data_desc(void *queue_pair,
 					      unsigned int idx,
 					      unsigned int *len,
@@ -1126,6 +1255,7 @@ static struct option long_options[] = {
 	{"l2fwd", no_argument, 0, 'l'},
 	{"zerocopy", required_argument, 0, 'z'},
 	{"interface", required_argument, 0, 'i'},
+	{"veth", required_argument, 0, 'e'},
 	{0, 0, 0, 0}
 };
 
@@ -1152,7 +1282,7 @@ static void parse_command_line(int argc, char **argv)
 	opterr = 0;
 
 	for (;;) {
-		c = getopt_long(argc, argv, "v:rtlz:i:", long_options,
+		c = getopt_long(argc, argv, "v:rtlz:i:e:", long_options,
 				&option_index);
 		if (c == -1)
 			break;
@@ -1182,6 +1312,9 @@ static void parse_command_line(int argc, char **argv)
 		case 'i':
 			opt_if = optarg;
 			break;
+		case 'e':
+			opt_veth = atoi(optarg);
+			break;
 		default:
 			usage();
 		}
@@ -1192,6 +1325,11 @@ static void parse_command_line(int argc, char **argv)
 		usage();
 	}
 
+	if (opt_veth) {
+		opt_bench = BENCH_L2FWD;
+		opt_if = veth_if1;
+	}
+
 	ret = if_nametoindex(opt_if);
 	if (!ret) {
 		fprintf(stderr, "ERROR: interface \"%s\" does not exist\n",
@@ -1246,7 +1384,6 @@ int main(int argc, char **argv)
 	parse_command_line(argc, argv);
 	print_benchmark(true);
 	benchmark = *get_benchmark(opt_tpver, opt_bench);
-	start_time = get_nsecs();
 	run_benchmark(opt_if);
 
 	return 0;
-- 
2.11.0
