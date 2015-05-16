From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [net] netlink: Reset portid after netlink_insert failure
Date: Sat, 16 May 2015 21:50:28 +0800
Message-ID: <20150516135028.GA1271@gondor.apana.org.au>
References: <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
 <20150514060230.GD6058@gondor.apana.org.au>
 <20150515.130219.331336809636676892.davem@redhat.com>
 <20150516123242.GA683@gondor.apana.org.au>
 <20150516134007.GA1152@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54725 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbbEPNuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 09:50:37 -0400
Content-Disposition: inline
In-Reply-To: <20150516134007.GA1152@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
eliminate nl_sk_hash_lock") breaks the autobind retry mechanism
because it doesn't reset portid after a failed netlink_insert.

This means that should autobind fail the first time around, then
the socket will be stuck in limbo as it can never be bound again
since it already has a non-zero portid.

Fixes: c5adde9468b0 ("netlink: eliminate nl_sk_hash_lock") 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6ffce5b..d2a4438 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1081,6 +1081,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	if (err) {
 		if (err == -EEXIST)
 			err = -EADDRINUSE;
+		nlk_sk(sk)->portid = 0;
 		sock_put(sk);
 	}
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
