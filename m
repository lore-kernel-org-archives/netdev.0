From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next V8 PATCH 0/5] New bpf cpumap type for XDP_REDIRECT
Date: Mon, 16 Oct 2017 12:19:23 +0200
Message-ID: <150814913767.1806.3470498528707259987.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Jesper Dangaard Brouer <brouer@redhat.com>, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37670 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbdJPKTa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 06:19:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introducing a new way to redirect XDP frames.  Notice how no driver
changes are necessary given the design of XDP_REDIRECT.

This redirect map type is called 'cpumap', as it allows redirection
XDP frames to remote CPUs.  The remote CPU will do the SKB allocation
and start the network stack invocation on that CPU.

This is a scalability and isolation mechanism, that allow separating
the early driver network XDP layer, from the rest of the netstack, and
assigning dedicated CPUs for this stage.  The sysadm control/configure
the RX-CPU to NIC-RX queue (as usual) via procfs smp_affinity and how
many queues are configured via ethtool --set-channels.  Benchmarks
show that a single CPU can handle approx 11Mpps.  Thus, only assigning
two NIC RX-queues (and two CPUs) is sufficient for handling 10Gbit/s
wirespeed smallest packet 14.88Mpps.  Reducing the number of queues
have the advantage that more packets being "bulk" available per hard
interrupt[1].

[1] https://www.netdevconf.org/2.1/papers/BusyPollingNextGen.pdf

Use-cases:

1. End-host based pre-filtering for DDoS mitigation.  This is fast
   enough to allow software to see and filter all packets wirespeed.
   Thus, no packets getting silently dropped by hardware.

2. Given NIC HW unevenly distributes packets across RX queue, this
   mechanism can be used for redistribution load across CPUs.  This
   usually happens when HW is unaware of a new protocol.  This
   resembles RPS (Receive Packet Steering), just faster, but with more
   responsibility placed on the BPF program for correct steering.

3. Auto-scaling or power saving via only activating the appropriate
   number of remote CPUs for handling the current load.  The cpumap
   tracepoints can function as a feedback loop for this purpose.

In V7, a --stress-mode was implemented for the samples program, which
between each stats update, adds + removes CPUs from the map
concurrently with traffic.  I did find and fix some concurrency issues
in the tear-down path, details in patch desc.  The stress test have
now been running for 15 hours without any issues, while being
bombarded with 11.6 Mpps via pktgen_sample04_many_flows.sh.

See individual patches for patchset-version changes.

---

Jesper Dangaard Brouer (5):
      bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
      bpf: XDP_REDIRECT enable use of cpumap
      bpf: cpumap xdp_buff to skb conversion and allocation
      bpf: cpumap add tracepoints
      samples/bpf: add cpumap sample program xdp_redirect_cpu


 include/linux/bpf.h                 |   31 +-
 include/linux/bpf_types.h           |    1 
 include/linux/netdevice.h           |    1 
 include/trace/events/xdp.h          |   80 ++++
 include/uapi/linux/bpf.h            |    1 
 kernel/bpf/Makefile                 |    1 
 kernel/bpf/cpumap.c                 |  702 +++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c                |    8 
 kernel/bpf/verifier.c               |    8 
 net/core/dev.c                      |   27 +
 net/core/filter.c                   |  140 ++++++-
 samples/bpf/Makefile                |    4 
 samples/bpf/xdp_redirect_cpu_kern.c |  609 ++++++++++++++++++++++++++++++
 samples/bpf/xdp_redirect_cpu_user.c |  697 +++++++++++++++++++++++++++++++++++
 tools/include/uapi/linux/bpf.h      |    1 
 15 files changed, 2277 insertions(+), 34 deletions(-)
 create mode 100644 kernel/bpf/cpumap.c
 create mode 100644 samples/bpf/xdp_redirect_cpu_kern.c
 create mode 100644 samples/bpf/xdp_redirect_cpu_user.c
