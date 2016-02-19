From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC][PATCH 00/10] Add trace event support to eBPF
Date: Thu, 18 Feb 2016 20:16:23 -0800
Message-ID: <20160219041622.GA88036@ast-mbp.thefacebook.com>
References: <cover.1455291671.git.tom.zanussi@linux.intel.com>
 <20160214000236.GA16236@ast-mbp.kubiwireless.com>
 <1455662127.2641.157.camel@tzanussi-mobl.amr.corp.intel.com>
 <20160217045103.GA47275@ast-mbp.thefacebook.com>
 <1455830838.14359.58.camel@tzanussi-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com,
	namhyung@kernel.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Tom Zanussi <tom.zanussi@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455830838.14359.58.camel@tzanussi-mobl.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 03:27:18PM -0600, Tom Zanussi wrote:
> On Tue, 2016-02-16 at 20:51 -0800, Alexei Starovoitov wrote:
> > On Tue, Feb 16, 2016 at 04:35:27PM -0600, Tom Zanussi wrote:
> > > On Sun, 2016-02-14 at 01:02 +0100, Alexei Starovoitov wrote:
> > > > On Fri, Feb 12, 2016 at 10:11:18AM -0600, Tom Zanussi wrote:
> > 
> 
>   # ./funccount.py '*spin*'
> 
> Which on my machine resulted in a hard lockup on all CPUs.  I'm not set

thanks for the report. looks like something got broken. After:
# ./funccount.par '*spin*'
Tracing 12 functions for "*spin*"... Hit Ctrl-C to end.
^C
ADDR             FUNC                          COUNT
ffffffff810aeb91 mutex_spin_on_owner             530
ffffffff8177f241 _raw_spin_unlock_bh            1325
ffffffff810aebe1 mutex_optimistic_spin          1696
ffffffff8177f581 _raw_spin_lock_bh              1985
ffffffff8177f511 _raw_spin_trylock             55337
ffffffff8177f3c1 _raw_spin_lock_irq           787875
ffffffff8177f551 _raw_spin_lock              2211324
ffffffff8177f331 _raw_spin_lock_irqsave      3556740
ffffffff8177f1c1 __lock_text_start           3593983
[  275.175524] Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 11
it seems kprobe cleanup is racing with bpf cleanup...

> > > surrounding that even in the comments.  I guess I'd have to spend a few
> > > hours reading the BPF code and the verifier even, to understand that.
> > 
> > not sure what is your goal. Runtime lookup via field name is not acceptable
> > whether it's cached or not. There is no place for strcmp in the critical path.
> 
> Exactly - that's why I was asking about a 'begin probe', in order to do
> the lookup once, in an non-critical path.

It is critical path. When program is called million times for_each{strcmp}
at the beginning of every program is unacceptable overhead.
In the crash above, Ctrl-C was pressed in a split second, yet bpf
already processed 2.2M + 3.5M + 3.5M events and then hung while unloading.
In the upcoming tracepoint+bpf patches the programs will have
direct access to tracepoint data without wasting time on strcmp.
The steps to do that were already outlined in the previous email.
