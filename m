From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 0/9] sockmap UAPI updates and fixes
Date: Mon, 28 Aug 2017 07:09:45 -0700
Message-ID: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36211 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdH1OJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:09:59 -0400
Received: by mail-pf0-f196.google.com with SMTP id k3so391955pfc.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:09:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series updates sockmap UAPI, adds additional test cases and
provides a couple fixes.

First the UAPI changes. The original API added two sockmap specific
API artifacts (a) a new map_flags field with a sockmap specific update
command and (b) a new sockmap specific attach field in the attach data
structure. After this series instead of attaching programs with a
single command now two commands are used to attach programs to maps
individually. This allows us to add new programs easily in the future
and avoids any specific sockmap data structure additions. The
map_flags field is also removed and instead we allow socks to be
added to multiple maps that may or may not have programs attached.
This allows users to decide if a sock should run a SK_SKB program type
on receive based on the map it is attached to. This is a nice
improvement. See patches for specific details.

More test cases were added to test above changes and also stress test
the interface.

Finally two fixes/improvements were made. First a missing rcu
section was added. Second now sockmap can build without KCM being
used to trigger 'y' on CONFIG_STREAM_PARSER by selecting a new
BPF config option.

---

John Fastabend (9):
      bpf: convert sockmap field attach_bpf_fd2 to type
      bpf: sockmap, remove STRPARSER map_flags and add multi-map support
      bpf: sockmap add missing rcu_read_(un)lock in smap_data_ready
      bpf: additional sockmap self tests
      bpf: more SK_SKB selftests
      bpf: harden sockmap program attach to ensure correct map type
      bpf: sockmap indicate sock events to listeners
      bpf: sockmap requires STREAM_PARSER add Kconfig entry
      bpf: test_maps add sockmap stress test


 include/linux/bpf.h                                |   10 +
 include/uapi/linux/bpf.h                           |   12 -
 kernel/bpf/sockmap.c                               |  312 ++++++++++++--------
 kernel/bpf/syscall.c                               |   38 +-
 net/Kconfig                                        |   12 +
 samples/sockmap/sockmap_kern.c                     |    6 
 samples/sockmap/sockmap_user.c                     |   12 +
 tools/include/uapi/linux/bpf.h                     |    9 -
 tools/lib/bpf/bpf.c                                |   14 -
 tools/lib/bpf/bpf.h                                |    4 
 tools/testing/selftests/bpf/bpf_helpers.h          |    3 
 tools/testing/selftests/bpf/sockmap_parse_prog.c   |    8 -
 tools/testing/selftests/bpf/sockmap_verdict_prog.c |   30 ++
 tools/testing/selftests/bpf/test_maps.c            |  272 +++++++++++------
 tools/testing/selftests/bpf/test_verifier.c        |   98 ++++++
 15 files changed, 544 insertions(+), 296 deletions(-)
