From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 6/n] forcedeth: protect slow path with mutex
Date: Sun, 07 Oct 2007 10:40:32 -0400
Message-ID: <4708EFE0.1080900@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org> <20071007112347.GA23577@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070305060203060704000902"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754789AbXJGOkt@vger.kernel.org>
In-Reply-To: <20071007112347.GA23577@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070305060203060704000902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> commit abca163a14b28c234df9bf38034bc967ff81c3aa
> Author: Jeff Garzik <jeff@garzik.org>
> Date:   Sun Oct 7 07:22:14 2007 -0400
> 
>     [netdrvr] forcedeth: wrap slow path hw manipulation inside hw_mutex
>     
>     * This makes sure everybody who wants to start/stop the RX and TX engines
>       first acquires this mutex.
>     
>     * tx_timeout code was deleted, replaced by scheduling reset_task.
>     
>     * linkchange moved to a workqueue (always inside hw_mutex)
>     
>     * simplified irq handling a bit
>     
>     * make sure to disable workqueues before NAPI
>     
>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> 
>  drivers/net/forcedeth.c |  272 ++++++++++++++++++++++++++++++------------------
>  1 file changed, 175 insertions(+), 97 deletions(-)

You will need the attached patch to even build (oops).

Also, testing shows there is a mutex deadlock somewhere.


--------------070305060203060704000902
Content-Type: text/plain;
 name="patch.fe6"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.fe6"

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d1c1efa..91926b1 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2929,6 +2929,7 @@ static void nv_linkchange_task(struct work_struct *work)
 
 static void nv_link_irq(struct net_device *dev)
 {
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 miistat;
 
@@ -4378,6 +4379,7 @@ static int nv_ethtool_begin (struct net_device *dev)
 	struct fe_priv *np = get_nvpriv(dev);
 
 	mutex_lock(&np->hw_mutex);
+	return 0;
 }
 
 static void nv_ethtool_complete (struct net_device *dev)

--------------070305060203060704000902--
