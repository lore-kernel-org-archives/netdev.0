From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: 2.4: [NETLINK] Fix bogus mc_list deletion
Date: Tue, 29 Mar 2005 21:23:44 +1000
Message-ID: <20050329112344.GA20040@gondor.apana.org.au>
References: <424937F1.30908@variosecure.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Burress <tim@variosecure.net>
Content-Disposition: inline
In-Reply-To: <424937F1.30908@variosecure.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 29, 2005 at 08:11:45PM +0900, Tim Burress wrote:
> 
> So not only is the socket dead, it's not even a Netlink socket. 
> Apparently a socket originally allocated to Netlink was not unlinked 
> from the mc_list after it was freed, but offhand I can't see how that 
> could happen.

Thanks for tracking this issue down.

Looks like I made a nasty typo in the 2.4 backport.  When entries
are unlinked from mc_list, we link the list up with the regular
hash bucket list by using next instead of bind_next!

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Marcelo, you'll want this to be in the next rc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.21 vs edited =====
--- 1.21/net/netlink/af_netlink.c	2005-02-17 06:21:57 +11:00
+++ edited/net/netlink/af_netlink.c	2005-03-29 21:19:30 +10:00
@@ -340,9 +340,9 @@
 	}
 	if (!nlk_sk(sk)->groups)
 		goto out;
-	for (skp = &table->mc_list; *skp; skp = &((*skp)->next)) {
+	for (skp = &table->mc_list; *skp; skp = &((*skp)->bind_next)) {
 		if (*skp == sk) {
-			*skp = sk->next;
+			*skp = sk->bind_next;
 			break;
 		}
 	}

--GvXjxJ+pjyke8COw--
