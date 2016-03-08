From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: ensure file->private_data can't be overridden
Date: Tue, 8 Mar 2016 20:14:30 +0100
Message-ID: <3f04de903b6be9e1c30427830c0a1568478e0c6c.1457462784.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>,
	Alan Cox <alan@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49223 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcCHTOe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 14:14:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lock ppp_mutex and check that file->private_data is NULL before
executing any action in ppp_unattached_ioctl().
The test done by ppp_ioctl() can't be relied upon, because
file->private_data may have been updated meanwhile. In which case
ppp_unattached_ioctl() will override file->private_data and mess up
reference counters or loose pointer to previously allocated PPP unit.

In case the test fails, -ENOTTY is returned, just like if ppp_ioctl()
had rejected the ioctl in the first place.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
This seems to originate in BKL removal=A0:
f3ff8a4d80e8 ("ppp: push BKL down into the driver") moved the test on
file->private_data (in ppp_ioctl()) out of BKL protection. BKL was then
replaced by ppp_mutex in 15fd0cd9a2ad ("net: autoconvert trivial BKL
users to private mutex").

 drivers/net/ppp/ppp_generic.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generi=
c.c
index d61da9ec..d1dbcb6 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -845,6 +845,11 @@ static int ppp_unattached_ioctl(struct net *net, s=
truct ppp_file *pf,
 	int __user *p =3D (int __user *)arg;
=20
 	mutex_lock(&ppp_mutex);
+	if (file->private_data) {
+		mutex_unlock(&ppp_mutex);
+		return -ENOTTY;
+	}
+
 	switch (cmd) {
 	case PPPIOCNEWUNIT:
 		/* Create a new ppp unit */
--=20
2.7.0
