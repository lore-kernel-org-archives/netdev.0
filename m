From: David Miller <davem@davemloft.net>
Subject: Re: loading sctp fails an order 10 allocation.
Date: Wed, 30 Mar 2011 17:52:02 -0700 (PDT)
Message-ID: <20110330.175202.235689626.davem@davemloft.net>
References: <20110330234020.GA24517@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756556Ab1CaAwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 20:52:41 -0400
In-Reply-To: <20110330234020.GA24517@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 30 Mar 2011 19:40:21 -0400

> modprobe sctp on my laptop does this which looks crazy..
 ...
> it doesn't look like the hashtable allocation code has changed in ages, so I'm 
> not sure why I've never triggered this before.

I decided to take a break from watching Charlie Sheen dubstep remixes
in a loop on youtube to look at this bug.

This situation is amusing because SCTP actually tries to allocate an
initially smaller hash table than, for example, the DCCP module does.

But DCCP won't show the behavior you see.

The thing that's different is that SCTP forgets to pass __GFP_NOWARN
to the allocation.  The code there is able to handle failures just
fine and simply tries to progressively grab a smaller table when that
happens.

I'll commit the following to net-2.6, thanks.

Now back to Adonis dubsteps...

--------------------
sctp: Pass __GFP_NOWARN to hash table allocation attempts.

Like DCCP and other similar pieces of code, there are mechanisms
here to try allocating smaller hash tables if the allocation
fails.  So pass in __GFP_NOWARN like the others do instead of
emitting a scary message.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/protocol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 152976e..d5bf91d 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1205,7 +1205,7 @@ SCTP_STATIC __init int sctp_init(void)
 		if ((sctp_assoc_hashsize > (64 * 1024)) && order > 0)
 			continue;
 		sctp_assoc_hashtable = (struct sctp_hashbucket *)
-					__get_free_pages(GFP_ATOMIC, order);
+			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
 	} while (!sctp_assoc_hashtable && --order > 0);
 	if (!sctp_assoc_hashtable) {
 		pr_err("Failed association hash alloc\n");
@@ -1238,7 +1238,7 @@ SCTP_STATIC __init int sctp_init(void)
 		if ((sctp_port_hashsize > (64 * 1024)) && order > 0)
 			continue;
 		sctp_port_hashtable = (struct sctp_bind_hashbucket *)
-					__get_free_pages(GFP_ATOMIC, order);
+			__get_free_pages(GFP_ATOMIC|__GFP_NOWARN, order);
 	} while (!sctp_port_hashtable && --order > 0);
 	if (!sctp_port_hashtable) {
 		pr_err("Failed bind hash alloc\n");
-- 
1.7.4.2

