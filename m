From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pch_gbe: oops with vlan (new)
Date: Fri, 11 May 2012 23:12:57 +0200
Message-ID: <1336770777.31653.283.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44DDF9105@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60126 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab2EKVND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 17:13:03 -0400
Received: by wgbdr13 with SMTP id dr13so2869550wgb.1
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 14:13:01 -0700 (PDT)
In-Reply-To: <40680C535D6FE6498883F1640FACD44DDF9105@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 13:48 -0700, Andy Cress wrote:
> Folks,
> 
> I am looking for help in debugging a pch_gbe driver oops/abort.
> 
> Kernel: version 2.6.32-220.el6.i686 (RHEL6.2)
> Driver: pch_gbe version 0.91-NAPI  (source tarball we used is at
> https://sendfile.kontron.com/message/24tdUi6MXklnUtBLnOsumq until May
> 16)
> NIC: 0b:00.1 Ethernet controller [0200]: Intel Corporation Platform
> Controller Hub EG20T Gigabit Ethernet Controller [8086:8802] (rev 02)
> 
> Configuration, with VLAN:
>  eth0 (not started)
>  eth0.100 = 192.168.100.1
>  eth0.200 = 192.168.200.1
>  eth0.6  = 192.168.6.1
> 
> When starting the VLAN configuration, then doing a ping test for >= 5
> minutes, I get a kernel oop/abort message as shown below.  This does not
> happen without configuring VLAN.
> Where should I look for possible causes for a transmit queue timeout
> like this?  
> 
> I have contacted the OKI/LAPIS driver authors, but no response so far.
> I thought that this group might be able to comment from similar
> experiences.
> 
> Andy

typical sign of a buggy driver

A quick look in current Linus tree show a non existent synchronization
between ndo_start_xmit and TX completion.

tx completion uses a tx_queue_lock spinlock for nothing but false sense
of correctness.

# find drivers/net/ethernet/oki-semi/pch_gbe -name "*.[ch]"|xargs grep -4 -n tx_queue_lock
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-583-
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-584-/**
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-585- * struct pch_gbe_adapter - board specific private data structure
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-586- * @stats_lock:	Spinlock structure for status
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h:587: * @tx_queue_lock:	Spinlock structure for transmit
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-588- * @ethtool_lock:	Spinlock structure for ethtool
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-589- * @irq_sem:		Semaphore for interrupt
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-590- * @netdev:		Pointer of network device structure
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-591- * @pdev:		Pointer of pci device structure
--
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-608- */
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-609-
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-610-struct pch_gbe_adapter {
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-611-	spinlock_t stats_lock;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h:612:	spinlock_t tx_queue_lock;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-613-	spinlock_t ethtool_lock;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-614-	atomic_t irq_sem;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-615-	struct net_device *netdev;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h-616-	struct pci_dev *pdev;
--
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1641-		netif_wake_queue(adapter->netdev);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1642-		adapter->stats.tx_restart_count++;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1643-		pr_debug("Tx wake queue\n");
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1644-	}
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c:1645:	spin_lock(&adapter->tx_queue_lock);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1646-	tx_ring->next_to_clean = i;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c:1647:	spin_unlock(&adapter->tx_queue_lock);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1648-	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1649-	return cleaned;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1650-}
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-1651-
--
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2036-		pr_err("Unable to allocate memory for queues\n");
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2037-		return -ENOMEM;
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2038-	}
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2039-	spin_lock_init(&adapter->hw.miim_lock);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c:2040:	spin_lock_init(&adapter->tx_queue_lock);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2041-	spin_lock_init(&adapter->stats_lock);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2042-	spin_lock_init(&adapter->ethtool_lock);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2043-	atomic_set(&adapter->irq_sem, 0);
drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c-2044-	pch_gbe_irq_disable(adapter);
