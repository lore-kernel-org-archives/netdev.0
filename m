From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Tue, 01 Dec 2009 17:24:23 +0100
Message-ID: <4B154337.8060702@trash.net>
References: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>	<4AF999DE.9060206@trash.net> <20091121.110832.213888237.davem@davemloft.net> <4B0883FD.2090806@trash.net> <4B088600.8090209@trash.net> <767BAF49E93AFB4B815B11325788A8ED4B1FDC@L01SLCXDB03.calltower.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080104060907050601070005"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46780 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbZLAQYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:24:18 -0500
In-Reply-To: <767BAF49E93AFB4B815B11325788A8ED4B1FDC@L01SLCXDB03.calltower.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080104060907050601070005
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

ben@bigfootnetworks.com wrote:
>> Ben, please give this patch a try.
> 
> I have not been able to recreate the issue after applying the patch,
> which is great.

Thanks for testing.

> Is this the only case in which large-ish SKBs might be
> recycled and cause the reassembly overflow?

I'm not aware of any other cases at least.

Dave, attached is the patch again with a proper changelog.


--------------080104060907050601070005
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit d45f8b9ff2b7c1c5787348a39d3778931beca7e3
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Dec 1 17:19:14 2009 +0100

    ip_fragment: also adjust skb->truesize for packets not owned by a socket
    
    When a large packet gets reassembled by ip_defrag(), the head skb
    accounts for all the fragments in skb->truesize. If this packet is
    refragmented again, skb->truesize is not re-adjusted to reflect only
    the head size since its not owned by a socket. If the head fragment
    then gets recycled and reused for another received fragment, it might
    exceed the defragmentation limits due to its large truesize value.
    
    skb_recycle_check() explicitly checks for linear skbs, so any recycled
    skb should reflect its true size in skb->truesize. Change ip_fragment()
    to also adjust the truesize value of skbs not owned by a socket.
    
    Reported-and-tested-by: Ben Menchaca <ben@bigfootnetworks.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b78e615..e34013a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -503,8 +503,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			if (skb->sk) {
 				frag->sk = skb->sk;
 				frag->destructor = sock_wfree;
-				truesizes += frag->truesize;
 			}
+			truesizes += frag->truesize;
 		}
 
 		/* Everything is OK. Generate! */

--------------080104060907050601070005--
