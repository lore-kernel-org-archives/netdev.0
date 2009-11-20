From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH 0/1] Defer skb allocation for both mergeable buffers and
 big packets in virtio_net
Date: Thu, 19 Nov 2009 22:09:19 -0800
Message-ID: <1258697359.7416.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754634AbZKTGJY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guest virtio_net receives packets from its pre-allocated vring 
buffers, then it delivers these packets to upper layer protocols
as skb buffs. So it's not necessary to pre-allocate skb for each
mergable buffer, then frees it when it's useless. 

This patch has deferred skb allocation when receiving packets for
both big packets and mergeable buffers. It reduces skb pre-allocations 
and skb_frees.

Based on Mickael & Avi's suggestion. A destroy function has been created
to push virtio free buffs to vring for unused pages, and used page private
to maintain page list.

I didn't touch small packet skb allocation to avoid extra copies for small
packets.

This patch has tested and measured against 2.6.32-rc5 git. It is built again
 2.6.32-rc7 kernel. Tests have been done for small packets, big packets and
mergeable buffers.

The single netperf TCP_STREAM performance improved for host to guest. 
It also reduces UDP packets drop rate.

The netperf laptop results were:

mtu=1500
netperf -H xxx -l 120

		w/o patch	w/i patch (two runs)	
guest to host:  3336.84Mb/s   3730.14Mb/s ~ 3582.88Mb/s

host to guest:  3165.10Mb/s   3370.39Mb/s ~ 3407.96Mb/s
