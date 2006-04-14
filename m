From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 15:51:29 -0700 (PDT)
Message-ID: <20060414.155129.121789313.davem@davemloft.net>
References: <Pine.WNT.4.63.0604141448520.2116@jbrandeb-desk.amr.corp.intel.com>
	<20060414.153219.62111494.davem@davemloft.net>
	<Pine.WNT.4.63.0604141533250.2116@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	Jeffrey.t.kirsher@intel.com, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48807
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751327AbWDNWvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:51:14 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.WNT.4.63.0604141533250.2116@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 15:43:02 -0700 (Pacific Daylight Time)

> Please help me understand how you think it should work when we have a 
> device that wants to receive a packet using header in the skb->data, and 
> application data in the ->frags[]? 

If you're removing the pages from ->frags[] and you already accounted
for them in skb->truesize, then yes I guess it could be correct to
subtract it back out.

Looking at S2IO it's doing something very wrong with it's modification
of skb->truesize.  It's not changing the amount of memory allocated
to an SKB in any way yet it's bumping skb->truesize for some reason.
That will definitely lead to performance problems.

That's why generally when we see an skb->truesize modification, it's
just assumed to be a bug, it's generally not necessary but may be
so in your e1000 situation here.

Another problem to look out for is that once a socket has a reference
to an SKB you must never ever modify skb->truesize because doing so
will break socket memory accounting.  There is exactly one spot in
the TCP stack where we are able to do this by adjusting the socket
memory accounting variables carefully in a locked context at the same
time, but otherwise it's not safe to modify skb->truesize when there
is an attached socket.

