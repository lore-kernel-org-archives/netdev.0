From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Question: how to detect if a qdisc is root or not?
Date: Sat, 21 Jul 2007 11:55:39 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290344621B@orsmsx414.amr.corp.intel.com>
References: <46A18503.8000800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57172 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754881AbXGUSzl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 14:55:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A18503.8000800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Anyways, I tried a few different things, and what it looks like is
> > sch->parent will be NULL (0) for the top-level device.  This is 
> > sch->correct,
> > and trying to mess with that screws up qdisc_graft() when unloading 
> > the qdisc.  I also tried adding a TCQ_F_ROOT flag to 
> sch->flags when 
> > classid is TC_H_ROOT, but that also screwed up unloading the qdisc.
> 
> 
> I dont think I understand. Whats the problem with setting 
> sch->parent on initialization instead on grafting as I did in 
> my example patch?
> Please explain the problems arrising on unload in detail.

sch->parent is getting set on initialization, and for the root and
ingress qdiscs, it's left at zero.  If I change that value, when the
root qdisc is unloaded and pfifo_fast is put back into place, the
qdisc_destroy() walks the tree and attempts to free memory from the
handle pointed at by sch->parent.  It stops when sch->parent is NULL, so
sch->parent is actually being set as intended.  The only thing that
confused me is that nowhere in the qdisc is TC_H_ROOT included
explicitly, rather, the root qdisc is where sch->parent is NULL.

So I misunderstood what was actually wrong.  The qdisc code is ok as-is,
it's just that the top-level qdisc (root and ingress) have a sch->parent
of NULL, which is being set correctly today.

Hope that clarifies.

Thanks,
-PJ
