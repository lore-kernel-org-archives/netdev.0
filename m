From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/6] bpf: update bpf.h uapi header for tools
Date: Mon, 25 Sep 2017 02:25:52 +0200
Message-ID: <4bdb49b4387d698443e32b8a6a85414e57ef4de0.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37207 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932906AbdIYA1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:06 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like a couple of updates missed to get carried into tools/include/uapi/,
so copy the bpf.h header as usual to pull in latest updates.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/include/uapi/linux/bpf.h | 45 ++++++++++++++++++++++++++++++------------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 461811e..e43491a 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -143,12 +143,6 @@ enum bpf_attach_type {
 
 #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
 
-enum bpf_sockmap_flags {
-	BPF_SOCKMAP_UNSPEC,
-	BPF_SOCKMAP_STRPARSER,
-	__MAX_BPF_SOCKMAP_FLAG
-};
-
 /* If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
  * to the given target_fd cgroup the descendent cgroup will be able to
  * override effective bpf program that was inherited from this cgroup
@@ -368,9 +362,20 @@ enum bpf_sockmap_flags {
  * int bpf_redirect(ifindex, flags)
  *     redirect to another netdev
  *     @ifindex: ifindex of the net device
- *     @flags: bit 0 - if set, redirect to ingress instead of egress
- *             other bits - reserved
- *     Return: TC_ACT_REDIRECT
+ *     @flags:
+ *	  cls_bpf:
+ *          bit 0 - if set, redirect to ingress instead of egress
+ *          other bits - reserved
+ *	  xdp_bpf:
+ *	    all bits - reserved
+ *     Return: cls_bpf: TC_ACT_REDIRECT on success or TC_ACT_SHOT on error
+ *	       xdp_bfp: XDP_REDIRECT on success or XDP_ABORT on error
+ * int bpf_redirect_map(map, key, flags)
+ *     redirect to endpoint in map
+ *     @map: pointer to dev map
+ *     @key: index in map to lookup
+ *     @flags: --
+ *     Return: XDP_REDIRECT on success or XDP_ABORT on error
  *
  * u32 bpf_get_route_realm(skb)
  *     retrieve a dst's tclassid
@@ -577,6 +582,12 @@ enum bpf_sockmap_flags {
  *	@map: pointer to sockmap to update
  *	@key: key to insert/update sock in map
  *	@flags: same flags as map update elem
+ *
+ * int bpf_xdp_adjust_meta(xdp_md, delta)
+ *     Adjust the xdp_md.data_meta by delta
+ *     @xdp_md: pointer to xdp_md
+ *     @delta: An positive/negative integer to be added to xdp_md.data_meta
+ *     Return: 0 on success or negative on error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -632,7 +643,8 @@ enum bpf_sockmap_flags {
 	FN(skb_adjust_room),		\
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
-	FN(sock_map_update),
+	FN(sock_map_update),		\
+	FN(xdp_adjust_meta),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -710,7 +722,7 @@ struct __sk_buff {
 	__u32 data_end;
 	__u32 napi_id;
 
-	/* accessed by BPF_PROG_TYPE_sk_skb types */
+	/* Accessed by BPF_PROG_TYPE_sk_skb types from here to ... */
 	__u32 family;
 	__u32 remote_ip4;	/* Stored in network byte order */
 	__u32 local_ip4;	/* Stored in network byte order */
@@ -718,6 +730,9 @@ struct __sk_buff {
 	__u32 local_ip6[4];	/* Stored in network byte order */
 	__u32 remote_port;	/* Stored in network byte order */
 	__u32 local_port;	/* stored in host byte order */
+	/* ... here. */
+
+	__u32 data_meta;
 };
 
 struct bpf_tunnel_key {
@@ -753,20 +768,23 @@ struct bpf_sock {
 	__u32 family;
 	__u32 type;
 	__u32 protocol;
+	__u32 mark;
+	__u32 priority;
 };
 
 #define XDP_PACKET_HEADROOM 256
 
 /* User return codes for XDP prog type.
  * A valid XDP program must return one of these defined values. All other
- * return codes are reserved for future use. Unknown return codes will result
- * in packet drop.
+ * return codes are reserved for future use. Unknown return codes will
+ * result in packet drops and a warning via bpf_warn_invalid_xdp_action().
  */
 enum xdp_action {
 	XDP_ABORTED = 0,
 	XDP_DROP,
 	XDP_PASS,
 	XDP_TX,
+	XDP_REDIRECT,
 };
 
 /* user accessible metadata for XDP packet hook
@@ -775,6 +793,7 @@ enum xdp_action {
 struct xdp_md {
 	__u32 data;
 	__u32 data_end;
+	__u32 data_meta;
 };
 
 enum sk_action {
-- 
1.9.3
