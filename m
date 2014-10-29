From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Tue, 28 Oct 2014 20:30:35 -0700
Message-ID: <1414553435.631.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34853 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbaJ2Dag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 23:30:36 -0400
Received: by mail-pd0-f170.google.com with SMTP id z10so2085950pdj.29
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 20:30:36 -0700 (PDT)
In-Reply-To: <CAADnVQJ0XD6YmUi_MBpoEgkScxp2ictQepY2YqtvfbXzF=voZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 18:17 -0700, Alexei Starovoitov wrote:

> Interesting! Are you trying to optimize some of such NIC drivers? ;)

??

> but all of 10G+ and virtio won't apply, right?


Which 10G+ driver could not use this ?

mlx4 patch would be :

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c8e75dab80553c876b195361456fb49587231055..c562c1468944f9ad4319e5faaf19bf9e66d15eaf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -878,8 +878,8 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
-	if (priv->port_up)
-		napi_schedule(&cq->napi);
+	if (likely(priv->port_up))
+		napi_schedule_irqoff(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 34c137878545fc672dad1a3d86e11c034c0ac368..5c4062921cdf46f1a7021a39705275c33ca4de77 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -479,8 +479,8 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
-	if (priv->port_up)
-		napi_schedule(&cq->napi);
+	if (likely(priv->port_up))
+		napi_schedule_irqoff(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
