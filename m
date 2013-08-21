From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Performance regression 3.11 with macvlan between 2 linux guests (bisected)
Date: Wed, 21 Aug 2013 14:38:44 +0200
Message-ID: <5214B4D4.7020806@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:53081 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab3HUMiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 08:38:50 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
	Wed, 21 Aug 2013 13:33:05 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 85A501B08066
	for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 13:38:47 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7LCcYwY61735062
	for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 12:38:34 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7LCcjVj013205
	for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 06:38:45 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,

the patch 

commit 3e4f8b787370978733ca6cae452720a4f0c296b8
Author: Vlad Yasevich <vyasevic@redhat.com>
Date:   Tue Jun 25 16:04:22 2013 -0400

    macvtap: Perform GSO on forwarding path.

causes a severe performance regression for 2 Linux guests with virtio-net
connected via macvlan/vtap doing iperf workload. (2GBit vs. 20Gbit)

If I understand the patch correctly, we now check for gso depending on the
macvlan features. If the underlying hardware does not support the necessary
offloads then we will do segmentation, even if we keep the whole traffic internal
between two guests and even if both guests supports LRO,GSO etc.
---snip---
[...]
+       features = netif_skb_features(skb) & vlan->tap_features;
+       if (netif_needs_gso(skb, features)) {
+               struct sk_buff *segs = __skb_gso_segment(skb, features, false);
[...]

---snip---
Shouldnt we take the features of the target device or even better do the gsoing in the
target device driver?

Christian

FYI, the underlying HW has:

Features for eth0:
rx-checksumming: off [fixed]
tx-checksumming: off
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: off
	tx-scatter-gather: off [fixed]
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [fixed]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
