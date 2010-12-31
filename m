From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
 skbs
Date: Fri, 31 Dec 2010 12:45:33 -0800 (PST)
Message-ID: <20101231.124533.15243601.davem@davemloft.net>
References: <9mk4bme8o97ir27xi8a9fbsd.1293750376929@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomas.winkler@intel.com, shemminger@vyatta.com,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58736
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753902Ab0LaUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 15:45:03 -0500
In-Reply-To: <9mk4bme8o97ir27xi8a9fbsd.1293750376929@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Thu, 30 Dec 2010 15:06:16 -0800

> Although copy is slower for large packets, this is a non performance
> path. The code in question is for bridged multicast Ipv6 ICMP
> packets. This case is so uncritical it could be done in BASIC and no
> one could possibly care!

I still think we should be judicious and keep using skb_clone() here.

Simply combine the two pskb_may_pull() calls into one on "skb2" after
the clone and before the blind __skb_pull() call.  Then add a error
path "out:" called "out_nopush:" for the error path to goto.

Also, I think the "+ 1" in the ipv6 stack code comes from the fact that
the parsing loop can "peek" into the next header's byte to see the type.
And I really don't think it's relevant here.

Also, all of these "x_header + ... + 1 - skb->data" factors are
irrelevent and shouldn't be used.  Just pass "offset + sizeof(*icmp6h)"
to pskb_may_pull().

