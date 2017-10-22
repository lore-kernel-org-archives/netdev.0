From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next] selftests/bpf: fix broken build of test_maps
Date: Sun, 22 Oct 2017 10:29:06 -0700
Message-ID: <20171022172906.3131400-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Lawrence Brakmo <brakmo@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50060 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751497AbdJVR3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 13:29:08 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9MHPLIJ019395
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 10:29:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dr1jd2jve-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 10:29:07 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix multiple build errors and warnings

1.
test_maps.c: In function =E2=80=98test_map_rdonly=E2=80=99:
test_maps.c:1051:30: error: =E2=80=98BPF_F_RDONLY=E2=80=99 undeclared (fi=
rst use in this function)
        MAP_SIZE, map_flags | BPF_F_RDONLY);

2.
test_maps.c:1048:6: warning: unused variable =E2=80=98i=E2=80=99 [-Wunuse=
d-variable]
  int i, fd, key =3D 0, value =3D 0;

3.
test_maps.c:1087:2: error: called object is not a function or function po=
inter
  assert(bpf_map_lookup_elem(fd, &key, &value) =3D=3D -1 && errno =3D=3D =
EPERM);

4.
./bpf_helpers.h:72:11: error: use of undeclared identifier 'BPF_FUNC_gets=
ockopt'
        (void *) BPF_FUNC_getsockopt;

