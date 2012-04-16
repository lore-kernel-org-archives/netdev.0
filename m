From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Subject: [PATCH] davinci_mdio: Fix MDIO timeout check
Date: Mon, 16 Apr 2012 16:35:25 +0200
Message-ID: <1334586925-11348-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>, <ravonereal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Manfred Rudigier <manfred.rudigier-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Under heavy load (flood ping) it is possible for the MDIO timeout to
expire before the loop checks the GO bit again. This patch adds an
additional check whether the operation was done before actually
returning -ETIMEDOUT.

To reproduce this bug, flood ping the device, e.g., ping -f -l 1000
After some time, a "timed out waiting for user access" warning
may appear. And even worse, link may go down since the PHY reported a
timeout.

Signed-off-by: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 2757c7d..e4e4708 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -181,6 +181,11 @@ static inline int wait_for_user_access(struct davinci_mdio_data *data)
 		__davinci_mdio_reset(data);
 		return -EAGAIN;
 	}
+
+	reg = __raw_readl(&regs->user[0].access);
+	if ((reg & USERACCESS_GO) == 0)
+		return 0;
+
 	dev_err(data->dev, "timed out waiting for user access\n");
 	return -ETIMEDOUT;
 }
-- 
1.7.0.4
