From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Possible bug in net/ipv4/route.c?
Date: Tue, 6 Jul 2010 15:29:28 +0800
Message-ID: <20100706072928.GB14612@gondor.apana.org.au>
References: <CB2DD11991B27C4F99935E6229450D3205B28E91@STORK.scenix.com> <20100705120413.GA6219@gondor.apana.org.au> <20100705110328.65702fc1@nehalam> <20100706002813.GA11194@gondor.apana.org.au> <CB2DD11991B27C4F99935E6229450D3203950BE5@STORK.scenix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sol Kavy <skavy@ubicom.com>, linux-kernel@vger.kernel.org,
	Greg Ren <gren@ubicom.com>, Murat Sezgin <msezgin@ubicom.com>,
	Sener Ilgen <silgen@ubicom.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Guojun Jin <gjin@ubicom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CB2DD11991B27C4F99935E6229450D3203950BE5@STORK.scenix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2010 at 11:06:30PM -0700, Guojun Jin wrote:
>
> Would you please point to where is the best place that CB should be cleared for this case?
> 
> I also wonder why IP packet is routed through ARP queue for ICMP delievry.

I was hoping that you guys would figure this out :)

Anyway, this patch should fix the crash.

bridge: Clear IPCB before possible entry into IP stack

The bridge protocol lives dangerously by having incestuous relations
with the IP stack.  In this instance an abomination has been created
where a bogus IPCB area from a bridged packet leads to a crash in
the IP stack because it's interpreted as IP options.

This patch papers over the problem by clearing the IPCB area in that
particular spot.  To fix this properly we'd also need to parse any
IP options if present but I'm way too lazy for that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4442099..8fb75f8 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -591,6 +591,9 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 
 	pskb_trim_rcsum(skb, len);
 
+	/* BUG: Should really parse the IP options here. */
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
 		return NF_DROP;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
