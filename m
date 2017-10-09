From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 0/7] bpf: get rid of global verifier state and reuse instruction printer
Date: Mon,  9 Oct 2017 10:30:08 -0700
Message-ID: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:54855 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751952AbdJIRa2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:30:28 -0400
Received: by mail-pf0-f180.google.com with SMTP id m28so9506233pfi.11
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 10:30:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set started off as simple extraction of eBPF verifier's instruction
printer into a separate file but evolved into removal of global state.
The purpose of moving instruction printing code is to be able to reuse it
from the bpftool.

As far as the global verifier lock goes, this set removes the global
variables relating to the log buffer, makes the one-time init done
by bpf_get_skb_set_tunnel_proto() not depend on any external locking,
and performs verifier log writeback as data is produced removing the need
for allocating a potentially large temporary buffer.

The final step of actually removing the verifier lock is left to someone
more competent and self-confident :)

Note that struct bpf_verifier_env is just 40B under two pages now,
we should probably switch to vzalloc() when it's expanded again...

v2:
 - add a selftest;
 - use env buffer and flush on every print (Alexei);
 - handle kernel log allocation failures (Daniel);
 - put the env log members into a struct (Daniel).


Jakub Kicinski (7):
  selftests/bpf: add a test for verifier logs
  bpf: encapsulate verifier log state into a structure
  bpf: move global verifier log into verifier environment
  bpf: move instruction printing into a separate file
  tools: bpftool: use the kernel's instruction printer
  bpf: don't rely on the verifier lock for metadata_dst allocation
  bpf: write back the verifier log buffer as it gets filled

 include/linux/bpf_verifier.h                     |  17 +
 include/net/dst_metadata.h                       |   1 +
 kernel/bpf/Makefile                              |   1 +
 kernel/bpf/disasm.c                              | 214 +++++++
 kernel/bpf/disasm.h                              |  32 ++
 kernel/bpf/verifier.c                            | 693 +++++++++--------------
 net/core/dst.c                                   |  16 +
 net/core/filter.c                                |  16 +-
 tools/bpf/bpftool/Documentation/bpftool-prog.rst |  11 +-
 tools/bpf/bpftool/Makefile                       |   7 +-
 tools/bpf/bpftool/main.h                         |  10 +-
 tools/bpf/bpftool/prog.c                         |  44 +-
 tools/testing/selftests/bpf/Makefile             |   2 +-
 tools/testing/selftests/bpf/test_verifier_log.c  | 171 ++++++
 14 files changed, 776 insertions(+), 459 deletions(-)
 create mode 100644 kernel/bpf/disasm.c
 create mode 100644 kernel/bpf/disasm.h
 create mode 100644 tools/testing/selftests/bpf/test_verifier_log.c

-- 
2.14.1
