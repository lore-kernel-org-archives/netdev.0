From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: Re: [PATCH 2.6.30-rc5] ehea: fix invalid pointer access
Date: Tue, 5 May 2009 15:45:05 +0200
Message-ID: <200905051545.05877.hannes.hering@linux.vnet.ibm.com>
References: <200905051319.05806.hannes.hering@linux.vnet.ibm.com> <25628.1241514687@redhat.com> <26110.1241525994@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, themann@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	raisch@de.ibm.com, ossrosch@linux.vnet.ibm.com,
	linuxppc-dev@ozlabs.org, ossthema@de.ibm.com, osstklei@de.ibm.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:38836 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbZEENpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 09:45:07 -0400
In-Reply-To: <26110.1241525994@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 May 2009 14:19:54 David Howells wrote:
> In that case, you might want to move the prefetchw() calls in the following:
> 
> 		pref = skb_array[x];
> 	-	prefetchw(pref);
> 	-	prefetchw(pref + EHEA_CACHE_LINE);
> 	+	if (pref) {
> 	+		prefetchw(pref);
> 	+		prefetchw(pref + EHEA_CACHE_LINE);
> 
> to before the if-statement.  That way the CPU can be attempting the prefetch
> whilst it's chewing over the test and branch.  prefetching shouldn't fault on
> a bad address.
> 
> David
Hi David,

you are right so far, but actually the prefetch calls on POWER also contain
an if statement to check if the address is valid (i. e. non-zero). We never
have the case that the pref != NULL and pref->data == NULL. And the situation
of pref==NULL is very rare. This means there is no benefit moving our if
statement down from performance perspective if we assume that our if does not
take longer then the if in the prefetch command. We can add an
if(likely(pref) if you like. In fact doing the if statement as we do it now
we actually save the prefetch if statements in case we hit the situation of
pref==NULL.

Regards

Hannes
