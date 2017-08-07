From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 11/12] Documentation: describe the new eBPF
 verifier value tracking behaviour
Date: Mon, 7 Aug 2017 15:30:09 +0100
Message-ID: <ef389418-780b-e663-3898-ba662b7df3fd@solarflare.com>
References: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also bring the eBPF documentation up to date in other ways.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 Documentation/networking/filter.txt | 122 ++++++++++++++++++++++++++++++------
 1 file changed, 104 insertions(+), 18 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index b69b205..d0fdba7 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -793,7 +793,7 @@ Some core changes of the new internal format:
     bpf_exit
 
   After the call the registers R1-R5 contain junk values and cannot be read.
-  In the future an eBPF verifier can be used to validate internal BPF programs.
+  An in-kernel eBPF verifier is used to validate internal BPF programs.
 
 Also in the new design, eBPF is limited to 4096 insns, which means that any
 program will terminate quickly and will only call a fixed number of kernel
@@ -1017,7 +1017,7 @@ At the start of the program the register R1 contains a pointer to context
 and has type PTR_TO_CTX.
 If verifier sees an insn that does R2=R1, then R2 has now type
 PTR_TO_CTX as well and can be used on the right hand side of expression.
-If R1=PTR_TO_CTX and insn is R2=R1+R1, then R2=UNKNOWN_VALUE,
+If R1=PTR_TO_CTX and insn is R2=R1+R1, then R2=SCALAR_VALUE,
 since addition of two valid pointers makes invalid pointer.
 (In 'secure' mode verifier will reject any type of pointer arithmetic to make
 sure that kernel addresses don't leak to unprivileged users)
@@ -1039,7 +1039,7 @@ is a correct program. If there was R1 instead of R6, it would have
 been rejected.
 
 load/store instructions are allowed only with registers of valid types, which
-are PTR_TO_CTX, PTR_TO_MAP, FRAME_PTR. They are bounds and alignment checked.
+are PTR_TO_CTX, PTR_TO_MAP, PTR_TO_STACK. They are bounds and alignment checked.
 For example:
  bpf_mov R1 = 1
  bpf_mov R2 = 2
@@ -1058,7 +1058,7 @@ intends to load a word from address R6 + 8 and store it into R0
 If R6=PTR_TO_CTX, via is_valid_access() callback the verifier will know
 that offset 8 of size 4 bytes can be accessed for reading, otherwise
 the verifier will reject the program.
-If R6=FRAME_PTR, then access should be aligned and be within
+If R6=PTR_TO_STACK, then access should be aligned and be within
 stack bounds, which are [-MAX_BPF_STACK, 0). In this example offset is 8,
 so it will fail verification, since it's out of bounds.
 
@@ -1069,7 +1069,7 @@ For example:
   bpf_ld R0 = *(u32 *)(R10 - 4)
   bpf_exit
 is invalid program.
-Though R10 is correct read-only register and has type FRAME_PTR
+Though R10 is correct read-only register and has type PTR_TO_STACK
 and R10 - 4 is within stack bounds, there were no stores into that location.
 
 Pointer register spill/fill is tracked as well, since four (R6-R9)
@@ -1094,6 +1094,71 @@ all use cases.
 
 See details of eBPF verifier in kernel/bpf/verifier.c
 
+Register value tracking
+-----------------------
+In order to determine the safety of an eBPF program, the verifier must track
+the range of possible values in each register and also in each stack slot.
+This is done with 'struct bpf_reg_state', defined in include/linux/
+bpf_verifier.h, which unifies tracking of scalar and pointer values.  Each
+register state has a type, which is either NOT_INIT (the register has not been
+written to), SCALAR_VALUE (some value which is not usable as a pointer), or a
+pointer type.  The types of pointers describe their base, as follows:
+    PTR_TO_CTX          Pointer to bpf_context.
+    CONST_PTR_TO_MAP    Pointer to struct bpf_map.  "Const" because arithmetic
+                        on these pointers is forbidden.
+    PTR_TO_MAP_VALUE    Pointer to the value stored in a map element.
+    PTR_TO_MAP_VALUE_OR_NULL
+                        Either a pointer to a map value, or NULL; map accesses
+                        (see section 'eBPF maps', below) return this type,
+                        which becomes a PTR_TO_MAP_VALUE when checked != NULL.
+                        Arithmetic on these pointers is forbidden.
+    PTR_TO_STACK        Frame pointer.
+    PTR_TO_PACKET       skb->data.
+    PTR_TO_PACKET_END   skb->data + headlen; arithmetic forbidden.
+However, a pointer may be offset from this base (as a result of pointer
+arithmetic), and this is tracked in two parts: the 'fixed offset' and 'variable
+offset'.  The former is used when an exactly-known value (e.g. an immediate
+operand) is added to a pointer, while the latter is used for values which are
+not exactly known.  The variable offset is also used in SCALAR_VALUEs, to track
+the range of possible values in the register.
+The verifier's knowledge about the variable offset consists of:
+* minimum and maximum values as unsigned
+* minimum and maximum values as signed
+* knowledge of the values of individual bits, in the form of a 'tnum': a u64
+'mask' and a u64 'value'.  1s in the mask represent bits whose value is unknown;
+1s in the value represent bits known to be 1.  Bits known to be 0 have 0 in both
+mask and value; no bit should ever be 1 in both.  For example, if a byte is read
+into a register from memory, the register's top 56 bits are known zero, while
+the low 8 are unknown - which is represented as the tnum (0x0; 0xff).  If we
+then OR this with 0x40, we get (0x40; 0xcf), then if we add 1 we get (0x0;
+0x1ff), because of potential carries.
+Besides arithmetic, the register state can also be updated by conditional
+branches.  For instance, if a SCALAR_VALUE is compared > 8, in the 'true' branch
+it will have a umin_value (unsigned minimum value) of 9, whereas in the 'false'
+branch it will have a umax_value of 8.  A signed compare (with BPF_JSGT or
+BPF_JSGE) would instead update the signed minimum/maximum values.  Information
+from the signed and unsigned bounds can be combined; for instance if a value is
+first tested < 8 and then tested s> 4, the verifier will conclude that the value
+is also > 4 and s< 8, since the bounds prevent crossing the sign boundary.
+PTR_TO_PACKETs with a variable offset part have an 'id', which is common to all
+pointers sharing that same variable offset.  This is important for packet range
+checks: after adding some variable to a packet pointer, if you then copy it to
+another register and (say) add a constant 4, both registers will share the same
+'id' but one will have a fixed offset of +4.  Then if it is bounds-checked and
+found to be less than a PTR_TO_PACKET_END, the other register is now known to
+have a safe range of at least 4 bytes.  See 'Direct packet access', below, for
+more on PTR_TO_PACKET ranges.
+The 'id' field is also used on PTR_TO_MAP_VALUE_OR_NULL, common to all copies of
+the pointer returned from a map lookup.  This means that when one copy is
+checked and found to be non-NULL, all copies can become PTR_TO_MAP_VALUEs.
+As well as range-checking, the tracked information is also used for enforcing
+alignment of pointer accesses.  For instance, on most systems the packet pointer
+is 2 bytes after a 4-byte alignment.  If a program adds 14 bytes to that to jump
+over the Ethernet header, then reads IHL and addes (IHL * 4), the resulting
+pointer will have a variable offset known to be 4n+2 for some n, so adding the 2
+bytes (NET_IP_ALIGN) gives a 4-byte alignment and so word-sized accesses through
+that pointer are safe.
+
 Direct packet access
 --------------------
 In cls_bpf and act_bpf programs the verifier allows direct access to the packet
