From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bonding: fix bond_poll_controller bh_enable
 warning
Date: Fri, 28 Aug 2015 14:13:51 -0700 (PDT)
Message-ID: <20150828.141351.2056521281131696426.davem@davemloft.net>
References: <658DEBCA-6BE2-4388-AFE8-58C6A71029AC@cumulusnetworks.com>
	<1440782540-7876-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 13806511171@163.com,
	shemminger@linux-foundation.org, maheshb@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbbH1VNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 17:13:52 -0400
In-Reply-To: <1440782540-7876-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 28 Aug 2015 10:22:20 -0700

> The problem is rcu_read_unlock_bh() which triggers a warning when
> irqs are disabled.  ndo_poll_controller can run with bh enabled,
> disabled or irqs disabled so check if that is the case and acquire
> rcu_read_lock_bh only when not running with disabled irqs.

I would say that having hard irqs disabled is a strict requirement, as
per the debugging test in netpoll_send_skb_on_dev():

	WARN_ON_ONCE(!irqs_disabled());

If you want to add the same check to netpoll_send_udp(), that's fine.

But what isn't fine is adding all of this conditional locking, we want
->poll_controller() implementations to be able to depend upon the IRQ
environment they execute in, otherwise every single implementation
might need to have ugly conditional locking as well.
