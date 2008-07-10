From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 10 Jul 2008 14:00:17 -0700
Message-ID: <1215723617.6901.3.camel@dell>
References: <4863DA40.9050508@broadcom.com>
 <20080709164619.GA26098@orion.carnet.hr>
 <1215622625.5532.43.camel@dell>
 <20080709.164659.157912631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "joy@debian.org" <joy@debian.org>,
	"billfink@mindspring.com" <billfink@mindspring.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4543 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753978AbYGJU50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 16:57:26 -0400
In-Reply-To: <20080709.164659.157912631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-09 at 16:46 -0700, David Miller wrote:
> Actually I went investigating this and all the code paths check for
> skb_cloned() and if true they make a copy of the data area (and thus
> the skb_shared_info()) and this should ensure that the driver doesn't
> see changing nr_frags values.

Since Josip can readily reproduce this problem, let's confirm if the SKB
is split while it is cloned.  Please try this debug patch:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5c459f2..03ec3b8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1960,6 +1960,10 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 {
 	int pos = skb_headlen(skb);
 
+	if (skb_cloned(skb)) {
+		printk(KERN_ALERT "Splitting cloned skb\n")
+		dump_stack();
+	}
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */



