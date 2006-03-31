From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 21:39:56 +1100
Message-ID: <20060331103956.GA12181@gondor.apana.org.au>
References: <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Cc: "David S. Miller" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, Andi Kleen <ak@suse.de>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <442D0186.8090705@kernelpanic.ru>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Mar 31, 2006 at 02:16:38PM +0400, Boris B. Zhmurov wrote:
> 
> And xdelta tells, that e1000.ko was modified :)

Thanks for checking again.

Anyway, it didn't take long to find another bug in the same area.
I'm afraid this driver does seem to be full of them :)

It sets last_tx_tso in between computing the number of descriptors and
calling e1000_tx_map.  This is bad because e1000_tx_map gets the wrong
value for last_tx_tso and therefore may corrupt memory for every TSO
packet when the ring is almost full.

This bug exists on UP as well as SMP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Please try this in conjunction with the previous patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="e1000-tso.patch"

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 49cd096..38aeff9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2891,7 +2891,6 @@
 	}
 
 	if (likely(tso)) {
-		tx_ring->last_tx_tso = 1;
 		tx_flags |= E1000_TX_FLAGS_TSO;
 	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
@@ -2905,6 +2904,8 @@
 	e1000_tx_queue(adapter, tx_ring, tx_flags,
 	               e1000_tx_map(adapter, tx_ring, skb, first,
 	                            max_per_txd, nr_frags, mss));
+
+	tx_ring->last_tx_tso = tso;
 
 	netdev->trans_start = jiffies;
 

--W/nzBZO5zC0uMSeA--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
