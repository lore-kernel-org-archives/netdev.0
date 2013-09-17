From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [RFC PATCH v2 net-next 2/2] extend OVS to use BPF
	programs on flow miss
Date: Mon, 16 Sep 2013 19:48:39 -0700
Message-ID: <1379386119-4157-3-git-send-email-ast@plumgrid.com>
References: <1379386119-4157-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Xi Wang <xi.wang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1379386119-4157-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Original OVS packet flow:
flow_table_lookup -> flow_miss -> upcall

Original OVS is a cache engine: controller simulates traversal of
network topology and establishes a flow == cached result of the traversal.

Extended OVS:
flow_table_lookup -> flow_miss -> BPF workflow -> upcall (optional)

BPF programs traverse a topology of BPF-bridges/routers/nats/firewalls (plums).
If they cannot do it completely, they can upcall into controller.
Controller can either adjust execution of BPF programs via corresponding
BPF tables or program flows in the main cache engine.

plum is a specific use case of BPF engine
plum stands for Parse Lookup Update Modify
'bpf_load_xxx' functions are used to read data from the packet.
'bpf_table_lookup' to access tables
'bpf_forward' to forward the packet

plums are connected to each other and to ovs-vport's
via OVS_BPF_CMD_CONNECT_PORTS netlink command.

plums can push data to userspace via 'bpf_channel_push_xxx'
functions that utilize ovs upcall mechanism

