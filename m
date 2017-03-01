From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 09/14] netfilter: conntrack: refine gc worker heuristics,
 redux
Date: Wed, 1 Mar 2017 16:38:00 +0100
Message-ID: <20170301153800.GA7669@salvia>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
 <1485448687-6072-10-git-send-email-pablo@netfilter.org>
 <09f1081e-ade3-6099-a3c6-b1b912592f54@6wind.com>
 <dd8b8fe3-5c73-c7b9-314f-70ceb0abd2b0@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57030 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752001AbdCAPiH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Mar 2017 10:38:07 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ABCEB1BCFCE
        for <netdev@vger.kernel.org>; Wed,  1 Mar 2017 16:38:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9986DDA807
        for <netdev@vger.kernel.org>; Wed,  1 Mar 2017 16:38:05 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6DC0EDA819
        for <netdev@vger.kernel.org>; Wed,  1 Mar 2017 16:38:01 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <dd8b8fe3-5c73-c7b9-314f-70ceb0abd2b0@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 01, 2017 at 04:02:53PM +0100, Nicolas Dichtel wrote:
> Le 27/01/2017 à 17:51, Nicolas Dichtel a écrit :
> > Le 26/01/2017 à 17:38, Pablo Neira Ayuso a écrit :
> >> From: Florian Westphal <fw@strlen.de>
> >>
> >> This further refines the changes made to conntrack gc_worker in
> >> commit e0df8cae6c16 ("netfilter: conntrack: refine gc worker heuristics").
> >>
> >> The main idea of that change was to reduce the scan interval when evictions
> >> take place.
> >>
> >> However, on the reporters' setup, there are 1-2 million conntrack entries
> >> in total and roughly 8k new (and closing) connections per second.
> >>
> >> In this case we'll always evict at least one entry per gc cycle and scan
> >> interval is always at 1 jiffy because of this test:
> >>
> >>  } else if (expired_count) {
> >>      gc_work->next_gc_run /= 2U;
> >>      next_run = msecs_to_jiffies(1);
> >>
> >> being true almost all the time.
> >>
> >> Given we scan ~10k entries per run its clearly wrong to reduce interval
> >> based on nonzero eviction count, it will only waste cpu cycles since a vast
> >> majorities of conntracks are not timed out.
> >>
> >> Thus only look at the ratio (scanned entries vs. evicted entries) to make
> >> a decision on whether to reduce or not.
> >>
> >> Because evictor is supposed to only kick in when system turns idle after
> >> a busy period, pick a high ratio -- this makes it 50%.  We thus keep
> >> the idea of increasing scan rate when its likely that table contains many
> >> expired entries.
> >>
> >> In order to not let timed-out entries hang around for too long
> >> (important when using event logging, in which case we want to timely
> >> destroy events), we now scan the full table within at most
> >> GC_MAX_SCAN_JIFFIES (16 seconds) even in worst-case scenario where all
> >> timed-out entries sit in same slot.
> >>
> >> I tested this with a vm under synflood (with
> >> sysctl net.netfilter.nf_conntrack_tcp_timeout_syn_recv=3).
> >>
> >> While flood is ongoing, interval now stays at its max rate
> >> (GC_MAX_SCAN_JIFFIES / GC_MAX_BUCKETS_DIV -> 125ms).
> >>
> >> With feedback from Nicolas Dichtel.
> >>
> >> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> >> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> Fixes: b87a2f9199ea82eaadc ("netfilter: conntrack: add gc worker to remove timed-out entries")
> >> Signed-off-by: Florian Westphal <fw@strlen.de>
> >> Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >> Tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> >> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > Pablo, is it possible to queue this patch (and the previous: 08/14) for the 4.9
> > stable?
> 
> Pablo, should I submit it formally?

Just requested this to Greg, sorry this didn't happen so far.

Thanks.
