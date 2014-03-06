From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] inet: frag: make sure forced eviction removes all frags
Date: Thu,  6 Mar 2014 18:06:41 +0100
Message-ID: <1394125601-27685-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40975 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752512AbaCFRKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 12:10:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Alexander Aring:
  While fragmentation and unloading of 6lowpan module I got this kernel Oops
  after few seconds:

  BUG: unable to handle kernel paging request at f88bbc30
  [..]
  Modules linked in: ipv6 [last unloaded: 6lowpan]
  Call Trace:
   [<c012af4c>] ? call_timer_fn+0x54/0xb3
   [<c012aef8>] ? process_timeout+0xa/0xa
   [<c012b66b>] run_timer_softirq+0x140/0x15f

Problem is that incomplete frags are still around after unload; when
their frag expire timer fires, we get crash.

When a netns is removed (also done when unloading module), inet_frag
calls the evictor with 'force' argument to purge remaining frags.

The evictor loop terminates when accounted memory ('work') drops to 0
or the lru-list becomes empty.  However, the mem accounting is done
via percpu counters and may not be accurate, i.e. loop may terminate
prematurely.

Alter evictor to only stop once the lru list is empty when force is
requested.

Reported-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Reported-by: Alexander Aring <alex.aring@gmail.com>
Tested-by: Alexander Aring <alex.aring@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 322dceb..3b01959 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -208,7 +208,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 	}
 
 	work = frag_mem_limit(nf) - nf->low_thresh;
-	while (work > 0) {
+	while (work > 0 || force) {
 		spin_lock(&nf->lru_lock);
 
 		if (list_empty(&nf->lru_list)) {
-- 
1.8.1.5
