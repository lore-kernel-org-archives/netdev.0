From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Tue, 15 Aug 2017 22:30:15 -0700
Message-ID: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34620 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdHPFak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:30:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id t86so420006pfe.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:30:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements a sockmap and socket redirect helper for BPF
using a model similar to XDP netdev redirect. A sockmap is a BPF map
type that holds references to sock structs. Then with a new sk
redirect bpf helper BPF programs can use the map to redirect skbs
between sockets,

      bpf_sk_redirect_map(map, key, flags)

Finally, we need a call site to attach our BPF logic to do socket
redirects. We added hooks to recv_sock using the existing strparser
infrastructure to do this. The call site is added via the BPF attach
map call. To enable users to use this infrastructure a new BPF program
BPF_PROG_TYPE_SK_SKB is created that allows users to reference sock
details, such as port and ip address fields, to build useful socket
layer program. The sockmap datapath is as follows,

     recv -> strparser -> verdict/action

where this series implements the drop and redirect actions.
Additional, actions can be added as needed.

A sample program is provided to illustrate how a sockmap can
be integrated with cgroups and used to add/delete sockets in
a sockmap. The program is simple but should show many of the
key ideas.

To test this work test_maps in selftests/bpf was leveraged.
We added a set of tests to add sockets and do send/recv ops
on the sockets to ensure correct behavior. Additionally, the
selftests tests a series of negative test cases. We can expand
on this in the future.

I also have a basic test program I use with iperf/netperf
clients that could be sent as an additional sample if folks
want this. It needs a bit of cleanup to send to the list and
wasn't included in this series.

For people who prefer git over pulling patches out of their mail
editor I've posted the code here,

https://github.com/jrfastab/linux-kernel-xdp/tree/sockmap

For some background information on the genesis of this work
it might be helpful to review these slides from netconf 2017
by Thomas Graf,

http://vger.kernel.org/netconf2017.html
https://docs.google.com/a/covalent.io/presentation/d/1dwSKSBGpUHD3WO5xxzZWj8awV_-xL-oYhvqQMOBhhtk/edit?usp=sharing

Thanks to Daniel Borkmann for reviewing and providing initial
feedback.

---

John Fastabend (10):
      net: early init support for strparser
      net: add sendmsg_locked and sendpage_locked to af_inet6
      net: fixes for skb_send_sock
      bpf: introduce new program type for skbs on sockets
      bpf: export bpf_prog_inc_not_zero
      bpf: sockmap with sk redirect support
      bpf: add access to sock fields and pkt data from sk_skb programs
      bpf: sockmap sample program
      bpf: selftests: add tests for new __sk_buff members
      bpf: selftests add sockmap tests


 include/linux/bpf.h                                |   14 
 include/linux/bpf_types.h                          |    2 
 include/linux/filter.h                             |    2 
 include/uapi/linux/bpf.h                           |   43 +
 kernel/bpf/Makefile                                |    2 
 kernel/bpf/sockmap.c                               |  792 ++++++++++++++++++++
 kernel/bpf/syscall.c                               |   54 +
 kernel/bpf/verifier.c                              |   15 
 net/core/filter.c                                  |  248 ++++++
 net/core/skbuff.c                                  |    2 
 net/ipv6/af_inet6.c                                |    2 
 net/socket.c                                       |    2 
 net/strparser/strparser.c                          |   10 
 samples/bpf/bpf_load.c                             |    8 
 samples/sockmap/Makefile                           |   78 ++
 samples/sockmap/sockmap_kern.c                     |  110 +++
 samples/sockmap/sockmap_user.c                     |  286 +++++++
 tools/include/uapi/linux/bpf.h                     |   46 +
 tools/lib/bpf/bpf.c                                |   14 
 tools/lib/bpf/bpf.h                                |    4 
 tools/lib/bpf/libbpf.c                             |   29 +
 tools/lib/bpf/libbpf.h                             |    2 
 tools/testing/selftests/bpf/Makefile               |    2 
 tools/testing/selftests/bpf/bpf_helpers.h          |    7 
 tools/testing/selftests/bpf/sockmap_parse_prog.c   |   38 +
 tools/testing/selftests/bpf/sockmap_verdict_prog.c |   48 +
 tools/testing/selftests/bpf/test_maps.c            |  308 ++++++++
 tools/testing/selftests/bpf/test_progs.c           |   55 -
 tools/testing/selftests/bpf/test_verifier.c        |  152 ++++
 29 files changed, 2316 insertions(+), 59 deletions(-)
 create mode 100644 kernel/bpf/sockmap.c
 create mode 100644 samples/sockmap/Makefile
 create mode 100644 samples/sockmap/sockmap_kern.c
 create mode 100644 samples/sockmap/sockmap_user.c
 create mode 100644 tools/testing/selftests/bpf/sockmap_parse_prog.c
 create mode 100644 tools/testing/selftests/bpf/sockmap_verdict_prog.c
