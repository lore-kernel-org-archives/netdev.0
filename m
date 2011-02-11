From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 1/4] batman-adv: Use successive sequence
	numbers for fragments
Date: Sat, 12 Feb 2011 00:21:40 +0100
Message-ID: <1297466503-13246-2-git-send-email-sven@narfation.org>
References: <1297466503-13246-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1297466503-13246-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

The two fragments of an unicast packet must have successive sequence numb=
ers to
allow the receiver side to detect matching fragments and merge them again=
. The
current implementation doesn't provide that property because a sequence o=
f two
atomic_inc_return may be interleaved with another sequence which also cha=
nges
the variable.

The access to the fragment sequence number pool has either to be protecte=
d by
correct locking or it has to reserve two sequence numbers in a single fet=
ch.
The latter one can easily be done by increasing the value of the last use=
d
sequence number by 2 in a single step. The generated window of two curren=
tly
unused sequence numbers can now be scattered across the two fragments.

Reported-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/unicast.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index cbf022c..9b2a222 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -226,6 +226,7 @@ int frag_send_skb(struct sk_buff *skb, struct bat_pri=
v *bat_priv,
 	int ucf_hdr_len =3D sizeof(struct unicast_frag_packet);
 	int data_len =3D skb->len - uc_hdr_len;
 	int large_tail =3D 0;
+	uint16_t seqno;
=20
 	if (!bat_priv->primary_if)
 		goto dropped;
@@ -261,10 +262,9 @@ int frag_send_skb(struct sk_buff *skb, struct bat_pr=
iv *bat_priv,
 	frag1->flags =3D UNI_FRAG_HEAD | large_tail;
 	frag2->flags =3D large_tail;
=20
-	frag1->seqno =3D htons((uint16_t)atomic_inc_return(
-			     &batman_if->frag_seqno));
-	frag2->seqno =3D htons((uint16_t)atomic_inc_return(
-			     &batman_if->frag_seqno));
+	seqno =3D atomic_add_return(2, &batman_if->frag_seqno);
+	frag1->seqno =3D htons(seqno - 1);
+	frag2->seqno =3D htons(seqno);
=20
 	send_skb_packet(skb, batman_if, dstaddr);
 	send_skb_packet(frag_skb, batman_if, dstaddr);
--=20
1.7.2.3
