From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/mlx4_en: initialize cmd.context_lock spinlock
 earlier
Date: Mon, 13 Jun 2016 07:50:25 -0700
Message-ID: <1465829425.7945.160.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35908 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbcFMOuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 10:50:37 -0400
Received: by mail-pa0-f66.google.com with SMTP id fg1so10651405pad.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 07:50:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Maciej =C5=BBenczykowski reported lockdep warning a spinlock
was not registered before being held in mlx4_cmd_wake_completions()

cmd.context_lock initialization is not at the right place.

1) mlx4_cmd_use_events() can be called multiple times.
   Calling spin_lock_init() on a live spinlock can lead
   to hangs.

2) mlx4_cmd_wake_completions() can be called while lock
   has not been initialized.
   Lockdep complains, and current logic is not race prone.

It seems better to move the initialization earlier in
mlx4_load_one()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c  |    1 -
 drivers/net/ethernet/mellanox/mlx4/main.c |    1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/eth=
ernet/mellanox/mlx4/cmd.c
index e94ca1c3fc7c..f04a423ff79d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2597,7 +2597,6 @@ int mlx4_cmd_use_events(struct mlx4_dev *dev)
 	priv->cmd.free_head =3D 0;
=20
 	sema_init(&priv->cmd.event_sem, priv->cmd.max_cmds);
-	spin_lock_init(&priv->cmd.context_lock);
=20
 	for (priv->cmd.token_mask =3D 1;
 	     priv->cmd.token_mask < priv->cmd.max_cmds;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/et=
hernet/mellanox/mlx4/main.c
index 12c77a70abdb..372ebfa880f5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3222,6 +3222,7 @@ static int mlx4_load_one(struct pci_dev *pdev, in=
t pci_dev_data,
=20
 	INIT_LIST_HEAD(&priv->pgdir_list);
 	mutex_init(&priv->pgdir_mutex);
+	spin_lock_init(&priv->cmd.context_lock);
=20
 	INIT_LIST_HEAD(&priv->bf_list);
 	mutex_init(&priv->bf_mutex);
