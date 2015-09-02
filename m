From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Wed, 02 Sep 2015 16:04:36 -0700 (PDT)
Message-ID: <20150902.160436.1598170214563453758.davem@davemloft.net>
References: <1441229445.8932.206.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150902215203.GB78846@kafai-mba.local>
	<1441234137.8932.209.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbbIBXEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:04:39 -0400
In-Reply-To: <1441234137.8932.209.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Sep 2015 15:48:57 -0700

> On Wed, 2015-09-02 at 14:52 -0700, Martin KaFai Lau wrote:
>> On Wed, Sep 02, 2015 at 02:30:45PM -0700, Eric Dumazet wrote:
>> > Object cannot be freed until all cpus have exited their RCU sections.
>> You meant the dst_destroy() here will wait for all cpus exited their RCU sections?
>> 
>> static inline void dst_free(struct dst_entry *dst)
>> {
>> 	if (dst->obsolete > 0)
>> 		return;
>> 	if (!atomic_read(&dst->__refcnt)) {
>> 		dst = dst_destroy(dst);
>> 		if (!dst)
>> 			return;
>> 	}
>> 	__dst_free(dst);
>> }
> 
> dst_free() is called after RCU grace period, in the case you are
> interested in.
> 
> Look at dst_rcu_free() and rt_free()

For ipv4, this is true, but in ipv6, it is not necessarily done in
this way.  And I think that is the point Martin is trying to make.

If you look, the dst_free() calls in ipv6 are basically synchronous,
it does not use dst_rcu_free().

And thus, the fix is to make ipv6 properly RCU free route entries.
