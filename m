From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bonding: remove dev_base_lock use
Date: Fri, 29 Oct 2010 13:52:46 +0200
Message-ID: <1288353166.2560.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59093 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991Ab0J2Lwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 07:52:50 -0400
Received: by wyf28 with SMTP id 28so3051316wyf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 04:52:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_info_seq_start() uses a read_lock(&dev_base_lock) to make sure
device doesn=E2=80=99t disappear. Same goal can be achieved using RCU.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bonding/bond_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index bdb68a6..5188448 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3209,7 +3209,7 @@ out:
 #ifdef CONFIG_PROC_FS
=20
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(&dev_base_lock)
+	__acquires(RCU)
 	__acquires(&bond->lock)
 {
 	struct bonding *bond =3D seq->private;
@@ -3218,7 +3218,7 @@ static void *bond_info_seq_start(struct seq_file =
*seq, loff_t *pos)
 	int i;
=20
 	/* make sure the bond won't be taken away */
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	read_lock(&bond->lock);
=20
 	if (*pos =3D=3D 0)
@@ -3248,12 +3248,12 @@ static void *bond_info_seq_next(struct seq_file=
 *seq, void *v, loff_t *pos)
=20
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
 	__releases(&bond->lock)
-	__releases(&dev_base_lock)
+	__releases(RCU)
 {
 	struct bonding *bond =3D seq->private;
=20
 	read_unlock(&bond->lock);
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
=20
 static void bond_info_show_master(struct seq_file *seq)


