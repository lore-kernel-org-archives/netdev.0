From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Thu, 02 Mar 2006 13:40:18 -0600
Message-ID: <44074A22.8060705@us.ibm.com>
References: <20060131041055.5623C68A46@ozlabs.org>
	<20060131042903.GF28896@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: anton@samba.org, linuxppc64-dev@ozlabs.org, michael@ellerman.id.au,
	jgarzik@pobox.com, netdev@vger.kernel.org
In-Reply-To: <20060131042903.GF28896@krispykreme>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Michael Ellerman <michael@ellerman.id.au>

After a kexec the veth driver will fail when trying to register with the
Hypervisor because the previous kernel has not unregistered.

So if the registration fails, we unregister and then try again.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
Acked-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@us.ibm.com>
---

  drivers/net/ibmveth.c |   32 ++++++++++++++++++++++++++------
  1 files changed, 26 insertions(+), 6 deletions(-)

Looks good to me, and has been around for a couple of months.

Index: kexec/drivers/net/ibmveth.c
===================================================================
--- kexec.orig/drivers/net/ibmveth.c
+++ kexec/drivers/net/ibmveth.c
@@ -436,6 +436,31 @@ static void ibmveth_cleanup(struct ibmve
  		ibmveth_free_buffer_pool(adapter, &adapter->rx_buff_pool[i]);
  }

+static int ibmveth_register_logical_lan(struct ibmveth_adapter *adapter,
+		union ibmveth_buf_desc rxq_desc, u64 mac_address)
+{
+	int rc, try_again = 1;
+
+	/* After a kexec the adapter will still be open, so our attempt to
+	 * open it will fail. So if we get a failure we free the adapter and
+	 * try again, but only once. */
+retry:
+	rc = h_register_logical_lan(adapter->vdev->unit_address,
+			adapter->buffer_list_dma, rxq_desc.desc,
+			adapter->filter_list_dma, mac_address);
+
+	if (rc != H_Success && try_again) {
+		do {
+			rc = h_free_logical_lan(adapter->vdev->unit_address);
+		} while (H_isLongBusy(rc) || (rc == H_Busy));
+
+		try_again = 0;
+		goto retry;
+	}
+
+	return rc;
+}
+
  static int ibmveth_open(struct net_device *netdev)
  {
  	struct ibmveth_adapter *adapter = netdev->priv;
@@ -504,12 +529,7 @@ static int ibmveth_open(struct net_devic
  	ibmveth_debug_printk("filter list @ 0x%p\n", adapter->filter_list_addr);
  	ibmveth_debug_printk("receive q   @ 0x%p\n", 
adapter->rx_queue.queue_addr);

-
-	lpar_rc = h_register_logical_lan(adapter->vdev->unit_address,
-					 adapter->buffer_list_dma,
-					 rxq_desc.desc,
-					 adapter->filter_list_dma,
-					 mac_address);
+	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc, mac_address);

  	if(lpar_rc != H_Success) {
  		ibmveth_error_printk("h_register_logical_lan failed with %ld\n", 
lpar_rc);
