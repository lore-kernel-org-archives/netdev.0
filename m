From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] llc: fix a device refcount imbalance
Date: Sun, 05 Dec 2010 13:03:26 +0100
Message-ID: <1291550606.2806.237.camel@edumazet-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1290996593-32416-4-git-send-email-maximlevitsky@gmail.com>
	 <1291504514.1874.92.camel@maxim-laptop>
	 <1291537161.2806.109.camel@edumazet-laptop>
	 <1291548233.2806.212.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux1394-devel <linux1394-devel@lists.sourceforge.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Octavian Purdila <opurdila@ixiacom.com>, stable@kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34155 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462Ab0LEMDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 07:03:34 -0500
Received: by wwa36 with SMTP id 36so11796782wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 04:03:33 -0800 (PST)
In-Reply-To: <1291548233.2806.212.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 05 d=C3=A9cembre 2010 =C3=A0 12:23 +0100, Eric Dumazet a =C3=
=A9crit :
> Le dimanche 05 d=C3=A9cembre 2010 =C3=A0 09:19 +0100, Eric Dumazet a =
=C3=A9crit :
>=20
> > Hmm..
> >=20
> > If somebody can explain why RTNL is held in arp_ioctl() (and theref=
ore
> > in arp_req_delete()), we might first remove RTNL use in arp_ioctl()=
 so
> > that your patch can be applied.
> >=20
> > Right now it is not good, because RTNL wont be necessarly held when=
 you
> > are going to call arp_invalidate() ?
>=20
> While doing this analysis, I found a refcount bug in llc, I'll send a
> patch for net-2.6

Oh well, of course I must first fix the bug in net-2.6, and wait David
pull the fix in net-next-2.6 before sending this rcu conversion.

Note: this patch should be sent to stable teams (2.6.34 and up)

[PATCH net-2.6] llc: fix a device refcount imbalance

commit abf9d537fea225 (llc: add support for SO_BINDTODEVICE) added one
refcount imbalance in llc_ui_bind(), because dev_getbyhwaddr() doesnt
take a reference on device, while dev_get_by_index() does.

=46ix this using RCU locking. And since an RCU conversion will be done =
for
2.6.38 for dev_getbyhwaddr(), put the rcu_read_lock/unlock exactly at
their final place.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: stable@kernel.org
Cc: Octavian Purdila <opurdila@ixiacom.com>
---
 net/llc/af_llc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 5826129..e35dbe5 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -317,8 +317,9 @@ static int llc_ui_bind(struct socket *sock, struct =
sockaddr *uaddr, int addrlen)
 		goto out;
 	rc =3D -ENODEV;
 	rtnl_lock();
+	rcu_read_lock();
 	if (sk->sk_bound_dev_if) {
-		llc->dev =3D dev_get_by_index(&init_net, sk->sk_bound_dev_if);
+		llc->dev =3D dev_get_by_index_rcu(&init_net, sk->sk_bound_dev_if);
 		if (llc->dev) {
 			if (!addr->sllc_arphrd)
 				addr->sllc_arphrd =3D llc->dev->type;
@@ -329,13 +330,13 @@ static int llc_ui_bind(struct socket *sock, struc=
t sockaddr *uaddr, int addrlen)
 			    !llc_mac_match(addr->sllc_mac,
 					   llc->dev->dev_addr)) {
 				rc =3D -EINVAL;
-				dev_put(llc->dev);
 				llc->dev =3D NULL;
 			}
 		}
 	} else
 		llc->dev =3D dev_getbyhwaddr(&init_net, addr->sllc_arphrd,
 					   addr->sllc_mac);
+	rcu_read_unlock();
 	rtnl_unlock();
 	if (!llc->dev)
 		goto out;


