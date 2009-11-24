From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Fix device name compares
Date: Tue, 24 Nov 2009 22:15:31 +0100
Message-ID: <4B0C4CF3.3050307@gmail.com>
References: <4B0A75A5.8000106@gmail.com>	<19210.40927.13011.176740@gargle.gargle.HOWL>	<4B0AA8C9.8060206@gmail.com> <20091124.122135.43806243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robert@herjulf.net, netdev@vger.kernel.org, robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47577 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933922AbZKXVPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 16:15:30 -0500
In-Reply-To: <20091124.122135.43806243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> Eric, I put the original version of your patch into net-next-2.6 and
> pushed it out already the other day.  Can you give me something relat=
ive
> with these updates in it?
>=20

Here is the relative patch against net-2.6

Thanks

[PATCH] pktgen: Fix netdevice unregister

When multi queue compatable names are used by pktgen (eg eth0@0),
we currently cannot unload a NIC driver if one of its device
is currently in use.

Allow pktgen_find_dev() to find pktgen devices by their suffix (netdev =
name)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 54c634f..6e79e96 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -427,7 +427,7 @@ static const char version[] =3D
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen=
_dev *i);
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifna=
me);
 static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
-					  const char *ifname);
+					  const char *ifname, bool exact);
 static int pktgen_device_event(struct notifier_block *, unsigned long,=
 void *);
 static void pktgen_run_all_threads(void);
 static void pktgen_reset_all_threads(void);
@@ -1818,9 +1818,10 @@ static struct pktgen_dev *__pktgen_NN_threads(co=
nst char *ifname, int remove)
 {
 	struct pktgen_thread *t;
 	struct pktgen_dev *pkt_dev =3D NULL;
+	bool exact =3D (remove =3D=3D FIND);
=20
 	list_for_each_entry(t, &pktgen_threads, th_list) {
-		pkt_dev =3D pktgen_find_dev(t, ifname);
+		pkt_dev =3D pktgen_find_dev(t, ifname, exact);
 		if (pkt_dev) {
 			if (remove) {
 				if_lock(t);
@@ -3567,13 +3568,18 @@ static int pktgen_thread_worker(void *arg)
 }
=20
 static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
-					  const char *ifname)
+					  const char *ifname, bool exact)
 {
 	struct pktgen_dev *p, *pkt_dev =3D NULL;
-	if_lock(t);
+	size_t len =3D strlen(ifname);
=20
+	if_lock(t);
 	list_for_each_entry(p, &t->if_list, list)
-		if (strncmp(p->odevname, ifname, IFNAMSIZ) =3D=3D 0) {
+		if (strncmp(p->odevname, ifname, len) =3D=3D 0) {
+			if (p->odevname[len]) {
+				if (exact || p->odevname[len] !=3D '@')
+					continue;
+			}
 			pkt_dev =3D p;
 			break;
 		}
