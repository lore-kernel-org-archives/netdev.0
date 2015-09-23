From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [Linux 4.2-rc8+...v4.3-rc2] REGRESSION: ppp: circular locking
 dependency detected: [pppd] ppp_dev_uninit() | rtnl_lock()
Date: Wed, 23 Sep 2015 12:38:03 +0200
Message-ID: <20150923103803.GC2869@alphalink.fr>
References: <CA+icZUXjsqw-C7mNHRYzha+1efjm3pT-eoU0wb5KhOtEkroF8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:54097 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752512AbbIWKiG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 06:38:06 -0400
Content-Disposition: inline
In-Reply-To: <CA+icZUXjsqw-C7mNHRYzha+1efjm3pT-eoU0wb5KhOtEkroF8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 08:06:16AM +0200, Sedat Dilek wrote:
> Without reverting the below culprit ppp patch...
>=20
> commit/?id=3D8cb775bc0a34dc596837e7da03fd22c747be618b
> ("ppp: fix device unregistration upon netns deletion")
>=20
> ...I have an unstable Internet connection via Network-Manager/ModemMa=
nager.
>=20
> First I saw this with Linux v4.2.
>=20

Thanks for reporting the issue. Can you test this patch=A0?

---
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generi=
c.c
index 0481daf..ed00446 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2755,6 +2755,7 @@ static struct ppp *ppp_create_interface(struct ne=
t *net, int unit,
 	 */
 	dev_net_set(dev, net);
=20
+	rtnl_lock();
 	mutex_lock(&pn->all_ppp_mutex);
=20
 	if (unit < 0) {
@@ -2785,7 +2786,7 @@ static struct ppp *ppp_create_interface(struct ne=
t *net, int unit,
 	ppp->file.index =3D unit;
 	sprintf(dev->name, "ppp%d", unit);
=20
-	ret =3D register_netdev(dev);
+	ret =3D register_netdevice(dev);
 	if (ret !=3D 0) {
 		unit_put(&pn->units_idr, unit);
 		netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
@@ -2797,6 +2798,7 @@ static struct ppp *ppp_create_interface(struct ne=
t *net, int unit,
=20
 	atomic_inc(&ppp_unit_count);
 	mutex_unlock(&pn->all_ppp_mutex);
+	rtnl_unlock();
=20
 	*retp =3D 0;
 	return ppp;
