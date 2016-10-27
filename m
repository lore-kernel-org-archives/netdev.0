From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] bpf: Print function name in addition to function id
Date: Thu, 27 Oct 2016 11:23:51 +0200
Message-ID: <67466f1b43b8a586bcf63fa1e5e292ed340d515c.1477560166.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:43412 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbcJ0QTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 12:19:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The verifier currently prints raw function ids when printing CALL
instructions or when complaining:

	5: (85) call 23
	unknown func 23

print a meaningful function name instead:

	5: (85) call bpf_redirect#23
	unknown func bpf_redirect#23

Moves the function documentation to a single comment and renames all
helpers names in the list to conform to the bpf_ prefix notation so
they can be greped in the kernel source.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 574 ++++++++++++++++++++++++-----------------------
 kernel/bpf/verifier.c    |  35 ++-
 2 files changed, 316 insertions(+), 293 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 374ef58..e2f38e0 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -143,297 +143,301 @@ union bpf_attr {
 	};
 } __attribute__((aligned(8)));
 
+/* BPF helper function descriptions:
+ *
+ * void *bpf_map_lookup_elem(&map, &key)
+ *     Return: Map value or NULL
+ *
+ * int bpf_map_update_elem(&map, &key, &value, flags)
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_map_delete_elem(&map, &key)
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_probe_read(void *dst, int size, void *src)
+ *     Return: 0 on success or negative error
+ *
+ * u64 bpf_ktime_get_ns(void)
+ *     Return: current ktime
+ *
+ * int bpf_trace_printk(const char *fmt, int fmt_size, ...)
+ *     Return: length of buffer written or negative error
+ *
+ * u32 bpf_prandom_u32(void)
+ *     Return: random value
+ *
+ * u32 bpf_raw_smp_processor_id(void)
+ *     Return: SMP processor ID
+ *
+ * int bpf_skb_store_bytes(skb, offset, from, len, flags)
+ *     store bytes into packet
+ *     @skb: pointer to skb
+ *     @offset: offset within packet from skb->mac_header
+ *     @from: pointer where to copy bytes from
+ *     @len: number of bytes to store into packet
+ *     @flags: bit 0 - if true, recompute skb->csum
+ *             other bits - reserved
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_l3_csum_replace(skb, offset, from, to, flags)
+ *     recompute IP checksum
+ *     @skb: pointer to skb
+ *     @offset: offset within packet where IP checksum is located
+ *     @from: old value of header field
+ *     @to: new value of header field
+ *     @flags: bits 0-3 - size of header field
+ *             other bits - reserved
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_l4_csum_replace(skb, offset, from, to, flags)
+ *     recompute TCP/UDP checksum
+ *     @skb: pointer to skb
+ *     @offset: offset within packet where TCP/UDP checksum is located
+ *     @from: old value of header field
+ *     @to: new value of header field
+ *     @flags: bits 0-3 - size of header field
+ *             bit 4 - is pseudo header
+ *             other bits - reserved
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_tail_call(ctx, prog_array_map, index)
+ *     jump into another BPF program
+ *     @ctx: context pointer passed to next program
+ *     @prog_array_map: pointer to map which type is BPF_MAP_TYPE_PROG_ARRAY
+ *     @index: index inside array that selects specific program to run
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_clone_redirect(skb, ifindex, flags)
+ *     redirect to another netdev
+ *     @skb: pointer to skb
+ *     @ifindex: ifindex of the net device
+ *     @flags: bit 0 - if set, redirect to ingress instead of egress
+ *             other bits - reserved
+ *     Return: 0 on success or negative error
+ *
+ * u64 bpf_get_current_pid_tgid(void)
+ *     Return: current->tgid << 32 | current->pid
+ *
+ * u64 bpf_get_current_uid_gid(void)
+ *     Return: current_gid << 32 | current_uid
+ *
+ * int bpf_get_current_comm(char *buf, int size_of_buf)
+ *     stores current->comm into buf
+ *     Return: 0 on success or negative error
+ *
+ * u32 bpf_get_cgroup_classid(skb)
+ *     retrieve a proc's classid
+ *     @skb: pointer to skb
+ *     Return: classid if != 0
+ *
+ * int bpf_skb_vlan_push(skb, vlan_proto, vlan_tci)
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_skb_vlan_pop(skb)
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_skb_get_tunnel_key(skb, key, size, flags)
+ * int bpf_skb_set_tunnel_key(skb, key, size, flags)
+ *     retrieve or populate tunnel metadata
+ *     @skb: pointer to skb
+ *     @key: pointer to 'struct bpf_tunnel_key'
+ *     @size: size of 'struct bpf_tunnel_key'
+ *     @flags: room for future extensions
+ *     Return: 0 on success or negative error
+ *
+ * u64 bpf_perf_event_read(&map, index)
+ *     Return: Number events read or error code
+ *
+ * int bpf_redirect(ifindex, flags)
+ *     redirect to another netdev
+ *     @ifindex: ifindex of the net device
+ *     @flags: bit 0 - if set, redirect to ingress instead of egress
+ *             other bits - reserved
+ *     Return: TC_ACT_REDIRECT
+ *
+ * u32 bpf_get_route_realm(skb)
+ *     retrieve a dst's tclassid
+ *     @skb: pointer to skb
+ *     Return: realm if != 0
+ *
+ * int bpf_perf_event_output(ctx, map, index, data, size)
+ *     output perf raw sample
+ *     @ctx: struct pt_regs*
+ *     @map: pointer to perf_event_array map
+ *     @index: index of event in the map
+ *     @data: data on stack to be output as raw data
+ *     @size: size of data
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_get_stackid(ctx, map, flags)
+ *     walk user or kernel stack and return id
+ *     @ctx: struct pt_regs*
+ *     @map: pointer to stack_trace map
+ *     @flags: bits 0-7 - numer of stack frames to skip
+ *             bit 8 - collect user stack instead of kernel
+ *             bit 9 - compare stacks by hash only
+ *             bit 10 - if two different stacks hash into the same stackid
+ *                      discard old
+ *             other bits - reserved
+ *     Return: >= 0 stackid on success or negative error
+ *
+ * s64 bpf_csum_diff(from, from_size, to, to_size, seed)
+ *     calculate csum diff
+ *     @from: raw from buffer
+ *     @from_size: length of from buffer
+ *     @to: raw to buffer
+ *     @to_size: length of to buffer
+ *     @seed: optional seed
+ *     Return: csum result or negative error code
+ *
+ * int bpf_skb_get_tunnel_opt(skb, opt, size)
+ *     retrieve tunnel options metadata
+ *     @skb: pointer to skb
+ *     @opt: pointer to raw tunnel option data
+ *     @size: size of @opt
+ *     Return: option size
+ *
+ * int bpf_skb_set_tunnel_opt(skb, opt, size)
+ *     populate tunnel options metadata
+ *     @skb: pointer to skb
+ *     @opt: pointer to raw tunnel option data
+ *     @size: size of @opt
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_skb_change_proto(skb, proto, flags)
+ *     Change protocol of the skb. Currently supported is v4 -> v6,
+ *     v6 -> v4 transitions. The helper will also resize the skb. eBPF
+ *     program is expected to fill the new headers via skb_store_bytes
+ *     and lX_csum_replace.
+ *     @skb: pointer to skb
+ *     @proto: new skb->protocol type
+ *     @flags: reserved
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_skb_change_type(skb, type)
+ *     Change packet type of skb.
+ *     @skb: pointer to skb
+ *     @type: new skb->pkt_type type
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_skb_under_cgroup(skb, map, index)
+ *     Check cgroup2 membership of skb
+ *     @skb: pointer to skb
+ *     @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
+ *     @index: index of the cgroup in the bpf_map
+ *     Return:
+ *       == 0 skb failed the cgroup2 descendant test
+ *       == 1 skb succeeded the cgroup2 descendant test
+ *        < 0 error
+ *
+ * u32 bpf_get_hash_recalc(skb)
+ *     Retrieve and possibly recalculate skb->hash.
+ *     @skb: pointer to skb
+ *     Return: hash
+ *
+ * u64 bpf_get_current_task(void)
+ *     Returns current task_struct
+ *     Return: current
+ *
+ * int bpf_probe_write_user(void *dst, void *src, int len)
+ *     safely attempt to write to a location
+ *     @dst: destination address in userspace
+ *     @src: source address on stack
+ *     @len: number of bytes to copy
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_current_task_under_cgroup(map, index)
+ *     Check cgroup2 membership of current task
+ *     @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
+ *     @index: index of the cgroup in the bpf_map
+ *     Return:
+ *       == 0 current failed the cgroup2 descendant test
+ *       == 1 current succeeded the cgroup2 descendant test
+ *        < 0 error
+ *
+ * int bpf_skb_change_tail(skb, len, flags)
+ *     The helper will resize the skb to the given new size, to be used f.e.
+ *     with control messages.
+ *     @skb: pointer to skb
+ *     @len: new skb length
+ *     @flags: reserved
+ *     Return: 0 on success or negative error
+ *
+ * int bpf_skb_pull_data(skb, len)
+ *     The helper will pull in non-linear data in case the skb is non-linear
+ *     and not all of len are part of the linear section. Only needed for
+ *     read/write with direct packet access.
+ *     @skb: pointer to skb
+ *     @len: len to make read/writeable
+ *     Return: 0 on success or negative error
+ *
+ * s64 bpf_csum_update(skb, csum)
+ *     Adds csum into skb->csum in case of CHECKSUM_COMPLETE.
+ *     @skb: pointer to skb
+ *     @csum: csum to add
+ *     Return: csum on success or negative error
+ *
+ * void bpf_set_hash_invalid(skb)
+ *     Invalidate current skb->hash.
+ *     @skb: pointer to skb
+ *
+ * int bpf_get_numa_node_id()
+ *     Return: Id of current NUMA node.
+ */
+#define __BPF_FUNC_MAPPER(FN)		\
+	FN(unspec),			\
+	FN(map_lookup_elem),		\
+	FN(map_update_elem),		\
+	FN(map_delete_elem),		\
+	FN(probe_read),			\
+	FN(ktime_get_ns),		\
+	FN(trace_printk),		\
+	FN(get_prandom_u32),		\
+	FN(get_smp_processor_id),	\
+	FN(skb_store_bytes),		\
+	FN(l3_csum_replace),		\
+	FN(l4_csum_replace),		\
+	FN(tail_call),			\
+	FN(clone_redirect),		\
+	FN(get_current_pid_tgid),	\
+	FN(get_current_uid_gid),	\
+	FN(get_current_comm),		\
+	FN(get_cgroup_classid),		\
+	FN(skb_vlan_push),		\
+	FN(skb_vlan_pop),		\
+	FN(skb_get_tunnel_key),		\
+	FN(skb_set_tunnel_key),		\
+	FN(perf_event_read),		\
+	FN(redirect),			\
+	FN(get_route_realm),		\
+	FN(perf_event_output),		\
+	FN(skb_load_bytes),		\
+	FN(get_stackid),		\
+	FN(csum_diff),			\
+	FN(skb_get_tunnel_opt),		\
+	FN(skb_set_tunnel_opt),		\
+	FN(skb_change_proto),		\
+	FN(skb_change_type),		\
+	FN(skb_under_cgroup),		\
+	FN(get_hash_recalc),		\
+	FN(get_current_task),		\
+	FN(probe_write_user),		\
+	FN(current_task_under_cgroup),	\
+	FN(skb_change_tail),		\
+	FN(skb_pull_data),		\
+	FN(csum_update),		\
+	FN(set_hash_invalid),		\
+	FN(get_numa_node_id),
+
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
  */
