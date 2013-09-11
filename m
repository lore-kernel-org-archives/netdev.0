From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH nf] netfilter: use RCU safe kfree for conntrack extensions
Date: Wed, 11 Sep 2013 17:28:05 +0200
Message-ID: <20130911152804.GA5397@unicorn.suse.cz>
References: <20130911090900.0129AE8AFF@unicorn.suse.cz>
 <20130911145715.GA2882@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	coreteam@netfilter.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130911145715.GA2882@linuxace.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 07:57:15AM -0700, Phil Oester wrote:
> On Wed, Sep 11, 2013 at 10:17:27AM +0200, Michal Kubecek wrote:
> > Commit 68b80f11 (netfilter: nf_nat: fix RCU races) introduced
> > RCU protection for freeing extension data when reallocation
> > moves them to a new location. We need the same protection when
> > freeing them in nf_ct_ext_free() in order to prevent a
> > use-after-free by other threads referencing a NAT extension data
> > via bysource list.
> 
> Hi Michal - 
> 
> coincidentally I've been looking into this area this week due to another
> bug report (https://bugzilla.kernel.org/show_bug.cgi?id=60853).

Looking at the initial command, I would say this bug report is actually
of the same origin as ours.

> Looking at
> your proposed fix, the NAT extension data should have been cleaned
> from the bysource list in nf_nat_cleanup_conntrack (via __nf_ct_ext_destroy)
> before reaching the kfree.  Would you agree?

It is cleaned from the list but as it is an RCU list, other readers can
still be holding pointers to it. We have to wait for the RCU grace
period before we can reuse it.

> The reporter of #60853 suggested adding a synchronize_rcu to the end of the
> nf_nat_cleanup_conntrack function, which seems sane.

That was also my first idea. However, nf_nat_cleanup_conntrack() is
called from __nf_ct_ext_destroy() inside a rcu_read_lock() /
rcu_read_unlock() block. Even if this block is for a different RCU list,
we still cannot call synchronize_rcu() while inside it.

We could call synchronize_rcu() in __nf_ct_ext_destroy() after
rcu_read_unlock() but this would IMHO add an unnecessary delay so it is
more efficient and more appropriate to wait before the actual kfree()
which is the operation that needs to wait for RCU grace period.

> I have been trying to reproduce the crash to test that theory.
> Are you able to reproduce an OOPS in your testing?  Or is there a bug
> report you are working from?

No, it is a bugreport from our customer. And even that customer
encountered it only once so far. Which is not very surprising as to
reproduce it, you have to be (un)lucky twice: first to have someone
overwrite the area soon enough and second to have someone access the
area after it is overwritten. This is IMHO the reason why the reporter
cleared the block with memset() for testing purposes.

                                                     Michal Kubecek

