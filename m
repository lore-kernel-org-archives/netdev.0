From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 09:54:23 +1100
Message-ID: <20050124225423.GA15405@gondor.apana.org.au>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Cc: David Coulson <david@davidcoulson.net>,
        "David S. Miller" <davem@davemloft.net>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050124151510.GV23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 24, 2005 at 04:15:10PM +0100, Thomas Graf wrote:
> 
> After inspecting your iptables rule set I think it is a general UDP DNAT
> problem under some circumstances. Some defragmentation weirdness in
> prerouting might be invovled. It would definitely help to have a dump
> of a complete ip fragments sequence causing this bug but I can't tell
> what exactly is the cause just now so yes it might be a good idea to
> limit the dump to the above subnet and hope the dodgy traffic comes
> from the same subnet again.

OK, I think I've found the problem.  It's a totally innocuous bug
in ip_fragment/ip6_fragment.  When we're in the fast path and use
the pre-existing frag_list skb's, we forgot to clear ip_summed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

However, the problem that Patrick identified is very serious and
we should fix that as a matter of urgency.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ip_output.c 1.73 vs edited =====
--- 1.73/net/ipv4/ip_output.c	2004-12-28 12:56:34 +11:00
+++ edited/net/ipv4/ip_output.c	2005-01-25 09:32:49 +11:00
@@ -504,6 +504,7 @@
 			/* Prepare header of the next frame,
 			 * before previous one went down. */
 			if (frag) {
+				frag->ip_summed = CHECKSUM_NONE;
 				frag->h.raw = frag->data;
 				frag->nh.raw = __skb_push(frag, hlen);
 				memcpy(frag->nh.raw, iph, hlen);
===== net/ipv6/ip6_output.c 1.81 vs edited =====
--- 1.81/net/ipv6/ip6_output.c	2005-01-15 15:41:34 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-01-25 09:48:25 +11:00
@@ -592,6 +592,7 @@
 			/* Prepare header of the next frame,
 			 * before previous one went down. */
 			if (frag) {
+				frag->ip_summed = CHECKSUM_NONE;
 				frag->h.raw = frag->data;
 				fh = (struct frag_hdr*)__skb_push(frag, sizeof(struct frag_hdr));
 				frag->nh.raw = __skb_push(frag, hlen);

--RnlQjJ0d97Da+TV1--
