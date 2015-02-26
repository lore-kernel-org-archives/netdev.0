From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to traverse
 the bridge without hitting netfilter
Date: Fri, 27 Feb 2015 10:17:42 +1300
Message-ID: <54EF8D76.6070703@openwrt.org>
References: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com> <20150223160619.GF24297@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Palik, Imre" <imrep@amazon.de>,
	Anthony Liguori <aliguori@amazon.com>
To: Florian Westphal <fw@strlen.de>, Imre Palik <imrep.amz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150223160619.GF24297@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-02-24 05:06, Florian Westphal wrote:
> Imre Palik <imrep.amz@gmail.com> wrote:
>> The netfilter code is made with flexibility instead of performance in mind.
>> So when all we want is to pass packets between different interfaces, the
>> performance penalty of hitting netfilter code can be considerable, even when
>> all the firewalling is disabled for the bridge.
>> 
>> This change makes it possible to disable netfilter on a per bridge basis.
>> In the case interesting to us, this can lead to more than 15% speedup
>> compared to the case when only bridge-iptables is disabled.
> 
> I wonder what the speed difference is between no-rules (i.e., we hit jump label
> in NF_HOOK), one single (ebtables) accept-all rule, and this patch, for
> the call_nf==false case.
> 
> I guess your 15% speedup figure is coming from ebtables' O(n) rule
> evaluation overhead?  If yes, how many rules are we talking about?
> 
> Iff thats true, then the 'better' (I know, it won't help you) solution
> would be to use nftables bridgeport-based verdict maps...
> 
> If thats still too much overhead, then we clearly need to do *something*...
I work with MIPS based routers that typically only have 32 or 64 KB of
Dcache. I've had quite a bit of 'fun' working on optimizing netfilter on
these systems. I've done a lot of measurements using oprofile (going to
use perf on my next run).

On these devices, even without netfilter compiled in, the data
structures and code are already way too big for the hot path to fit in
the Dcache (not to mention Icache). This problem has typically gotten a
little bit worse with every new kernel release, aside from just a few
exceptions.

This means that in the hot path, any unnecessary memory access to packet
data (especially IP headers) or to some degree also extra data
structures for netfilter, ebtables, etc. has a significant and visible
performance impact. The impact of the memory accesses is orders of
magnitude bigger than the pure cycles used for running the actual code.

In OpenWrt, I made similar hacks a long time ago, and on the system I
tested on, the speedup was even bigger than 15%, probably closer to 30%.
By the way, this was also with a completely empty ruleset.

Maybe there's a way to get reasonable performance by optimizing NF_HOOK,
however I'd like to remind you guys that if we have to fetch some
netfilter/nftables/ebtables data structures and run part of the table
processing code on a system where no rules are present (or ebtables
functionality is otherwise not needed for a particular bridge), then
performance is going to suck - at least on most small scale embedded
devices.

Based on that, I support the general approach taken by this patch, at
least until somebody has shown that a better approach is feasible.

- Felix
