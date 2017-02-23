From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] A Sample of using socket cookie and uid
 for traffic monitoring
Date: Thu, 23 Feb 2017 12:20:23 -0500
Message-ID: <CAF=yD-LzUjhG7f=fXqomB_wpzThZ1J7W7V1FzTHQrYw-a7fT9g@mail.gmail.com>
References: <1487825093-5221-1-git-send-email-chenbofeng.kernel@gmail.com> <1487825093-5221-4-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:33387 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdBWRVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:21:38 -0500
Received: by mail-wr0-f173.google.com with SMTP id 97so25987997wrb.0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 09:21:04 -0800 (PST)
In-Reply-To: <1487825093-5221-4-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* This test is a demo of using get_socket_uid and get_socket_cookie
> + * helper function to do per socket based network traffic monitoring.
> + * It requires iptable version higher then 1.6.1. to load pined eBPF
> + * program into the xt_bpf match.

iptable -> iptables (everywhre
pined -> pinned

> + * Clean up: if using shell script, the script file will delete the iptables
> + * rule and unmount the bpf program when exit. Else the iptables rule need
> + * to be deleted using:
> + *   iptables -D INPUT -m bpf --object-pinned ${mnt_dir}/bpf_prog -j ACCEPT

this is already in the wrapper script

> +       struct bpf_insn prog[] = {
> +               /*
> +                * it for future usage. value stored in R6 to R10 will not be
> +                * reset after a bpf helper function call.

garbled comment

> +                */
> +               BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
> +               /*
> +                * pc1: BPF_FUNC_get_socket_cookie takes one parameter,
> +                * R1: sk_buff
> +                */
> +               BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
> +                               BPF_FUNC_get_socket_cookie),
> +               /* pc2-4: save &socketCookie to r7 for future usage*/
> +               BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
> +               BPF_MOV64_REG(BPF_REG_7, BPF_REG_10),
> +               BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, -8),
> +               /*
> +                * pc5-8: set up the registers for BPF_FUNC_map_lookup_elem,
> +                * it takes two parameters (R1: map_fd,  R2: &socket_cookie)
> +                */
> +               BPF_LD_MAP_FD(BPF_REG_1, map_fd),
> +               BPF_MOV64_REG(BPF_REG_2, BPF_REG_7),
> +               BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
> +                               BPF_FUNC_map_lookup_elem),
> +               /*
> +                * pc9. if r0 != 0x0, go to pc+14, since we have the cookie
> +                * stored already
> +                * Otherwise do pc10-22 to setup a new data entry.
> +                */
> +               BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 14),
> +               BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
> +               BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
> +                               BPF_FUNC_get_socket_uid),
> +               /*
> +                * Place a struct stats in the R10 stack and sequentially
> +                * place the member value into the memory. Packets value
> +                * is set by directly place a IMM value 1 into the stack.
> +                */
> +               BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0,
> +                               -32 + offsetof(struct stats, uid)),
> +               BPF_ST_MEM(BPF_DW, BPF_REG_10,
> +                               -32 + offsetof(struct stats, packets), 1),
> +               /*
> +                * __sk_buff is a special struct used for eBPF program to
> +                * directly access some sk_buff field.
> +                */
> +               BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_6,
> +                               offsetof(struct __sk_buff, len)),
> +               BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1,
> +                               -32 + offsetof(struct stats, bytes)),
> +               /*
> +                * add new map entry using BPF_FUNC_map_update_elem, it takes
> +                * 4 parameters (R1: map_fd, R2: &socket_cookie, R3: &stats)

R4: flags

> +                */
> +               BPF_LD_MAP_FD(BPF_REG_1, map_fd),
> +               BPF_MOV64_REG(BPF_REG_2, BPF_REG_7),
> +               BPF_MOV64_REG(BPF_REG_3, BPF_REG_10),
> +               BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -32),
> +               BPF_MOV64_IMM(BPF_REG_4, 0),
> +               BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
> +                               BPF_FUNC_map_update_elem),
> +               BPF_JMP_IMM(BPF_JA, 0, 0, 5),
> +               /*
> +                * pc24-30 update the packet info to a exist data entry, it can
> +                * be done by directly write to pointers instead of using
> +                * BPF_FUNC_map_update_elem helper function
> +                */
> +               BPF_MOV64_REG(BPF_REG_9, BPF_REG_0),
> +               BPF_MOV64_IMM(BPF_REG_1, 1),
> +               BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_9, BPF_REG_1,
> +                               offsetof(struct stats, packets), 0),

BPF_STX_XADD here and below

> +               BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_6,
> +                               offsetof(struct __sk_buff, len)),
> +               BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_9, BPF_REG_1,
> +                                         offsetof(struct stats, bytes), 0),
> +               BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_6,
> +                               offsetof(struct __sk_buff, len)),

No requirement to return len. It goes unused, can just return non-zero
immediate.

> +static void prog_attach_iptables(char *file)
> +{
> +       int ret;
> +       char rules[100];
> +
> +       if (bpf_obj_pin(prog_fd, file))
> +               error(1, errno, "bpf_obj_pin");
> +       sprintf(rules, "iptables -A INPUT -m bpf --object-pinned %s -j ACCEPT",
> +               file);

this is a test, but still: unsafe to pass user input unchecked to sprintf

> +                       printf("cookie: %u, uid: 0x%x, Pakcet Count: %lu,"

Packet

> diff --git a/samples/bpf/run_cookie_uid_helper_example.sh b/samples/bpf/run_cookie_uid_helper_example.sh
> new file mode 100755
> index 0000000..a7a6208
> --- /dev/null
> +++ b/samples/bpf/run_cookie_uid_helper_example.sh
> @@ -0,0 +1,14 @@
> +#!/bin/bash
> +local_dir="$(pwd)"
> +root_dir=$local_dir/../..
> +mnt_dir=/sys/fs/bpf

Don't modify state outside the test environment. Perhaps use a temporary dir:

mnt_dir=$(mktemp -d --tmp)

and remove it in on_exit
