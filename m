From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/7] bpf: add documentation for 'direct packet access'
Date: Thu, 5 May 2016 19:49:13 -0700
Message-ID: <1462502955-1731797-6-git-send-email-ast@fb.com>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57067 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756737AbcEFCtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:21 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u462k6lY001676
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22r650p24w-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:18 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1fa0ef98133511e69fe30002c9dfb610-afee4c50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

explain how verifier checks safety of packet access
and update email addresses.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 Documentation/networking/filter.txt | 85 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 83 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 96da119a47e7..6aef0b5f3bc7 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -1095,6 +1095,87 @@ all use cases.
 
 See details of eBPF verifier in kernel/bpf/verifier.c
 
+Direct packet access
+--------------------
+In cls_bpf and act_bpf programs the verifier allows direct access to the packet
+data via skb->data and skb->data_end pointers.
+Ex:
+1:  r4 = *(u32 *)(r1 +80)  /* load skb->data_end */
+2:  r3 = *(u32 *)(r1 +76)  /* load skb->data */
+3:  r5 = r3
+4:  r5 += 14
+5:  if r5 > r4 goto pc+16
+R1=ctx R3=pkt(id=0,off=0,r=14) R4=pkt_end R5=pkt(id=0,off=14,r=14) R10=fp
+6:  r0 = *(u16 *)(r3 +12) /* access 12 and 13 bytes of the packet */
+
+this 2byte load from the packet is safe to do, since the program author
+did check 'if (skb->data + 14 > skb->data_end) goto err' at insn #5 which
+means that in the fall-through case the register R3 (which points to skb->data)
+has at least 14 directly accessible bytes. The verifier marks it
+as R3=pkt(id=0,off=0,r=14).
+id=0 means that no additional variables were added to the register.
+off=0 means that no additional constants were added.
+r=14 is the range of safe access which means that bytes [R3, R3 + 14) are ok.
+Note that R5 is marked as R5=pkt(id=0,off=14,r=14). It also points
+to the packet data, but constant 14 was added to the register, so
+it now points to 'skb->data + 14' and accessible range is [R5, R5 + 14 - 14)
+which is zero bytes.
+
+More complex packet access may look like:
+ R0=imm1 R1=ctx R3=pkt(id=0,off=0,r=14) R4=pkt_end R5=pkt(id=0,off=14,r=14) R10=fp
+ 6:  r0 = *(u8 *)(r3 +7) /* load 7th byte from the packet */
+ 7:  r4 = *(u8 *)(r3 +12)
+ 8:  r4 *= 14
+ 9:  r3 = *(u32 *)(r1 +76) /* load skb->data */
+10:  r3 += r4
+11:  r2 = r1
+12:  r2 <<= 48
+13:  r2 >>= 48
+14:  r3 += r2
+15:  r2 = r3
+16:  r2 += 8
+17:  r1 = *(u32 *)(r1 +80) /* load skb->data_end */
+18:  if r2 > r1 goto pc+2
+ R0=inv56 R1=pkt_end R2=pkt(id=2,off=8,r=8) R3=pkt(id=2,off=0,r=8) R4=inv52 R5=pkt(id=0,off=14,r=14) R10=fp
+19:  r1 = *(u8 *)(r3 +4)
+The state of the register R3 is R3=pkt(id=2,off=0,r=8)
+id=2 means that two 'r3 += rX' instructions were seen, so r3 points to some
+offset within a packet and since the program author did
+'if (r3 + 8 > r1) goto err' at insn #18, the safe range is [R3, R3 + 8).
+The verifier only allows 'add' operation on packet registers. Any other
+operation will set the register state to 'unknown_value' and it won't be
+available for direct packet access.
+Operation 'r3 += rX' may overflow and become less than original skb->data,
+therefore the verifier has to prevent that. So it tracks the number of
+upper zero bits in all 'uknown_value' registers, so when it sees
+'r3 += rX' instruction and rX is more than 16-bit value, it will error as:
+"cannot add integer value with N upper zero bits to ptr_to_packet"
+Ex. after insn 'r4 = *(u8 *)(r3 +12)' (insn #7 above) the state of r4 is
+R4=inv56 which means that upper 56 bits on the register are guaranteed
+to be zero. After insn 'r4 *= 14' the state becomes R4=inv52, since
+multiplying 8-bit value by constant 14 will keep upper 52 bits as zero.
+Similarly 'r2 >>= 48' will make R2=inv48, since the shift is not sign
+extending. This logic is implemented in evaluate_reg_alu() function.
+
+The end result is that bpf program author can access packet directly
+using normal C code as:
+  void *data = (void *)(long)skb->data;
+  void *data_end = (void *)(long)skb->data_end;
+  struct eth_hdr *eth = data;
+  struct iphdr *iph = data + sizeof(*eth);
+  struct udphdr *udp = data + sizeof(*eth) + sizeof(*iph);
+
+  if (data + sizeof(*eth) + sizeof(*iph) + sizeof(*udp) > data_end)
+          return 0;
+  if (eth->h_proto != htons(ETH_P_IP))
+          return 0;
+  if (iph->protocol != IPPROTO_UDP || iph->ihl != 5)
+          return 0;
+  if (udp->dest == 53 || udp->source == 9)
+          ...;
+which makes such programs easier to write comparing to LD_ABS insn
+and significantly faster.
+
 eBPF maps
 ---------
 'maps' is a generic storage of different types for sharing data between kernel
@@ -1293,5 +1374,5 @@ to give potential BPF hackers or security auditors a better overview of
 the underlying architecture.
 
 Jay Schulist <jschlst@samba.org>
-Daniel Borkmann <dborkman@redhat.com>
-Alexei Starovoitov <ast@plumgrid.com>
+Daniel Borkmann <daniel@iogearbox.net>
+Alexei Starovoitov <ast@kernel.org>
-- 
2.8.0
