From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [Openswan dev] [IPSEC] COW skb header in UDP decap
Date: Sat, 9 Apr 2005 11:01:24 +1000
Message-ID: <20050409010124.GA22059@gondor.apana.org.au>
References: <21730.1112984853@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@openswan.org>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <21730.1112984853@marajade.sandelman.ottawa.on.ca>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Michael:

On Fri, Apr 08, 2005 at 02:27:33PM -0400, Michael Richardson wrote:
> 
> Herbert, I think that there is a bug/mis-feature in net/ipv4/udp.c.
> The skb is modified without having checked if it is in fact shared/cloned.
> The result is that tcpdump sees the wrong thing. This can be confusing:

Indeed, it's not just confusing but wrong :) This violates the
laws of skb's.
 
> I think that this fixes the problem. I must admit to being a bit

Thanks for the patch.  I think we can use something a little lighter
than skb_unshare.  The following patch just makes the header part of
the skb writeable.  This is needed since we modify the IP headers
just a few lines below.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

> ignorant as to which PRIO might be appropriate here. Also is there a
> good FAQ on the difference between cloned SKBs vs shared SKBs? 

There might be, but the source is the ultimate documentation :)

Shared skb's are the same object held by multiple users.  No one
must write to either the metadata or the data without the consent
of everyone involved.

Clone skb's only share the data.  The metadata can be written freely.

To get a completely standalone skb from a cloned skb, you can call
skb_copy.  However, it is pretty heavy weight and also copies the
metadata which isn't necessary for skb's which are cloned but not
shared.

That's why we have pskb_expand_head (and its wrapper skb_cow) which
can be used when you only need to modify the bits between skb->head
and skb->tail (this is what we call the header of the skb, don't
confuse it with the protocol header of a packet).

As it doesn't copy the metadata, you can't call it on shared skb's.
However, you can always clone it and then do pskb_expand_head.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/udp.c 1.78 vs edited =====
--- 1.78/net/ipv4/udp.c	2005-03-27 09:04:35 +10:00
+++ edited/net/ipv4/udp.c	2005-04-09 10:39:05 +10:00
@@ -955,6 +955,8 @@
 	 * header and optional ESP marker bytes) and then modify the
 	 * protocol to ESP, and then call into the transform receiver.
 	 */
+	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		return 0;
 
 	/* Now we can update and verify the packet length... */
 	iph = skb->nh.iph;

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Dev mailing list
Dev@openswan.org
http://lists.openswan.org/mailman/listinfo/dev

--rwEMma7ioTxnRzrJ--
