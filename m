From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Thu, 26 Aug 2010 11:44:35 +0200
Message-ID: <1282815875.2476.294.camel@edumazet-laptop>
References: <bug-16529-10286@https.bugzilla.kernel.org/>
	 <20100825153107.2f547f0e.akpm@linux-foundation.org>
	 <4C759F8C.9050301@goop.org>
	 <1282806640.3469.26.camel@localhost.localdomain>
	 <1282809788.2476.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	"heil@terminal-consulting.de" <heil@terminal-consulting.de>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62974 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab0HZJok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 05:44:40 -0400
Received: by wyb35 with SMTP id 35so1967821wyb.19
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 02:44:39 -0700 (PDT)
In-Reply-To: <1282809788.2476.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 10:03 +0200, Eric Dumazet a =C3=A9cri=
t :
> Here is the patch, could you test it please ?
>=20
> Thanks !
>=20
> [PATCH] l2tp: test for malicious frames in l2tp_eth_dev_recv()
>=20
> close https://bugzilla.kernel.org/show_bug.cgi?id=3D16529
>=20
> Before calling dev_forward_skb(), we should make sure skb contains at
> least an ethernet header, even if length included in upper layer said
> so.
>=20
> Reported-by: Thomas Heil <heil@terminal-consulting.de>
> Reported-by: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/l2tp/l2tp_core.c |    2 +-
>  net/l2tp/l2tp_eth.c  |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 58c6c4c..0687c5c 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -132,7 +132,7 @@ static void l2tp_eth_dev_recv(struct l2tp_session=
 *session, struct sk_buff *skb,
>  		printk("\n");
>  	}
> =20
> -	if (data_len < ETH_HLEN)
> +	if (skb->len < ETH_HLEN)
>  		goto error;
> =20
>  	secpath_reset(skb);
>=20

Hmm, reading this code again, I suspect a much better fix is to make
sure 'ethernet header' is in skb head, not in a fragment.

Maybe frame is valid but only L2TP encapsulation in skb->header at this
point.

Thanks !

[PATCH] l2tp: test for ethernet header in l2tp_eth_dev_recv()

close https://bugzilla.kernel.org/show_bug.cgi?id=3D16529

Before calling dev_forward_skb(), we should make sure skb head contains
at least an ethernet header, even if length included in upper layer sai=
d
so. Use pskb_may_pull() to make sure this ethernet header is present in
skb head.

Reported-by: Thomas Heil <heil@terminal-consulting.de>
Reported-by: Ian Campbell <Ian.Campbell@eu.citrix.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 58c6c4c..1ae6976 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -132,7 +132,7 @@ static void l2tp_eth_dev_recv(struct l2tp_session *=
session, struct sk_buff *skb,
 		printk("\n");
 	}
=20
-	if (data_len < ETH_HLEN)
+	if (!pskb_may_pull(skb, sizeof(ETH_HLEN)))
 		goto error;
=20
 	secpath_reset(skb);


