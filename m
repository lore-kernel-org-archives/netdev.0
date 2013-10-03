From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] fix unsafe set_memory_rw from softirq
Date: Thu, 3 Oct 2013 04:57:07 -0700
Message-ID: <CAMEtUuy2Luxwvf4bjpdKW13S-+5ooAZGi1MDyT8gAM-gtFm1pw@mail.gmail.com>
References: <1380772231-3566-1-git-send-email-ast@plumgrid.com>
	<1380774230.19002.135.camel@edumazet-glaptop.roam.corp.google.com>
	<CAMEtUux5Fvffdg1G-aAe4XN8hJ3oUZyD2Gs3sqcwDdGf9VQ5fw@mail.gmail.com>
	<1380775982.19002.145.camel@edumazet-glaptop.roam.corp.google.com>
	<1380776250.19002.147.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Xi Wang <xi.wang@gmail.com>, x86@kernel.org,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380776250.19002.147.camel@edumazet-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 2, 2013 at 9:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-10-02 at 21:53 -0700, Eric Dumazet wrote:
>> On Wed, 2013-10-02 at 21:44 -0700, Alexei Starovoitov wrote:
>>
>> > I think ifdef config_x86 is a bit ugly inside struct sk_filter, but
>> > don't mind whichever way.
>>
>> Its not fair to make sk_filter bigger, because it means that simple (non
>> JIT) filter might need an extra cache line.
>>
>> You could presumably use the following layout instead :
>>
>> struct sk_filter
>> {
>>         atomic_t                refcnt;
>>         struct rcu_head         rcu;
>>       struct work_struct      work;
>>
>>         unsigned int            len ____cacheline_aligned;    /* Number of filter blocks */
>>         unsigned int            (*bpf_func)(const struct sk_buff *skb,
>>                                             const struct sock_filter *filter);
>>         struct sock_filter      insns[0];
>> };
>
> And since @len is not used by sk_run_filter() use :
>
> struct sk_filter {
>         atomic_t                refcnt;
>         int                     len; /* number of filter blocks */
>         struct rcu_head         rcu;
>         struct work_struct      work;
>
>         unsigned int            (*bpf_func)(const struct sk_buff *skb,
>                                             const struct sock_filter *filter) ____cacheline_aligned;
>         struct sock_filter      insns[0];
> };

yes. make sense to avoid first insn cache miss inside sk_run_filter()
at the expense
of 8-byte gap between work and bpf_func (on x86_64 w/o lockdep)

Probably even better to overlap work and insns fields.
Pro: sk_filter size the same, no impact on non-jit case
Con: would be harder to understand the code

another problem is that kfree(sk_filter) inside
sk_filter_release_rcu() needs to move inside bpf_jit_free().
so self nack. Let me fix these issues and respin

Thanks
Alexei
