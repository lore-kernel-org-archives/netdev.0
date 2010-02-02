From: Patrick McHardy <kaber@trash.net>
Subject: Re: PROBLEM with summary: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 18:04:20 +0100
Message-ID: <4B685B14.1040207@trash.net>
References: <1264813832.2793.446.camel@tonnant>	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>	 <1264834704.2919.3.camel@edumazet-laptop>	 <1265016745.7499.144.camel@tonnant>	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>	 <1265019160.2848.14.camel@edumazet-laptop>	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>	 <1265023437.2848.30.camel@edumazet-laptop>	 <1265035970.2848.50.camel@edumazet-laptop>	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>	 <1265036548.2848.55.camel@edumazet-laptop>	 <1265108690.2861.118.camel@tonnant>  <1265110504.2861.135.camel@tonnant>	 <1265129192.2861.141.camel@tonnant> <1265129903.2861.150.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265129903.2861.150.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Masters wrote:
> On Tue, 2010-02-02 at 11:46 -0500, Jon Masters wrote:
>> On Tue, 2010-02-02 at 06:35 -0500, Jon Masters wrote:
>>
>>> I think there's something more fundamental going on here.
>> What happens is the conntrack code attempts to free
>> nf_conntrack_untracked back into the SL[U]B cache from which it
>> allocates other ct's. There's just one problem...that's a static struct
>> not from the cache. So, this is why we end up with the SLAB being
>> corrupted and the address immediately following the
>> nf_conntrack_untracked being corrupted.
>>
>> I shoved some debug comments into the destroy code to see if we were
>> trying to free nf_conntrack_untracked, and bingo. I have shoved a panic
>> in there now, will send you a backtrace.
> 
> So we attach after starting a VM due to icmpv6_error setting the ct in
> some incoming skb to the "untracked" catchall one. Then we panic when I
> force a panic if attempting to free the nf_conntrack_untracked static
> struct with this backtrace:
> 
> #5  0xffffffff81455884 in panic (
>     fmt=0xffffffff81ec51e0 "JCM: nf_conntrack_destroy: trying to destroy
> nf_conntrack_untracked!\n")
>     at kernel/panic.c:73
> #6  0xffffffff813d266c in nf_conntrack_destroy (nfct=<value optimized
> out>) at net/netfilter/core.c:244
> #7  0xffffffff813abd97 in nf_conntrack_put (skb=0xffff880223b8b700) at
> include/linux/skbuff.h:1924
> #8  skb_release_head_state (skb=0xffff880223b8b700) at
> net/core/skbuff.c:402
> #9  0xffffffff813abaf9 in skb_release_all (skb=0xffff880223b8b700) at
> net/core/skbuff.c:420
> #10 __kfree_skb (skb=0xffff880223b8b700) at net/core/skbuff.c:435
> #11 0xffffffff813abbfe in kfree_skb (skb=0xffff880223b8b700) at
> net/core/skbuff.c:456
> 
> Could you please add (or recommend for me to test) some logic to catch
> attempts to free the nf_conntrack_untracked and prevent it? Also, maybe
> in the init_net code you could remove the re-initialization of the
> untracked conntrack each time a namespace is created?

Ah nice catch, that seems to be the problem. When the untracked
conntrack is already attached to an skb and thus has refcnt > 1
and we re-initalize the refcnt, it will get freed.

The question is whether the ct_net pointer of the untracked conntrack
is actually required. If so, we need one instance per namespace,
otherwise we can just move initialization and cleanup to the init_net
init/cleanup functions. Alexey, do you happen to know this?