+#define __BPF_ENUM_FN(x) BPF_FUNC_ ## x
 enum bpf_func_id {
-	BPF_FUNC_unspec,
-	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
-	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
-	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
-	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
-	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
-	BPF_FUNC_trace_printk,    /* int bpf_trace_printk(const char *fmt, int fmt_size, ...) */
-	BPF_FUNC_get_prandom_u32, /* u32 prandom_u32(void) */
-	BPF_FUNC_get_smp_processor_id, /* u32 raw_smp_processor_id(void) */
-
-	/**
-	 * skb_store_bytes(skb, offset, from, len, flags) - store bytes into packet
-	 * @skb: pointer to skb
-	 * @offset: offset within packet from skb->mac_header
-	 * @from: pointer where to copy bytes from
-	 * @len: number of bytes to store into packet
-	 * @flags: bit 0 - if true, recompute skb->csum
-	 *         other bits - reserved
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_skb_store_bytes,
-
-	/**
-	 * l3_csum_replace(skb, offset, from, to, flags) - recompute IP checksum
-	 * @skb: pointer to skb
-	 * @offset: offset within packet where IP checksum is located
-	 * @from: old value of header field
-	 * @to: new value of header field
-	 * @flags: bits 0-3 - size of header field
-	 *         other bits - reserved
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_l3_csum_replace,
-
-	/**
-	 * l4_csum_replace(skb, offset, from, to, flags) - recompute TCP/UDP checksum
-	 * @skb: pointer to skb
-	 * @offset: offset within packet where TCP/UDP checksum is located
-	 * @from: old value of header field
-	 * @to: new value of header field
-	 * @flags: bits 0-3 - size of header field
-	 *         bit 4 - is pseudo header
-	 *         other bits - reserved
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_l4_csum_replace,
-
-	/**
-	 * bpf_tail_call(ctx, prog_array_map, index) - jump into another BPF program
-	 * @ctx: context pointer passed to next program
-	 * @prog_array_map: pointer to map which type is BPF_MAP_TYPE_PROG_ARRAY
-	 * @index: index inside array that selects specific program to run
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_tail_call,
-
-	/**
-	 * bpf_clone_redirect(skb, ifindex, flags) - redirect to another netdev
-	 * @skb: pointer to skb
-	 * @ifindex: ifindex of the net device
-	 * @flags: bit 0 - if set, redirect to ingress instead of egress
-	 *         other bits - reserved
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_clone_redirect,
-
-	/**
-	 * u64 bpf_get_current_pid_tgid(void)
-	 * Return: current->tgid << 32 | current->pid
-	 */
-	BPF_FUNC_get_current_pid_tgid,
-
-	/**
-	 * u64 bpf_get_current_uid_gid(void)
-	 * Return: current_gid << 32 | current_uid
-	 */
-	BPF_FUNC_get_current_uid_gid,
-
-	/**
-	 * bpf_get_current_comm(char *buf, int size_of_buf)
-	 * stores current->comm into buf
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_get_current_comm,
-
-	/**
-	 * bpf_get_cgroup_classid(skb) - retrieve a proc's classid
-	 * @skb: pointer to skb
-	 * Return: classid if != 0
-	 */
-	BPF_FUNC_get_cgroup_classid,
-	BPF_FUNC_skb_vlan_push, /* bpf_skb_vlan_push(skb, vlan_proto, vlan_tci) */
-	BPF_FUNC_skb_vlan_pop,  /* bpf_skb_vlan_pop(skb) */
-
-	/**
-	 * bpf_skb_[gs]et_tunnel_key(skb, key, size, flags)
-	 * retrieve or populate tunnel metadata
-	 * @skb: pointer to skb
-	 * @key: pointer to 'struct bpf_tunnel_key'
-	 * @size: size of 'struct bpf_tunnel_key'
-	 * @flags: room for future extensions
-	 * Retrun: 0 on success
-	 */
-	BPF_FUNC_skb_get_tunnel_key,
-	BPF_FUNC_skb_set_tunnel_key,
-	BPF_FUNC_perf_event_read,	/* u64 bpf_perf_event_read(&map, index) */
-	/**
-	 * bpf_redirect(ifindex, flags) - redirect to another netdev
-	 * @ifindex: ifindex of the net device
-	 * @flags: bit 0 - if set, redirect to ingress instead of egress
-	 *         other bits - reserved
-	 * Return: TC_ACT_REDIRECT
-	 */
-	BPF_FUNC_redirect,
-
-	/**
-	 * bpf_get_route_realm(skb) - retrieve a dst's tclassid
-	 * @skb: pointer to skb
-	 * Return: realm if != 0
-	 */
-	BPF_FUNC_get_route_realm,
-
-	/**
-	 * bpf_perf_event_output(ctx, map, index, data, size) - output perf raw sample
-	 * @ctx: struct pt_regs*
-	 * @map: pointer to perf_event_array map
-	 * @index: index of event in the map
-	 * @data: data on stack to be output as raw data
-	 * @size: size of data
-	 * Return: 0 on success
-	 */
-	BPF_FUNC_perf_event_output,
-	BPF_FUNC_skb_load_bytes,
-
-	/**
-	 * bpf_get_stackid(ctx, map, flags) - walk user or kernel stack and return id
-	 * @ctx: struct pt_regs*
-	 * @map: pointer to stack_trace map
-	 * @flags: bits 0-7 - numer of stack frames to skip
-	 *         bit 8 - collect user stack instead of kernel
-	 *         bit 9 - compare stacks by hash only
-	 *         bit 10 - if two different stacks hash into the same stackid
-	 *                  discard old
-	 *         other bits - reserved
-	 * Return: >= 0 stackid on success or negative error
-	 */
-	BPF_FUNC_get_stackid,
-
-	/**
-	 * bpf_csum_diff(from, from_size, to, to_size, seed) - calculate csum diff
-	 * @from: raw from buffer
-	 * @from_size: length of from buffer
-	 * @to: raw to buffer
-	 * @to_size: length of to buffer
-	 * @seed: optional seed
-	 * Return: csum result
-	 */
-	BPF_FUNC_csum_diff,
-
-	/**
-	 * bpf_skb_[gs]et_tunnel_opt(skb, opt, size)
-	 * retrieve or populate tunnel options metadata
-	 * @skb: pointer to skb
-	 * @opt: pointer to raw tunnel option data
-	 * @size: size of @opt
-	 * Return: 0 on success for set, option size for get
-	 */
-	BPF_FUNC_skb_get_tunnel_opt,
-	BPF_FUNC_skb_set_tunnel_opt,
-
-	/**
-	 * bpf_skb_change_proto(skb, proto, flags)
-	 * Change protocol of the skb. Currently supported is
-	 * v4 -> v6, v6 -> v4 transitions. The helper will also
-	 * resize the skb. eBPF program is expected to fill the
-	 * new headers via skb_store_bytes and lX_csum_replace.
-	 * @skb: pointer to skb
-	 * @proto: new skb->protocol type
-	 * @flags: reserved
-	 * Return: 0 on success or negative error
-	 */
-	BPF_FUNC_skb_change_proto,
-
-	/**
-	 * bpf_skb_change_type(skb, type)
-	 * Change packet type of skb.
-	 * @skb: pointer to skb
-	 * @type: new skb->pkt_type type
-	 * Return: 0 on success or negative error
-	 */
-	BPF_FUNC_skb_change_type,
-
-	/**
-	 * bpf_skb_under_cgroup(skb, map, index) - Check cgroup2 membership of skb
-	 * @skb: pointer to skb
-	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
-	 * @index: index of the cgroup in the bpf_map
-	 * Return:
-	 *   == 0 skb failed the cgroup2 descendant test
-	 *   == 1 skb succeeded the cgroup2 descendant test
-	 *    < 0 error
-	 */
-	BPF_FUNC_skb_under_cgroup,
-
-	/**
-	 * bpf_get_hash_recalc(skb)
-	 * Retrieve and possibly recalculate skb->hash.
-	 * @skb: pointer to skb
-	 * Return: hash
-	 */
-	BPF_FUNC_get_hash_recalc,
-
-	/**
-	 * u64 bpf_get_current_task(void)
-	 * Returns current task_struct
-	 * Return: current
-	 */
-	BPF_FUNC_get_current_task,
-
-	/**
-	 * bpf_probe_write_user(void *dst, void *src, int len)
-	 * safely attempt to write to a location
-	 * @dst: destination address in userspace
-	 * @src: source address on stack
-	 * @len: number of bytes to copy
-	 * Return: 0 on success or negative error
-	 */
-	BPF_FUNC_probe_write_user,
-
-	/**
-	 * bpf_current_task_under_cgroup(map, index) - Check cgroup2 membership of current task
-	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
-	 * @index: index of the cgroup in the bpf_map
-	 * Return:
-	 *   == 0 current failed the cgroup2 descendant test
-	 *   == 1 current succeeded the cgroup2 descendant test
-	 *    < 0 error
-	 */
-	BPF_FUNC_current_task_under_cgroup,
-
-	/**
-	 * bpf_skb_change_tail(skb, len, flags)
-	 * The helper will resize the skb to the given new size,
-	 * to be used f.e. with control messages.
-	 * @skb: pointer to skb
-	 * @len: new skb length
-	 * @flags: reserved
-	 * Return: 0 on success or negative error
-	 */
-	BPF_FUNC_skb_change_tail,
-
-	/**
-	 * bpf_skb_pull_data(skb, len)
-	 * The helper will pull in non-linear data in case the
-	 * skb is non-linear and not all of len are part of the
-	 * linear section. Only needed for read/write with direct
-	 * packet access.
-	 * @skb: pointer to skb
-	 * @len: len to make read/writeable
-	 * Return: 0 on success or negative error
-	 */
-	BPF_FUNC_skb_pull_data,
-
-	/**
-	 * bpf_csum_update(skb, csum)
-	 * Adds csum into skb->csum in case of CHECKSUM_COMPLETE.
-	 * @skb: pointer to skb
-	 * @csum: csum to add
-	 * Return: csum on success or negative error
-	 */
-	BPF_FUNC_csum_update,
-
-	/**
-	 * bpf_set_hash_invalid(skb)
-	 * Invalidate current skb>hash.
-	 * @skb: pointer to skb
-	 */
-	BPF_FUNC_set_hash_invalid,
-
-	/**
-	 * bpf_get_numa_node_id()
-	 * Returns the id of the current NUMA node.
-	 */
-	BPF_FUNC_get_numa_node_id,
-
+	__BPF_FUNC_MAPPER(__BPF_ENUM_FN)
 	__BPF_FUNC_MAX_ID,
 };
