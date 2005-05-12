From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
	net/netlink/af_netlink.c (122)
Date: Thu, 12 May 2005 11:58:07 +0200
Message-ID: <1115891887.30106.89.camel@tsc-6.cph.tpack.net>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp>
	 <20050510220751.GA459@gondor.apana.org.au>
	 <20050511005836.GA1674@gondor.apana.org.au> <4282846F.6070403@tpack.net>
	 <20050511231751.GA21781@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PVeijJmpk17Glw/H2tA2"
Cc: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050511231751.GA21781@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-PVeijJmpk17Glw/H2tA2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-05-12 at 01:17, Herbert Xu wrote:
> BTW, we could also move the skb_orphan to the skb_get path since the
> cloned packets don't need the orphan call.

Yes, I like this better.  Good idea.

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--=-PVeijJmpk17Glw/H2tA2
Content-Description: 
Content-Disposition: inline; filename=netlink-3.patch
Content-Type: text/x-patch; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
--- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
+++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 11:51:57.427312857 +0200
@@ -735,11 +735,13 @@
 
 	sock_hold(sk);
 	if (p->skb2 == NULL) {
-		if (atomic_read(&p->skb->users) != 1) {
+		if (skb_shared(p->skb)) {
 			p->skb2 = skb_clone(p->skb, p->allocation);
 		} else {
-			p->skb2 = p->skb;
-			atomic_inc(&p->skb->users);
+			p->skb2 = skb_get(p->skb);
+			/* skb ownership may have been set when
+			   delivered to a previous socket. */
+			skb_orphan(p->skb2);
 		}
 	}
 	if (p->skb2 == NULL) {

--=-PVeijJmpk17Glw/H2tA2--
