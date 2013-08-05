From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: RCUify bond_set_rx_mode()
Date: Mon, 05 Aug 2013 12:21:56 +0200
Message-ID: <51FF7CC4.7010806@redhat.com>
References: <1375694776-3429-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab3HEKZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 06:25:31 -0400
In-Reply-To: <1375694776-3429-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 11:26 AM, Veaceslav Falico wrote:
> Currently, we might easily deadlock with bond_set_rx_mode() and
> bond_hw_addr_swap(). bond_set_rx_mode() is called via dev_set_rx_mode(),
> which already holds the netif_addr_lock_bh(bond), and inside it takes the
> bond->curr_active_slave lock, while bond_hw_addr_swap() is called with
> bond->curr_active_slave lock held and then takes netif_addr_lock_bh(bond),
> which results in deadlock.
> 
> CPU0                    CPU1
> ----                    ----
> lock(&bonding_netdev_addr_lock_key);
> 			lock(&bond->curr_slave_lock);
> 			lock(&bonding_netdev_addr_lock_key);
> lock(&bond->curr_slave_lock);
> 
> Fix this by using the RCU primites in bond_set_rx_mode(). We're safe wrt
> racing of dev_?c_(un)sync() because we hold
> lock(&bonding_netdev_addr_lock_key), and thus nobody will be able to modify
> these lists before we finish.
>
Hi,
I don't think this deadlock can actually happen because bond_hw_addr_swap() is
called from bond_change_active_slave() only in USES_PRIMARY mode, and in such
mode it's always called with rtnl acquired before that, and since
dev_set_rx_mode is called with rtnl, IMO such deadlock can't happen.
Also I think bond_set_rx_mode() can work without RCU because of the held rtnl
and converted to ASSERT_RTNL (this is optional) + rtnl_dereference for the
curr_active_slave.

Cheers,
 Nik

> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Nikolay Aleksandrov <nikolay@redhat.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
