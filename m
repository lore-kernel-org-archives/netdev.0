From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: [RFC PATCH tip/master 0/3] kprobes: tracing: kretprobe_instance dynamic allocation
Date: Wed, 29 Mar 2017 14:20:51 +0900
Message-ID: <149076484118.24574.7083269903420611708.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io,
        Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a correction of patches to introduce kretprobe_instance
dynamic allocation for avoiding kretprobe silently miss-hits.

Original issue was reported by Lukasz on linux-trace ml.
 https://www.spinics.net/lists/linux-trace/msg00448.html

Also Alban is working on kprobe-tracer side because of
iovisor's issue.
 https://www.spinics.net/lists/netdev/msg427149.html
(Note that this series is independently applicable, no conflict)

This series is a kind of complementary patches for
Alban's patch. So I think both of them are needed.

 [1/3]: Add kretprobe's miss-hit counter to miss-hit
        column on kprobe_profile. This helps user to
        see what happened.
 [2/3]: Introduce kretprobe_instance dynamic allocation.
        This will help user not to miss the ret probes
        even it has low number of maxactive.
 [3/3]: Set maximum limitation for pre-allocated maxactive.
        This can avoid miss configuration of struct kretprobe.

The downside of this patch is, dynamic allocation will
involve memory allocation, which sometimes traced by
kprobes. In that case those nested kprobes are missed.
To avoid this kind of miss-hit, user may need to make
maxactive enough large when registering kretprobes.

However, in other case, this can reduce the possibility
of miss-hit of kretprobes. Since the maxactive increased
automatically, user will not need to retry tracing with
larger maxactive.

Alban, you can reuse KRETPROBE_MAXACTIVE_ALLOC for checking
upper limiation in trace_kprobe.c too.

Thank you,

---

Masami Hiramatsu (3):
      trace: kprobes: Show sum of probe/retprobe nmissed count
      kprobes: Allocate kretprobe instance if its free list is empty
      kprobes: Limit kretprobe maximum instances


 Documentation/kprobes.txt   |   25 +++++++++++++++---------
 include/linux/kprobes.h     |    2 ++
 kernel/kprobes.c            |   44 +++++++++++++++++++++++++++++++------------
 kernel/trace/trace_kprobe.c |    2 +-
 4 files changed, 50 insertions(+), 23 deletions(-)

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
