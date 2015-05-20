From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 11:07:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505201050590.1557@ja.home.ssi.bg>
References: <1432085113-25063-1-git-send-email-ying.xue@windriver.com> <1432099637.4060.12.camel@edumazet-glaptop2.roam.corp.google.com> <555C313E.1020003@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, alexei@purestorage.com, joern@purestorage.com
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57223 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751341AbbETIHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2015 04:07:46 -0400
In-Reply-To: <555C313E.1020003@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 20 May 2015, Ying Xue wrote:

> On 05/20/2015 01:27 PM, Eric Dumazet wrote:
> > Sorry, this atomic_read() makes no sense to me.
> > 
> > When rcu is used, this is perfectly fine to use an object which refcount
> > is 0. If you believe the opposite, then point me to relevant
> > Documentation/RCU/ file.
> > 
> 
> However, the reality for us is that rcu_read_lock() can guarantee that a neigh
> object is not freed within the area covered by rcu read lock, but it cannot
> prevent neigh_destroy() from being executed in another context at the same time.

	The situation is that one writer decided that
entry is to be removed. Reader comes and tries to become
second writer. It should check refcnt==0 or dead==1 as
in your last patch, always under write_lock. Second and next
writers should not try to change state, timers, etc.
Such writers are possible only if they were readers because
only they can find entry that is unlinked by another writer.

	And we want to keep the readers free of any memory
barriers as they can cost hundreds of clocks. We are lucky
that the neigh states allow RCU readers to run without any 
atomic_inc_not_zero calls because memory barriers are not
cheap.

Regards

--
Julian Anastasov <ja@ssi.bg>
