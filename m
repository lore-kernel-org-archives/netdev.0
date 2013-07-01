From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next] ethtool: make .get_dump_data() harder to misuse by drivers
Date: Mon,  1 Jul 2013 17:23:30 +0200
Message-ID: <1372692210-31131-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab3GAPXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 11:23:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the patch "bnx2x: remove zeroing of dump data buffer" showed,
it is too easy implement .get_dump_data=C2=A0incorrectly in a driver.

Let's make sure drivers cannot get confused by userspace requesting
a too big dump.

Also WARN if the driver sets dump->len to something weird and make
sure the length reported to userspace is the actual length of data
copied to userspace.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 net/core/ethtool.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index ce91766..3b71cdb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1319,10 +1319,19 @@ static int ethtool_get_dump_data(struct net_dev=
ice *dev,
 	if (ret)
 		return ret;
=20
-	len =3D (tmp.len > dump.len) ? dump.len : tmp.len;
+	len =3D min(tmp.len, dump.len);
 	if (!len)
 		return -EFAULT;
=20
+	/* Don't ever let the driver think there's more space available
+	 * than it requested with .get_dump_flag().
+	 */
+	dump.len =3D len;
+
+	/* Always allocate enough space to hold the whole thing so that the
+	 * driver does not need to check the length and bother with partial
+	 * dumping.
+	 */
 	data =3D vzalloc(tmp.len);
 	if (!data)
 		return -ENOMEM;
@@ -1330,6 +1339,16 @@ static int ethtool_get_dump_data(struct net_devi=
ce *dev,
 	if (ret)
 		goto out;
=20
+	/* There are two sane possibilities:
+	 * 1. The driver's .get_dump_data() does not touch dump.len.
+	 * 2. Or it may set dump.len to how much it really writes, which
+	 *    should be tmp.len (or len if it can do a partial dump).
+	 * In any case respond to userspace with the actual length of data
+	 * it's receiving.
+	 */
+	WARN_ON(dump.len !=3D len && dump.len !=3D tmp.len);
+	dump.len =3D len;
+
 	if (copy_to_user(useraddr, &dump, sizeof(dump))) {
 		ret =3D -EFAULT;
 		goto out;
--=20
1.8.1.4
