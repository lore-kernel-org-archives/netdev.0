From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question: how to detect if a qdisc is root or not?
Date: Thu, 19 Jul 2007 01:39:58 +0200
Message-ID: <469EA4CE.4000402@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290340F87C@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50983 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937513AbXGRXkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:40:37 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290340F87C@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>You're right, thats a bug. TC_H_ROOT is the parent ID, which 
>>is stored in sch->parent. IIRC its also passed to the 
>>->init() function.
> 
> 
> Unfortunately it's not passed.  It is passed into the ->change()
> function:
> 
> static int prio_init(struct Qdisc *sch, struct rtattr *opt)
> 
> static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct
> rtattr **tca, unsigned long *arg)
> 
> I did mess around with sch->parent a bit, with no success (it appears to
> be zero / unitialized).  I'll keep investigating.


Its set after grafting the parent, which is after initialization.
I think what should work is to set it in qdisc_create instead,
sch_api.c around line 490:

+	sch->parent = handle;

        if (handle == TC_H_INGRESS) {
                sch->flags |= TCQ_F_INGRESS;
                sch->stats_lock = &dev->ingress_lock;
...

and remove the initialization in qdisc_graft. That would additionally
have the benefit that ingress qdiscs also have it initialized properly.
