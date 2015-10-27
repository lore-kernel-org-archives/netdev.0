From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Tue, 27 Oct 2015 13:26:47 +0100
Message-ID: <20151027122647.GG9891@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151026165619.GB2214@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 26-10-15 12:56:19, Johannes Weiner wrote:
[...]
> Now you could argue that there might exist specialized workloads that
> need to account anonymous pages and page cache, but not socket memory
> buffers.

Exactly, and there are loads doing this. Memcg groups are also created to
limit anon/page cache consumers to not affect the others running on
the system (basically in the root memcg context from memcg POV) which
don't care about tracking and they definitely do not want to pay for an
additional overhead. We should definitely be able to offer a global
disable knob for them. The same applies to kmem accounting in general.

I do understand with having the accounting enabled by default after we
are reasonably sure that both kmem/tcp are stable enough (which I am
not convinced about yet to be honest) but there will be always special
loads which simply do not care about kmem/tcp accounting and rather pay
a global balancing price (even OOM) rather than a permanent price. And
they should get a way to opt-out.

> Or any other combination of pick-and-choose consumers. But
> honestly, nowadays all our paths are lockless, and the counting is an
> atomic-add-return with a per-cpu batch cache.

You are still hooking into hot paths and there are users who want to
squeeze every single cycle from the HW.

> I don't think there is a compelling case for an elaborate interface
> to make individual memory consumers configurable inside the memory
> controller.

I do not think we need an elaborate interface. We just want to have
a global boot time knob to overwrite the default behavior. This is
few lines of code and it should give the sufficient flexibility.
-- 
Michal Hocko
SUSE Labs
