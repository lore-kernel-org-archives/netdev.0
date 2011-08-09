From: Julian Anastasov <ja@ssi.bg>
Subject: Re: return of ip_rt_bug()
Date: Tue, 9 Aug 2011 16:51:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108091645351.1527@ja.ssi.bg>
References: <CAFiZG+Ve9Y4v9CWCrbGsR+7C79AyoiWncVSVbeqApDuKaPm_jA@mail.gmail.com> <CAFiZG+VJ27939BT-dTbvSotxO6+ACbxWiYwQBUT9pC_Fw22O-w@mail.gmail.com> <alpine.LFD.2.00.1108070104440.1413@ja.ssi.bg> <20110807.222042.1034530719366562334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@gmail.com, davej@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47571 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab1HINqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:46:40 -0400
In-Reply-To: <20110807.222042.1034530719366562334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 7 Aug 2011, David Miller wrote:

> commit 1b86a58f9d7ce4fe2377687f378fbfb53bdc9b6c
> Author: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> Date:   Thu Apr 7 14:04:08 2011 -0700
> 
>     ipv4: Fix "Set rt->rt_iif more sanely on output routes."

	I now checked these changes back to 2.6.38.
As rt_iif is used to provide input device even for loopback packets
that come with output route, may be we can optimize further
the code to save some CPU cycles. In fact, it restores
some route.c functions to 2.6.38 semantics. The conversion was:

fl.iif -> rt_route_iif
rt_iif -> preserved

	There are other places that used fl.iif (0 for output
routes) but are now using rt_iif instead of rt_route_iif,
not sure if this change is fatal for them because:

- net/sched/cls_route.c, route4_classify() gets optional
iif, so it can be 0, may be to match output route? And
later route4_classify does exact match for rt_iif. Does
it mean that now we can not match output packets without
providing "fromif OUTDEV" ?

- net/sched/em_meta.c: now int_rtiif (being rt_iif) is
always != 0, may be not good to match output routes?

	In short, the fl.iif -> rt_iif conversion is risky
at some places.

	For now posting patch for route.c in another thread...

Regards

--
Julian Anastasov <ja@ssi.bg>
