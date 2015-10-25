From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Sun, 25 Oct 2015 09:23:36 -0700
Message-ID: <562D0208.7090608@plumgrid.com>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <20151023120335.GZ17308@twins.programming.kicks-ass.net>
 <562A474E.6040401@plumgrid.com> <20151025092142.GB4380@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151025092142.GB4380@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/15 2:21 AM, Ingo Molnar wrote:
> Then old crap can be de-emphasised and eventually removed, instead of having to
> live with crap forever ...

strongly disagree. none of the helpers are 'crap'.
bpf_perf_event_read() muxes of -EINVAL into return value, but it's non
ambiguous to the program whether it got an error or real counter value.
So it's not pretty, but it's a reasonable trade off.
Properly written bpf programs will not be hitting the error path (which
is there for safety and protection against buggy programs) and will
consume return value without any extra checks.
bpf_perf_event_read() could have been done via passing a pointer to
stack where counter value can be stored, but that is much slower,
since program would need to init the stack and pass pointers while
helpers are not inlined, so the cost of return via stack is higher
than returning by value. In this case bpf_perf_event_read() can be hot,
so makes sense to optimize and sacrifice 'pretty' factor.

All existing helpers have use cases behind them and none overlap,
so not a single one can be 'deprecated'.
In general I don't think it's worth to make an exception in the kernel
that some interfaces are not ABI. That will give a bad impression on
the kernel overall. Either we have generic deprecation mechanism for
everything or none and my vote is for none.
