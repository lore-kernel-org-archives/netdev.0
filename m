From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 19/28] batman-adv: Fix possible buffer
	overflow in softif neigh list output
Date: Sat,  5 Mar 2011 13:28:33 +0100
Message-ID: <1299328122-21468-20-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing-8gDhuhu/iIQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1299328122-21468-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-8gDhuhu/iIQ@public.gmane.org>

When printing the soft interface table the number of entries in the
softif neigh list are first being counted and a fitting buffer
allocated. After that the softif neigh list gets locked again and
the buffer printed - which has the following two issues:

For one thing, the softif neigh list might have grown when reacquiring
the rcu lock, which results in writing outside of the allocated buffer.
Furthermore 31 Bytes are not enough for printing an entry with a vid
of more than 2 digits.

The manual buffering is unnecessary, we can safely print to the seq
directly during the rcu_read_lock().

Signed-off-by: Linus L=C3=BCssing <linus.luessing-8gDhuhu/iIQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/soft-interface.c |   22 +---------------------
 1 files changed, 1 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
index 152beaa..c30ccd6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -171,8 +171,6 @@ int softif_neigh_seq_print_text(struct seq_file *seq,=
 void *offset)
 	struct bat_priv *bat_priv =3D netdev_priv(net_dev);
 	struct softif_neigh *softif_neigh;
 	struct hlist_node *node;
-	size_t buf_size, pos;
-	char *buff;
=20
 	if (!bat_priv->primary_if) {
 		return seq_printf(seq, "BATMAN mesh %s disabled - "
@@ -182,33 +180,15 @@ int softif_neigh_seq_print_text(struct seq_file *se=
q, void *offset)
=20
 	seq_printf(seq, "Softif neighbor list (%s)\n", net_dev->name);
=20
-	buf_size =3D 1;
-	/* Estimate length for: "   xx:xx:xx:xx:xx:xx\n" */
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(softif_neigh, node,
 				 &bat_priv->softif_neigh_list, list)
-		buf_size +=3D 30;
-	rcu_read_unlock();
-
-	buff =3D kmalloc(buf_size, GFP_ATOMIC);
-	if (!buff)
-		return -ENOMEM;
-
-	buff[0] =3D '\0';
-	pos =3D 0;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(softif_neigh, node,
-				 &bat_priv->softif_neigh_list, list) {
-		pos +=3D snprintf(buff + pos, 31, "%s %pM (vid: %d)\n",
+		seq_printf(seq, "%s %pM (vid: %d)\n",
 				bat_priv->softif_neigh =3D=3D softif_neigh
 				? "=3D>" : "  ", softif_neigh->addr,
 				softif_neigh->vid);
-	}
 	rcu_read_unlock();
=20
-	seq_printf(seq, "%s", buff);
-	kfree(buff);
 	return 0;
 }
=20
--=20
1.7.2.3
