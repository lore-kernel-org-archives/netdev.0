From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Do not compile options in br_parse_ip_options
Date: Sat, 4 Oct 2014 22:18:02 +0800
Message-ID: <20141004141802.GA10878@gondor.apana.org.au>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
 <20141004135508.GA10705@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141004135508.GA10705@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 04, 2014 at 09:55:08PM +0800, Herbert Xu wrote:
>
> I'll try to create a patch that essentially reverts the patch
> that led us here.

Here is a patch that's only compile-tested:

bridge: Do not compile options in br_parse_ip_options

Commit 462fb2af9788a82a534f8184abfde31574e1cfa0

	bridge : Sanitize skb before it enters the IP stack

broke when IP options are actually used because it mangles the
skb as if it entered the IP stack which is wrong because the
bridge is supposed to operate below the IP stack.

Since nobody has actually requested for parsing of IP options
this patch fixes it by simply reverting to the previous approach
of ignoring all IP options, i.e., zeroing the IPCB.

If and when somebody who uses IP options and actually needs them
to be parsed by the bridge complains then we can revisit this.

Reported-by: David Newall <davidn@davidnewall.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a615264..c0fdb4d 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -260,7 +260,6 @@ static inline void nf_bridge_update_protocol(struct sk_buff *skb)
 
 static int br_parse_ip_options(struct sk_buff *skb)
 {
-	struct ip_options *opt;
 	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
 	u32 len;
@@ -269,7 +268,6 @@ static int br_parse_ip_options(struct sk_buff *skb)
 		goto inhdr_error;
 
 	iph = ip_hdr(skb);
-	opt = &(IPCB(skb)->opt);
 
 	/* Basic sanity checks */
 	if (iph->ihl < 5 || iph->version != 4)
@@ -295,23 +293,11 @@ static int br_parse_ip_options(struct sk_buff *skb)
 	}
 
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-	if (iph->ihl == 5)
-		return 0;
-
-	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
-	if (ip_options_compile(dev_net(dev), opt, skb))
-		goto inhdr_error;
-
-	/* Check correct handling of SRR option */
-	if (unlikely(opt->srr)) {
-		struct in_device *in_dev = __in_dev_get_rcu(dev);
-		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
-			goto drop;
-
-		if (ip_options_rcv_srr(skb))
-			goto drop;
-	}
-
+	/* We should really parse IP options here but until
+	 * somebody who actually uses IP options complains to
+	 * us we'll just silently ignore the options because
+	 * we're lazy!
+	 */
 	return 0;
 
 inhdr_error:

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
