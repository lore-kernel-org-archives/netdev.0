From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [RFC PATCH net-next 0/3] Extend macvtap with multiple qdiscs
Date: Sun,  7 Feb 2016 22:14:53 -0500
Message-ID: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Cc: jasowang@redhat.com, mst@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:35358 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbcBHDPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 22:15:05 -0500
Received: by mail-qg0-f65.google.com with SMTP id b35so7868377qge.2
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 19:15:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an RFC series to extend macvtap with multiple qdisc.  Right now
multiqueue macvtap setups suffer from lock contention.  Macvtap sets
the queue index and thus gets a default qdisc allocated to it.  Since
it later users dev_queue_xmit() call to the macvlan type device (so that
we can packet captures and other filtering on macvtap itself) we end up
with qdisc lock contention since what we have is multiple file descriptors
writing to the same qdisc.

With this series, the macvtap device now becomes a true multi-queue device
that defaults to 1 queue.  Every time the user opens the device (this is
how multiqueue macvtap is used), we update the number of real queues for
the device.  When the user writes to the device, we record the queue index
associted with the file descriptor to the skb, and that ends up translating
to the device queue index.  This is one transmit only.  Receive side
is left alone and will prefer skb hash if available. 

Macvlan through this all is left with lockless transmit path.

Thanks
-vlad

Vladislav Yasevich (3):
  macvtap: mutiple qdiscs support
  macvlan: add queue selection functionality
  macvtap: Record the rx queue based on the user tap queue

 drivers/net/macvlan.c | 20 ++++++++++++++++++++
 drivers/net/macvtap.c | 19 +++++++++++++++++++
 2 files changed, 39 insertions(+)

-- 
2.1.0
