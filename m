From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10437] New: MSG_ERRQUEUE messages do not pass
 to connected raw sockets
Date: Sun, 13 Apr 2008 23:15:44 -0700 (PDT)
Message-ID: <20080413.231544.83437216.davem@davemloft.net>
References: <bug-10437-10286@http.bugzilla.kernel.org/>
	<20080410103444.d7309e1f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@butskoy.name, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752645AbYDNGPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:15:42 -0400
In-Reply-To: <20080410103444.d7309e1f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 10 Apr 2008 10:34:44 -0700

> Dmitry, I'd suggest that you send the patch via email to
> netdev@vger.kernel.org and to YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>.

This person is having trouble emailing things to the lists and elsewhere,
for whatever reason, and he states this in the bugzilla entry so asking
him to email a patch somewhere isn't going to help.

The code in this area has changed a bit, here is the patch I just checked
into net-2.6 and which I'll push to Linus for 2.6.25 and will also submit
for the 2.6.24-stable branch.

commit b45e9189c058bfa495073951ff461ee0eea968be
Author: David S. Miller <davem@davemloft.net>
Date:   Sun Apr 13 23:14:15 2008 -0700

    [IPV6]: Fix ipv6 address fetching in raw6_icmp_error().
    
    Fixes kernel bugzilla 10437
    
    Based almost entirely upon a patch by Dmitry Butskoy.
    
    When deciding what raw sockets to deliver the ICMPv6
    to, we should use the addresses in the ICMPv6 quoted
    IPV6 header, not the top-level one.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8897ccf..0a6fbc1 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -372,8 +372,10 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 	if (sk != NULL) {
-		saddr = &ipv6_hdr(skb)->saddr;
-		daddr = &ipv6_hdr(skb)->daddr;
+		struct ipv6hdr *hdr = (struct ipv6hdr *) skb->data;
+
+		saddr = &hdr->saddr;
+		daddr = &hdr->daddr;
 		net = skb->dev->nd_net;
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,
