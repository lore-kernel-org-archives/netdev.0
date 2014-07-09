From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: call unregister_netdev() exactly
 once per device
Date: Tue, 08 Jul 2014 20:42:18 -0700 (PDT)
Message-ID: <20140708.204218.141082766724192890.davem@davemloft.net>
References: <20140708161827.GO19954@sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.kleikamp@oracle.com,
	dan.carpenter@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaGIDmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:42:19 -0400
In-Reply-To: <20140708161827.GO19954@sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sowmini.varadhan@oracle.com
Date: Tue, 8 Jul 2014 12:18:27 -0400

> unregister_netdev the parent net_device only after
> the last port in the port_list of a `struct vnet'
> is removed when the vnet is dismantled. Moreover,
> this should only be done if the net_device was
> successfully registered.
> 
> Without this fix, 'modprobe -r sunvnet' could
> trigger the following in rollback_registered_many()
> 5693   BUG_ON(dev->reg_state != NETREG_REGISTERED);
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>
> Acked-by: Dan Carpenter <dan.carpenter@oracle.com>

This is definitely not the right fix, you're just removing a symptom
of a much larger problem.

And that problem is that nothing cleans up the objects created by
vnet_new(), they are completely leaked.

vnet_exit(), after doing the vio_unregister_driver(), should call a
helper function that iterates over vnet_list and cleans up those
objects.

That's where the unregister_netdevice() belongs, not in vnet_port_remove().
