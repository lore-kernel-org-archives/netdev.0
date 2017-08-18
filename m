From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next PATCH] ipv6: fix false-postive maybe-uninitialized warning
Date: Fri, 18 Aug 2017 21:46:46 +0200
Message-ID: <CAK8P3a1tv-paF3jHkPDK46bvMR3+2fd3+pFNpn7QJqyNut+DCg@mail.gmail.com>
References: <20170818113434.3037484-1-arnd@arndb.de> <20170818.104940.305624900632112023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        Florian Westphal <fw@strlen.de>, dsahern@gmail.com,
        kafai@fb.com, weiwan@google.com, xiyou.wangcong@gmail.com,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818.104940.305624900632112023.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2017 at 7:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Fri, 18 Aug 2017 13:34:22 +0200

>>
>> This kind of warning involving an unlock between variable initialization
>> and use is relatively frequent for false-positives. I should try to
>> seek clarification from the gcc developers on whether this can be
>> improved.
>
> This will have to do for now I suppose.
>
> I guess the issue is that if the local variable ever sits on the stack
> then the memory barriers in the locks block the full dataflow
> analysis.
>
> But this makes no sense from a dataflow perspective.  Even if the
> local variable has a stack slot, there is no "escapability" of that
> memory addres to foreign modifications.
>
> If I had a nickel for every uninitialized variable warning we had to
> work around....

Since this pattern has come up so often, I spent most of my working
day today on a reduced testcase, and ended up with this surprising
snippet:

int f(void);
static inline void rcu_read_unlock(void)
{
        static _Bool __warned;
        if (f() && !__warned && !f()) {
                __warned = 1;
        }
}
int inet6_rtm_getroute(void)
{
        int dst;
        int fibmatch = f();

        if (!fibmatch)
                dst = f();
        rcu_read_unlock();
        if (fibmatch)
                dst = 0;

        return dst;
}

So at least in this particular case, the culprit is not actually
a memory barrier, but RCU_LOCKDEP_WARN(). A related
problem is __branch_check__()/__trace_if().

While the maybe-uninitialized warnings are unreliable by
definition, I think that case really should be understood by gcc.

I looked through the gcc bug database which has countless
entries but doesn't seem to have this one yet, so I opened
a new bug:
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81897

Unfortunately the basic behavior shows up in gcc-4.7 already,
so it has no chance of getting fixed on older compilers.

        Arnd
