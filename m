From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 14:06:32 +0100
Message-ID: <1324645592.2223.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
	 <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
	 <1324616007.2674.8.camel@edumazet-laptop>
	 <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
	 <1324617390.2674.13.camel@edumazet-laptop>
	 <1324618555.10854.4.camel@edumazet-laptop>
	 <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64106 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab1LWNGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 08:06:35 -0500
Received: by wgbdr13 with SMTP id dr13so17439360wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 05:06:34 -0800 (PST)
In-Reply-To: <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 00:56 -0500, Xi Wang a =C3=A9c=
rit :
> On Dec 23, 2011, at 12:35 AM, Eric Dumazet wrote:
> > By the way, the theorical limit on number of flows on 64bit platfor=
m is
> > 2^32  (rxhash being an u32)
> >=20
> > Not sure spending 32GB per table would be wise for typical machines=
 :)
>=20
> True, a large rps_flow_cnt is not that useful. ;-)
>=20
> Anyway, my point is that if the patch looks confusing to you, then
> it is probably not good.  I am happy to see a more elegant fix.
>=20

I'll submit following patch for net-next, once your patch is in this
tree.

- Full u32 range on 64bit arches (2^32 flows max)
- Use of kstrtoul() instead of simple_strtoul()

 net/core/net-sysfs.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 385aefe..63bd152 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -618,7 +618,7 @@ static ssize_t show_rps_dev_flow_table_cnt(struct n=
etdev_rx_queue *queue,
 					   char *buf)
 {
 	struct rps_dev_flow_table *flow_table;
-	unsigned int val =3D 0;
+	unsigned long val =3D 0;
=20
 	rcu_read_lock();
 	flow_table =3D rcu_dereference(queue->rps_flow_table);
@@ -626,7 +626,7 @@ static ssize_t show_rps_dev_flow_table_cnt(struct n=
etdev_rx_queue *queue,
 		val =3D flow_table->mask + 1;
 	rcu_read_unlock();
=20
-	return sprintf(buf, "%u\n", val);
+	return sprintf(buf, "%lu\n", val);
 }
=20
 static void rps_dev_flow_table_release_work(struct work_struct *work)
@@ -650,24 +650,23 @@ static ssize_t store_rps_dev_flow_table_cnt(struc=
t netdev_rx_queue *queue,
 				     struct rx_queue_attribute *attr,
 				     const char *buf, size_t len)
 {
-	unsigned int count;
-	char *endp;
+	unsigned long i, count;
 	struct rps_dev_flow_table *table, *old_table;
 	static DEFINE_SPINLOCK(rps_dev_flow_lock);
+	int rc;
=20
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
=20
-	count =3D simple_strtoul(buf, &endp, 0);
-	if (endp =3D=3D buf)
-		return -EINVAL;
+	rc =3D kstrtoul(buf, 0, &count);
+	if (rc < 0)
+		return rc;
=20
 	if (count) {
-		int i;
-
-		if (count > INT_MAX)
-			return -EINVAL;
 		count =3D roundup_pow_of_two(count);
+		if (!count ||
+		    count !=3D (unsigned long)(u32)count)
+			return -EINVAL;
 		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
 				/ sizeof(struct rps_dev_flow)) {
 			/* Enforce a limit to prevent overflow */
