From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 20:52:45 +1100
Message-ID: <20060330095245.GA2385@gondor.apana.org.au>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408> <20060329.204409.109404254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Cc: jesse.brandeburg@intel.com, nipsy@bitgnome.net,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, bb@kernelpanic.ru, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060329.204409.109404254.davem@davemloft.net>
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


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 29, 2006 at 08:44:09PM -0800, David S. Miller wrote:
> 
> Herbert do you see any holes here?

Well I started from the beginning again, and found this.  This may be
the smoking gun that we're after :)

The xmit routine is lockless but checks last_tx_tso outside the locked
section.  So if a TSO packet wins a race against a non-TSO packet with
last_tx_tso == 0 then we'll have memory corruption.

Everyone, please try this patch and let us know whether the problem
goes away.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="e1000.patch"

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 49cd096..96b7bef 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2821,13 +2821,6 @@
 		count++;
 #endif
 
-#ifdef NETIF_F_TSO
-	/* Controller Erratum workaround */
-	if (!skb->data_len && tx_ring->last_tx_tso &&
-	    !skb_shinfo(skb)->tso_size)
-		count++;
-#endif
-
 	count += TXD_USE_COUNT(len, max_txd_pwr);
 
 	if (adapter->pcix_82544)
@@ -2846,11 +2839,6 @@
 				       max_txd_pwr);
 	if (adapter->pcix_82544)
 		count += nr_frags;
-
-
-	if (adapter->hw.tx_pkt_filtering &&
-	    (adapter->hw.mac_type == e1000_82573))
-		e1000_transfer_dhcp_info(adapter, skb);
 
 	local_irq_save(flags);
 	if (!spin_trylock(&tx_ring->tx_lock)) {
@@ -2858,6 +2846,17 @@
 		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
 	}
+
+#ifdef NETIF_F_TSO
+	/* Controller Erratum workaround */
+	if (!skb->data_len && tx_ring->last_tx_tso &&
+	    !skb_shinfo(skb)->tso_size)
+		count++;
+#endif
+
+	if (adapter->hw.tx_pkt_filtering &&
+	    (adapter->hw.mac_type == e1000_82573))
+		e1000_transfer_dhcp_info(adapter, skb);
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */

--x+6KMIRAuhnl3hBn--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
