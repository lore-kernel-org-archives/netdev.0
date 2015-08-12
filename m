From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net] netconsole: Check for carrier before calling netpoll_send_udp()
Date: Wed, 12 Aug 2015 13:06:10 +1000
Message-ID: <CAGHK07AWDvE6=3f5bWnWaz0GmTNSYB7y4vNWfrT=-1jLUH1hmg@mail.gmail.com>
References: <1439256746-7953-1-git-send-email-jmaxwell37@gmail.com>
	<20150810.212256.1658635789817625453.davem@davemloft.net>
	<CAGHK07DgBuVk==rJrc2gWa311DCMJK9NdDDk8OJAfRb=YLigBg@mail.gmail.com>
	<20150811.102521.448694660627631235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jon Maxwell <jmaxwell@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33893 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932265AbbHLDGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 23:06:11 -0400
In-Reply-To: <20150811.102521.448694660627631235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I personally think that drivers need to synchronize such things
> internally.  They are the only entity which knows when it's "OK"
> to do whatever the netpoll method does, and they are also the only
> entity which can properly synchronize such checks.

Thanks agreed. I am testing the following ixgbe patch on my reproducer
that  checks for resetting/removing/down state flags in ixgbe_poll() and
bails if true. It does that check in other ixgbe routines as well. It's working
fine so far. We will need to do something similar for vmxnet3 as well and
possibly other drivers.

--- a/drivers/net/ixgbe/ixgbe_main.c 2015-08-10 17:13:02.899400508 +1000
+++ b/drivers/net/ixgbe/ixgbe_main.c.patch 2015-08-12 11:34:49.951053887 +1000
@@ -2672,6 +2672,11 @@
  int per_ring_budget;
  bool clean_complete = true;

+ if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+    test_bit(__IXGBE_REMOVING, &adapter->state) ||
+    test_bit(__IXGBE_RESETTING, &adapter->state))
+ return budget;
+
 #ifdef CONFIG_IXGBE_DCA
  if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
  ixgbe_update_dca(q_vector);