Fixes: e043325b3087 ("bpf: Add tests for eBPF file mode")
Fixes: 6e71b04a8224 ("bpf: Add file mode configuration into bpf maps")
Fixes: cd86d1fd2102 ("bpf: Adding helper function bpf_getsockops")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/include/uapi/linux/bpf.h          | 62 +++++++++++++++++++++++++++=
+-----
 tools/testing/selftests/bpf/test_maps.c |  6 ++--
 2 files changed, 57 insertions(+), 11 deletions(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bp=
f.h
index 850a5497dcc3..f650346aaa1a 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -218,6 +218,10 @@ enum bpf_attach_type {
=20
 #define BPF_OBJ_NAME_LEN 16U
=20
+/* Flags for accessing BPF object */
+#define BPF_F_RDONLY		(1U << 3)
+#define BPF_F_WRONLY		(1U << 4)
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -260,6 +264,7 @@ union bpf_attr {
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
 		__aligned_u64	pathname;
 		__u32		bpf_fd;
+		__u32		file_flags;
 	};
=20
 	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
@@ -287,6 +292,7 @@ union bpf_attr {
 			__u32		map_id;
 		};
 		__u32		next_id;
+		__u32		open_flags;
 	};
=20
 	struct { /* anonymous struct used by BPF_OBJ_GET_INFO_BY_FD */
@@ -607,12 +613,22 @@ union bpf_attr {
  * int bpf_setsockopt(bpf_socket, level, optname, optval, optlen)
  *     Calls setsockopt. Not all opts are available, only those with
  *     integer optvals plus TCP_CONGESTION.
- *     Supported levels: SOL_SOCKET and IPROTO_TCP
+ *     Supported levels: SOL_SOCKET and IPPROTO_TCP
  *     @bpf_socket: pointer to bpf_socket
- *     @level: SOL_SOCKET or IPROTO_TCP
+ *     @level: SOL_SOCKET or IPPROTO_TCP
  *     @optname: option name
  *     @optval: pointer to option value
- *     @optlen: length of optval in byes
+ *     @optlen: length of optval in bytes
+ *     Return: 0 or negative error
+ *
+ * int bpf_getsockopt(bpf_socket, level, optname, optval, optlen)
+ *     Calls getsockopt. Not all opts are available.
+ *     Supported levels: IPPROTO_TCP
+ *     @bpf_socket: pointer to bpf_socket
+ *     @level: IPPROTO_TCP
+ *     @optname: option name
+ *     @optval: pointer to option value
+ *     @optlen: length of optval in bytes
  *     Return: 0 or negative error
  *
  * int bpf_skb_adjust_room(skb, len_diff, mode, flags)
@@ -623,10 +639,9 @@ union bpf_attr {
  *     @flags: reserved for future use
  *     Return: 0 on success or negative error code
  *
- * int bpf_sk_redirect_map(skb, map, key, flags)
+ * int bpf_sk_redirect_map(map, key, flags)
  *     Redirect skb to a sock in map using key as a lookup key for the
  *     sock in map.
- *     @skb: pointer to skb
  *     @map: pointer to sockmap
  *     @key: key to lookup sock in map
  *     @flags: reserved for future use
@@ -643,6 +658,21 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data_m=
eta
  *     Return: 0 on success or negative on error
+ *
+ * int bpf_perf_event_read_value(map, flags, buf, buf_size)
+ *     read perf event counter value and perf event enabled/running time
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     @buf: buf to fill
+ *     @buf_size: size of the buf
+ *     Return: 0 on success or negative error code
+ *
+ * int bpf_perf_prog_read_value(ctx, buf, buf_size)
+ *     read perf prog attached perf event counter and enabled/running ti=
me
+ *     @ctx: pointer to ctx
+ *     @buf: buf to fill
+ *     @buf_size: size of the buf
+ *     Return : 0 on success or negative error code
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -701,7 +731,8 @@ union bpf_attr {
 	FN(sock_map_update),		\
 	FN(xdp_adjust_meta),		\
 	FN(perf_event_read_value),	\
-	FN(perf_prog_read_value),
+	FN(perf_prog_read_value),	\
+	FN(getsockopt),
=20
 /* integer value in 'imm' field of BPF_CALL instruction selects which he=
lper
  * function eBPF program intends to call
@@ -745,7 +776,9 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
=20
-/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
+/* BPF_FUNC_perf_event_output, BPF_FUNC_perf_event_read and
+ * BPF_FUNC_perf_event_read_value flags.
+ */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
 /* BPF_FUNC_perf_event_output for sk_buff input context. */
@@ -873,7 +906,7 @@ struct bpf_prog_info {
 	__u32 created_by_uid;
 	__u32 nr_map_ids;
 	__aligned_u64 map_ids;
-	char  name[BPF_OBJ_NAME_LEN];
+	char name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
=20
 struct bpf_map_info {
@@ -933,9 +966,22 @@ enum {
 	BPF_SOCK_OPS_NEEDS_ECN,		/* If connection's congestion control
 					 * needs ECN
 					 */
+	BPF_SOCK_OPS_BASE_RTT,		/* Get base RTT. The correct value is
+					 * based on the path and may be
+					 * dependent on the congestion control
+					 * algorithm. In general it indicates
+					 * a congestion threshold. RTTs above
+					 * this indicate congestion
+					 */
 };
=20
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
=20
+struct bpf_perf_event_value {
+	__u64 counter;
+	__u64 enabled;
+	__u64 running;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/self=
tests/bpf/test_maps.c
index 057da0cba517..040356ecc862 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -1045,7 +1045,7 @@ static void test_map_parallel(void)
=20
 static void test_map_rdonly(void)
 {
-	int i, fd, key =3D 0, value =3D 0;
+	int fd, key =3D 0, value =3D 0;
=20
 	fd =3D bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    MAP_SIZE, map_flags | BPF_F_RDONLY);
@@ -1068,7 +1068,7 @@ static void test_map_rdonly(void)
=20
 static void test_map_wronly(void)
 {
-	int i, fd, key =3D 0, value =3D 0;
+	int fd, key =3D 0, value =3D 0;
=20
 	fd =3D bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    MAP_SIZE, map_flags | BPF_F_WRONLY);
@@ -1081,7 +1081,7 @@ static void test_map_wronly(void)
 	key =3D 1;
 	value =3D 1234;
 	/* Insert key=3D1 element. */
-	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) =3D=3D 0)
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) =3D=3D 0);
=20
 	/* Check that key=3D2 is not found. */
 	assert(bpf_map_lookup_elem(fd, &key, &value) =3D=3D -1 && errno =3D=3D =
EPERM);
--=20
2.9.5
