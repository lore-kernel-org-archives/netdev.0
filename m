From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make dev_set_mtu() honor notification
 return code
Date: Mon, 13 Jan 2014 15:18:55 -0800 (PST)
Message-ID: <20140113.151855.1046745397621207165.davem@davemloft.net>
References: <1389358097-5396-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, edumazet@google.com,
	alexander.h.duyck@intel.com, nicolas.dichtel@6wind.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbaAMXS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 18:18:58 -0500
In-Reply-To: <1389358097-5396-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Fri, 10 Jan 2014 13:48:17 +0100

> Currently, after changing the MTU for a device, dev_set_mtu() calls
> NETDEV_CHANGEMTU notification, however doesn't verify it's return code -
> which can be NOTIFY_BAD - i.e. some of the net notifier blocks refused this
> change, and continues nevertheless.
> 
> To fix this, verify the return code, and if it's an error - then revert the
> MTU to the original one, and pass the error code.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

This is really a precariously designed code path.

If one of the notifiers says NOTIFY_BAD, well we've already changed
dev->mtu, therefore what if a packet got sent during this time?

Whoever the NOTIFY_BAD signaller is, obviously cannot handle an MTU
setting which we've already set in the netdev.  So allowing it's a
terribly idea to allow visibility of the new MTU value until we can be
sure everyone can handle it.

The problem is that we really need a transaction of some sort to fix
this properly.  First, we'd need to ask all the notifiers if they
can handle the new MTU, then we somehow atomically set netdev->mtu
and have the notifiers commit their own state changes.

Then we'll have the stick issue of what to do if a notifier is
unregistered between the check and the commit. :-)

Your patch is an improvement so I will apply it, this stuff really
is full of holes still.

Thanks.
