From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] bpf: expose netns inode to bpf programs
Date: Wed, 25 Jan 2017 19:27:54 -0800
Message-ID: <1485401274-2836524-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53681 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752576AbdAZD17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 22:27:59 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0Q3PR9v021713
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 19:27:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2875dmgkec-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 19:27:58 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 6d218256e37711e6820d24be05956610-d7f2a50 for <netdev@vger.kernel.org>; Wed,
 25 Jan 2017 19:27:55 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in cases where bpf programs are looking at sockets and packets
that belong to different netns, it could be useful to read netns inode,
so that programs can make intelligent decisions.
For example to disallow raw sockets in all non-init netns the program can do:
if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
  return 0;
where 0xf0000075 inode comes from /proc/pid/ns/net

Similarly TC cls_bpf/act_bpf and socket filters can do
if (skb->netns_inum == expected_inode)

The lack of netns awareness was a concern even for socket filters,
since the application can attach the same bpf program to sockets
in a different netns. Just like tc cls_bpf program can work in
different netns as well, so it has to be addressed uniformly
across all types of bpf programs.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
with corresponding change in 'ip vrf' that David Ahern is working on,
this will address 'malfunction' concern that Andy discovered in 'ip vrf',
hence this fix is needed for 'net'.
---
 include/uapi/linux/bpf.h      |  2 ++
 net/core/filter.c             | 27 +++++++++++++++++++++++++++
 samples/bpf/sock_flags_kern.c |  2 ++
 samples/bpf/sockex1_kern.c    |  3 +++
 4 files changed, 34 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0eb0e87dbe9f..867cbe043d77 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -546,6 +546,7 @@ struct __sk_buff {
 	__u32 tc_classid;
 	__u32 data;
 	__u32 data_end;
+	__u32 netns_inum;
 };
 
 struct bpf_tunnel_key {
@@ -581,6 +582,7 @@ struct bpf_sock {
 	__u32 family;
 	__u32 type;
 	__u32 protocol;
+	__u32 netns_inum;
 };
 
 #define XDP_PACKET_HEADROOM 256
diff --git a/net/core/filter.c b/net/core/filter.c
index 1969b3f118c1..b2a15402c034 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3118,6 +3118,22 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 			*insn++ = BPF_MOV64_IMM(dst_reg, 0);
 		break;
 #endif
+	case offsetof(struct __sk_buff, netns_inum):
+#ifdef CONFIG_NET_NS
+		/* return dev_net(skb->dev)->ns.inum; */
+		BUILD_BUG_ON(FIELD_SIZEOF(struct net, ns.inum) != 4);
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
+				      dst_reg, src_reg,
+				      offsetof(struct sk_buff, dev));
+		*insn++ = BPF_JMP_IMM(BPF_JEQ, dst_reg, 0, 2);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), dst_reg, dst_reg,
+				      offsetof(struct net_device, nd_net));
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, dst_reg,
+				      offsetof(struct net, ns.inum));
+#else
+		*insn++ = BPF_MOV64_IMM(dst_reg, 0);
+		break;
+#endif
 	}
 
 	return insn - insn_buf;
@@ -3163,6 +3179,17 @@ static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
 		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_PROTO_MASK);
 		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_PROTO_SHIFT);
 		break;
+	case offsetof(struct bpf_sock, netns_inum):
+#ifdef CONFIG_NET_NS
+		/* return sock_net(sk)->ns.inum; */
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), dst_reg, src_reg,
+				      offsetof(struct sock, sk_net));
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, dst_reg,
+				      offsetof(struct net, ns.inum));
+#else
+		*insn++ = BPF_MOV64_IMM(dst_reg, 0);
+		break;
+#endif
 	}
 
 	return insn - insn_buf;
diff --git a/samples/bpf/sock_flags_kern.c b/samples/bpf/sock_flags_kern.c
index 533dd11a6baa..6d9073509b45 100644
--- a/samples/bpf/sock_flags_kern.c
+++ b/samples/bpf/sock_flags_kern.c
@@ -9,8 +9,10 @@ SEC("cgroup/sock1")
 int bpf_prog1(struct bpf_sock *sk)
 {
 	char fmt[] = "socket: family %d type %d protocol %d\n";
+	char fmt2[] = "socket: netns_inum %u\n";
 
 	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
+	bpf_trace_printk(fmt2, sizeof(fmt2), sk->netns_inum);
 
 	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
 	 * ie., make ping6 fail
diff --git a/samples/bpf/sockex1_kern.c b/samples/bpf/sockex1_kern.c
index ed18e9a4909c..d522a70bd661 100644
--- a/samples/bpf/sockex1_kern.c
+++ b/samples/bpf/sockex1_kern.c
@@ -24,6 +24,9 @@ int bpf_prog1(struct __sk_buff *skb)
 	if (value)
 		__sync_fetch_and_add(value, skb->len);
 
+	char fmt[] = "skb %p netns inode %u\n";
+
+	bpf_trace_printk(fmt, sizeof(fmt), skb, skb->netns_inum);
 	return 0;
 }
 char _license[] SEC("license") = "GPL";
-- 
2.8.0
