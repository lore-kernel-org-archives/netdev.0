From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Fri, 9 Jan 2009 23:04:55 +1100
Message-ID: <20090109120455.GB12486@gondor.apana.org.au>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com> <20090109031408.GB11336@gondor.apana.org.au> <20090109115515.GA12486@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Speedster <speedster@haveacry.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40645 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752691AbZAIMFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 07:05:03 -0500
Content-Disposition: inline
In-Reply-To: <20090109115515.GA12486@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 10:55:15PM +1100, Herbert Xu wrote:
> 
> It turns out that even though we have sysctl's that's supposed
> to control pppoe/vlan processing, they don't actually work.
> 
> This patch should make them work.

With that we can actually turn them off.

bridge: Disable PPPOE/VLAN processing by default

The PPPOE/VLAN processing code in the bridge netfilter is broken
by design.  The VLAN tag and the PPPOE session ID are an integral
part of the packet flow information, yet they're completely
ignored by the bridge netfilter.  This is potentially a security
hole as it treats all VLANs and PPPOE sessions as the same.

What's more, it's actually broken for PPPOE as the bridge netfilter
tries to trim the packets to the IP length without adjusting the
PPPOE header (and adjusting the PPPOE header isn't much better
since the PPPOE peer may require the padding to be present).

Therefore we should disable this by default.

It does mean that people relying on this feature may lose networking
depending on how their bridge netfilter rules are configured.
However, IMHO the problems this code causes are serious enough to
warrant this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 9a1cd75..cf754ac 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -58,11 +58,11 @@ static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
 static int brnf_call_ip6tables __read_mostly = 1;
 static int brnf_call_arptables __read_mostly = 1;
-static int brnf_filter_vlan_tagged __read_mostly = 1;
-static int brnf_filter_pppoe_tagged __read_mostly = 1;
+static int brnf_filter_vlan_tagged __read_mostly = 0;
+static int brnf_filter_pppoe_tagged __read_mostly = 0;
 #else
-#define brnf_filter_vlan_tagged 1
-#define brnf_filter_pppoe_tagged 1
+#define brnf_filter_vlan_tagged 0
+#define brnf_filter_pppoe_tagged 0
 #endif
 
 static inline __be16 vlan_proto(const struct sk_buff *skb)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