'bpf_csum_xxx' are helper functions when plum wants to modify the packet

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Signed-off-by: Wei-Chun Chao <weichunc-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/uapi/linux/openvswitch.h |  140 +++++
 net/openvswitch/Makefile         |    7 +-
 net/openvswitch/bpf_callbacks.c  |  295 +++++++++
 net/openvswitch/bpf_plum.c       |  931 +++++++++++++++++++++++++++++
 net/openvswitch/bpf_replicator.c |  155 +++++
 net/openvswitch/bpf_table.c      |  500 ++++++++++++++++
 net/openvswitch/datapath.c       |  102 +++-
 net/openvswitch/datapath.h       |    5 +
 net/openvswitch/dp_bpf.c         | 1228 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/dp_bpf.h         |  160 +++++
 net/openvswitch/dp_notify.c      |    7 +
 net/openvswitch/vport-gre.c      |   10 -
 net/openvswitch/vport-netdev.c   |   15 +-
 net/openvswitch/vport-netdev.h   |    1 +
 net/openvswitch/vport.h          |   10 +
 15 files changed, 3539 insertions(+), 27 deletions(-)
 create mode 100644 net/openvswitch/bpf_callbacks.c
 create mode 100644 net/openvswitch/bpf_plum.c
 create mode 100644 net/openvswitch/bpf_replicator.c
 create mode 100644 net/openvswitch/bpf_table.c
 create mode 100644 net/openvswitch/dp_bpf.c
 create mode 100644 net/openvswitch/dp_bpf.h

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index a74d375..2c308ad7 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -495,4 +495,144 @@ enum ovs_action_attr {
 
 #define OVS_ACTION_ATTR_MAX (__OVS_ACTION_ATTR_MAX - 1)
 
+/* BPFs. */
+
+#define OVS_BPF_FAMILY "ovs_bpf"
+#define OVS_BPF_VERSION 0x1
+
+enum ovs_bpf_cmd {
+	OVS_BPF_CMD_UNSPEC,
+	OVS_BPF_CMD_REGISTER_PLUM,
+	OVS_BPF_CMD_UNREGISTER_PLUM,
+	OVS_BPF_CMD_CONNECT_PORTS,
+	OVS_BPF_CMD_DISCONNECT_PORTS,
+	OVS_BPF_CMD_CLEAR_TABLE_ELEMENTS,
+	OVS_BPF_CMD_DELETE_TABLE_ELEMENT,
+	OVS_BPF_CMD_READ_TABLE_ELEMENT,
+	OVS_BPF_CMD_UPDATE_TABLE_ELEMENT,
+	OVS_BPF_CMD_DEL_REPLICATOR,
+	OVS_BPF_CMD_ADD_PORT_TO_REPLICATOR,
+	OVS_BPF_CMD_DEL_PORT_FROM_REPLICATOR,
+	OVS_BPF_CMD_CHANNEL_PUSH,
+	OVS_BPF_CMD_READ_PORT_STATS,
+	__OVS_BPF_CMD_MAX
+};
+
+#define OVS_BPF_CMD_MAX (__OVS_BPF_CMD_MAX - 1)
+
+enum ovs_bpf_attr {
+	OVS_BPF_ATTR_UNSPEC,
+	OVS_BPF_ATTR_PLUM,          /* struct bpf_image */
+	OVS_BPF_ATTR_UPCALL_PID,    /* u32 Netlink PID to receive upcalls */
+	OVS_BPF_ATTR_PLUM_ID,       /* u32 plum_id */
+	OVS_BPF_ATTR_PORT_ID,       /* u32 port_id */
+	OVS_BPF_ATTR_DEST_PLUM_ID,  /* u32 dest plum_id */
+	OVS_BPF_ATTR_DEST_PORT_ID,  /* u32 dest port_id */
+	OVS_BPF_ATTR_TABLE_ID,      /* u32 table_id */
+	OVS_BPF_ATTR_KEY_OBJ,       /* table key (opaque data) */
+	OVS_BPF_ATTR_LEAF_OBJ,      /* table leaf/element/value (opaque data) */
+	OVS_BPF_ATTR_REPLICATOR_ID, /* u32 replicator_id */
+	OVS_BPF_ATTR_PACKET,        /* packet (opaque data) */
+	OVS_BPF_ATTR_DIRECTION,     /* u32 direction */
+	__OVS_BPF_ATTR_MAX
+};
+
+#define OVS_BPF_ATTR_MAX (__OVS_BPF_ATTR_MAX - 1)
+
+enum ovs_bpf_channel_push_direction {
+	OVS_BPF_OUT_DIR,
+	OVS_BPF_IN_DIR
+};
+
+struct ovs_bpf_port_stats {
+	__u64   rx_packets;		/* total packets received            */
+	__u64   rx_bytes;		/* total bytes received              */
+	__u64   rx_mcast_packets;	/* total multicast pkts received     */
+	__u64   rx_mcast_bytes;		/* total multicast bytes received    */
+	__u64   tx_packets;		/* total packets transmitted         */
+	__u64   tx_bytes;		/* total bytes transmitted           */
+	__u64   tx_mcast_packets;	/* total multicast pkts transmitted  */
+	__u64   tx_mcast_bytes;		/* total multicast bytes transmitted */
+};
+
+struct bpf_ipv4_tun_key {
+	__u32 tun_id;
+	__u32 src_ip;
+	__u32 dst_ip;
+	__u8 tos;
+	__u8 ttl;
+};
+
+struct bpf_context {
+	__u32 port_id;
+	__u32 plum_id;
+	__u32 length;
+	__u32 arg1;
+	__u32 arg2;
+	__u32 arg3;
+	__u32 arg4;
+	__u16 vlan_tag;
+	__u8 hw_csum;
+	__u8 rsvd;
+	struct bpf_ipv4_tun_key tun_key;
+};
+
+enum {
+	FUNC_bpf_load_byte = 3,
+	FUNC_bpf_load_half,
+	FUNC_bpf_load_word,
+	FUNC_bpf_load_dword,
+	FUNC_bpf_load_bits,
+	FUNC_bpf_store_byte,
+	FUNC_bpf_store_half,
+	FUNC_bpf_store_word,
+	FUNC_bpf_store_dword,
+	FUNC_bpf_store_bits,
+	FUNC_bpf_channel_push_packet,
+	FUNC_bpf_channel_push_struct,
+	FUNC_bpf_forward,
+	FUNC_bpf_forward_self,
+	FUNC_bpf_forward_to_plum,
+	FUNC_bpf_clone_forward,
+	FUNC_bpf_replicate,
+	FUNC_bpf_checksum,
+	FUNC_bpf_checksum_pkt,
+	FUNC_bpf_csum_replace2,
+	FUNC_bpf_csum_replace4,
+	FUNC_bpf_pseudo_csum_replace2,
+	FUNC_bpf_pseudo_csum_replace4,
+	FUNC_bpf_get_usec_time,
+	FUNC_bpf_push_vlan,
+	FUNC_bpf_pop_vlan,
+};
+
+__u8 bpf_load_byte(struct bpf_context *ctx, __u32 off);
+__u16 bpf_load_half(struct bpf_context *ctx, __u32 off);
+__u32 bpf_load_word(struct bpf_context *ctx, __u32 off);
+__u64 bpf_load_dword(struct bpf_context *ctx, __u32 off);
+int bpf_load_bits(struct bpf_context *ctx, __u32 off, void *to, __u32 len);
+void bpf_store_byte(struct bpf_context *pkt, __u32 off, __u8 val);
+void bpf_store_half(struct bpf_context *pkt, __u32 off, __u16 val);
+void bpf_store_word(struct bpf_context *pkt, __u32 off, __u32 val);
+void bpf_store_dword(struct bpf_context *pkt, __u32 off, __u64 val);
+void bpf_store_bits(struct bpf_context *pkt, __u32 off, const void *from,
+		    __u32 len);
+void bpf_channel_push_struct(struct bpf_context *pkt, __u32 struct_id,
+			     const void *entry, __u32 len);
+void bpf_channel_push_packet(struct bpf_context *pkt);
+void bpf_forward(struct bpf_context *ctx, __u32 port_id);
+void bpf_forward_self(struct bpf_context *pkt, __u32 port_id);
+void bpf_forward_to_plum(struct bpf_context *ctx, __u32 plumid);
+void bpf_clone_forward(struct bpf_context *pkt, __u32 port_id);
+void bpf_replicate(struct bpf_context *ctx, __u32 replicator, __u32 src_port);
+__u16 bpf_checksum(const __u8 *buf, __u32 len);
+__u16 bpf_checksum_pkt(struct bpf_context *ctx, __u32 off, __u32 len);
+__u16 bpf_csum_replace2(__u16 csum, __u16 from,	__u16 to);
+__u16 bpf_csum_replace4(__u16 csum, __u32 from,	__u32 to);
+__u16 bpf_pseudo_csum_replace2(__u16 csum, __u16 from, __u16 to);
+__u16 bpf_pseudo_csum_replace4(__u16 csum, __u32 from, __u32 to);
+__u64 bpf_get_usec_time(void);
+int bpf_push_vlan(struct bpf_context *ctx, __u16 proto, __u16 vlan);
+int bpf_pop_vlan(struct bpf_context *ctx);
+
 #endif /* _LINUX_OPENVSWITCH_H */
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index ea36e99..63722c5 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -11,7 +11,12 @@ openvswitch-y := \
 	flow.o \
 	vport.o \
 	vport-internal_dev.o \
-	vport-netdev.o
+	vport-netdev.o \
+	dp_bpf.o \
+	bpf_plum.o \
+	bpf_table.o \
+	bpf_replicator.o \
+	bpf_callbacks.o
 
 ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
 openvswitch-y += vport-vxlan.o
diff --git a/net/openvswitch/bpf_callbacks.c b/net/openvswitch/bpf_callbacks.c
new file mode 100644
index 0000000..efecdd2
--- /dev/null
+++ b/net/openvswitch/bpf_callbacks.c
@@ -0,0 +1,295 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/filter.h>
+#include <linux/openvswitch.h>
+
+#define MAX_CTX_OFF sizeof(struct bpf_context)
+
+static const struct bpf_context_access ctx_access[MAX_CTX_OFF] = {
+	[offsetof(struct bpf_context, port_id)] = {
+		FIELD_SIZEOF(struct bpf_context, port_id),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, plum_id)] = {
+		FIELD_SIZEOF(struct bpf_context, plum_id),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, length)] = {
+		FIELD_SIZEOF(struct bpf_context, length),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, length)] = {
+		FIELD_SIZEOF(struct bpf_context, arg1),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, length)] = {
+		FIELD_SIZEOF(struct bpf_context, arg2),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, length)] = {
+		FIELD_SIZEOF(struct bpf_context, arg3),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, length)] = {
+		FIELD_SIZEOF(struct bpf_context, arg4),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, vlan_tag)] = {
+		FIELD_SIZEOF(struct bpf_context, vlan_tag),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, hw_csum)] = {
+		FIELD_SIZEOF(struct bpf_context, hw_csum),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, tun_key.tun_id)] = {
+		FIELD_SIZEOF(struct bpf_context, tun_key.tun_id),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, tun_key.src_ip)] = {
+		FIELD_SIZEOF(struct bpf_context, tun_key.src_ip),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, tun_key.dst_ip)] = {
+		FIELD_SIZEOF(struct bpf_context, tun_key.dst_ip),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, tun_key.tos)] = {
+		FIELD_SIZEOF(struct bpf_context, tun_key.tos),
+		BPF_READ | BPF_WRITE
+	},
+	[offsetof(struct bpf_context, tun_key.ttl)] = {
+		FIELD_SIZEOF(struct bpf_context, tun_key.ttl),
+		BPF_READ | BPF_WRITE
+	},
+};
+
+static const struct bpf_context_access *get_context_access(int off)
+{
+	if (off >= MAX_CTX_OFF)
+		return NULL;
+	return &ctx_access[off];
+}
+
+static const struct bpf_func_proto funcs[] = {
+	[FUNC_bpf_load_byte] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_load_half] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_load_word] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_load_dword] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_load_bits] = {RET_INTEGER, PTR_TO_CTX, CONST_ARG,
+				PTR_TO_STACK_IMM, CONST_ARG},
+	[FUNC_bpf_store_byte] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_store_half] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_store_word] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_store_dword] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_store_bits] = {RET_INTEGER, PTR_TO_CTX, CONST_ARG,
+				 PTR_TO_STACK_IMM, CONST_ARG},
+	[FUNC_bpf_channel_push_struct] = {RET_VOID, PTR_TO_CTX, CONST_ARG,
+					  PTR_TO_STACK_IMM, CONST_ARG},
+	[FUNC_bpf_channel_push_packet] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_forward] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_forward_self] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_forward_to_plum] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_clone_forward] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_replicate] = {RET_VOID, PTR_TO_CTX},
+	[FUNC_bpf_checksum] = {RET_INTEGER, PTR_TO_STACK_IMM, CONST_ARG},
+	[FUNC_bpf_checksum_pkt] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_csum_replace2] = {RET_INTEGER},
+	[FUNC_bpf_csum_replace4] = {RET_INTEGER},
+	[FUNC_bpf_pseudo_csum_replace2] = {RET_INTEGER},
+	[FUNC_bpf_pseudo_csum_replace4] = {RET_INTEGER},
+	[FUNC_bpf_get_usec_time] = {RET_INTEGER},
+	[FUNC_bpf_push_vlan] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_pop_vlan] = {RET_INTEGER, PTR_TO_CTX},
+	[FUNC_bpf_max_id] = {}
+};
+
+static const struct bpf_func_proto *get_func_proto(int id)
+{
+	return &funcs[id];
+}
+
+static void execute_func(s32 func, u64 *regs)
+{
+	regs[R0] = 0;
+
+	switch (func) {
+	case FUNC_bpf_table_lookup:
+		regs[R0] = (u64)bpf_table_lookup((struct bpf_context *)regs[R1],
+						 (int)regs[R2],
+						 (const void *)regs[R3]);
+		break;
+	case FUNC_bpf_table_update:
+		regs[R0] = bpf_table_update((struct bpf_context *)regs[R1],
+					    (int)regs[R2],
+					    (const void *)regs[R3],
+					    (const void *)regs[R4]);
+		break;
+	case FUNC_bpf_load_byte:
+		regs[R0] = bpf_load_byte((struct bpf_context *)regs[R1],
+					 (u32)regs[R2]);
+		break;
+	case FUNC_bpf_load_half:
+		regs[R0] = bpf_load_half((struct bpf_context *)regs[R1],
+					 (u32)regs[R2]);
+		break;
+	case FUNC_bpf_load_word:
+		regs[R0] = bpf_load_word((struct bpf_context *)regs[R1],
+					 (u32)regs[R2]);
+		break;
+	case FUNC_bpf_load_dword:
+		regs[R0] = bpf_load_dword((struct bpf_context *)regs[R1],
+					  (u32)regs[R2]);
+		break;
+	case FUNC_bpf_load_bits:
+		regs[R0] = bpf_load_bits((struct bpf_context *)regs[R1],
+					  (u32)regs[R2], (void *)regs[R3],
+					  (u32)regs[R4]);
+		break;
+	case FUNC_bpf_store_byte:
+		bpf_store_byte((struct bpf_context *)regs[R1], (u32)regs[R2],
+			       (u8)regs[R3]);
+		break;
+	case FUNC_bpf_store_half:
+		bpf_store_half((struct bpf_context *)regs[R1], (u32)regs[R2],
+			       (u16)regs[R3]);
+		break;
+	case FUNC_bpf_store_word:
+		bpf_store_word((struct bpf_context *)regs[R1], (u32)regs[R2],
+			       (u32)regs[R3]);
+		break;
+	case FUNC_bpf_store_dword:
+		bpf_store_dword((struct bpf_context *)regs[R1], (u32)regs[R2],
+				(u64)regs[R3]);
+		break;
+	case FUNC_bpf_store_bits:
+		bpf_store_bits((struct bpf_context *)regs[R1], (u32)regs[R2],
+			       (const void *)regs[R3], (u32)regs[R4]);
+		break;
+	case FUNC_bpf_channel_push_packet:
+		bpf_channel_push_packet((struct bpf_context *)regs[R1]);
+		break;
+	case FUNC_bpf_channel_push_struct:
+		bpf_channel_push_struct((struct bpf_context *)regs[R1],
+					(u32)regs[R2], (const void *)regs[R3],
+					(u32)regs[R4]);
+		break;
+	case FUNC_bpf_forward:
+		bpf_forward((struct bpf_context *)regs[R1], (u32)regs[R2]);
+		break;
+	case FUNC_bpf_forward_self:
+		bpf_forward_self((struct bpf_context *)regs[R1], (u32)regs[R2]);
+		break;
+	case FUNC_bpf_forward_to_plum:
+		bpf_forward_to_plum((struct bpf_context *)regs[R1],
+				    (u32)regs[R2]);
+		break;
+	case FUNC_bpf_clone_forward:
+		bpf_clone_forward((struct bpf_context *)regs[R1],
+				  (u32)regs[R2]);
+		break;
+	case FUNC_bpf_replicate:
+		bpf_replicate((struct bpf_context *)regs[R1], (u32)regs[R2],
+			      (u32)regs[R3]);
+		break;
+	case FUNC_bpf_checksum:
+		regs[R0] = bpf_checksum((const u8 *)regs[R1], (u32)regs[R2]);
+		break;
+	case FUNC_bpf_checksum_pkt:
+		regs[R0] = bpf_checksum_pkt((struct bpf_context *)regs[R1],
+					 (u32)regs[R2], (u32)regs[R3]);
+		break;
+	case FUNC_bpf_csum_replace2:
+		regs[R0] = bpf_csum_replace2((u16)regs[R1], (u16)regs[R2],
+					     (u16)regs[R3]);
+		break;
+	case FUNC_bpf_csum_replace4:
+		regs[R0] = bpf_csum_replace4((u16)regs[R1], (u32)regs[R2],
+					     (u32)regs[R3]);
+		break;
+	case FUNC_bpf_pseudo_csum_replace2:
+		regs[R0] = bpf_pseudo_csum_replace2((u16)regs[R1],
+						    (u16)regs[R2],
+						    (u16)regs[R3]);
+		break;
+	case FUNC_bpf_pseudo_csum_replace4:
+		regs[R0] = bpf_pseudo_csum_replace4((u16)regs[R1],
+						    (u32)regs[R2],
+						    (u32)regs[R3]);
+		break;
+	case FUNC_bpf_get_usec_time:
+		regs[R0] = bpf_get_usec_time();
+		break;
+	case FUNC_bpf_push_vlan:
+		regs[R0] = bpf_push_vlan((struct bpf_context *)regs[R1],
+					 (u16)regs[R2], (u16)regs[R3]);
+		break;
+	case FUNC_bpf_pop_vlan:
+		regs[R0] = bpf_pop_vlan((struct bpf_context *)regs[R1]);
+		break;
+	default:
+		pr_err("unknown FUNC_bpf_%d\n", func);
+		return;
+	}
+}
+
+static void *jit_funcs[] = {
+	[FUNC_bpf_table_lookup] = bpf_table_lookup,
+	[FUNC_bpf_table_update] = bpf_table_update,
+	[FUNC_bpf_load_byte] = bpf_load_byte,
+	[FUNC_bpf_load_half] = bpf_load_half,
+	[FUNC_bpf_load_word] = bpf_load_word,
+	[FUNC_bpf_load_dword] = bpf_load_dword,
+	[FUNC_bpf_load_bits] = bpf_load_bits,
+	[FUNC_bpf_store_byte] = bpf_store_byte,
+	[FUNC_bpf_store_half] = bpf_store_half,
+	[FUNC_bpf_store_word] = bpf_store_word,
+	[FUNC_bpf_store_dword] = bpf_store_dword,
+	[FUNC_bpf_store_bits] = bpf_store_bits,
+	[FUNC_bpf_channel_push_struct] = bpf_channel_push_struct,
+	[FUNC_bpf_channel_push_packet] = bpf_channel_push_packet,
+	[FUNC_bpf_forward] = bpf_forward,
+	[FUNC_bpf_forward_self] = bpf_forward_self,
+	[FUNC_bpf_forward_to_plum] = bpf_forward_to_plum,
+	[FUNC_bpf_clone_forward] = bpf_clone_forward,
+	[FUNC_bpf_replicate] = bpf_replicate,
+	[FUNC_bpf_checksum] = bpf_checksum,
+	[FUNC_bpf_checksum_pkt] = bpf_checksum_pkt,
+	[FUNC_bpf_csum_replace2] = bpf_csum_replace2,
+	[FUNC_bpf_csum_replace4] = bpf_csum_replace4,
+	[FUNC_bpf_pseudo_csum_replace2] = bpf_pseudo_csum_replace2,
+	[FUNC_bpf_pseudo_csum_replace4] = bpf_pseudo_csum_replace4,
+	[FUNC_bpf_get_usec_time] = bpf_get_usec_time,
+	[FUNC_bpf_push_vlan] = bpf_push_vlan,
+	[FUNC_bpf_pop_vlan] = bpf_pop_vlan,
+	[FUNC_bpf_max_id] = 0
+};
+
+static void *jit_select_func(int id)
+{
+	if (id < 0 || id >= FUNC_bpf_max_id)
+		return NULL;
+	return jit_funcs[id];
+}
+
+struct bpf_callbacks bpf_plum_cb = {
+	execute_func, jit_select_func, get_func_proto, get_context_access
+};
+
diff --git a/net/openvswitch/bpf_plum.c b/net/openvswitch/bpf_plum.c
new file mode 100644
index 0000000..eeb1e36
--- /dev/null
+++ b/net/openvswitch/bpf_plum.c
@@ -0,0 +1,931 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/rculist.h>
+#include <linux/filter.h>
+#include <linux/jhash.h>
+#include <linux/if_vlan.h>
+#include <net/ip_tunnels.h>
+#include "datapath.h"
+
+static void bpf_run_wrap(struct bpf_dp_context *ctx)
+{
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+
+	plum = rcu_dereference(dp->plums[ctx->context.plum_id]);
+	bpf_run(plum->bpf_prog, &ctx->context);
+}
+
+struct plum *bpf_dp_register_plum(struct bpf_image *image,
+				  struct plum *old_plum, u32 plum_id)
+{
+	int ret;
+	struct bpf_program *bpf_prog;
+	struct plum *plum;
+	int i;
+
+	ret = bpf_load(image, &bpf_plum_cb, &bpf_prog);
+	if (ret < 0) {
+		pr_err("BPF load failed %d\n", ret);
+		return ERR_PTR(ret);
+	}
+
+	ret = -ENOMEM;
+	plum = kzalloc(sizeof(*plum), GFP_KERNEL);
+	if (!plum)
+		goto err_free_bpf_prog;
+
+	plum->bpf_prog = bpf_prog;
+
+	plum->tables = kzalloc(bpf_prog->table_cnt * sizeof(struct plum_table),
+			       GFP_KERNEL);
+	if (!plum->tables)
+		goto err_free_plum;
+
+	plum->num_tables = bpf_prog->table_cnt;
+
+	for (i = 0; i < bpf_prog->table_cnt; i++) {
+		memcpy(&plum->tables[i].info, &bpf_prog->tables[i],
+		       sizeof(struct bpf_table));
+	}
+
+	if (init_plum_tables(plum, plum_id) < 0)
+		goto err_free_table_array;
+
+	plum->replicators = kzalloc(PLUM_MAX_REPLICATORS *
+				    sizeof(struct hlist_head), GFP_KERNEL);
+	if (!plum->replicators)
+		goto err_free_tables;
+
+	for (i = 0; i < PLUM_MAX_REPLICATORS; i++)
+		INIT_HLIST_HEAD(&plum->replicators[i]);
+
+	if (bpf_prog->jit_image)
+		plum->run = (void (*)(struct bpf_dp_context *ctx))bpf_prog->jit_image;
+	else
+		plum->run = bpf_run_wrap;
+
+	return plum;
+
+err_free_tables:
+	free_plum_tables(plum);
+err_free_table_array:
+	kfree(plum->tables);
+err_free_plum:
+	kfree(plum);
+err_free_bpf_prog:
+	bpf_free(bpf_prog);
+	return ERR_PTR(ret);
+}
+
+static void free_plum_rcu(struct rcu_head *rcu)
+{
+	struct plum *plum = container_of(rcu, struct plum, rcu);
+	int i;
+
+	for (i = 0; i < PLUM_MAX_PORTS; i++)
+		free_percpu(plum->stats[i]);
+
+	free_plum_tables(plum);
+	kfree(plum->replicators);
+	bpf_free(plum->bpf_prog);
+	kfree(plum);
+}
+
+void bpf_dp_unregister_plum(struct plum *plum)
+{
+	if (plum) {
+		cleanup_plum_replicators(plum);
+		cleanup_plum_tables(plum);
+		call_rcu(&plum->rcu, free_plum_rcu);
+	}
+}
+
+/* Called with ovs_mutex. */
+void bpf_dp_disconnect_port(struct vport *p)
+{
+	struct datapath *dp = p->dp;
+	struct plum *plum, *dest_plum;
+	u32 dest;
+
+	plum = ovsl_dereference(dp->plums[0]);
+
+	dest = atomic_read(&plum->ports[p->port_no]);
+	if (dest) {
+		dest_plum = ovsl_dereference(dp->plums[dest >> 16]);
+		atomic_set(&dest_plum->ports[dest & 0xffff], 0);
+	}
+	atomic_set(&plum->ports[p->port_no], 0);
+	smp_wmb();
+
+	/* leave the stats allocated until plum is freed */
+}
+
+static int bpf_dp_ctx_init(struct bpf_dp_context *ctx)
+{
+	struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(ctx->skb)->tun_key;
+
+	if (skb_headroom(ctx->skb) < 64) {
+		if (pskb_expand_head(ctx->skb, 64, 0, GFP_ATOMIC))
+			return -ENOMEM;
+	}
+	ctx->context.length = ctx->skb->len;
+	ctx->context.vlan_tag = vlan_tx_tag_present(ctx->skb) ?
+			vlan_tx_tag_get(ctx->skb) : 0;
+	ctx->context.hw_csum = (ctx->skb->ip_summed == CHECKSUM_PARTIAL);
+	if (tun_key) {
+		ctx->context.tun_key.tun_id =
+				be32_to_cpu(be64_get_low32(tun_key->tun_id));
+		ctx->context.tun_key.src_ip = be32_to_cpu(tun_key->ipv4_src);
+		ctx->context.tun_key.dst_ip = be32_to_cpu(tun_key->ipv4_dst);
+		ctx->context.tun_key.tos = tun_key->ipv4_tos;
+		ctx->context.tun_key.ttl = tun_key->ipv4_ttl;
+	} else {
+		memset(&ctx->context.tun_key, 0,
+		       sizeof(struct bpf_ipv4_tun_key));
+	}
+
+	return 0;
+}
+
+static int bpf_dp_ctx_copy(struct bpf_dp_context *ctx,
+			   struct bpf_dp_context *orig_ctx)
+{
+	struct sk_buff *skb = skb_copy(orig_ctx->skb, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	ctx->context = orig_ctx->context;
+	ctx->skb = skb;
+	ctx->dp = orig_ctx->dp;
+	ctx->stack = orig_ctx->stack;
+
+	return 0;
+}
+
+void plum_update_stats(struct plum *plum, u32 port_id, struct sk_buff *skb,
+			 bool rx)
+{
+	struct pcpu_port_stats *stats;
+	struct ethhdr *eh = eth_hdr(skb);
+
+	if (unlikely(!plum->stats[port_id])) /* forward on disconnected port */
+		return;
+
+	stats = this_cpu_ptr(plum->stats[port_id]);
+	u64_stats_update_begin(&stats->syncp);
+	if (rx) {
+		if (is_multicast_ether_addr(eh->h_dest)) {
+			stats->rx_mcast_packets++;
+			stats->rx_mcast_bytes += skb->len;
+		} else {
+			stats->rx_packets++;
+			stats->rx_bytes += skb->len;
+		}
+	} else {
+		if (is_multicast_ether_addr(eh->h_dest)) {
+			stats->tx_mcast_packets++;
+			stats->tx_mcast_bytes += skb->len;
+		} else {
+			stats->tx_packets++;
+			stats->tx_bytes += skb->len;
+		}
+	}
+	u64_stats_update_end(&stats->syncp);
+}
+
+/* called by execute_plums() to execute BPF program
+ * or send it out of vport if destination plum_id is zero
+ * It's called with rcu_read_lock.
+ */
+static void __bpf_forward(struct bpf_dp_context *ctx, u32 dest)
+{
+	struct datapath *dp = ctx->dp;
+	u32 plum_id = dest >> 16;
+	u32 port_id = dest & 0xffff;
+	struct plum *plum;
+	struct vport *vport;
+	struct ovs_key_ipv4_tunnel tun_key;
+
+	plum = rcu_dereference(dp->plums[plum_id]);
+	if (unlikely(!plum)) {
+		kfree_skb(ctx->skb);
+		return;
+	}
+	if (plum_id == 0) {
+		if (ctx->context.tun_key.dst_ip) {
+			tun_key.tun_id =
+				cpu_to_be64(ctx->context.tun_key.tun_id);
+			tun_key.ipv4_src =
+				cpu_to_be32(ctx->context.tun_key.src_ip);
+			tun_key.ipv4_dst =
+				cpu_to_be32(ctx->context.tun_key.dst_ip);
+			tun_key.ipv4_tos = ctx->context.tun_key.tos;
+			tun_key.ipv4_ttl = ctx->context.tun_key.ttl;
+			tun_key.tun_flags = TUNNEL_KEY;
+			OVS_CB(ctx->skb)->tun_key = &tun_key;
+		} else {
+			OVS_CB(ctx->skb)->tun_key = NULL;
+		}
+
+		plum_update_stats(plum, port_id, ctx->skb, false);
+
+		vport = ovs_vport_rcu(dp, port_id);
+		if (unlikely(!vport)) {
+			kfree_skb(ctx->skb);
+			return;
+		}
+		ovs_vport_send(vport, ctx->skb);
+	} else {
+		ctx->context.port_id = port_id;
+		ctx->context.plum_id = plum_id;
+		BUG_ON(plum->run == NULL);
+		plum_update_stats(plum, port_id, ctx->skb, true);
+		/* execute BPF program */
+		plum->run(ctx);
+		consume_skb(ctx->skb);
+	}
+}
+
+
+/* plum_stack_push() is called to enqueue plum_id|port_id pair into
+ * stack of plums to be executed
+ */
+void plum_stack_push(struct bpf_dp_context *ctx, u32 dest, int copy)
+{
+	struct plum_stack *stack;
+	struct plum_stack_frame *frame;
+
+	stack = ctx->stack;
+
+	if (stack->push_cnt > 1024)
+		/* number of frames to execute is too high, ignore
+		 * all further bpf_*_forward() calls
+		 *
+		 * this can happen if connections between plums make a loop:
+		 * three bridge-plums in a loop is a valid network
+		 * topology if STP is working, but kernel needs to make sure
+		 * that packet doesn't loop forever
+		 */
+		return;
+
+	stack->push_cnt++;
+
+	if (!copy) {
+		frame = stack->curr_frame;
+		if (!frame) /* bpf_*_forward() is called 2nd time. ignore it */
+			return;
+
+		BUG_ON(&frame->ctx != ctx);
+		stack->curr_frame = NULL;
+
+		skb_get(ctx->skb);
+	} else {
+		frame = kmem_cache_alloc(plum_stack_cache, GFP_ATOMIC);
+		if (!frame)
+			return;
+		frame->kmem = 1;
+		if (bpf_dp_ctx_copy(&frame->ctx, ctx)) {
+			kmem_cache_free(plum_stack_cache, frame);
+			return;
+		}
+	}
+
+	frame->dest = dest;
+	list_add(&frame->link, &stack->list);
+}
+
+/* execute_plums() pops the stack and execute plums until stack is empty */
+static void execute_plums(struct plum_stack *stack)
+{
+	struct plum_stack_frame *frame;
+
+	while (!list_empty(&stack->list)) {
+		frame = list_first_entry(&stack->list, struct plum_stack_frame,
+					 link);
+		list_del(&frame->link);
+
+		/* let plum_stack_push() know which frame is current
+		 * plum_stack_push() will be called by bpf_*_forward()
+		 * functions from BPF program
+		 */
+		stack->curr_frame = frame;
+
+		/* execute BPF program or forward skb out */
+		__bpf_forward(&frame->ctx, frame->dest);
+
+		/* when plum_stack_push() reuses the current frame while
+		 * pushing it to the stack, it will set curr_frame to NULL
+		 * kmem flag indicates whether frame was allocated or
+		 * it's the first_frame from bpf_process_received_packet() stack
+		 * free it here if it was allocated
+		 */
+		if (stack->curr_frame && stack->curr_frame->kmem)
+			kmem_cache_free(plum_stack_cache, stack->curr_frame);
+	}
+}
+
+/* packet arriving on vport processed here
+ * must be called with rcu_read_lock
+ */
+void bpf_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
+{
+	struct datapath *dp = p->dp;
+	struct plum *plum;
+	u32 dest;
+	struct plum_stack stack = {};
+	struct plum_stack_frame first_frame;
+	struct plum_stack_frame *frame;
+	struct bpf_dp_context *ctx;
+
+	plum = rcu_dereference(dp->plums[0]);
+	dest = atomic_read(&plum->ports[p->port_no]);
+
+	if (dest) {
+		frame = &first_frame;
+		frame->kmem = 0;
+
+		INIT_LIST_HEAD(&stack.list);
+		ctx = &frame->ctx;
+		ctx->stack = &stack;
+		ctx->context.port_id = p->port_no;
+		ctx->context.plum_id = 0;
+		ctx->skb = skb;
+		ctx->dp = dp;
+		bpf_dp_ctx_init(ctx);
+
+		plum_update_stats(plum, p->port_no, skb, true);
+
+		frame->dest = dest;
+		stack.curr_frame = NULL;
+		list_add(&frame->link, &stack.list);
+		execute_plums(&stack);
+	} else {
+		consume_skb(skb);
+	}
+}
+
+/* userspace injects packet into plum */
+int bpf_dp_channel_push_on_plum(struct datapath *dp, u32 plum_id, u32 port_id,
+				struct sk_buff *skb, u32 direction)
+{
+	struct plum_stack stack = {};
+	struct plum_stack_frame first_frame;
+	struct plum_stack_frame *frame;
+	struct bpf_dp_context *ctx;
+	u32 dest;
+
+	frame = &first_frame;
+	frame->kmem = 0;
+
+	INIT_LIST_HEAD(&stack.list);
+	ctx = &frame->ctx;
+	ctx->stack = &stack;
+	ctx->context.port_id = 0;
+	ctx->context.plum_id = 0;
+	ctx->skb = skb;
+	ctx->dp = dp;
+	bpf_dp_ctx_init(ctx);
+
+	rcu_read_lock();
+
+	if (direction == OVS_BPF_OUT_DIR) {
+		ctx->context.plum_id = plum_id;
+		stack.curr_frame = frame;
+		bpf_forward(&ctx->context, port_id);
+	} else {
+		dest = MUX(plum_id, port_id);
+		frame->dest = dest;
+		stack.curr_frame = NULL;
+		list_add(&frame->link, &stack.list);
+	}
+	execute_plums(&stack);
+
+	rcu_read_unlock();
+
+	return 0;
+}
+
+/* from current_plum_id:port_id find next_plum_id:next_port_id
+ * and queue the packet to that plum
+ *
+ * plum can still modify the packet, but it's not recommended
+ * all subsequent bpf_forward()/bpf_forward_self()/bpf_forward_to_plum()
+ * calls from this plum will be ignored
+ */
+void bpf_forward(struct bpf_context *pctx, u32 port_id)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+	u32 dest;
+
+	if (unlikely(!ctx->skb) || port_id >= PLUM_MAX_PORTS)
+		return;
+
+	plum = rcu_dereference(dp->plums[pctx->plum_id]);
+	if (unlikely(!plum)) /* plum was unregistered while running */
+		return;
+
+	dest = atomic_read(&plum->ports[port_id]);
+	if (dest) {
+		plum_update_stats(plum, port_id, ctx->skb, false);
+		plum_stack_push(ctx, dest, 0);
+	}
+}
+
+/* from current_plum_id:port_id find next_plum_id:next_port_id
+ * copy the packet and queue the copy to that plum
+ *
+ * later plum can modify the packet and potentially forward it other port
+ * bpf_clone_forward() can be called any number of times
+ */
+void bpf_clone_forward(struct bpf_context *pctx, u32 port_id)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+	u32 dest;
+
+	if (unlikely(!ctx->skb) || port_id >= PLUM_MAX_PORTS)
+		return;
+
+	plum = rcu_dereference(dp->plums[pctx->plum_id]);
+	if (unlikely(!plum))
+		return;
+
+	dest = atomic_read(&plum->ports[port_id]);
+	if (dest)
+		plum_stack_push(ctx, dest, 1);
+}
+
+/* re-queue the packet to plum's own port
+ *
+ * all subsequent bpf_forward()/bpf_forward_self()/bpf_forward_to_plum()
+ * calls from this plum will be ignored
+ */
+void bpf_forward_self(struct bpf_context *pctx, u32 port_id)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+	u32 dest;
+
+	if (unlikely(!ctx->skb) || port_id >= PLUM_MAX_PORTS)
+		return;
+
+	plum = rcu_dereference(dp->plums[pctx->plum_id]);
+	if (unlikely(!plum))
+		return;
+
+	dest = MUX(pctx->plum_id, port_id);
+	if (dest) {
+		plum_update_stats(plum, port_id, ctx->skb, false);
+		plum_stack_push(ctx, dest, 0);
+	}
+}
+
+/* queue the packet to port zero of different plum
+ *
+ * all subsequent bpf_forward()/bpf_forward_self()/bpf_forward_to_plum()
+ * calls from this plum will be ignored
+ */
+void bpf_forward_to_plum(struct bpf_context *pctx, u32 plum_id)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	u32 dest;
+
+	if (unlikely(!ctx->skb) || plum_id >= DP_MAX_PLUMS)
+		return;
+
+	dest = MUX(plum_id, 0);
+	if (dest)
+		plum_stack_push(ctx, dest, 0);
+}
+
+/* called from BPF program, therefore rcu_read_lock is held
+ * bpf_check() verified that pctx is a valid pointer
+ */
+u8 bpf_load_byte(struct bpf_context *pctx, u32 off)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return 0;
+	if (!pskb_may_pull(skb, off + 1))
+		return 0;
+	return *(u8 *)(skb->data + off);
+}
+
+u16 bpf_load_half(struct bpf_context *pctx, u32 off)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return 0;
+	if (!pskb_may_pull(skb, off + 2))
+		return 0;
+	return *(u16 *)(skb->data + off);
+}
+
+u32 bpf_load_word(struct bpf_context *pctx, u32 off)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return 0;
+	if (!pskb_may_pull(skb, off + 4))
+		return 0;
+	return *(u32 *)(skb->data + off);
+}
+
+u64 bpf_load_dword(struct bpf_context *pctx, u32 off)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return 0;
+	if (!pskb_may_pull(skb, off + 8))
+		return 0;
+	return *(u64 *)(skb->data + off);
+}
+
+int bpf_load_bits(struct bpf_context *pctx, u32 off, void *to, u32 len)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return -EFAULT;
+	if (!pskb_may_pull(skb, off + len))
+		return -EFAULT;
+	memcpy(to, skb->data + off, len);
+
+	return 0;
+}
+
+static void update_skb_csum(struct sk_buff *skb, u32 from, u32 to)
+{
+	u32 diff[] = { ~from, to };
+
+	skb->csum = ~csum_partial(diff, sizeof(diff), ~skb->csum);
+}
+
+void bpf_store_byte(struct bpf_context *pctx, u32 off, u8 val)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+	u8 old = 0;
+	u16 from, to;
+
+	if (unlikely(!skb))
+		return;
+	if (!pskb_may_pull(skb, off + 1))
+		return;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		old = *(u8 *)(skb->data + off);
+
+	*(u8 *)(skb->data + off) = val;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		from = (off & 0x1) ? htons(old) : htons(old << 8);
+		to = (off & 0x1) ? htons(val) : htons(val << 8);
+		update_skb_csum(skb, (u32)from, (u32)to);
+	}
+}
+
+void bpf_store_half(struct bpf_context *pctx, u32 off, u16 val)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+	u16 old = 0;
+
+	if (unlikely(!skb))
+		return;
+	if (!pskb_may_pull(skb, off + 2))
+		return;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		old = *(u16 *)(skb->data + off);
+
+	*(u16 *)(skb->data + off) = val;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		update_skb_csum(skb, (u32)old, (u32)val);
+}
+
+void bpf_store_word(struct bpf_context *pctx, u32 off, u32 val)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+	u32 old = 0;
+
+	if (unlikely(!skb))
+		return;
+	if (!pskb_may_pull(skb, off + 4))
+		return;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		old = *(u32 *)(skb->data + off);
+
+	*(u32 *)(skb->data + off) = val;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		update_skb_csum(skb, old, val);
+}
+
+void bpf_store_dword(struct bpf_context *pctx, u32 off, u64 val)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+	u64 old = 0;
+	u32 *from, *to;
+	u32 diff[4];
+
+	if (unlikely(!skb))
+		return;
+	if (!pskb_may_pull(skb, off + 8))
+		return;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		old = *(u64 *)(skb->data + off);
+
+	*(u64 *)(skb->data + off) = val;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		from = (u32 *)&old;
+		to = (u32 *)&val;
+		diff[0] = ~from[0],
+		diff[1] = ~from[1],
+		diff[2] = to[0],
+		diff[3] = to[0],
+		skb->csum = ~csum_partial(diff, sizeof(diff), ~skb->csum);
+	}
+}
+
+void bpf_store_bits(struct bpf_context *pctx, u32 off, const void *from,
+		    u32 len)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return;
+	if (!pskb_may_pull(skb, off + len))
+		return;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_sub(skb->csum,
+				     csum_partial(skb->data + off, len, 0));
+
+	memcpy(skb->data + off, from, len);
+
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum,
+				     csum_partial(skb->data + off, len, 0));
+}
+
+/* return time in microseconds */
+u64 bpf_get_usec_time(void)
+{
+	struct timespec now;
+	getnstimeofday(&now);
+	return (((uint64_t)now.tv_sec) * 1000000) + now.tv_nsec / 1000;
+}
+
+/* called from BPF program, therefore rcu_read_lock is held
+ * bpf_check() verified that 'buf' pointer to BPF's stack
+ * and it has 'len' bytes for us to read
+ */
+void bpf_channel_push_struct(struct bpf_context *pctx, u32 struct_id,
+			     const void *buf, u32 len)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct dp_upcall_info upcall;
+	struct plum *plum;
+	struct nlattr *nla;
+
+	if (unlikely(!ctx->skb))
+		return;
+
+	plum = rcu_dereference(ctx->dp->plums[pctx->plum_id]);
+	if (unlikely(!plum))
+		return;
+
+	/* allocate temp nlattr to pass it into ovs_dp_upcall */
+	nla = kzalloc(nla_total_size(4 + len), GFP_ATOMIC);
+	if (unlikely(!nla))
+		return;
+
+	nla->nla_type = OVS_PACKET_ATTR_USERDATA;
+	nla->nla_len = nla_attr_size(4 + len);
+	memcpy(nla_data(nla), &struct_id, 4);
+	memcpy(nla_data(nla) + 4, buf, len);
+
+	upcall.cmd = OVS_PACKET_CMD_ACTION;
+	upcall.key = NULL;
+	upcall.userdata = nla;
+	upcall.portid = plum->upcall_pid;
+	ovs_dp_upcall(ctx->dp, NULL, &upcall);
+	kfree(nla);
+}
+
+/* called from BPF program, therefore rcu_read_lock is held */
+void bpf_channel_push_packet(struct bpf_context *pctx)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct dp_upcall_info upcall;
+	struct sk_buff *nskb;
+	struct plum *plum;
+
+	if (unlikely(!ctx->skb))
+		return;
+
+	plum = rcu_dereference(ctx->dp->plums[pctx->plum_id]);
+	if (unlikely(!plum))
+		return;
+
+	/* queue_gso_packets() inside ovs_dp_upcall() changes skb,
+	 * so copy it here, since BPF program might still be using it
+	 */
+	nskb = skb_clone(ctx->skb, GFP_ATOMIC);
+	if (unlikely(!nskb))
+		return;
+
+	upcall.cmd = OVS_PACKET_CMD_ACTION;
+	upcall.key = NULL;
+	upcall.userdata = NULL;
+	upcall.portid = plum->upcall_pid;
+	/* don't exit earlier even if upcall_pid is invalid,
+	 * since we want 'lost' count to be incremented
+	 */
+	ovs_dp_upcall(ctx->dp, nskb, &upcall);
+	consume_skb(nskb);
+}
+
+int bpf_push_vlan(struct bpf_context *pctx, u16 proto, u16 vlan)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+	u16 current_tag;
+
+	if (unlikely(!skb))
+		return -EINVAL;
+
+	if (vlan_tx_tag_present(skb)) {
+		current_tag = vlan_tx_tag_get(skb);
+
+		if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag)) {
+			ctx->skb = NULL;
+			return -ENOMEM;
+		}
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->csum = csum_add(skb->csum, csum_partial(skb->data
+					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
+		ctx->context.length = skb->len;
+	}
+	__vlan_hwaccel_put_tag(skb, proto, vlan);
+	ctx->context.vlan_tag = vlan;
+
+	return 0;
+}
+
+int bpf_pop_vlan(struct bpf_context *pctx)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct sk_buff *skb = ctx->skb;
+
+	if (unlikely(!skb))
+		return -EINVAL;
+
+	ctx->context.vlan_tag = 0;
+	if (vlan_tx_tag_present(skb)) {
+		skb->vlan_tci = 0;
+	} else {
+		if (skb->protocol != htons(ETH_P_8021Q) ||
+		    skb->len < VLAN_ETH_HLEN)
+			return 0;
+
+		if (!pskb_may_pull(skb, ETH_HLEN))
+			return 0;
+
+		__skb_pull(skb, ETH_HLEN);
+		skb = vlan_untag(skb);
+		if (!skb) {
+			ctx->skb = NULL;
+			return -ENOMEM;
+		}
+		__skb_push(skb, ETH_HLEN);
+
+		skb->vlan_tci = 0;
+		ctx->context.length = skb->len;
+		ctx->skb = skb;
+	}
+	/* move next vlan tag to hw accel tag */
+	if (skb->protocol != htons(ETH_P_8021Q) ||
+	    skb->len < VLAN_ETH_HLEN)
+		return 0;
+
+	if (!pskb_may_pull(skb, ETH_HLEN))
+		return 0;
+
+	__skb_pull(skb, ETH_HLEN);
+	skb = vlan_untag(skb);
+	if (!skb) {
+		ctx->skb = NULL;
+		return -ENOMEM;
+	}
+	__skb_push(skb, ETH_HLEN);
+
+	ctx->context.vlan_tag = vlan_tx_tag_get(skb);
+	ctx->context.length = skb->len;
+	ctx->skb = skb;
+
+	return 0;
+}
+
+u16 bpf_checksum(const u8 *buf, u32 len)
+{
+	/* if 'buf' points to BPF program stack, bpf_check()
+	 * verified that 'len' bytes of it are valid
+	 * len/4 rounds the length down, so that memory is safe to access
+	 */
+	return ip_fast_csum(buf, len/4);
+}
+
+u16 bpf_checksum_pkt(struct bpf_context *pctx, u32 off, u32 len)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	if (!ctx->skb)
+		return 0;
+	if (!pskb_may_pull(ctx->skb, off + len))
+		return 0;
+	/* linearized all the way till 'off + len' byte of the skb
+	 * can compute checksum now
+	 */
+	return bpf_checksum(ctx->skb->data + off, len);
+}
+
+u16 bpf_csum_replace2(u16 csum, u16 from, u16 to)
+{
+	return bpf_csum_replace4(csum, (u32)from, (u32)to);
+}
+
+u16 bpf_csum_replace4(u16 csum, u32 from, u32 to)
+{
+	csum_replace4(&csum, from, to);
+	return csum;
+}
+
+u16 bpf_pseudo_csum_replace2(u16 csum, u16 from, u16 to)
+{
+	return bpf_pseudo_csum_replace4(csum, (u32)from, (u32)to);
+}
+
+u16 bpf_pseudo_csum_replace4(u16 csum, u32 from, u32 to)
+{
+	u32 diff[] = { ~from, to };
+	return ~csum_fold(csum_partial(diff, sizeof(diff),
+			  csum_unfold(csum)));
+}
+
diff --git a/net/openvswitch/bpf_replicator.c b/net/openvswitch/bpf_replicator.c
new file mode 100644
index 0000000..51631b3
--- /dev/null
+++ b/net/openvswitch/bpf_replicator.c
@@ -0,0 +1,155 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/rculist.h>
+#include "datapath.h"
+
+static struct hlist_head *replicator_hash_bucket(const struct plum *plum,
+						 u32 replicator_id)
+{
+	return &plum->replicators[replicator_id & (PLUM_MAX_REPLICATORS - 1)];
+}
+
+/* Must be called with rcu_read_lock. */
+static
+struct plum_replicator_elem *replicator_lookup_port(const struct plum *plum,
+						    u32 replicator_id,
+						    u32 port_id)
+{
+	struct hlist_head *head;
+	struct plum_replicator_elem *elem;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	head = replicator_hash_bucket(plum, replicator_id);
+	hlist_for_each_entry_rcu(elem, head, hash_node) {
+		if (elem->replicator_id == replicator_id &&
+		    elem->port_id == port_id)
+			return elem;
+	}
+	return NULL;
+}
+
+int bpf_dp_replicator_del_all(struct plum *plum, u32 replicator_id)
+{
+	struct hlist_head *head;
+	struct hlist_node *n;
+	struct plum_replicator_elem *elem;
+
+	head = replicator_hash_bucket(plum, replicator_id);
+	hlist_for_each_entry_safe(elem, n, head, hash_node) {
+		if (elem->replicator_id == replicator_id) {
+			hlist_del_rcu(&elem->hash_node);
+			kfree_rcu(elem, rcu);
+		}
+	}
+
+	return 0;
+}
+
+int bpf_dp_replicator_add_port(struct plum *plum, u32 replicator_id,
+			       u32 port_id)
+{
+	struct hlist_head *head;
+	struct plum_replicator_elem *elem;
+
+	rcu_read_lock();
+	elem = replicator_lookup_port(plum, replicator_id, port_id);
+	if (elem) {
+		rcu_read_unlock();
+		return -EEXIST;
+	}
+	rcu_read_unlock();
+
+	elem = kzalloc(sizeof(*elem), GFP_KERNEL);
+	if (!elem)
+		return -ENOMEM;
+
+	elem->replicator_id = replicator_id;
+	elem->port_id = port_id;
+
+	head = replicator_hash_bucket(plum, replicator_id);
+	hlist_add_head_rcu(&elem->hash_node, head);
+
+	return 0;
+}
+
+int bpf_dp_replicator_del_port(struct plum *plum, u32 replicator_id,
+			       u32 port_id)
+{
+	struct plum_replicator_elem *elem;
+
+	rcu_read_lock();
+	elem = replicator_lookup_port(plum, replicator_id, port_id);
+	if (!elem) {
+		rcu_read_unlock();
+		return -ENODEV;
+	}
+
+	hlist_del_rcu(&elem->hash_node);
+	kfree_rcu(elem, rcu);
+	rcu_read_unlock();
+
+	return 0;
+}
+
+void cleanup_plum_replicators(struct plum *plum)
+{
+	int i;
+
+	if (!plum->replicators)
+		return;
+
+	for (i = 0; i < PLUM_MAX_REPLICATORS; i++)
+		bpf_dp_replicator_del_all(plum, i);
+}
+
+/* Must be called with rcu_read_lock. */
+static void replicator_for_each(struct plum *plum, struct bpf_dp_context *ctx,
+				u32 replicator_id, u32 src_port)
+{
+	struct hlist_head *head;
+	struct plum_replicator_elem *elem;
+	u32 dest;
+
+	head = replicator_hash_bucket(plum, replicator_id);
+	hlist_for_each_entry_rcu(elem, head, hash_node) {
+		if (elem->replicator_id == replicator_id &&
+		    elem->port_id != src_port) {
+			dest = atomic_read(&plum->ports[elem->port_id]);
+			if (dest) {
+				plum_update_stats(plum, elem->port_id, ctx->skb,
+						  false);
+				plum_stack_push(ctx, dest, 1);
+			}
+		}
+	}
+}
+
+void bpf_replicate(struct bpf_context *pctx, u32 replicator_id, u32 src_port)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+
+	if (!ctx->skb ||
+	    ctx->context.plum_id >= DP_MAX_PLUMS)
+		return;
+
+	plum = rcu_dereference(dp->plums[pctx->plum_id]);
+	replicator_for_each(plum, ctx, replicator_id, src_port);
+}
diff --git a/net/openvswitch/bpf_table.c b/net/openvswitch/bpf_table.c
new file mode 100644
index 0000000..6ff2c6a
--- /dev/null
+++ b/net/openvswitch/bpf_table.c
@@ -0,0 +1,500 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/rculist.h>
+#include <linux/filter.h>
+#include <linux/jhash.h>
+#include <linux/workqueue.h>
+#include "datapath.h"
+
+static inline u32 hash_table_hash(const void *key, u32 key_len)
+{
+	return jhash(key, key_len, 0);
+}
+
+static inline
+struct hlist_head *hash_table_find_bucket(struct plum_hash_table *table,
+					  u32 hash)
+{
+	return &table->buckets[hash & (table->n_buckets - 1)];
+}
+
+/* Must be called with rcu_read_lock. */
+static struct plum_hash_elem *hash_table_lookup(struct plum_hash_table *table,
+						const void *key, u32 key_len,
+						u32 hit_cnt)
+{
+	struct plum_hash_elem *l;
+	struct hlist_head *head;
+	u32 hash;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (!key)
+		return NULL;
+
+	hash = hash_table_hash(key, key_len);
+
+	head = hash_table_find_bucket(table, hash);
+	hlist_for_each_entry_rcu(l, head, hash_node) {
+		if (l->hash == hash && !memcmp(&l->key, key, key_len)) {
+			if (hit_cnt)
+				atomic_inc(&l->hit_cnt);
+			return l;
+		}
+	}
+	return NULL;
+}
+
+static
+struct plum_hash_elem *hash_table_alloc_element(struct plum_hash_table *table)
+{
+	struct plum_hash_elem *l;
+	l = kmem_cache_alloc(table->leaf_cache, GFP_ATOMIC);
+	if (!l)
+		return ERR_PTR(-ENOMEM);
+	return l;
+}
+
+static void free_hash_table_element_rcu(struct rcu_head *rcu)
+{
+	struct plum_hash_elem *elem = container_of(rcu, struct plum_hash_elem,
+						   rcu);
+
+	kmem_cache_free(elem->table->leaf_cache, elem);
+}
+
+static void hash_table_release_element(struct plum_hash_table *table,
+				       struct plum_hash_elem *l)
+{
+	if (!l)
+		return;
+
+	l->table = table;
+	call_rcu(&l->rcu, free_hash_table_element_rcu);
+}
+
+static void hash_table_clear_elements(struct plum_hash_table *table)
+{
+	int i;
+
+	spin_lock_bh(&table->lock);
+	for (i = 0; i < table->n_buckets; i++) {
+		struct plum_hash_elem *l;
+		struct hlist_head *head = hash_table_find_bucket(table, i);
+		struct hlist_node *n;
+
+		hlist_for_each_entry_safe(l, n, head, hash_node) {
+			hlist_del_rcu(&l->hash_node);
+			table->count--;
+			hash_table_release_element(table, l);
+		}
+	}
+	spin_unlock_bh(&table->lock);
+	WARN_ON(table->count != 0);
+}
+
+static struct plum_hash_elem *hash_table_find(struct plum_hash_table *table,
+					      const void *key, u32 key_len)
+{
+	return hash_table_lookup(table, key, key_len, 0);
+}
+
+static struct plum_table *get_table(struct plum *plum, u32 table_id)
+{
+	int i;
+	struct plum_table *table;
+
+	for (i = 0; i < plum->num_tables; i++) {
+		table = &plum->tables[i];
+
+		if (table->info.id == table_id)
+			return table;
+	}
+
+	return NULL;
+}
+
+static void hash_table_remove(struct plum_hash_table *table,
+			      struct plum_hash_elem *l)
+{
+	if (!l)
+		return;
+
+	spin_lock_bh(&table->lock);
+	hlist_del_rcu(&l->hash_node);
+	table->count--;
+	hash_table_release_element(table, l);
+	spin_unlock_bh(&table->lock);
+	WARN_ON(table->count < 0);
+}
+
+int bpf_dp_clear_table_elements(struct plum *plum, u32 table_id)
+{
+	struct plum_table *table;
+
+	table = get_table(plum, table_id);
+	if (!table)
+		return -EINVAL;
+
+	if (table->info.type == BPF_TABLE_HASH)
+		hash_table_clear_elements(table->base);
+
+	return 0;
+}
+
+int bpf_dp_update_table_element(struct plum *plum, u32 table_id,
+				const char *key_data, const char *leaf_data)
+{
+	struct plum_table *table;
+	struct plum_hash_table *htable;
+	struct plum_hash_elem *l_new;
+	struct plum_hash_elem *l_old;
+	struct hlist_head *head;
+	u32 key_size, leaf_size;
+
+	table = get_table(plum, table_id);
+	if (!table)
+		return -EINVAL;
+
+	key_size = table->info.key_size;
+	leaf_size = table->info.elem_size;
+
+	if (table->info.type == BPF_TABLE_HASH) {
+		htable = table->base;
+		l_new = hash_table_alloc_element(htable);
+		if (IS_ERR(l_new))
+			return -ENOMEM;
+		atomic_set(&l_new->hit_cnt, 0);
+		memcpy(&l_new->key, key_data, key_size);
+		memcpy(&l_new->key[key_size], leaf_data, leaf_size);
+		l_new->hash = hash_table_hash(&l_new->key, key_size);
+		head = hash_table_find_bucket(htable, l_new->hash);
+
+		rcu_read_lock();
+		l_old = hash_table_find(htable, key_data, key_size);
+
+		spin_lock_bh(&htable->lock);
+		if (!l_old && htable->count >= htable->max_entries) {
+			spin_unlock_bh(&htable->lock);
+			rcu_read_unlock();
+			return -EFBIG;
+		}
+		hlist_add_head_rcu(&l_new->hash_node, head);
+		if (l_old) {
+			hlist_del_rcu(&l_old->hash_node);
+			hash_table_release_element(htable, l_old);
+		} else {
+			htable->count++;
+		}
+		spin_unlock_bh(&htable->lock);
+
+		rcu_read_unlock();
+	}
+
+	return 0;
+}
+
+int bpf_dp_delete_table_element(struct plum *plum, u32 table_id,
+				const char *key_data)
+{
+	struct plum_table *table;
+	struct plum_hash_elem *l;
+	u32 key_size;
+
+	table = get_table(plum, table_id);
+	if (!table)
+		return -EINVAL;
+
+	key_size = table->info.key_size;
+
+	if (table->info.type == BPF_TABLE_HASH) {
+		rcu_read_lock();
+		l = hash_table_find(table->base, key_data, key_size);
+		if (l)
+			hash_table_remove(table->base, l);
+		rcu_read_unlock();
+	}
+
+	return 0;
+}
+
+/* Must be called with rcu_read_lock. */
+void *bpf_dp_read_table_element(struct plum *plum, u32 table_id,
+				const char *key_data, u32 *elem_size)
+{
+	struct plum_table *table;
+	struct plum_hash_elem *l;
+	u32 key_size;
+
+	table = get_table(plum, table_id);
+	if (!table)
+		return ERR_PTR(-EINVAL);
+
+	key_size = table->info.key_size;
+
+	if (table->info.type == BPF_TABLE_HASH) {
+		l = hash_table_find(table->base, key_data, key_size);
+		if (l) {
+			*elem_size = key_size + table->info.elem_size +
+				     sizeof(int);
+			return &l->hit_cnt.counter;
+		}
+	}
+
+	return ERR_PTR(-ESRCH);
+}
+
+/* Must be called with rcu_read_lock. */
+void *bpf_dp_read_table_element_next(struct plum *plum, u32 table_id,
+				     u32 *row, u32 *last, u32 *elem_size)
+{
+	struct plum_table *table;
+	struct plum_hash_table *htable;
+	struct hlist_head *head;
+	struct plum_hash_elem *l;
+	u32 key_size;
+	int i;
+
+	table = get_table(plum, table_id);
+	if (!table)
+		return ERR_PTR(-EINVAL);
+
+	key_size = table->info.key_size;
+
+	if (table->info.type == BPF_TABLE_HASH) {
+		htable = table->base;
+		*elem_size = key_size + table->info.elem_size + sizeof(int);
+		while (*row < htable->n_buckets) {
+			i = 0;
+			head = &htable->buckets[*row];
+			hlist_for_each_entry_rcu(l, head, hash_node) {
+				if (i < *last) {
+					i++;
+					continue;
+				}
+				*last = i + 1;
+				return &l->hit_cnt.counter;
+			}
+			(*row)++;
+			*last = 0;
+		}
+	}
+
+	return NULL;
+}
+
+static void free_hash_table_work(struct work_struct *work)
+{
+	struct plum_hash_table *table = container_of(work,
+						struct plum_hash_table, work);
+	kmem_cache_destroy(table->leaf_cache);
+	kfree(table);
+}
+
+static void free_hash_table(struct plum_hash_table *table)
+{
+	kfree(table->buckets);
+	schedule_work(&table->work);
+}
+
+static int init_hash_table(struct plum_table *table, u32 plum_id)
+{
+	int ret;
+	int i;
+	u32 n_buckets = table->info.max_entries;
+	u32 leaf_size;
+	struct plum_hash_table *htable;
+
+	/* hash table size must be power of 2 */
+	if ((n_buckets & (n_buckets - 1)) != 0) {
+		pr_err("pg_hash_table_init size %d is not power of 2\n",
+		       n_buckets);
+		return -EINVAL;
+	}
+
+	leaf_size = sizeof(struct plum_hash_elem) + table->info.key_size +
+		    table->info.elem_size;
+
+	ret = -ENOMEM;
+	htable = kzalloc(sizeof(*htable), GFP_KERNEL);
+	if (!htable)
+		goto err;
+
+	snprintf(htable->slab_name, sizeof(htable->slab_name),
+		 "plum_%u_hashtab_%u", plum_id, table->info.elem_size);
+
+	spin_lock_init(&htable->lock);
+	htable->max_entries = table->info.max_entries;
+	htable->n_buckets = n_buckets;
+	htable->key_size = table->info.key_size;
+	htable->leaf_size = leaf_size;
+	htable->leaf_cache = kmem_cache_create(htable->slab_name, leaf_size, 0,
+					       0, NULL);
+	if (!htable->leaf_cache)
+		goto err_free_table;
+
+	htable->buckets = kmalloc(n_buckets * sizeof(struct hlist_head),
+				 GFP_KERNEL);
+	if (!htable->buckets)
+		goto err_destroy_cache;
+
+	for (i = 0; i < n_buckets; i++)
+		INIT_HLIST_HEAD(&htable->buckets[i]);
+
+	table->base = htable;
+
+	INIT_WORK(&htable->work, free_hash_table_work);
+
+	return 0;
+
+err_destroy_cache:
+	kmem_cache_destroy(htable->leaf_cache);
+err_free_table:
+	kfree(htable);
+err:
+	return ret;
+}
+
+int init_plum_tables(struct plum *plum, u32 plum_id)
+{
+	int ret;
+	int i;
+	struct plum_table *table;
+
+	for (i = 0; i < plum->num_tables; i++) {
+		table = &plum->tables[i];
+		if (table->info.id > PLUM_MAX_TABLES) {
+			pr_err("table_id %d is too large\n", table->info.id);
+			continue;
+		}
+
+		if (table->info.type == BPF_TABLE_HASH) {
+			ret = init_hash_table(table, plum_id);
+			if (ret)
+				goto err_cleanup;
+		} else {
+			pr_err("table_type %d is unknown\n", table->info.type);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+
+err_cleanup:
+	for (i = 0; i < plum->num_tables; i++) {
+		table = &plum->tables[i];
+		if (!table->base)
+			continue;
+		if (table->info.type == BPF_TABLE_HASH)
+			free_hash_table(table->base);
+	}
+
+	return ret;
+}
+
+void cleanup_plum_tables(struct plum *plum)
+{
+	int i;
+	struct plum_table *table;
+
+	for (i = 0; i < plum->num_tables; i++) {
+		table = &plum->tables[i];
+
+		if (table->info.type == BPF_TABLE_HASH)
+			hash_table_clear_elements(table->base);
+	}
+}
+
+void free_plum_tables(struct plum *plum)
+{
+	int i;
+	struct plum_table *table;
+
+	for (i = 0; i < plum->num_tables; i++) {
+		table = &plum->tables[i];
+
+		if (table->info.type == BPF_TABLE_HASH)
+			free_hash_table(table->base);
+	}
+
+	kfree(plum->tables);
+}
+
+/* bpf_check() verified that 'pctx' is a valid pointer, table_id is a valid
+ * table_id and 'key' points to valid region inside BPF program stack
+ */
+void *bpf_table_lookup(struct bpf_context *pctx, int table_id, const void *key)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+	struct plum_table *table;
+	struct plum_hash_table *htable;
+	struct plum_hash_elem *helem;
+
+	if (!ctx->skb ||
+	    ctx->context.plum_id >= DP_MAX_PLUMS)
+		return NULL;
+
+	plum = rcu_dereference(dp->plums[pctx->plum_id]);
+
+	table = get_table(plum, table_id);
+	if (!table) {
+		pr_err("table_lookup plumg_id:table_id %d:%d not found\n",
+		       ctx->context.plum_id, table_id);
+		return NULL;
+	}
+
+	switch (table->info.type) {
+	case BPF_TABLE_HASH:
+		htable = table->base;
+		if (!htable) {
+			pr_err("table_lookup plumg_id:table_id %d:%d empty\n",
+			       ctx->context.plum_id, table_id);
+			return NULL;
+		}
+
+		helem = hash_table_lookup(htable, key, htable->key_size, 1);
+		if (helem)
+			return helem->key + htable->key_size;
+		break;
+	default:
+		break;
+	}
+
+	return NULL;
+}
+
+int bpf_table_update(struct bpf_context *pctx, int table_id, const void *key,
+		     const void *leaf)
+{
+	struct bpf_dp_context *ctx = container_of(pctx, struct bpf_dp_context,
+						  context);
+	struct datapath *dp = ctx->dp;
+	struct plum *plum;
+	int ret;
+
+	if (!ctx->skb ||
+	    ctx->context.plum_id >= DP_MAX_PLUMS)
+		return -EINVAL;
+
+	plum = rcu_dereference(dp->plums[pctx->plum_id]);
+	ret = bpf_dp_update_table_element(plum, table_id, key, leaf);
+
+	return ret;
+}
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2aa13bd..785ba71 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -119,7 +119,7 @@ static int queue_userspace_packet(struct net *, int dp_ifindex,
 				  const struct dp_upcall_info *);
 
 /* Must be called with rcu_read_lock or ovs_mutex. */
-static struct datapath *get_dp(struct net *net, int dp_ifindex)
+struct datapath *get_dp(struct net *net, int dp_ifindex)
 {
 	struct datapath *dp = NULL;
 	struct net_device *dev;
@@ -168,6 +168,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 	ovs_flow_tbl_destroy((__force struct flow_table *)dp->table, false);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
+	kfree(dp->plums);
 	kfree(dp->ports);
 	kfree(dp);
 }
@@ -210,6 +211,9 @@ void ovs_dp_detach_port(struct vport *p)
 {
 	ASSERT_OVSL();
 
+	/* Disconnect port from BPFs */
+	bpf_dp_disconnect_port(p);
+
 	/* First drop references to device. */
 	hlist_del_rcu(&p->dp_hash_node);
 
@@ -240,6 +244,16 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	flow = ovs_flow_lookup(rcu_dereference(dp->table), &key);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
+		struct plum *plum;
+
+		stats_counter = &stats->n_missed;
+
+		/* BPF enabled */
+		plum = rcu_dereference(dp->plums[0]);
+		if (atomic_read(&plum->ports[p->port_no])) {
+			bpf_dp_process_received_packet(p, skb);
+			goto out;
+		}
 
 		upcall.cmd = OVS_PACKET_CMD_MISS;
 		upcall.key = &key;
@@ -247,7 +261,6 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 		upcall.portid = p->upcall_portid;
 		ovs_dp_upcall(dp, skb, &upcall);
 		consume_skb(skb);
-		stats_counter = &stats->n_missed;
 		goto out;
 	}
 
@@ -275,6 +288,32 @@ static struct genl_family dp_packet_genl_family = {
 	.parallel_ops = true,
 };
 
+static int queue_userdata(struct net *net, int dp_ifindex,
+			  const struct dp_upcall_info *upcall_info)
+{
+	const struct nlattr *userdata = upcall_info->userdata;
+	struct ovs_header *ovs_header;
+	struct sk_buff *user_skb;
+
+	if (!userdata)
+		return -EINVAL;
+
+	user_skb = genlmsg_new(NLMSG_ALIGN(sizeof(struct ovs_header)) +
+			       NLA_ALIGN(userdata->nla_len), GFP_ATOMIC);
+	if (!user_skb)
+		return -ENOMEM;
+
+	ovs_header = genlmsg_put(user_skb, 0, 0, &dp_packet_genl_family, 0,
+				 upcall_info->cmd);
+	ovs_header->dp_ifindex = dp_ifindex;
+
+	__nla_put(user_skb, OVS_PACKET_ATTR_USERDATA,
+		  nla_len(userdata), nla_data(userdata));
+
+	genlmsg_end(user_skb, ovs_header);
+	return genlmsg_unicast(net, user_skb, upcall_info->portid);
+}
+
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 		  const struct dp_upcall_info *upcall_info)
 {
@@ -293,7 +332,9 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 		goto err;
 	}
 
