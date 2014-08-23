From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sat, 23 Aug 2014 13:28:11 -0700 (PDT)
Message-ID: <20140823.132811.751469424156827125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaHWU2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 16:28:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Over time, and specifically and more recently at the Networking
Workshop during Kernel SUmmit in Chicago, we have discussed the idea
of having some way to optimize transmits of multiple TX packets at
a time.

There are several areas of overhead that could be amortized with such
schemes.  One has to do with locking and transactional overhead, the
other has to do with device specific costs.

This patch set here is more aimed at device specific costs.

Typically a device queues up a packet in the TX queue and then has to
do something to have the device start processing that new entry.
Sometimes this is composed of doing an MMIO write to a "tail"
register, and in other cases it can involve something as expensive as
a hypervisor call.

The basic setup defined here is that when the driver supports deferred
TX queue flushing, ndo_start_xmit should no longer perform that
operation.  Instead a new operation, ndo_xmit_flush, should do it.

I have converted IGB and virtio_net as example initial users.  The IGB
conversion is tested, virtio_net is not but it does compile :-)

All ndo_start_xmit call sites have been abstracted behind a new helper
called netdev_start_xmit().

This just adds the infrastructure, it does not actually add any
instances of actually doing multiple ndo_start_xmit calls per
ndo_xmit_flush invocation.

Signed-off-by: David S. Miller <davem@davemloft.net>
