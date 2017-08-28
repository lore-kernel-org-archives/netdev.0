From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 4/9] bpf: additional sockmap self tests
Date: Mon, 28 Aug 2017 07:11:05 -0700
Message-ID: <20170828141105.14143.31609.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37522 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdH1OLT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:11:19 -0400
Received: by mail-pf0-f194.google.com with SMTP id a2so391444pfj.4
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:11:19 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some more sockmap tests to cover,

 - forwarding to NULL entries
 - more than two maps to test list ops
 - forwarding to different map

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/sockmap_parse_prog.c   |    6 +
 tools/testing/selftests/bpf/sockmap_verdict_prog.c |   23 +++-
 tools/testing/selftests/bpf/test_maps.c            |  113 +++++++++++++-------
 3 files changed, 96 insertions(+), 46 deletions(-)

diff --git a/tools/testing/selftests/bpf/sockmap_parse_prog.c b/tools/testing/selftests/bpf/sockmap_parse_prog.c
index 710f43f..fae3b96 100644
--- a/tools/testing/selftests/bpf/sockmap_parse_prog.c
+++ b/tools/testing/selftests/bpf/sockmap_parse_prog.c
@@ -19,16 +19,16 @@ int bpf_prog1(struct __sk_buff *skb)
 	void *data = (void *)(long) skb->data;
 	__u32 lport = skb->local_port;
 	__u32 rport = skb->remote_port;
-	char *d = data;
+	__u8 *d = data;
 
-	if (data + 8 > data_end)
+	if (data + 10 > data_end)
 		return skb->len;
 
 	/* This write/read is a bit pointless but tests the verifier and
 	 * strparser handler for read/write pkt data and access into sk
 	 * fields.
 	 */
-	d[0] = 1;
+	d[7] = 1;
 
 	bpf_printk("parse: data[0] = (%u): local_port %i remote %i\n",
 		   d[0], lport, bpf_ntohl(rport));
diff --git a/tools/testing/selftests/bpf/sockmap_verdict_prog.c b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
index 0573c1d..dada207 100644
--- a/tools/testing/selftests/bpf/sockmap_verdict_prog.c
+++ b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
@@ -12,7 +12,14 @@
 				##__VA_ARGS__);			\
 })
 