+#undef __BPF_ENUM_FN
 
 /* All flags used by eBPF helper functions, placed here. */
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 846d7ce..9002575 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -19,6 +19,7 @@
 #include <net/netlink.h>
 #include <linux/file.h>
 #include <linux/vmalloc.h>
+#include <linux/stringify.h>
 
 /* bpf_check() is a static code analyzer that walks eBPF program
  * instruction by instruction and updates register/stack state.
@@ -190,6 +191,22 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_PACKET_END]	= "pkt_end",
 };
 
+#define __BPF_FUNC_STR_FN(x) [BPF_FUNC_ ## x] = __stringify(bpf_ ## x)
+static const char * const func_id_str[] = {
+	__BPF_FUNC_MAPPER(__BPF_FUNC_STR_FN)
+};
+#undef __BPF_FUNC_STR_FN
+
+static const char *func_id_name(int id)
+{
+	BUILD_BUG_ON(ARRAY_SIZE(func_id_str) != __BPF_FUNC_MAX_ID);
+
+	if (id >= 0 && id < __BPF_FUNC_MAX_ID && func_id_str[id])
+		return func_id_str[id];
+	else
+		return "unknown";
+}
+
 static void print_verifier_state(struct bpf_verifier_state *state)
 {
 	struct bpf_reg_state *reg;
@@ -354,7 +371,8 @@ static void print_bpf_insn(struct bpf_insn *insn)
 		u8 opcode = BPF_OP(insn->code);
 
 		if (opcode == BPF_CALL) {
-			verbose("(%02x) call %d\n", insn->code, insn->imm);
+			verbose("(%02x) call %s#%d\n", insn->code,
+				func_id_name(insn->imm), insn->imm);
 		} else if (insn->code == (BPF_JMP | BPF_JA)) {
 			verbose("(%02x) goto pc%+d\n",
 				insn->code, insn->off);
@@ -1114,8 +1132,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 
 	return 0;
 error:
-	verbose("cannot pass map_type %d into func %d\n",
-		map->map_type, func_id);
+	verbose("cannot pass map_type %d into func %s#%d\n",
+		map->map_type, func_id_name(func_id), func_id);
 	return -EINVAL;
 }
 
@@ -1172,7 +1190,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 
 	/* find function prototype */
 	if (func_id < 0 || func_id >= __BPF_FUNC_MAX_ID) {
-		verbose("invalid func %d\n", func_id);
+		verbose("invalid func %s#%d\n", func_id_name(func_id), func_id);
 		return -EINVAL;
 	}
 
@@ -1180,7 +1198,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 		fn = env->prog->aux->ops->get_func_proto(func_id);
 
 	if (!fn) {
-		verbose("unknown func %d\n", func_id);
+		verbose("unknown func %s#%d\n", func_id_name(func_id), func_id);
 		return -EINVAL;
 	}
 
@@ -1200,7 +1218,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 	 */
 	err = check_raw_mode(fn);
 	if (err) {
-		verbose("kernel subsystem misconfigured func %d\n", func_id);
+		verbose("kernel subsystem misconfigured func %s#%d\n",
+			func_id_name(func_id), func_id);
 		return err;
 	}
 
@@ -1256,8 +1275,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 		regs[BPF_REG_0].map_ptr = meta.map_ptr;
 		regs[BPF_REG_0].id = ++env->id_gen;
 	} else {
-		verbose("unknown return type %d of func %d\n",
-			fn->ret_type, func_id);
+		verbose("unknown return type %d of func %s#%d\n",
+			fn->ret_type, func_id_name(func_id), func_id);
 		return -EINVAL;
 	}
 
-- 
2.7.4
