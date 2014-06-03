From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: netfront: Compound pages problem
Date: Tue, 3 Jun 2014 23:03:17 +0100
Message-ID: <538E4625.3080804@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	David Miller <davem@davemloft.net>
To: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35305 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaFCWDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 18:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There were already discussions on this list and at Xen Hackathon about a 
netback/netfront issue:

http://lists.xenproject.org/archives/html/xen-devel/2014-06/msg00300.html

In a nutshell: due to compound pages an skb can consume more slots than 
we can transfer for a single packet. Lots of ideas came up about how to 
solve this problem, the preferred short term one is to poke the buffer 
layout of the affected skbs so they will finally fit onto the ring.
That might sound simple, but after 2 days of implementing an algorithm, 
which is:
- handle all the possible weird scenarios
- try to do as few memcpy's as possible
I can tell that it's not :). Now I'm at 110 lines without comments, and 
it's not ready yet.

Paul came up with an idea today: we can call dev_gso_segment() which 
will slice up the problematic skb into MTU size chunks. Then we can add 
this list of skbs to our queues and transmit them separately.

Pros:
- it already exists and works
- doesn't copy the payload apart from the headers

Cons:
- it is also very complicated, but at least a well tested code
- it creates new skbs and copies the header there, worst case 
max_gso_size / MTU times

I tend to say this could be a good solution for us, but I want to hear 
other opinions as well.

Regards,

Zoli
