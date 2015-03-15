From: Linhaifeng <haifeng.lin@huawei.com>
Subject: virtio-net: tx queue was stopped
Date: Sun, 15 Mar 2015 14:50:27 +0800
Message-ID: <55052BB3.2080705@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	lilijun <jerry.lilijun@huawei.com>,
	"liuyongan@huawei.com" <liuyongan@huawei.com>,
	"lixiao (H)" <lixiao91@huawei.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [119.145.14.65] ([119.145.14.65]:64510 "EHLO
	szxga02-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbCOGvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 02:51:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,Michael

I had tested the start_xmit function by the follow code found that the tx queue's state is stopped and can't send any packets anymore.

static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	... ...


        capacity = 10;	//########## test code : force to call netif_stop_queue

        if (capacity < 2+MAX_SKB_FRAGS) {
                netif_stop_queue(dev);

                if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
                        /* More just got used, free them then recheck. */
                        capacity += free_old_xmit_skbs(vi);
                        dev_warn(&dev->dev, "free_old_xmit_skbs capacity =%d MAX_SKB_FRAGS=%d", capacity, MAX_SKB_FRAGS);

                        capacity = 10;		//########## test code : force not to call  netif_start_queue

                        if (capacity >= 2+MAX_SKB_FRAGS) {
                                netif_start_queue(dev);
                                virtqueue_disable_cb(vi->svq);
                        } else {
				//########## OTOH if often enter this branch tx queue maybe stopped.
			}
			
                }

		//########## Should we start queue here? I found that sometimes skb_xmit_done run before netif_stop_queue if this occurred the queue's state is
		//########## stopped and have to reload virtio-net module to restore network.

        }
	
}

ping 9.62.1.2 -i 0.1
64 bytes from 9.62.1.2: icmp_seq=19 ttl=64 time=0.115 ms
64 bytes from 9.62.1.2: icmp_seq=20 ttl=64 time=0.101 ms
64 bytes from 9.62.1.2: icmp_seq=21 ttl=64 time=0.094 ms
64 bytes from 9.62.1.2: icmp_seq=22 ttl=64 time=0.098 ms
64 bytes from 9.62.1.2: icmp_seq=23 ttl=64 time=0.097 ms
64 bytes from 9.62.1.2: icmp_seq=24 ttl=64 time=0.095 ms
64 bytes from 9.62.1.2: icmp_seq=25 ttl=64 time=0.095 ms
....
ping:  sendmsg:  No buffer space available
ping:  sendmsg:  No buffer space available
ping:  sendmsg:  No buffer space available
ping:  sendmsg:  No buffer space available
ping:  sendmsg:  No buffer space available
ping:  sendmsg:  No buffer space available
....

-- 
Regards,
Haifeng
