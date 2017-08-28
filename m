From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 3/3 v9] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Mon, 28 Aug 2017 11:40:39 -0600
Message-ID: <86de09154bfe0b4e13ac5fcc9090389a@codeaurora.org>
References: <1503635966-14076-1-git-send-email-subashab@codeaurora.org>
 <1503635966-14076-4-git-send-email-subashab@codeaurora.org>
 <20170825.200623.1467784779129980276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@aculab.com, marcel@holtmann.org, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60540 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdH1Rkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:41 -0400
In-Reply-To: <20170825.200623.1467784779129980276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> In these code paths where you are the writer, you have to rely upon
> the RTNL mutex (or some other mutual exclusion mechanism) to protect
> the update operation.  RCU locking itself does not provide this.
> 
> So you should use something like rcu_dereference_rtnl() or similar.
> 
> So this would be rmnet_force_unassociate_device() and rmnet_dellink()
> 
> RCU is subtle and the writer paths have the be handled differently
> from the reader paths.  Please take some time to study how RCU should
> be applied properly in these situations rather than just slapping a
> patch together overnight.
> 
> Thank you.

Sorry about the mess David.

Can you tell me if the following design is correct -

The shared resource which needs to be protected is 
real_dev->rx_handler_data.

For the writer path, this needs to be protected using rtnl_lock() and 
rcu.
The writer paths are rmnet_newlink(), rmnet_delink() and
rmnet_force_unassociate_device(). These paths are already called with
rtnl_lock() acquired in, so we just need to acquire the rcu_read_lock(). 
To
dereference here, we will need to use rtnl_dereference().

For the reader path, the real_dev->rx_handler_data is called in the TX / 
RX
path. We only need rcu_read_lock() for these scenarios. In these cases,
the rcu_read_lock() is held in __dev_queue_xmit() and
netif_receive_skb_internal(), so readers need to use 
rcu_dereference_rtnl()
to get the relevant information.
