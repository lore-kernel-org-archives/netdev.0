From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] net/bonding: announce fail-over for the active-backup
 mode
Date: Tue, 27 May 2008 10:33:10 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com>
References: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:30483 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756340AbYE0HdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 03:33:13 -0400
In-Reply-To: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Enhance bonding to announce fail-over for the active-backup mode through the
> netdev events notifier chain mechanism. Such an event can be of use for the
> RDMA CM (communication manager) to let native RDMA ULPs (eg NFS-RDMA, iSER)
> always be aligned with the IP stack, in the sense that they use the same
> ports/links as the stack does. More usages can be done to allow monitoring
> tools based on netlink events be aware to bonding failover.
>
> Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
[...]
> --- linux-2.6.26-rc2.orig/drivers/net/bonding/bond_main.c	2008-05-13 10:02:22.000000000 +0300
> +++ linux-2.6.26-rc2/drivers/net/bonding/bond_main.c	2008-05-15 12:29:44.000000000 +0300
> @@ -1117,6 +1117,7 @@ void bond_change_active_slave(struct bon
>  			bond->send_grat_arp = 1;
>  		} else
>  			bond_send_gratuitous_arp(bond);
> +		netdev_bonding_change(bond->dev);
>  	}
>  }
[...]
> --- linux-2.6.26-rc2.orig/net/core/dev.c	2008-05-13 10:02:31.000000000 +0300
> +++ linux-2.6.26-rc2/net/core/dev.c	2008-05-13 11:50:49.000000000 +0300
> @@ -956,6 +956,12 @@ void netdev_state_change(struct net_devi
>  	}
>  }
>
> +void netdev_bonding_change(struct net_device *dev)
> +{
> +	call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, dev);
> +}
> +EXPORT_SYMBOL(netdev_bonding_change);

Hi Jay,

First, I'll be happy to get a comment from you on the patch.

Second, bond_change_active_slave() is called on few occasions under write_lock_bh()
which means it runs in atomic context. I was thinking that it might be better to
invoke call_netdevice_notifiers() from thread context, since some components may
need to allocate memory in order to deliver event (eg netlink) and may assume the
context they are being called is not atomic.

For example I sometimes get the below "scheduling while atomic" warning which points
on ipoib code, but the stack trace has some netlink calls which allocate skb. I am
not sure yet what triggers this, however I wanted to check with you and Jeff if/what
there are some convensions for the context of call_netdevice_notifiers(), thanks.

Or.


bonding: bond0: link status definitely down for interface ib0, disabling it
bonding: bond0: making interface ib1 the new active one.
BUG: scheduling while atomic: bond0/14237/0x10000100
Pid: 14237, comm: bond0 Not tainted 2.6.26-rc3 #4

Call Trace:
 [<ffffffff804777d7>] schedule+0x98/0x57b
 [<ffffffff80277836>] dbg_redzone1+0x16/0x1f
 [<ffffffffa0106f22>] :ib_ipoib:ipoib_start_xmit+0x445/0x459
 [<ffffffff802799c2>] kmem_cache_alloc_node+0x147/0x177
 [<ffffffff8040a939>] __alloc_skb+0x35/0x12b
 [<ffffffff8022c99b>] __cond_resched+0x1c/0x43
 [<ffffffff80477e11>] _cond_resched+0x2d/0x38
 [<ffffffff802798a0>] kmem_cache_alloc_node+0x25/0x177
 [<ffffffff8040a939>] __alloc_skb+0x35/0x12b
 [<ffffffff8041825e>] rtmsg_ifinfo+0x3a/0xd4
 [<ffffffff80418335>] rtnetlink_event+0x3d/0x41
 [<ffffffff8047b925>] notifier_call_chain+0x30/0x54
 [<ffffffffa00a3d4b>] :bonding:bond_select_active_slave+0xb9/0xe8
 [<ffffffffa00a495e>] :bonding:__bond_mii_monitor+0x43a/0x464
 [<ffffffffa00a49e6>] :bonding:bond_mii_monitor+0x5e/0xaa
 [<ffffffffa00a4988>] :bonding:bond_mii_monitor+0x0/0xaa
 [<ffffffff8023d6fa>] run_workqueue+0x7f/0x107
 [<ffffffff8023d782>] worker_thread+0x0/0xef
 [<ffffffff8023d867>] worker_thread+0xe5/0xef
 [<ffffffff8024088f>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8024088f>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8024055a>] kthread+0x3d/0x63
 [<ffffffff8020c068>] child_rip+0xa/0x12
 [<ffffffff8024051d>] kthread+0x0/0x63
 [<ffffffff8020c05e>] child_rip+0x0/0x12