@@ -1121,7 +1186,7 @@ it now points to 'skb->data + 14' and accessible range is [R5, R5 + 14 - 14)
 which is zero bytes.
 
 More complex packet access may look like:
- R0=imm1 R1=ctx R3=pkt(id=0,off=0,r=14) R4=pkt_end R5=pkt(id=0,off=14,r=14) R10=fp
+ R0=inv1 R1=ctx R3=pkt(id=0,off=0,r=14) R4=pkt_end R5=pkt(id=0,off=14,r=14) R10=fp
  6:  r0 = *(u8 *)(r3 +7) /* load 7th byte from the packet */
  7:  r4 = *(u8 *)(r3 +12)
  8:  r4 *= 14
@@ -1135,26 +1200,31 @@ More complex packet access may look like:
 16:  r2 += 8
 17:  r1 = *(u32 *)(r1 +80) /* load skb->data_end */
 18:  if r2 > r1 goto pc+2
- R0=inv56 R1=pkt_end R2=pkt(id=2,off=8,r=8) R3=pkt(id=2,off=0,r=8) R4=inv52 R5=pkt(id=0,off=14,r=14) R10=fp
+ R0=inv(id=0,umax_value=255,var_off=(0x0; 0xff)) R1=pkt_end R2=pkt(id=2,off=8,r=8) R3=pkt(id=2,off=0,r=8) R4=inv(id=0,umax_value=3570,var_off=(0x0; 0xfffe)) R5=pkt(id=0,off=14,r=14) R10=fp
 19:  r1 = *(u8 *)(r3 +4)
 The state of the register R3 is R3=pkt(id=2,off=0,r=8)
 id=2 means that two 'r3 += rX' instructions were seen, so r3 points to some
 offset within a packet and since the program author did
 'if (r3 + 8 > r1) goto err' at insn #18, the safe range is [R3, R3 + 8).
