From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 0/6] BPF socket redirect
Date: Thu, 03 Aug 2017 16:36:31 -0700
Message-ID: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: davem@davemloft.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38679 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:36:46 -0400
Received: by mail-pf0-f196.google.com with SMTP id h75so157594pfh.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:36:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements socket redirect for BPF using XDP redirect
as a model. The user flow and internals are similar in many ways.
First we add a new map type called, sockmap. A sockmap holds
references to sock structs. Next a bpf helper call is added to
support redirect between sockets,

      bpf_sk_redirect_map(map, key, flags)

This allows BPF programs to redirect packets between sockets.

Finally, we need a call site, as a first call site to implement
we added hooks to recv_sock using the existing strparser blocks.
The call site is added via a new BPF attach map call.

For details see patches. The final patch provides a sample program
that shows a real example that uses cgroups.

I probably need a few more iterations of fixes/cleanup etc. to
get these ready for non-RFC submission, but because its working
with "real" traffic now and is running without issues getting
some feedback would be great. I tried to add comments in the code
with "TBD" around areas I know need some work or where I see a bug
could happen in the error case, etc.

For people who prefer git over pulling patches out of their mail
editor I've posted the code here,

https://github.com/jrfastab/linux-kernel-xdp/tree/kproxy_sockmap7

TBD:
  - bpf program refcnting cleanup
  - publish performance numbers
  - probably a couple more iterations of cleanup
  - build a better cover letter ;)

Thanks to Daniel Borkmann for reviewing and providing feedback even
though some of it just made it into the TBD column so far.

Parts of this code started with initial kproxy RFC patches (Tom
Herbert) here,

 https://patchwork.ozlabs.org/patch/782406/

although its been heavily modified/changed/etc by now.

Some original ideas/dissussions around this started at netconf here
is a link with notes. Search for "In-kernel layer-7 proxying" and
presentation from Thomas Graf,

https://lwn.net/Articles/719985/

Sorry if I forgot citing anyone :) its just an RFC after all.

Thanks,
John

---

John Fastabend (6):
      net: early init support for strparser
      net: add sendmsg_locked and sendpage_locked to af_inet6
      net: fixes for skb_send_sock
      net: sockmap with sk redirect support
      net: bpf, add skb to sk lookup routines
      net: sockmap sample program


 include/linux/bpf.h                       |   11 +
 include/linux/bpf_types.h                 |    1 
 include/uapi/linux/bpf.h                  |   15 +
 kernel/bpf/Makefile                       |    2 
 kernel/bpf/helpers.c                      |   20 +
 kernel/bpf/sockmap.c                      |  623 +++++++++++++++++++++++++++++
 kernel/bpf/syscall.c                      |   41 ++
 net/core/filter.c                         |   87 ++++
 net/core/skbuff.c                         |    2 
 net/ipv6/af_inet6.c                       |    2 
 net/socket.c                              |    2 
 net/strparser/strparser.c                 |   10 
 samples/sockmap/Makefile                  |   78 ++++
 samples/sockmap/sockmap_kern.c            |  143 +++++++
 samples/sockmap/sockmap_user.c            |   84 ++++
 tools/include/uapi/linux/bpf.h            |    1 
 tools/lib/bpf/bpf.c                       |   11 -
 tools/lib/bpf/bpf.h                       |    4 
 tools/testing/selftests/bpf/bpf_helpers.h |   12 +
 19 files changed, 1136 insertions(+), 13 deletions(-)
 create mode 100644 kernel/bpf/sockmap.c
 create mode 100644 samples/sockmap/Makefile
 create mode 100644 samples/sockmap/sockmap_kern.c
 create mode 100644 samples/sockmap/sockmap_user.c
