From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Problem with xfrm (ipsec) as state/spi selected solely on outer ip addresses
Date: Fri, 11 May 2007 16:22:24 +0300
Message-ID: <200705111622.24680.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:46025 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147AbXEKNv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 09:51:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by creon.otaverkko.fi (Postfix) with ESMTP id 6B79221AF64
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:22:25 +0300 (EEST)
Received: from argo.otaverkko.fi (argo.otaverkko.fi [212.68.0.2])
	by creon.otaverkko.fi (Postfix) with ESMTP id 40B8C21AF59
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:22:24 +0300 (EEST)
Received: from vetar.pc.hiit.fi (vetar.pc.hiit.fi [128.214.113.230])
	by argo.otaverkko.fi (Postfix) with ESMTP id 3C7E425ED06
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:22:24 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all, 

I'm running a system where there might be multiple simultenously
active ipsec states between two hosts (ipv6, but guess it applies to
v4 as well) where the outer ip is the same for all states, but the
inner differ (using beet mode).

The problem is that after establishing these states, it seems that the
one associated with outgoing traffic is selected solely by the outer
address (the first state matching the outer ip-pairs is used), which
usually results in the wrong spi and the packet being dropped at the
receiver.

I've circumvented the problem by modifying the state selection
algorithm in xfrm_state_find() [xfrm_state.c] to prefer, if possible,
states which also match by the inner addresses. Is this really a
problem of the selection algorithm, or might I be doing something 
wrong elsewhere?

Here's the changes I've done to make it work for me.  As said, it
prefers states with matching inner-address, but if none is found it
works as before:


diff -urN  a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c 2007-05-11 15:37:35.000000000 +0300
+++ b/net/xfrm/xfrm_state.c 2007-05-11 15:37:35.000000000 +0300
@@ -374,6 +374,17 @@
                                    (best->km.dying == x->km.dying &&
                                     best->curlft.add_time < x->curlft.add_time))
                                        best = x;
+                               else if (pol->selector.family == x->sel.family &&
+                                        (pol->selector.family == AF_INET6 &&
+                                         !ipv6_addr_cmp((struct in6_addr *)&pol->selector.daddr,
+                                                        (struct in6_addr *)&x->sel.daddr) &&
+                                         !ipv6_addr_cmp((struct in6_addr *)&pol->selector.saddr,
+                                                        (struct in6_addr *)&x->sel.saddr)) ||
+                                        (pol->selector.family == AF_INET &&
+                                         pol->selector.daddr.a4 == x->sel.daddr.a4 &&
+                                         pol->selector.saddr.a4 == x->sel.saddr.a4))
+                                       best = x;
+
                        } else if (x->km.state == XFRM_STATE_ACQ) {
                                acquire_in_progress = 1;
                        } else if (x->km.state == XFRM_STATE_ERROR ||

br, j

--
Joakim Koskela
Helsinki Institute for Information Technology, http://www.hiit.fi