-	if (!skb_is_gso(skb))
+	if (!skb)
+		err = queue_userdata(ovs_dp_get_net(dp), dp_ifindex, upcall_info);
+	else if (!skb_is_gso(skb))
 		err = queue_userspace_packet(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
 	else
 		err = queue_gso_packets(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
@@ -338,12 +379,14 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 			 * in this case is for a first fragment, so we need to
 			 * properly mark later fragments.
 			 */
-			later_key = *upcall_info->key;
-			later_key.ip.frag = OVS_FRAG_TYPE_LATER;
+			if (upcall_info->key) {
+				later_key = *upcall_info->key;
+				later_key.ip.frag = OVS_FRAG_TYPE_LATER;
 
-			later_info = *upcall_info;
-			later_info.key = &later_key;
-			upcall_info = &later_info;
+				later_info = *upcall_info;
+				later_info.key = &later_key;
+				upcall_info = &later_info;
+			}
 		}
 	} while ((skb = skb->next));
 
@@ -434,9 +477,12 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 			     0, upcall_info->cmd);
 	upcall->dp_ifindex = dp_ifindex;
 
-	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	ovs_flow_to_nlattrs(upcall_info->key, upcall_info->key, user_skb);
-	nla_nest_end(user_skb, nla);
+	if (upcall_info->key) {
+		nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
+		ovs_flow_to_nlattrs(upcall_info->key, upcall_info->key,
+				    user_skb);
+		nla_nest_end(user_skb, nla);
+	}
 
 	if (upcall_info->userdata)
 		__nla_put(user_skb, OVS_PACKET_ATTR_USERDATA,
@@ -1708,6 +1754,19 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++)
 		INIT_HLIST_HEAD(&dp->ports[i]);
 
