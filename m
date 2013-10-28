From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sched: cls_bpf: add BPF-based classifier
Date: Mon, 28 Oct 2013 06:34:52 -0700
Message-ID: <1382967292.13037.22.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382960120-2198-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51889 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262Ab3J1Nex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 09:34:53 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so6994357pdj.6
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 06:34:52 -0700 (PDT)
In-Reply-To: <1382960120-2198-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-28 at 12:35 +0100, Daniel Borkmann wrote:
> This work contains a lightweight BPF-based traffic classifier that can
> serve as a flexible alternative to ematch-based tree classification, i.e.
> now that BPF filter engine can also be JITed in the kernel. Naturally, tc
> actions and policies are supported as well with cls_bpf. Multiple BPF
> programs/filter can be attached for a class, or they can just as well be
> written within a single BPF program, that's really up to the user how he
> wishes to run/optimize the code, e.g. also for inversion of verdicts etc.
> The notion of a BPF program's return/exit codes is being kept as follows:
> non-zero for match, zero for mismatch.
> 
> As a minimal usage example with iproute2, we use a 3 band prio root qdisc
> on a router with sfq each as leave, and assign ssh and icmp bpf-based
> filters to band 1, http traffic to band 2 and the rest to band 3. For the
> first two bands we load the bytecode from a file, in the 2nd we load it
> inline as an example:
> 
> echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> tc qdisc del dev em1 root
> tc qdisc add dev em1 root handle 1: prio bands 3 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1


> tc qdisc add dev em1 parent 1:1 sfq perturb 16
> tc qdisc add dev em1 parent 1:2 sfq perturb 16
> tc qdisc add dev em1 parent 1:3 sfq perturb 16
> 
> tc filter add dev em1 parent 1: bpf run bytecode-file /etc/tc/ssh.bpf flowid 1:1
> tc filter add dev em1 parent 1: bpf run bytecode-file /etc/tc/icmp.bpf flowid 1:1
> tc filter add dev em1 parent 1: bpf run bytecode-file /etc/tc/http.bpf flowid 1:2
> tc filter add dev em1 parent 1: bpf run bytecode "`bpfc -f tc -i misc.ops`" flowid 1:3
> 
> BPF programs can be easily created and passed to tc, either as inline
> 'bytecode' or 'bytecode-file'. There are a couple of front-ends that can
> compile opcodes, for example:
> 
> 1) People familiar with tcpdump-like filters:
> 
>    tcpdump -iem1 -ddd port 22 | tr '\n' ',' > /etc/tc/ssh.bpf
> 
> 2) People that want to low-level program their filters or use BPF
>    extensions that lack support by libpcap's compiler:
> 
>    bpfc -f tc -i ssh.ops > /etc/tc/ssh.bpf
> 
>    ssh.ops example code:
>    ldh [12]
>    jne #0x800, drop
>    ldb [23]
>    jneq #6, drop
>    ldh [20]
>    jset #0x1fff, drop
>    ldxb 4 * ([14] & 0xf)
>    ldh [%x + 14]
>    jeq #0x16, pass
>    ldh [%x + 16]
>    jne #0x16, drop
>    pass: ret #-1
>    drop: ret #0
> 
> It was chosen to load bytecode into tc, since the reverse operation,
> tc filter list dev em1, is then able to show the exact commands again.
> Possible follow-up work could also include a small expression compiler
> for iproute2. Tested with the help of bmon. This idea came up during
> the Netfilter Workshop 2013 in Copenhagen.
> 

Well, running a large amount of filters might be very expensive [1],
have you considered returning the flowid from the filter, instead of
returning 0 and !0 ?

0 : would mean : not matched filter
<>0 : flowid

[1] Because of lot of duplicated code in all filters...
