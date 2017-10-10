From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next] netfilter: x_tables: speed up iptables-restore
Date: Tue, 10 Oct 2017 23:39:43 +0200
Message-ID: <20171010213945.19074-1-fw@strlen.de>
To: <netdev@vger.kernel.org>, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:37040 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754255AbdJJVjc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:39:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iptables-restore can take quite a long time when sytem is busy,
in order of half a minute or more.
The main reason for this is the way ip(6)tables performs table
swap, or, more precisely, expensive sequence lock synchronizations
when reading counters.

When xt_replace_table assigns the new ruleset pointer, it does
not wait for other processors to finish with old ruleset.

Instead it relies on the counter sequence lock in get_counters()
to do this.

This works but this is very costly if system is busy as each counter
read operation can possibly be restarted indefinitely.

Instead, make xt_replace_table wait until all processors are
known to not use the old ruleset anymore.

This allows to read the old counters without any locking, no cpu is
using the ruleset anymore so counters can't change either.

 ipv4/netfilter/arp_tables.c |   22 ++++++++++++++++++++--
 ipv4/netfilter/ip_tables.c  |   23 +++++++++++++++++++++--
 ipv6/netfilter/ip6_tables.c |   22 ++++++++++++++++++++--
 netfilter/x_tables.c        |   15 ++++++++++++---
 4 files changed, 73 insertions(+), 9 deletions(-)