+	/* Allocate BPF table. */
+	dp->plums = kzalloc(DP_MAX_PLUMS * sizeof(struct plum *), GFP_KERNEL);
+	if (!dp->plums) {
+		err = -ENOMEM;
+		goto err_destroy_ports_array;
+	}
+
+	dp->plums[0] = kzalloc(sizeof(struct plum), GFP_KERNEL);
+	if (!dp->plums[0]) {
+		err = -ENOMEM;
+		goto err_destroy_plums_array;
+	}
+
 	/* Set up our datapath device. */
 	parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
 	parms.type = OVS_VPORT_TYPE_INTERNAL;
@@ -1722,7 +1781,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		if (err == -EBUSY)
 			err = -EEXIST;
 
-		goto err_destroy_ports_array;
+		goto err_destroy_plum0;
 	}
 
 	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
@@ -1741,6 +1800,10 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 err_destroy_local_port:
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
+err_destroy_plum0:
+	kfree(dp->plums[0]);
+err_destroy_plums_array:
+	kfree(dp->plums);
 err_destroy_ports_array:
 	kfree(dp->ports);
 err_destroy_percpu:
@@ -1772,6 +1835,9 @@ static void __dp_destroy(struct datapath *dp)
 
 	list_del_rcu(&dp->list_node);
 
