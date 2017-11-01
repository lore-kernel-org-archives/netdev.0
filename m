From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 0/2][v3] Add the ability to do BPF directed error injection
Date: Wed,  1 Nov 2017 13:00:41 -0400
Message-ID: <1509555643-2899-1-git-send-email-josef@toxicpanda.com>
To: rostedt@goodmis.org, mingo@redhat.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm sending this through Dave since it'll conflict with other BPF changes in his
tree, but since it touches tracing as well Dave would like a review from
somebody on the tracing side.

v2->v3:
- added a ->kprobe_override flag to bpf_prog.
- added some sanity checks to disallow attaching bpf progs that have
  ->kprobe_override set that aren't for ftrace kprobes.
- added the trace_kprobe_ftrace helper to check if the trace_event_call is a
  ftrace kprobe.
- renamed bpf_kprobe_state to bpf_kprobe_override, fixed it so we only read this
  value in the kprobe path, and thus only write to it if we're overriding or
  clearing the override.

v1->v2:
- moved things around to make sure that bpf_override_return could really only be
  used for an ftrace kprobe.
- killed the special return values from trace_call_bpf.
- renamed pc_modified to bpf_kprobe_state so bpf_override_return could tell if
  it was being called from an ftrace kprobe context.
- reworked the logic in kprobe_perf_func to take advantage of bpf_kprobe_state.
- updated the test as per Alexei's review.

- Original message - 

A lot of our error paths are not well tested because we have no good way of
injecting errors generically.  Some subystems (block, memory) have ways to
inject errors, but they are random so it's hard to get reproduceable results.

With BPF we can add determinism to our error injection.  We can use kprobes and
other things to verify we are injecting errors at the exact case we are trying
to test.  This patch gives us the tool to actual do the error injection part.
It is very simple, we just set the return value of the pt_regs we're given to
whatever we provide, and then override the PC with a dummy function that simply
returns.

Right now this only works on x86, but it would be simple enough to expand to
other architectures.  Thanks,

Josef
