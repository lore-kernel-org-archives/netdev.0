From: David Howells <dhowells@redhat.com>
Subject: [PATCH] eHEA: Don't do memory allocation under lock if not necessary
Date: Wed, 11 Mar 2009 08:44:57 +0000
Message-ID: <20090311084456.9190.52805.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: raisch@de.ibm.com, themann@de.ibm.com, tklein@de.ibm.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

In ehea_probe_adapter() the initial memory allocation and initialisation does
not need to be done with the ehea_fw_handles.lock semaphore held.  Doing so
extends the amount of time the lock is held unnecessarily.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/net/ehea/ehea_main.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)


diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index dfe9226..34480ae 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3370,18 +3370,19 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
-	mutex_lock(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
-		ret = -ENOMEM;
 		dev_err(&dev->dev, "no mem for ehea_adapter\n");
-		goto out;
+		return -ENOMEM;
 	}
 
-	list_add(&adapter->list, &adapter_list);
-
 	adapter->ofdev = dev;
+	adapter->pd = EHEA_PD_ID;
+
+	mutex_lock(&ehea_fw_handles.lock);
+
+	list_add(&adapter->list, &adapter_list);
 
 	adapter_handle = of_get_property(dev->node, "ibm,hea-handle",
 					 NULL);
@@ -3395,8 +3396,6 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		goto out_free_ad;
 	}
 
-	adapter->pd = EHEA_PD_ID;
-
 	dev->dev.driver_data = adapter;