+	for (i = 0; i < DP_MAX_PLUMS; i++)
+		bpf_dp_unregister_plum(dp->plums[i]);
+
 	/* OVSP_LOCAL is datapath internal port. We need to make sure that
 	 * all port in datapath are destroyed first before freeing datapath.
 	 */
@@ -2296,6 +2362,9 @@ static const struct genl_family_and_ops dp_genl_families[] = {
 	{ &dp_packet_genl_family,
 	  dp_packet_genl_ops, ARRAY_SIZE(dp_packet_genl_ops),
 	  NULL },
+	{ &dp_bpf_genl_family,
+	  dp_bpf_genl_ops, ARRAY_SIZE(dp_bpf_genl_ops),
+	  NULL },
 };
 
 static void dp_unregister_genl(int n_families)
@@ -2407,10 +2476,14 @@ static int __init dp_init(void)
 	if (err)
 		goto error_flow_exit;
 
-	err = register_pernet_device(&ovs_net_ops);
+	err = ovs_bpf_init();
 	if (err)
 		goto error_vport_exit;
 
+	err = register_pernet_device(&ovs_net_ops);
+	if (err)
+		goto error_bpf_exit;
+
 	err = register_netdevice_notifier(&ovs_dp_device_notifier);
 	if (err)
 		goto error_netns_exit;
