From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NETFILTER]: Fix race between clusterip_config_find_get
 and _entry_put.
Date: Sun, 13 Apr 2008 06:55:47 +0200
Message-ID: <48019253.2090007@trash.net>
References: <48009282.9040808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48009282.9040808@openvz.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Please remeber to CC netfilter-devel]

Pavel Emelyanov wrote:
> Consider we are putting a clusterip_config entry with the "entries"
> count == 1, and on the other CPU there's a clusterip_config_find_get
> in progress:
> 
> CPU1:							CPU2:
> clusterip_config_entry_put:				clusterip_config_find_get:
> if (atomic_dec_and_test(&c->entries)) { 
> 	/* true */
> 							read_lock_bh(&clusterip_lock);
> 							c = __clusterip_config_find(clusterip);
> 							/* found - it's still in list */
> 							...
> 							atomic_inc(&c->entries);
> 							read_unlock_bh(&clusterip_lock);
> 
> 	write_lock_bh(&clusterip_lock);
> 	list_del(&c->list);
> 	write_unlock_bh(&clusterip_lock);
> 	...
> 	dev_put(c->dev);
> 
> Oops! We have an entry returned by the clusterip_config_find_get,
> which is a) not in list b) has a stale dev pointer.
> 
> The problems will happen when the CPU2 will release the entry - it
> will remove it from the list for the 2nd time, thus spoiling it, and
> will put a stale dev pointer.
> 
> The fix is to make atomic_dec_and_test under the clusterip_lock.

I guess an alternative would have been to use atomic_inc_not_zero
in clusterip_config_find_get. But this is only called very rarely,
so it doesn't really matter.

Applied, thanks.