-The verifier only allows 'add' operation on packet registers. Any other
-operation will set the register state to 'unknown_value' and it won't be
+The verifier only allows 'add'/'sub' operations on packet registers. Any other
+operation will set the register state to 'SCALAR_VALUE' and it won't be
 available for direct packet access.
 Operation 'r3 += rX' may overflow and become less than original skb->data,
-therefore the verifier has to prevent that. So it tracks the number of
-upper zero bits in all 'uknown_value' registers, so when it sees
-'r3 += rX' instruction and rX is more than 16-bit value, it will error as:
-"cannot add integer value with N upper zero bits to ptr_to_packet"
+therefore the verifier has to prevent that.  So when it sees 'r3 += rX'
+instruction and rX is more than 16-bit value, any subsequent bounds-check of r3
+against skb->data_end will not give us 'range' information, so attempts to read
+through the pointer will give "invalid access to packet" error.
 Ex. after insn 'r4 = *(u8 *)(r3 +12)' (insn #7 above) the state of r4 is
-R4=inv56 which means that upper 56 bits on the register are guaranteed
-to be zero. After insn 'r4 *= 14' the state becomes R4=inv52, since
-multiplying 8-bit value by constant 14 will keep upper 52 bits as zero.
-Similarly 'r2 >>= 48' will make R2=inv48, since the shift is not sign
-extending. This logic is implemented in evaluate_reg_alu() function.
+R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff)) which means that upper 56 bits
+of the register are guaranteed to be zero, and nothing is known about the lower
+8 bits. After insn 'r4 *= 14' the state becomes
+R4=inv(id=0,umax_value=3570,var_off=(0x0; 0xfffe)), since multiplying an 8-bit
+value by constant 14 will keep upper 52 bits as zero, also the least significant
+bit will be zero as 14 is even.  Similarly 'r2 >>= 48' will make
+R2=inv(id=0,umax_value=65535,var_off=(0x0; 0xffff)), since the shift is not sign
+extending.  This logic is implemented in adjust_reg_min_max_vals() function,
+which calls adjust_ptr_min_max_vals() for adding pointer to scalar (or vice
+versa) and adjust_scalar_min_max_vals() for operations on two scalars.
 
 The end result is that bpf program author can access packet directly
 using normal C code as:
@@ -1214,6 +1284,22 @@ The map is defined by:
   . key size in bytes
   . value size in bytes
 
+Pruning
+-------
+The verifier does not actually walk all possible paths through the program.  For
+each new branch to analyse, the verifier looks at all the states it's previously
+been in when at this instruction.  If any of them contain the current state as a
+subset, the branch is 'pruned' - that is, the fact that the previous state was
+accepted implies the current state would be as well.  For instance, if in the
+previous state, r1 held a packet-pointer, and in the current state, r1 holds a
+packet-pointer with a range as long or longer and at least as strict an
+alignment, then r1 is safe.  Similarly, if r2 was NOT_INIT before then it can't
+have been used by any path from that point, so any value in r2 (including
+another NOT_INIT) is safe.  The implementation is in the function regsafe().
+Pruning considers not only the registers but also the stack (and any spilled
+registers it may hold).  They must all be safe for the branch to be pruned.
+This is implemented in states_equal().
+
 Understanding eBPF verifier messages
 ------------------------------------
 
