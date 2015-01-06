From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/6] batman-adv: fix delayed foreign originator recognition
Date: Tue,  6 Jan 2015 12:10:01 +0100
Message-ID: <1420542605-28865-3-git-send-email-antonio@meshcoding.com>
References: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:33270 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348AbbAFLKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:10:47 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

Currently it can happen that the reception of an OGM from a new
originator is not being accepted. More precisely it can happen that
an originator struct gets allocated and initialized
(batadv_orig_node_new()), even the TQ gets calculated and set correctly
(batadv_iv_ogm_calc_tq()) but still the periodic orig_node purging
thread will decide to delete it if it has a chance to jump between
these two function calls.

This is because batadv_orig_node_new() initializes the last_seen value
to zero and its caller (batadv_iv_ogm_orig_get()) makes it visible to
other threads by adding it to the hash table already.
batadv_iv_ogm_calc_tq() will set the last_seen variable to the correct,
current time a few lines later but if the purging thread jumps in betwe=
en
that it will think that the orig_node timed out and will wrongly
schedule it for deletion already.

If the purging interval is the same as the originator interval (which i=
s
the default:=E2=80=AF1 second), then this game can continue for several=
 rounds
until the random OGM jitter added enough difference between these
two (in tests, two to about four rounds seemed common).

=46ixing this by initializing the last_seen variable of an orig_node
to the current time before adding it to the hash table.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 6a48451..648bdba 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -678,6 +678,7 @@ struct batadv_orig_node *batadv_orig_node_new(struc=
t batadv_priv *bat_priv,
 	atomic_set(&orig_node->last_ttvn, 0);
 	orig_node->tt_buff =3D NULL;
 	orig_node->tt_buff_len =3D 0;
+	orig_node->last_seen =3D jiffies;
 	reset_time =3D jiffies - 1 - msecs_to_jiffies(BATADV_RESET_PROTECTION=
_MS);
 	orig_node->bcast_seqno_reset =3D reset_time;
 #ifdef CONFIG_BATMAN_ADV_MCAST
--=20
2.2.1