-struct bpf_map_def SEC("maps") sock_map = {
+struct bpf_map_def SEC("maps") sock_map_rx = {
+	.type = BPF_MAP_TYPE_SOCKMAP,
+	.key_size = sizeof(int),
+	.value_size = sizeof(int),
+	.max_entries = 20,
+};
+
+struct bpf_map_def SEC("maps") sock_map_tx = {
 	.type = BPF_MAP_TYPE_SOCKMAP,
 	.key_size = sizeof(int),
 	.value_size = sizeof(int),
@@ -26,11 +33,15 @@ int bpf_prog2(struct __sk_buff *skb)
 	void *data = (void *)(long) skb->data;
 	__u32 lport = skb->local_port;
 	__u32 rport = skb->remote_port;
-	char *d = data;
+	__u8 *d = data;
+	__u8 sk, map;
 
 	if (data + 8 > data_end)
 		return SK_DROP;
 
+	map = d[0];
+	sk = d[1];
+
 	d[0] = 0xd;
 	d[1] = 0xe;
 	d[2] = 0xa;
@@ -40,9 +51,11 @@ int bpf_prog2(struct __sk_buff *skb)
 	d[6] = 0xe;
 	d[7] = 0xf;
 
-	bpf_printk("verdict: data[0] = (%u): local_port %i remote %i redirect 5\n",
-		   d[0], lport, bpf_ntohl(rport));
-	return bpf_sk_redirect_map(&sock_map, 5, 0);
+	bpf_printk("verdict: data[0] = redir(%u:%u)\n", map, sk);
+
+	if (!map)
+		return bpf_sk_redirect_map(&sock_map_rx, sk, 0);
+	return bpf_sk_redirect_map(&sock_map_tx, sk, 0);
 }
 
 char _license[] SEC("license") = "GPL";
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 6df6e62..0a7f457 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -465,10 +465,10 @@ static void test_sockmap(int task, void *data)
 {
 	int ports[] = {50200, 50201, 50202, 50204};
 	int err, i, fd, sfd[6] = {0xdeadbeef};
-	char buf[] = "hello sockmap user\n";
-	int one = 1, map_fd, s, sc, rc;
+	u8 buf[20] = {0x0, 0x5, 0x3, 0x2, 0x1, 0x0};
+	int one = 1, map_fd_rx, map_fd_tx, s, sc, rc;
 	int parse_prog, verdict_prog;
-	struct bpf_map *bpf_map;
+	struct bpf_map *bpf_map_rx, *bpf_map_tx;
 	struct sockaddr_in addr;
 	struct bpf_object *obj;
 	struct timeval to;
@@ -585,26 +585,38 @@ static void test_sockmap(int task, void *data)
 		goto out_sockmap;
 	}
 
-	bpf_map = bpf_object__find_map_by_name(obj, "sock_map");
-	if (IS_ERR(bpf_map)) {
-		printf("Failed to load map from verdict prog\n");
+	bpf_map_rx = bpf_object__find_map_by_name(obj, "sock_map_rx");
+	if (IS_ERR(bpf_map_rx)) {
+		printf("Failed to load map rx from verdict prog\n");
 		goto out_sockmap;
 	}
 
-	map_fd = bpf_map__fd(bpf_map);
-	if (map_fd < 0) {
+	map_fd_rx = bpf_map__fd(bpf_map_rx);
+	if (map_fd_rx < 0) {
 		printf("Failed to get map fd\n");
 		goto out_sockmap;
 	}
 
-	err = bpf_prog_attach(parse_prog, map_fd,
+	bpf_map_tx = bpf_object__find_map_by_name(obj, "sock_map_tx");
+	if (IS_ERR(bpf_map_tx)) {
+		printf("Failed to load map tx from verdict prog\n");
+		goto out_sockmap;
+	}
+
+	map_fd_tx = bpf_map__fd(bpf_map_tx);
+	if (map_fd_tx < 0) {
+		printf("Failed to get map tx fd\n");
+		goto out_sockmap;
+	}
+
+	err = bpf_prog_attach(parse_prog, map_fd_rx,
 		      BPF_SK_SKB_STREAM_PARSER, 0);
 	if (err) {
 		printf("Failed bpf prog attach\n");
 		goto out_sockmap;
 	}
 
-	err = bpf_prog_attach(verdict_prog, map_fd,
+	err = bpf_prog_attach(verdict_prog, map_fd_rx,
 			      BPF_SK_SKB_STREAM_VERDICT, 0);
 	if (err) {
 		printf("Failed bpf prog attach\n");
@@ -613,9 +625,15 @@ static void test_sockmap(int task, void *data)
 
 	/* Test map update elem afterwards fd lives in fd and map_fd */
 	for (i = 0; i < 6; i++) {
-		err = bpf_map_update_elem(map_fd, &i, &sfd[i], BPF_ANY);
+		err = bpf_map_update_elem(map_fd_rx, &i, &sfd[i], BPF_ANY);
+		if (err) {
+			printf("Failed map_fd_rx update sockmap %i '%i:%i'\n",
+			       err, i, sfd[i]);
+			goto out_sockmap;
+		}
+		err = bpf_map_update_elem(map_fd_tx, &i, &sfd[i], BPF_ANY);
 		if (err) {
-			printf("Failed map_fd update sockmap %i '%i:%i'\n",
+			printf("Failed map_fd_tx update sockmap %i '%i:%i'\n",
 			       err, i, sfd[i]);
 			goto out_sockmap;
 		}
@@ -623,42 +641,61 @@ static void test_sockmap(int task, void *data)
 
 	/* Test map delete elem and remove send/recv sockets */
 	for (i = 2; i < 4; i++) {
-		err = bpf_map_delete_elem(map_fd, &i);
+		err = bpf_map_delete_elem(map_fd_rx, &i);
+		if (err) {
+			printf("Failed delete sockmap rx %i '%i:%i'\n",
+			       err, i, sfd[i]);
+			goto out_sockmap;
+		}
+		err = bpf_map_delete_elem(map_fd_tx, &i);
 		if (err) {
-			printf("Failed delete  sockmap %i '%i:%i'\n",
+			printf("Failed delete sockmap tx %i '%i:%i'\n",
 			       err, i, sfd[i]);
 			goto out_sockmap;
 		}
 	}
 
 	/* Test map send/recv */
-	sc = send(sfd[2], buf, 10, 0);
-	if (sc < 0) {
-		printf("Failed sockmap send\n");
-		goto out_sockmap;
-	}
+	for (i = 0; i < 2; i++) {
+		buf[0] = i;
+		buf[1] = 0x5;
+		sc = send(sfd[2], buf, 20, 0);
+		if (sc < 0) {
+			printf("Failed sockmap send\n");
+			goto out_sockmap;
+		}
 
-	FD_ZERO(&w);
-	FD_SET(sfd[3], &w);
-	to.tv_sec = 1;
-	to.tv_usec = 0;
-	s = select(sfd[3] + 1, &w, NULL, NULL, &to);
-	if (s == -1) {
-		perror("Failed sockmap select()");
-		goto out_sockmap;
-	} else if (!s) {
-		printf("Failed sockmap unexpected timeout\n");
-		goto out_sockmap;
-	}
+		FD_ZERO(&w);
+		FD_SET(sfd[3], &w);
+		to.tv_sec = 1;
+		to.tv_usec = 0;
+		s = select(sfd[3] + 1, &w, NULL, NULL, &to);
+		if (s == -1) {
+			perror("Failed sockmap select()");
+			goto out_sockmap;
+		} else if (!s) {
+			printf("Failed sockmap unexpected timeout\n");
+			goto out_sockmap;
+		}
 
-	if (!FD_ISSET(sfd[3], &w)) {
-		printf("Failed sockmap select/recv\n");
-		goto out_sockmap;
+		if (!FD_ISSET(sfd[3], &w)) {
+			printf("Failed sockmap select/recv\n");
+			goto out_sockmap;
+		}
+
+		rc = recv(sfd[3], buf, sizeof(buf), 0);
+		if (rc < 0) {
+			printf("Failed sockmap recv\n");
+			goto out_sockmap;
+		}
 	}
 
-	rc = recv(sfd[3], buf, sizeof(buf), 0);
-	if (rc < 0) {
-		printf("Failed sockmap recv\n");
+	/* Negative null entry lookup from datapath should be dropped */
+	buf[0] = 1;
+	buf[1] = 12;
+	sc = send(sfd[2], buf, 20, 0);
+	if (sc < 0) {
+		printf("Failed sockmap send\n");
 		goto out_sockmap;
 	}
 
@@ -730,7 +767,7 @@ static void test_sockmap(int task, void *data)
 	for (i = 0; i < 6; i++)
 		close(sfd[i]);
 	close(fd);
-	close(map_fd);
+	close(map_fd_rx);
 	bpf_object__close(obj);
 	return;
 out:
