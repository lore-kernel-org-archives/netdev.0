From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2.6.30-rc5] ehea: fix invalid pointer access
Date: Tue, 05 May 2009 13:19:54 +0100
Message-ID: <26110.1241525994@redhat.com>
References: <200905051319.05806.hannes.hering@linux.vnet.ibm.com> <200905041802.30527.hannes.hering@linux.vnet.ibm.com> <25628.1241514687@redhat.com>
Cc: dhowells@redhat.com, David Miller <davem@davemloft.net>,
	themann@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, raisch@de.ibm.com,
	ossrosch@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org,
	ossthema@de.ibm.com, osstklei@de.ibm.com
To: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51486 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbZEEMWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 08:22:21 -0400
In-Reply-To: <200905051319.05806.hannes.hering@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Hering <hannes.hering@linux.vnet.ibm.com> wrote:

> this is an ehea driver problem, which is occuring when the receive queue runs
> empty. The faulting code is more specifically the following line:
> 
> 	pref = (skb_array[x]->data);

In that case, you might want to move the prefetchw() calls in the following:

		pref = skb_array[x];
	-	prefetchw(pref);
	-	prefetchw(pref + EHEA_CACHE_LINE);
	+	if (pref) {
	+		prefetchw(pref);
	+		prefetchw(pref + EHEA_CACHE_LINE);

to before the if-statement.  That way the CPU can be attempting the prefetch
whilst it's chewing over the test and branch.  prefetching shouldn't fault on
a bad address.

David
