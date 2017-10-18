From: John Fastabend <john.r.fastabend@gmail.com>
Subject: [net PATCH 0/5] sockmap fixes for net
Date: Wed, 18 Oct 2017 07:09:48 -0700
Message-ID: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:43771 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdJROKK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:10:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id a8so4053833pfc.0
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:10:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following implements a set of fixes for sockmap and changes the
API slightly in a few places to reduce preempt_disable/enable scope.
We do this here in net because it requires an API change and this
avoids getting stuck with legacy API going forward.

The short description:

Access to skb mark is removed, it is problematic when we add
features in the future because mark is a union and used by the
TCP/socket code internally. We don't want to expose this to the
BPF programs or let programs change the values.

The other change is caching metadata in the skb itself between
when the BPF program returns a redirect code and the core code
implements the redirect. This avoids having per cpu metadata.

Finally, tighten restriction on using sockmap to CAP_NET_ADMIN and
only SOCK_STREAM sockets.

Thanks,
John

---

John Fastabend (5):
      bpf: enforce TCP only support for sockmap
      bpf: avoid preempt enable/disable in sockmap using tcp_skb_cb region
      bpf: remove mark access for SK_SKB program types
      bpf: require CAP_NET_ADMIN when using sockmap maps
      bpf: require CAP_NET_ADMIN when using devmap


 include/linux/filter.h                             |    2 +
 include/net/tcp.h                                  |    5 +++
 kernel/bpf/devmap.c                                |    3 ++
 kernel/bpf/sockmap.c                               |   28 ++++++++++++------
 net/core/filter.c                                  |   31 ++++++++++----------
 samples/sockmap/sockmap_kern.c                     |    2 +
 tools/include/uapi/linux/bpf.h                     |    3 +-
 tools/testing/selftests/bpf/bpf_helpers.h          |    2 +
 tools/testing/selftests/bpf/sockmap_verdict_prog.c |    4 +--
 tools/testing/selftests/bpf/test_maps.c            |   12 +++++++-
 tools/testing/selftests/bpf/test_verifier.c        |   16 +++++++++-
 11 files changed, 74 insertions(+), 34 deletions(-)
