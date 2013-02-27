From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2] net/sctp: Validate parameter size for SCTP_GET_ASSOC_STATS
Date: Wed, 27 Feb 2013 12:57:31 -0800
Message-ID: <1361998651-19354-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:59789 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab3B0U5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:57:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building sctp may fail with:

In function =E2=80=98copy_from_user=E2=80=99,
    inlined from =E2=80=98sctp_getsockopt_assoc_stats=E2=80=99 at
    net/sctp/socket.c:5656:20:
arch/x86/include/asm/uaccess_32.h:211:26: error: call to
    =E2=80=98copy_from_user_overflow=E2=80=99 declared with attribute e=
rror: copy_from_user()
    buffer size is not provably correct

if built with W=3D1 due to a missing parameter size validation
before the call to copy_from_user.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2: Fix by moving the existing parameter size validation up
    in the function instead of adding an additional one.

 net/sctp/socket.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index cedd9bf..9ef5c73 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5653,6 +5653,9 @@ static int sctp_getsockopt_assoc_stats(struct soc=
k *sk, int len,
 	if (len < sizeof(sctp_assoc_t))
 		return -EINVAL;
=20
+	/* Allow the struct to grow and fill in as much as possible */
+	len =3D min_t(size_t, len, sizeof(sas));
+
 	if (copy_from_user(&sas, optval, len))
 		return -EFAULT;
=20
@@ -5686,9 +5689,6 @@ static int sctp_getsockopt_assoc_stats(struct soc=
k *sk, int len,
 	/* Mark beginning of a new observation period */
 	asoc->stats.max_obs_rto =3D asoc->rto_min;
=20
-	/* Allow the struct to grow and fill in as much as possible */
-	len =3D min_t(size_t, len, sizeof(sas));
-
 	if (put_user(len, optlen))
 		return -EFAULT;
=20
--=20
1.7.9.7
