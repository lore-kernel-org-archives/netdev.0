From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] 6lowpan: add missing fragment list spinlock
Date: Tue, 04 Feb 2014 20:32:03 -0800 (PST)
Message-ID: <20140204.203203.1380460749447396879.davem@davemloft.net>
References: <1391511473-30000-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbaBEEcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:32:04 -0500
In-Reply-To: <1391511473-30000-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Tue,  4 Feb 2014 11:57:53 +0100

> @@ -197,7 +197,9 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
>  
>  	pr_debug("timer expired for frame with tag %d\n", entry->tag);
>  
> +	spin_lock_bh(&flist_lock);
>  	list_del(&entry->list);
> +	spin_unlock_bh(&flist_lock);
>  	dev_kfree_skb(entry->skb);
>  	kfree(entry);
>  }

This will deadlock, because the other code path holding flist_lock calls
del_timer_sync() to wait for this timer to return.

The synchornization in this code is really a big mess.
