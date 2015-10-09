From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Fri, 9 Oct 2015 10:30:49 -0700
Message-ID: <5617F9C9.10407@plumgrid.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
 <1444281803-24274-2-git-send-email-ast@plumgrid.com>
 <1444328452.3935641.405110585.76554E06@webmail.messagingengine.com>
 <5616E8A8.5020809@plumgrid.com> <87mvvsb6zg.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mvvsb6zg.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/9/15 4:45 AM, Hannes Frederic Sowa wrote:
> Afaics this problem hasn't even be solved in
> perf so far, tracepoints hit independent of the namespace currently.

yes and that's exactly what we're trying to solve.
The "demux+worker bpf programs" proposal is a work-in-progress solution
to get confidence how to actually separate tracepoint events into
namespaces before adding any new APIs to kernel.

> For me namespacing of ebpf code is actually not that important, I would
> much rather like to control which namespace is allowed to execute ebpf
> in an unpriviledged manner. Like Thomas wrote, a capability was great
> for that, but I don't know if any new capabilities will be added.

I think we're mixing too many things here.
First I believe eBPF 'socket filters' do not need any caps.
They're packet read-only and functionally very similar to classic with
a distinction that packet data can be aggregated into maps and programs
can be written in C. So I see no reason to restrict them per user or
per namespace.
Openstack use case is different. There it will be prog_type_sched_cls
that can mangle packets, change skb metadata, etc under TC framework.
These are not suitable for all users and this patch leaves
them root-only. If you're proposing to add CAP_BPF_TC to let containers
use them without being CAP_SYS_ADMIN, then I agree, it is useful, but
needs a lot more safety analysis on tc side.
Similar for prog_type_kprobe: we can add CAP_BPF_KPROBE to let
some trusted applications run unprivileged, but still being able
to do performance monitoring/analytics.
And we would need to carefully think about program restrictions,
since bpf_probe_read and kernel pointer walking is essential part
in tracing.
