From: Santiago Leon <santil@us.ibm.com>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Fri, 28 Apr 2006 14:51:41 -0500
Message-ID: <4452724D.7050800@us.ibm.com>
References: <20060131041055.5623C68A46@ozlabs.org>	 <20060131042903.GF28896@krispykreme>  <44074A22.8060705@us.ibm.com>	 <1143421876.7795.2.camel@localhost.localdomain> <1146047837.10735.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020700020008030409020008"
Cc: jgarzik@pobox.com, anton@samba.org, linuxppc64-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:28822 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751449AbWD1Tx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 15:53:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3SJrtvo001777
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:53:55 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3SJrtOk210370
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:53:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3SJrsW4013948
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:53:55 -0400
To: michael@ellerman.id.au
In-Reply-To: <1146047837.10735.29.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020700020008030409020008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Michael Ellerman wrote:
>>Looks like this hit the floor. Any chance of getting it into to 2.6.17
>>Jeff? AFAICT it should still apply cleanly.
>  
> /me knocks politely

Actually, it doesn't apply cleanly anymore.  Here's a patch that does.
-- 
Santiago A. Leon
Power Linux Development
IBM Linux Technology Center

--------------020700020008030409020008
Content-Type: text/plain;
 name="ibmveth_harden_init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ibmveth_harden_init.patch"

From: Michael Ellerman <michael@ellerman.id.au>

After a kexec the ibmveth driver will fail when trying to register with the Hypervisor because the previous kernel has not unregistered.

So if the registration fails, we unregister and then try again.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
Acked-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@us.ibm.com>

 ibmveth.c |   31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

Index: kexec/drivers/net/ibmveth.c
===================================================================
--- a/drivers/net/ibmveth.c	2006-04-28 13:16:22.244724056 -0500
+++ b/drivers/net/ibmveth.c	2006-04-28 13:29:49.429736784 -0500
@@ -436,6 +436,31 @@ static void ibmveth_cleanup(struct ibmve
 		ibmveth_free_buffer_pool(adapter, &adapter->rx_buff_pool[i]);
 }
 
+static int ibmveth_register_logical_lan(struct ibmveth_adapter *adapter,
+        union ibmveth_buf_desc rxq_desc, u64 mac_address)
+{
+	int rc, try_again = 1;
+
+	/* After a kexec the adapter will still be open, so our attempt to
+	* open it will fail. So if we get a failure we free the adapter and
+	* try again, but only once. */
+retry:
+	rc = h_register_logical_lan(adapter->vdev->unit_address,
+				    adapter->buffer_list_dma, rxq_desc.desc,
+				    adapter->filter_list_dma, mac_address);
+
+	if (rc != H_SUCCESS && try_again) {
+		do {
+			rc = h_free_logical_lan(adapter->vdev->unit_address);
+		} while (H_IS_LONG_BUSY(rc) || (rc == H_BUSY));
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
@@ -505,11 +530,7 @@ static int ibmveth_open(struct net_devic
 	ibmveth_debug_printk("receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
 
     
-	lpar_rc = h_register_logical_lan(adapter->vdev->unit_address,
-					 adapter->buffer_list_dma,
-					 rxq_desc.desc,
-					 adapter->filter_list_dma,
-					 mac_address);
+	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc, mac_address);
 
 	if(lpar_rc != H_SUCCESS) {
 		ibmveth_error_printk("h_register_logical_lan failed with %ld\n", lpar_rc);

--------------020700020008030409020008--

