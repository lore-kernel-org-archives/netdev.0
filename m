From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] hv_netvsc: Fix race condition on Multi-Send Data field
Date: Fri, 11 Dec 2015 13:34:17 +0100
Message-ID: <877fklyxiu.fsf@vitty.brq.redhat.com>
References: <1449778775-14404-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: davem@davemloft.net, netdev@vger.kernel.org, olaf@aepfle.de,
	jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
	linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449778775-14404-1-git-send-email-haiyangz@microsoft.com>
	(Haiyang Zhang's message of "Thu, 10 Dec 2015 12:19:35 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Haiyang Zhang <haiyangz@microsoft.com> writes:

> In commit 2a04ae8acb14 ("hv_netvsc: remove locking in netvsc_send()"), the
> locking for MSD (Multi-Send Data) field was removed. This could cause a
> race condition between RNDIS control messages and data packets processing,
> because these two types of traffic are not synchronized.
> This patch fixes this issue by sending control messages out directly
> without reading MSD field.
>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 02bab9a..059fc52 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -867,6 +867,14 @@ int netvsc_send(struct hv_device *device,
>  	packet->send_buf_index = NETVSC_INVALID_INDEX;
>  	packet->cp_partial = false;
>  
> +	/* Send control message directly without accessing msd (Multi-Send
> +	 * Data) field which may be changed during data packet processing.
> +	 */
> +	if (!skb) {
> +		cur_send = packet;
> +		goto send_now;
> +	}
> +

Is is supposed to be applied on top of some other patches? It doesn't
compile on top of current net-next:

drivers/net/hyperv/netvsc.c: In function ‘netvsc_send’:
drivers/net/hyperv/netvsc.c:865:7: error: ‘skb’ undeclared (first use in
this function)
  if (!skb) {
         ^
         
Did you mean to check rndis_msg instead (as skb is not defined here)?

>  	msdp = &net_device->msd[q_idx];
>  
>  	/* batch packets in send buffer if possible */
> @@ -939,6 +947,7 @@ int netvsc_send(struct hv_device *device,
>  		}
>  	}
>  
> +send_now:
>  	if (cur_send)
>  		ret = netvsc_send_pkt(cur_send, net_device, pb, skb);

I suppose we untangle these two pathes completely: let
rndis_filter_send_request() call netvsc_send_pkt() directly. Please see
my patch attached (note: it should be split in 3 patches if
submitted). If you like the idea I can send it.

-- 
  Vitaly


--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=untangle.patch

commit b2784f827d2b7b19d3af6025bbe8be5b1450b88c
Author: Vitaly Kuznetsov <vkuznets@redhat.com>
Date:   Fri Dec 11 13:29:40 2015 +0100

    netvsc: untangle rndis_filter_send_request and netvsc_send
    
    Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index f5b2145..03da20c 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -189,6 +189,8 @@ int netvsc_device_remove(struct hv_device *device);
 int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg);
+int netvsc_send_pkt(struct hv_netvsc_packet *packet,
+		    struct netvsc_device *net_device);
 void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				struct rndis_message *resp);
 void netvsc_xmit_completion(void *context);
@@ -211,6 +213,8 @@ int rndis_filter_receive(struct hv_device *dev,
 int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter);
 int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac);
 
+struct netvsc_device *netvsc_outbound_net_device(struct hv_device *device);
+
 #define NVSP_INVALID_PROTOCOL_VERSION	((u32)0xFFFFFFFF)
 
 #define NVSP_PROTOCOL_VERSION_1		2
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 081f14f..eadbb03 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -67,7 +67,7 @@ static void free_netvsc_device(struct netvsc_device *nvdev)
 	kfree(nvdev);
 }
 
-static struct netvsc_device *get_outbound_net_device(struct hv_device *device)
+struct netvsc_device *netvsc_outbound_net_device(struct hv_device *device)
 {
 	struct netvsc_device *net_device;
 
@@ -226,7 +226,7 @@ static int netvsc_init_buf(struct hv_device *device)
 	struct net_device *ndev;
 	int node;
 
-	net_device = get_outbound_net_device(device);
+	net_device = netvsc_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
 	ndev = net_device->ndev;
@@ -478,7 +478,7 @@ static int netvsc_connect_vsp(struct hv_device *device)
 		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5 };
 	int i, num_ver = 4; /* number of different NVSP versions */
 
-	net_device = get_outbound_net_device(device);
+	net_device = netvsc_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
 	ndev = net_device->ndev;
@@ -740,7 +740,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	return msg_size;
 }
 
-static inline int netvsc_send_pkt(
+int netvsc_send_pkt(
 	struct hv_netvsc_packet *packet,
 	struct netvsc_device *net_device)
 {
@@ -850,7 +850,7 @@ int netvsc_send(struct hv_device *device,
 	struct hv_netvsc_packet *msd_send = NULL, *cur_send = NULL;
 	bool try_batch;
 
-	net_device = get_outbound_net_device(device);
+	net_device = netvsc_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
 
@@ -1063,7 +1063,7 @@ static void netvsc_send_table(struct hv_device *hdev,
 	int i;
 	u32 count, *tab;
 
-	nvscdev = get_outbound_net_device(hdev);
+	nvscdev = netvsc_outbound_net_device(hdev);
 	if (!nvscdev)
 		return;
 	ndev = nvscdev->ndev;
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index c8af172..9ee422d 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -210,6 +210,11 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	int ret;
 	struct hv_netvsc_packet *packet;
 	struct hv_page_buffer page_buf[2];
+	struct netvsc_device *net_device;
+
+	net_device = netvsc_outbound_net_device(dev->net_dev->dev);
+	if (!net_device)
+		return -ENODEV;
 
 	/* Setup the packet to send it */
 	packet = &req->pkt;
@@ -239,8 +244,10 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 
 	packet->completion_func = 0;
 	packet->xmit_more = false;
+	packet->send_buf_index = NETVSC_INVALID_INDEX;
+	packet->cp_partial = false;
 
-	ret = netvsc_send(dev->net_dev->dev, packet, NULL);
+	ret = netvsc_send_pkt(packet, net_device);
 	return ret;
 }
 

--=-=-=--