@@ -2427,6 +2500,8 @@ error_unreg_notifier:
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 error_netns_exit:
 	unregister_pernet_device(&ovs_net_ops);
+error_bpf_exit:
+	ovs_bpf_exit();
 error_vport_exit:
 	ovs_vport_exit();
 error_flow_exit:
@@ -2442,6 +2517,7 @@ static void dp_cleanup(void)
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 	unregister_pernet_device(&ovs_net_ops);
 	rcu_barrier();
+	ovs_bpf_exit();
 	ovs_vport_exit();
 	ovs_flow_exit();
 }
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 4d109c1..c2923a4 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -28,6 +28,7 @@
 
 #include "flow.h"
 #include "vport.h"
+#include "dp_bpf.h"
 
 #define DP_MAX_PORTS           USHRT_MAX
 #define DP_VPORT_HASH_BUCKETS  1024
@@ -83,6 +84,9 @@ struct datapath {
 	/* Network namespace ref. */
 	struct net *net;
 #endif
+
+	/* BPF extension */
+	struct plum **plums;
 };
 
 /**
@@ -130,6 +134,7 @@ struct ovs_net {
 extern int ovs_net_id;
 void ovs_lock(void);
 void ovs_unlock(void);
+struct datapath *get_dp(struct net *net, int dp_ifindex);
 
 #ifdef CONFIG_LOCKDEP
 int lockdep_ovsl_is_held(void);
diff --git a/net/openvswitch/dp_bpf.c b/net/openvswitch/dp_bpf.c
new file mode 100644
index 0000000..d638616
--- /dev/null
+++ b/net/openvswitch/dp_bpf.c
@@ -0,0 +1,1228 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/openvswitch.h>
+#include "datapath.h"
+
+struct kmem_cache *plum_stack_cache;
+
+struct genl_family dp_bpf_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = sizeof(struct ovs_header),
+	.name = OVS_BPF_FAMILY,
+	.version = OVS_BPF_VERSION,
+	.maxattr = OVS_BPF_ATTR_MAX,
+	.netnsok = true,
+	.parallel_ops = true,
+};
+
+static const struct nla_policy bpf_policy[OVS_BPF_ATTR_MAX + 1] = {
+	[OVS_BPF_ATTR_PLUM] = { .type = NLA_UNSPEC },
+	[OVS_BPF_ATTR_PLUM_ID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_PORT_ID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_UPCALL_PID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_DEST_PLUM_ID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_DEST_PORT_ID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_TABLE_ID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_KEY_OBJ] = { .type = NLA_UNSPEC },
+	[OVS_BPF_ATTR_LEAF_OBJ] = { .type = NLA_UNSPEC },
+	[OVS_BPF_ATTR_REPLICATOR_ID] = { .type = NLA_U32 },
+	[OVS_BPF_ATTR_PACKET] = { .type = NLA_UNSPEC },
+	[OVS_BPF_ATTR_DIRECTION] = { .type = NLA_U32 }
+};
+
+static struct sk_buff *gen_reply_u32(u32 pid, u32 value)
+{
+	struct sk_buff *skb;
+	int ret;
+	void *data;
+
+	skb = genlmsg_new(nla_total_size(sizeof(u32)), GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	data = genlmsg_put(skb, pid, 0, &dp_bpf_genl_family, 0, 0);
+	if (!data) {
+		ret = -EMSGSIZE;
+		goto error;
+	}
+
+	ret = nla_put_u32(skb, OVS_BPF_ATTR_UNSPEC, value);
+	if (ret < 0)
+		goto error;
+
+	genlmsg_end(skb, data);
+
+	return skb;
+
+error:
+	kfree_skb(skb);
+	return ERR_PTR(ret);
+}
+
+static struct sk_buff *gen_reply_unspec(u32 pid, u32 len, void *ptr)
+{
+	struct sk_buff *skb;
+	int ret;
+	void *data;
+
+	skb = genlmsg_new(nla_total_size(len), GFP_ATOMIC);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	data = genlmsg_put(skb, pid, 0, &dp_bpf_genl_family, 0, 0);
+	if (!data) {
+		ret = -EMSGSIZE;
+		goto error;
+	}
+
+	ret = nla_put(skb, OVS_BPF_ATTR_UNSPEC, len, ptr);
+	if (ret < 0)
+		goto error;
+
+	genlmsg_end(skb, data);
+
+	return skb;
+
+error:
+	kfree_skb(skb);
+	return ERR_PTR(ret);
+}
+
+static void reset_port_stats(struct plum *plum, u32 port_id)
+{
+	int i;
+	struct pcpu_port_stats *stats;
+
+	for_each_possible_cpu(i) {
+		stats = per_cpu_ptr(plum->stats[port_id], i);
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_packets = 0;
+		stats->rx_bytes = 0;
+		stats->rx_mcast_packets = 0;
+		stats->rx_mcast_bytes = 0;
+		stats->tx_packets = 0;
+		stats->tx_bytes = 0;
+		stats->tx_mcast_packets = 0;
+		stats->tx_mcast_bytes = 0;
+		u64_stats_update_end(&stats->syncp);
+	}
+}
+
+static int get_port_stats(struct plum *plum, u32 port_id,
+			  struct ovs_bpf_port_stats *stats)
+{
+	int i;
+	const struct pcpu_port_stats *pstats;
+	struct pcpu_port_stats local_pstats;
+	int start;
+
+	if (!plum->stats[port_id])
+		return -EINVAL;
+
+	memset(stats, 0, sizeof(*stats));
+
+	for_each_possible_cpu(i) {
+		pstats = per_cpu_ptr(plum->stats[port_id], i);
+
+		do {
+			start = u64_stats_fetch_begin_bh(&pstats->syncp);
+			local_pstats = *pstats;
+		} while (u64_stats_fetch_retry_bh(&pstats->syncp, start));
+
+		stats->rx_packets += local_pstats.rx_packets;
+		stats->rx_bytes += local_pstats.rx_bytes;
+		stats->rx_mcast_packets += local_pstats.rx_mcast_packets;
+		stats->rx_mcast_bytes += local_pstats.rx_mcast_bytes;
+		stats->tx_packets += local_pstats.tx_packets;
+		stats->tx_bytes += local_pstats.tx_bytes;
+		stats->tx_mcast_packets += local_pstats.tx_mcast_packets;
+		stats->tx_mcast_bytes += local_pstats.tx_mcast_bytes;
+	}
+
+	return 0;
+}
+
+static int ovs_bpf_cmd_register_plum(struct sk_buff *skb,
+				     struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	int ret;
+	u32 plum_id = -EINVAL;
+	struct plum *plum;
+	u32 upcall_pid;
+	struct bpf_image *image;
+
+	if (!a[OVS_BPF_ATTR_PLUM] || !a[OVS_BPF_ATTR_UPCALL_PID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	image = nla_data(a[OVS_BPF_ATTR_PLUM]);
+
+	if (nla_len(a[OVS_BPF_ATTR_PLUM]) != sizeof(struct bpf_image)) {
+		pr_err("unsupported plum size %d\n",
+		       nla_len(a[OVS_BPF_ATTR_PLUM]));
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	upcall_pid = nla_get_u32(a[OVS_BPF_ATTR_UPCALL_PID]);
+
+	for (plum_id = 1;; plum_id++) {
+		if (plum_id >= DP_MAX_PLUMS) {
+			ret = -EFBIG;
+			goto exit_unlock;
+		}
+		plum = ovsl_dereference(dp->plums[plum_id]);
+		if (!plum)
+			break;
+	}
+
+	plum = bpf_dp_register_plum(image, NULL, plum_id);
+	ret = PTR_ERR(plum);
+	if (IS_ERR(plum))
+		goto exit_unlock;
+
+	plum->upcall_pid = upcall_pid;
+	rcu_assign_pointer(dp->plums[plum_id], plum);
+
+	reply = gen_reply_u32(info->snd_portid, plum_id);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+static int ovs_bpf_cmd_unregister_plum(struct sk_buff *skb,
+				       struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	u32 plum_id;
+	struct plum *plum;
+	struct plum *dest_plum;
+	u32 dest;
+	int ret;
+	int i;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	for (i = 0; i < PLUM_MAX_PORTS; i++) {
+		dest = atomic_read(&plum->ports[i]);
+		if (dest) {
+			dest_plum = ovsl_dereference(dp->plums[dest >> 16]);
+			if (!dest_plum)
+				continue;
+			atomic_set(&dest_plum->ports[dest & 0xffff], 0);
+		}
+	}
+
+	rcu_assign_pointer(dp->plums[plum_id], NULL);
+
+	bpf_dp_unregister_plum(plum);
+
+	reply = gen_reply_u32(info->snd_portid, plum_id);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+static int validate_ports(struct datapath *dp, u32 plum_id, u32 port_id,
+			  u32 dest_plum_id, u32 dest_port_id)
+{
+	if (plum_id >= DP_MAX_PLUMS || dest_plum_id >= DP_MAX_PLUMS) {
+		pr_err("validate_ports(%d, %d, %d, %d): plum_id is too large",
+		       plum_id, port_id, dest_plum_id, dest_port_id);
+		return -EFBIG;
+	} else if (MUX(plum_id, port_id) == 0 ||
+		   MUX(dest_plum_id, dest_port_id) == 0 ||
+		   plum_id == dest_plum_id) {
+		pr_err("validate_ports(%d, %d, %d, %d): plum/port combination is invalid\n",
+		       plum_id, port_id, dest_plum_id, dest_port_id);
+		return -EINVAL;
+	} else if (port_id >= PLUM_MAX_PORTS ||
+		   dest_port_id >= PLUM_MAX_PORTS) {
+		pr_err("validate_ports(%d, %d, %d, %d): port_id is too large\n",
+		       plum_id, port_id, dest_plum_id, dest_port_id);
+		return -EFBIG;
+	}
+	if (plum_id == 0) {
+		struct vport *vport;
+		vport = ovs_vport_ovsl_rcu(dp, port_id);
+		if (!vport) {
+			pr_err("validate_ports(%d, %d, %d, %d): vport doesn't exist\n",
+			       plum_id, port_id, dest_plum_id, dest_port_id);
+			return -EINVAL;
+		}
+	}
+	if (dest_plum_id == 0) {
+		struct vport *dest_vport;
+		dest_vport = ovs_vport_ovsl_rcu(dp, dest_port_id);
+		if (!dest_vport) {
+			pr_err("validate_ports(%d, %d, %d, %d): vport doesn't exist\n",
+			       plum_id, port_id, dest_plum_id, dest_port_id);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+/* connect_ports(src_plum_id, src_port_id, dest_plum_id, dest_port_id)
+ * establishes bi-directional virtual wire between two plums
+ */
+static int ovs_bpf_cmd_connect_ports(struct sk_buff *skb,
+				     struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	u32 plum_id, port_id, dest_plum_id, dest_port_id;
+	struct plum *plum, *dest_plum;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_PORT_ID] ||
+	    !a[OVS_BPF_ATTR_DEST_PLUM_ID] || !a[OVS_BPF_ATTR_DEST_PORT_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	dest_plum_id = nla_get_u32(a[OVS_BPF_ATTR_DEST_PLUM_ID]);
+	port_id = nla_get_u32(a[OVS_BPF_ATTR_PORT_ID]);
+	dest_port_id = nla_get_u32(a[OVS_BPF_ATTR_DEST_PORT_ID]);
+
+	ret = validate_ports(dp, plum_id, port_id, dest_plum_id, dest_port_id);
+	if (ret != 0)
+		goto exit_unlock;
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	dest_plum = ovsl_dereference(dp->plums[dest_plum_id]);
+	if (!plum || !dest_plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	if (atomic_read(&plum->ports[port_id]) != 0 ||
+	    atomic_read(&dest_plum->ports[dest_port_id]) != 0) {
+		ret = -EBUSY;
+		goto exit_unlock;
+	}
+
+	if (!plum->stats[port_id]) {
+		plum->stats[port_id] = alloc_percpu(struct pcpu_port_stats);
+		if (!plum->stats[port_id]) {
+			ret = -ENOMEM;
+			goto exit_unlock;
+		}
+	} else {
+		reset_port_stats(plum, port_id);
+	}
+
+	if (!dest_plum->stats[dest_port_id]) {
+		dest_plum->stats[dest_port_id] =
+			alloc_percpu(struct pcpu_port_stats);
+		if (!dest_plum->stats[dest_port_id]) {
+			ret = -ENOMEM;
+			goto exit_unlock;
+		}
+	} else {
+		reset_port_stats(dest_plum, dest_port_id);
+	}
+
+	atomic_set(&plum->ports[port_id], MUX(dest_plum_id, dest_port_id));
+	atomic_set(&dest_plum->ports[dest_port_id], MUX(plum_id, port_id));
+	smp_wmb();
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* disconnect_ports(src_plum_id, src_port_id, dest_plum_id, dest_port_id)
+ * removes virtual wire between two plums
+ */
+static int ovs_bpf_cmd_disconnect_ports(struct sk_buff *skb,
+					struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	u32 plum_id, port_id, dest_plum_id, dest_port_id;
+	struct plum *plum, *dest_plum;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_PORT_ID] ||
+	    !a[OVS_BPF_ATTR_DEST_PLUM_ID] || !a[OVS_BPF_ATTR_DEST_PORT_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	dest_plum_id = nla_get_u32(a[OVS_BPF_ATTR_DEST_PLUM_ID]);
+	port_id = nla_get_u32(a[OVS_BPF_ATTR_PORT_ID]);
+	dest_port_id = nla_get_u32(a[OVS_BPF_ATTR_DEST_PORT_ID]);
+
+	ret = validate_ports(dp, plum_id, port_id, dest_plum_id, dest_port_id);
+	if (ret != 0)
+		goto exit_unlock;
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	dest_plum = ovsl_dereference(dp->plums[dest_plum_id]);
+
+	if (plum)
+		atomic_set(&plum->ports[port_id], 0);
+	if (dest_plum)
+		atomic_set(&dest_plum->ports[dest_port_id], 0);
+	smp_wmb();
+
+	/* leave the stats allocated until plum is freed */
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* update_table_element(plum_id, table_id, key, value) */
+static int ovs_bpf_cmd_update_table_element(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, table_id;
+	char *key_data, *leaf_data;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_TABLE_ID] ||
+	    !a[OVS_BPF_ATTR_KEY_OBJ] || !a[OVS_BPF_ATTR_LEAF_OBJ])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	table_id = nla_get_u32(a[OVS_BPF_ATTR_TABLE_ID]);
+	if (table_id >= plum->num_tables) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	key_data = nla_data(a[OVS_BPF_ATTR_KEY_OBJ]);
+	leaf_data = nla_data(a[OVS_BPF_ATTR_LEAF_OBJ]);
+
+	ret = bpf_dp_update_table_element(plum, table_id, key_data, leaf_data);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* clear_table_elements(plum_id, table_id) */
+static int ovs_bpf_cmd_clear_table_elements(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, table_id;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_TABLE_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	table_id = nla_get_u32(a[OVS_BPF_ATTR_TABLE_ID]);
+	if (table_id >= plum->num_tables) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	ret = bpf_dp_clear_table_elements(plum, table_id);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* delete_table_element(plum_id, table_id, key) */
+static int ovs_bpf_cmd_delete_table_element(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, table_id;
+	char *key_data;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_TABLE_ID] ||
+	    !a[OVS_BPF_ATTR_KEY_OBJ])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	table_id = nla_get_u32(a[OVS_BPF_ATTR_TABLE_ID]);
+	if (table_id >= plum->num_tables) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	key_data = nla_data(a[OVS_BPF_ATTR_KEY_OBJ]);
+
+	ret = bpf_dp_delete_table_element(plum, table_id, key_data);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* read_table_element(plum_id, table_id, key) */
+static int ovs_bpf_cmd_read_table_element(struct sk_buff *skb,
+					  struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, table_id;
+	char *key_data;
+	void *elem_data;
+	u32 elem_size;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_TABLE_ID] ||
+	    !a[OVS_BPF_ATTR_KEY_OBJ])
+		return -EINVAL;
+
+	rcu_read_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = rcu_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	table_id = nla_get_u32(a[OVS_BPF_ATTR_TABLE_ID]);
+	if (table_id >= plum->num_tables) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	key_data = nla_data(a[OVS_BPF_ATTR_KEY_OBJ]);
+
+	elem_data = bpf_dp_read_table_element(plum, table_id, key_data,
+					      &elem_size);
+	if (IS_ERR(elem_data)) {
+		ret = PTR_ERR(elem_data);
+		goto exit_unlock;
+	}
+
+	reply = gen_reply_unspec(info->snd_portid, elem_size, elem_data);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	rcu_read_unlock();
+
+	return ret;
+}
+
+/* read_table_elements(plum_id, table_id) via dumpit */
+static int ovs_bpf_cmd_read_table_elements(struct sk_buff *skb,
+					   struct netlink_callback *cb)
+{
+	struct nlattr *nla_plum_id, *nla_table_id;
+	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, table_id;
+	u32 row, obj;
+	void *data;
+	void *elem_data;
+	u32 elem_size;
+	int ret = 0;
+
+	nla_plum_id = nlmsg_find_attr(cb->nlh, GENL_HDRLEN +
+				      sizeof(struct ovs_header),
+				      OVS_BPF_ATTR_PLUM_ID);
+	nla_table_id = nlmsg_find_attr(cb->nlh, GENL_HDRLEN +
+				       sizeof(struct ovs_header),
+				       OVS_BPF_ATTR_TABLE_ID);
+	if (!nla_plum_id || !nla_table_id)
+		return -EINVAL;
+
+	rcu_read_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(nla_plum_id);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = rcu_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	table_id = nla_get_u32(nla_table_id);
+	if (table_id >= plum->num_tables) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	for (;;) {
+		row = cb->args[0];
+		obj = cb->args[1];
+
+		elem_data = bpf_dp_read_table_element_next(plum, table_id,
+							   &row, &obj,
+							   &elem_size);
+		if (IS_ERR(elem_data)) {
+			ret = PTR_ERR(elem_data);
+			goto exit_unlock;
+		}
+
+		if (!elem_data)
+			goto exit_unlock;
+
+		data = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, 0,
+				   &dp_bpf_genl_family, NLM_F_MULTI, 0);
+		if (!data)
+			goto exit_unlock;
+
+		ret = nla_put(skb, OVS_BPF_ATTR_UNSPEC, elem_size, elem_data);
+		if (ret < 0) {
+			genlmsg_cancel(skb, data);
+			ret = 0;
+			goto exit_unlock;
+		}
+
+		genlmsg_end(skb, data);
+
+		cb->args[0] = row;
+		cb->args[1] = obj;
+	}
+
+exit_unlock:
+	rcu_read_unlock();
+
+	return ret < 0 ? ret : skb->len;
+}
+
+/* del_replicator(plum_id, replicator_id) */
+static int ovs_bpf_cmd_del_replicator(struct sk_buff *skb,
+				      struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, replicator_id;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_REPLICATOR_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	replicator_id = nla_get_u32(a[OVS_BPF_ATTR_REPLICATOR_ID]);
+	if (replicator_id >= PLUM_MAX_REPLICATORS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	ret = bpf_dp_replicator_del_all(plum, replicator_id);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* add_port_to_replicator(plum_id, replicator_id, port_id) */
+static int ovs_bpf_cmd_add_port_to_replicator(struct sk_buff *skb,
+					      struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, port_id, replicator_id;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_PORT_ID] ||
+	    !a[OVS_BPF_ATTR_REPLICATOR_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	port_id = nla_get_u32(a[OVS_BPF_ATTR_PORT_ID]);
+	if (port_id >= PLUM_MAX_PORTS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	replicator_id = nla_get_u32(a[OVS_BPF_ATTR_REPLICATOR_ID]);
+	if (replicator_id >= PLUM_MAX_REPLICATORS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	ret = bpf_dp_replicator_add_port(plum, replicator_id, port_id);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* del_port_from_replicator(plum_id, replicator_id, port_id) */
+static int ovs_bpf_cmd_del_port_from_replicator(struct sk_buff *skb,
+						struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, port_id, replicator_id;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_PORT_ID] ||
+	    !a[OVS_BPF_ATTR_REPLICATOR_ID])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = ovsl_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	port_id = nla_get_u32(a[OVS_BPF_ATTR_PORT_ID]);
+	if (port_id >= PLUM_MAX_PORTS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	replicator_id = nla_get_u32(a[OVS_BPF_ATTR_REPLICATOR_ID]);
+	if (replicator_id >= PLUM_MAX_REPLICATORS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	ret = bpf_dp_replicator_del_port(plum, replicator_id, port_id);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* channel_push(plum_id, port_id, packet, direction) */
+static int ovs_bpf_cmd_channel_push(struct sk_buff *skb,
+				    struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	u32 plum_id, port_id, dir;
+	struct sk_buff *packet;
+	struct ethhdr *eth;
+	struct plum *plum;
+	int len;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_PORT_ID] ||
+	    !a[OVS_BPF_ATTR_PACKET] || !a[OVS_BPF_ATTR_DIRECTION])
+		return -EINVAL;
+
+	ovs_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = rcu_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	port_id = nla_get_u32(a[OVS_BPF_ATTR_PORT_ID]);
+	if (port_id >= PLUM_MAX_PORTS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	dir = nla_get_u32(a[OVS_BPF_ATTR_DIRECTION]);
+
+	len = nla_len(a[OVS_BPF_ATTR_PACKET]);
+	packet = __dev_alloc_skb(NET_IP_ALIGN + len, GFP_KERNEL);
+	if (!packet) {
+		ret = -ENOMEM;
+		goto exit_unlock;
+	}
+	skb_reserve(packet, NET_IP_ALIGN);
+
+	nla_memcpy(__skb_put(packet, len), a[OVS_BPF_ATTR_PACKET], len);
+
+	skb_reset_mac_header(packet);
+
+	eth = eth_hdr(packet);
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
+		packet->protocol = eth->h_proto;
+	else
+		packet->protocol = htons(ETH_P_802_2);
+
+	ret = bpf_dp_channel_push_on_plum(dp, plum_id, port_id, packet, dir);
+
+	reply = gen_reply_u32(info->snd_portid, ret);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	ovs_unlock();
+
+	return ret;
+}
+
+/* read_port_stats(plum_id, port_id) */
+static int ovs_bpf_cmd_read_port_stats(struct sk_buff *skb,
+				       struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct plum *plum;
+	u32 plum_id, port_id;
+	struct ovs_bpf_port_stats stats;
+	int ret;
+
+	if (!a[OVS_BPF_ATTR_PLUM_ID] || !a[OVS_BPF_ATTR_PORT_ID])
+		return -EINVAL;
+
+	rcu_read_lock();
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	plum_id = nla_get_u32(a[OVS_BPF_ATTR_PLUM_ID]);
+	if (plum_id >= DP_MAX_PLUMS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	plum = rcu_dereference(dp->plums[plum_id]);
+	if (!plum) {
+		ret = -EINVAL;
+		goto exit_unlock;
+	}
+
+	port_id = nla_get_u32(a[OVS_BPF_ATTR_PORT_ID]);
+	if (port_id >= PLUM_MAX_PORTS) {
+		ret = -EFBIG;
+		goto exit_unlock;
+	}
+
+	ret = get_port_stats(plum, port_id, &stats);
+	if (ret < 0)
+		goto exit_unlock;
+
+	reply = gen_reply_unspec(info->snd_portid, sizeof(stats), &stats);
+
+	if (IS_ERR(reply)) {
+		ret = PTR_ERR(reply);
+		goto exit_unlock;
+	}
+
+	ret = genlmsg_unicast(sock_net(skb->sk), reply, info->snd_portid);
+
+exit_unlock:
+	rcu_read_unlock();
+
+	return ret;
+}
+
+struct genl_ops dp_bpf_genl_ops[] = {
+	{ .cmd = OVS_BPF_CMD_REGISTER_PLUM,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_register_plum
+	},
+	{ .cmd = OVS_BPF_CMD_UNREGISTER_PLUM,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_unregister_plum
+	},
+	{ .cmd = OVS_BPF_CMD_CONNECT_PORTS,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_connect_ports
+	},
+	{ .cmd = OVS_BPF_CMD_DISCONNECT_PORTS,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_disconnect_ports
+	},
+	{ .cmd = OVS_BPF_CMD_CLEAR_TABLE_ELEMENTS,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_clear_table_elements
+	},
+	{ .cmd = OVS_BPF_CMD_DELETE_TABLE_ELEMENT,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_delete_table_element
+	},
+	{ .cmd = OVS_BPF_CMD_READ_TABLE_ELEMENT,
+	  .flags = 0,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_read_table_element,
+	  .dumpit = ovs_bpf_cmd_read_table_elements
+	},
+	{ .cmd = OVS_BPF_CMD_UPDATE_TABLE_ELEMENT,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_update_table_element
+	},
+	{ .cmd = OVS_BPF_CMD_DEL_REPLICATOR,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_del_replicator
+	},
+	{ .cmd = OVS_BPF_CMD_ADD_PORT_TO_REPLICATOR,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_add_port_to_replicator
+	},
+	{ .cmd = OVS_BPF_CMD_DEL_PORT_FROM_REPLICATOR,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_del_port_from_replicator
+	},
+	{ .cmd = OVS_BPF_CMD_CHANNEL_PUSH,
+	  .flags = GENL_ADMIN_PERM,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_channel_push
+	},
+	{ .cmd = OVS_BPF_CMD_READ_PORT_STATS,
+	  .flags = 0,
+	  .policy = bpf_policy,
+	  .doit = ovs_bpf_cmd_read_port_stats
+	},
+};
+
+/* Initializes the BPF module.
+ * Returns zero if successful or a negative error code.
+ */
+int ovs_bpf_init(void)
+{
+	plum_stack_cache = kmem_cache_create("plum_stack",
+					     sizeof(struct plum_stack_frame), 0,
+					     0, NULL);
+	if (plum_stack_cache == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/* Uninitializes the BPF module. */
+void ovs_bpf_exit(void)
+{
+	kmem_cache_destroy(plum_stack_cache);
+}
diff --git a/net/openvswitch/dp_bpf.h b/net/openvswitch/dp_bpf.h
new file mode 100644
index 0000000..4550434
--- /dev/null
+++ b/net/openvswitch/dp_bpf.h
@@ -0,0 +1,160 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#ifndef DP_BPF_H
+#define DP_BPF_H 1
+
+#include <net/genetlink.h>
+#include <linux/openvswitch.h>
+#include <linux/filter.h>
+
+#define DP_MAX_PLUMS 1024
+#define PLUM_MAX_PORTS 1000
+#define PLUM_MAX_TABLES 128
+#define PLUM_MAX_REPLICATORS 256
+
+/* PLUM is short of Packet Lookup Update Modify.
+ * It is using BPF program as core execution engine
+ * one plum = one BPF program
+ * BPF program can run BPF insns, call functions and access BPF tables
+ * PLUM provides the functions that BPF can call and semantics behind it
+ */
+
+struct pcpu_port_stats {
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 tx_packets;
+	u64 tx_bytes;
+	u64 rx_mcast_packets;
+	u64 rx_mcast_bytes;
+	u64 tx_mcast_packets;
+	u64 tx_mcast_bytes;
+	struct u64_stats_sync syncp;
+};
+
+/* 'bpf_context' is passed into BPF programs
+ * 'bpf_dp_context' encapsulates it
+ */
+struct bpf_dp_context {
+	struct bpf_context context;
+	struct sk_buff *skb;
+	struct datapath *dp;
+	struct plum_stack *stack;
+};
+
+struct plum_stack_frame {
+	struct bpf_dp_context ctx;
+	u32 dest; /* destination plum_id|port_id */
+	u32 kmem; /* if true this stack frame came from kmem_cache_alloc */
+	struct list_head link;
+};
+
+struct plum_stack {
+	struct list_head list; /* link list of plum_stack_frame's */
+	struct plum_stack_frame *curr_frame; /* current frame */
+	int push_cnt; /* number of frames pushed */
+};
+
+struct plum_hash_elem {
+	struct rcu_head rcu;
+	struct hlist_node hash_node;
+	struct plum_hash_table *table;
+	u32 hash;
+	atomic_t hit_cnt;
+	char key[0];
+};
+
+struct plum_hash_table {
+	spinlock_t lock;
+	struct kmem_cache *leaf_cache;
+	struct hlist_head *buckets;
+	u32 leaf_size;
+	u32 key_size;
+	u32 count;
+	u32 n_buckets;
+	u32 max_entries;
+	char slab_name[32];
+	struct work_struct work;
+};
+
+struct plum_table {
+	struct bpf_table info;
+	void *base;
+};
+
+struct plum_replicator_elem {
+	struct rcu_head rcu;
+	struct hlist_node hash_node;
+	u32 replicator_id;
+	u32 port_id;
+};
+
+struct plum {
+	struct rcu_head rcu;
+	struct bpf_program *bpf_prog;
+	struct plum_table *tables;
+	struct hlist_head *replicators;
+	u32 num_tables;
+	atomic_t ports[PLUM_MAX_PORTS];
+	u32 version;
+	u32 upcall_pid;
+	struct pcpu_port_stats __percpu *stats[PLUM_MAX_PORTS];
+	void (*run)(struct bpf_dp_context *ctx);
+};
+
+#define MUX(plum, port) ((((u32)plum) << 16) | (((u32)port) & 0xffff))
+
+extern struct kmem_cache *plum_stack_cache;
+
+extern struct genl_family dp_bpf_genl_family;
+extern struct genl_ops dp_bpf_genl_ops[OVS_BPF_CMD_MAX];
+
+int ovs_bpf_init(void);
+void ovs_bpf_exit(void);
+
+void bpf_dp_process_received_packet(struct vport *p, struct sk_buff *skb);
+struct plum *bpf_dp_register_plum(struct bpf_image *image,
+				  struct plum *old_plum, u32 plum_id);
+void bpf_dp_unregister_plum(struct plum *plum);
+void bpf_dp_disconnect_port(struct vport *p);
+int bpf_dp_channel_push_on_plum(struct datapath *, u32 plum_id, u32 port_id,
+				struct sk_buff *skb, u32 direction);
+void plum_stack_push(struct bpf_dp_context *ctx, u32 dest, int copy);
+void plum_update_stats(struct plum *plum, u32 port_id, struct sk_buff *skb,
+		       bool rx);
+
+int init_plum_tables(struct plum *plum, u32 plum_id);
+void cleanup_plum_tables(struct plum *plum);
+void free_plum_tables(struct plum *plum);
+int bpf_dp_clear_table_elements(struct plum *plum, u32 table_id);
+int bpf_dp_delete_table_element(struct plum *plum, u32 table_id,
+				const char *key_data);
+void *bpf_dp_read_table_element(struct plum *plum, u32 table_id,
+				const char *key_data, u32 *elem_size);
+void *bpf_dp_read_table_element_next(struct plum *plum, u32 table_id,
+				     u32 *row, u32 *last, u32 *elem_size);
+int bpf_dp_update_table_element(struct plum *plum, u32 table_id,
+				const char *key_data, const char *leaf_data);
+
+int bpf_dp_replicator_del_all(struct plum *plum, u32 replicator_id);
+int bpf_dp_replicator_add_port(struct plum *plum, u32 replicator_id,
+			       u32 port_id);
+int bpf_dp_replicator_del_port(struct plum *plum, u32 replicator_id,
+			       u32 port_id);
+void cleanup_plum_replicators(struct plum *plum);
+extern struct bpf_callbacks bpf_plum_cb;
+
+#endif /* dp_bpf.h */
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index c323567..e601f64 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -88,6 +88,13 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_UNREGISTER) {
+		/* unlink dev now, otherwise rollback_registered_many()
+		 * will complain of lack of upper_dev cleanup
+		 */
+		if (dev->reg_state == NETREG_UNREGISTERING)
+			ovs_netdev_unlink_dev(vport);
+
+		/* schedule vport destroy, dev_put and genl notification */
 		ovs_net = net_generic(dev_net(dev), ovs_net_id);
 		queue_work(system_wq, &ovs_net->dp_notify_work);
 	}
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index c99dea5..4c03dd9 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -47,16 +47,6 @@
 #include "datapath.h"
 #include "vport.h"
 
-/* Returns the least-significant 32 bits of a __be64. */
-static __be32 be64_get_low32(__be64 x)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be32)x;
-#else
-	return (__force __be32)((__force u64)x >> 32);
-#endif
-}
-
 static __be16 filter_tnl_flags(__be16 flags)
 {
 	return flags & (TUNNEL_CSUM | TUNNEL_KEY);
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 09d93c1..5505c5e 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -79,7 +79,7 @@ static struct net_device *get_dpdev(struct datapath *dp)
 {
 	struct vport *local;
 
-	local = ovs_vport_ovsl(dp, OVSP_LOCAL);
+	local = ovs_vport_ovsl_rcu(dp, OVSP_LOCAL);
 	BUG_ON(!local);
 	return netdev_vport_priv(local)->dev;
 }
@@ -150,15 +150,24 @@ static void free_port_rcu(struct rcu_head *rcu)
 	ovs_vport_free(vport_from_priv(netdev_vport));
 }
 
-static void netdev_destroy(struct vport *vport)
+void ovs_netdev_unlink_dev(struct vport *vport)
 {
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
 
-	rtnl_lock();
+	ASSERT_RTNL();
 	netdev_vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
 	netdev_rx_handler_unregister(netdev_vport->dev);
 	netdev_upper_dev_unlink(netdev_vport->dev, get_dpdev(vport->dp));
 	dev_set_promiscuity(netdev_vport->dev, -1);
+}
+
+static void netdev_destroy(struct vport *vport)
+{
+	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+
+	rtnl_lock();
+	if (netdev_vport->dev->reg_state != NETREG_UNREGISTERING)
+		ovs_netdev_unlink_dev(vport);
 	rtnl_unlock();
 
 	call_rcu(&netdev_vport->rcu, free_port_rcu);
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index dd298b5..21e3770 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -39,5 +39,6 @@ netdev_vport_priv(const struct vport *vport)
 }
 
 const char *ovs_netdev_get_name(const struct vport *);
+void ovs_netdev_unlink_dev(struct vport *);
 
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1a9fbce..0aedebc 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -208,4 +208,14 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
 }
 
+/* Returns the least-significant 32 bits of a __be64. */
+static inline __be32 be64_get_low32(__be64 x)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be32)x;
+#else
+	return (__force __be32)((__force u64)x >> 32);
+#endif
+}
+
 #endif /* vport.h */
-- 
1.7.9.5
