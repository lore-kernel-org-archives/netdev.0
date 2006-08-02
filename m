From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Wed, 02 Aug 2006 23:11:52 +0200
Message-ID: <m3y7u6q1uv.fsf@defiant.localdomain>
References: <m3bqr5z0ah.fsf@defiant.localdomain>
	<20060801195431.GA29335@ms2.inr.ac.ru>
	<m37j1sc7ck.fsf@defiant.localdomain>
	<20060801.173843.35018003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:2757 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S932180AbWHBVLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 17:11:55 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.173843.35018003.davem@davemloft.net> (David Miller's message of "Tue, 01 Aug 2006 17:38:43 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I think Alexey is saying that setting ->hard_header() creates an
> agreement between the device and IP that IP will make sure
> that dev->hard_header_len bytes are available in the header
> area.

I think I now understand it: hard_header_len is guaranteed while
calling hard_header() (because the check is done just before the call)
but not elsewhere, particularly not in hard_start_xmit().
dev->hard_header being NULL or not doesn't change anything.

I think hard_start_xmit() can be called without calling hard_header()
first, for example with things like PF_PACKET. This way the
hard_header_len check is skipped.


It looks it needs to be audited. I think either:
a) dev->hard_header_len must be eliminated completely and skb allocations
   have to assume some sane amount of header space (32 bytes or so), or
b) all dev->hard_header() and dev->hard_start_xmit() calling paths must
   be checked to contain at least dev->hard_header_len header space, or
c) dev->hard_header_len must be clearly marked as advisory, no core
   code changes (all drivers must be audited and fixed).
d) another idea?

What do you prefer?

a) would IMHO the best code quality, reallocations where they are needed
   and no strange semantics which can be easily broken by accident
   (nobody would count on nonexistent hard_header_len either).
   Fast path would not need to reallocate skb data, though the check
   would still be in place.
   We could test it by reducing "default" header space to zero,
   possibly a "hacking" kernel config option may be useful?

b) my patch is the starting point but I'm not sure it's practical.
c) IMHO the worst by all means.

I think I could do a) in a couple of weeks so that it could go into
2.6.19.

Back to my patch. I understand the part about ip_output() is ok
for 2.6.18, isn't it?

What about the psched_mtu() thing? While it's not kernel panic,
I think we should fix it. I'm not sure it should return  dev->mtu +
dev->hard_header_len or just dev->mtu, though.
-- 
Krzysztof Halasa
