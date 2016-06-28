From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] notifier: Fix soft lockup for notifier_call_chain().
Date: Tue, 28 Jun 2016 08:22:43 +0200
Message-ID: <1467094963.6850.189.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57720369.6040507@huawei.com>
	 <1467090824.6850.185.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5772149D.6040304@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35365 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcF1GWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 02:22:47 -0400
In-Reply-To: <5772149D.6040304@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-28 at 14:09 +0800, Ding Tianhong wrote:
> On 2016/6/28 13:13, Eric Dumazet wrote:
> > On Tue, 2016-06-28 at 12:56 +0800, Ding Tianhong wrote:
> >> The problem was occurs in my system that a lot of drviers register
> >> its own handler to the notifiler call chain for netdev_chain, and
> >> then create 4095 vlan dev for one nic, and add several ipv6 address
> >> on each one of them, just like this:
> >>
> >> for i in `seq 1 4095`; do ip link add link eth0 name eth0.$i type vlan id $i; done
> >> for i in `seq 1 4095`; do ip -6 addr add 2001::$i dev eth0.$i; done
> >> for i in `seq 1 4095`; do ip -6 addr add 2002::$i dev eth0.$i; done
> >> for i in `seq 1 4095`; do ip -6 addr add 2003::$i dev eth0.$i; done
> >>
> >> ifconfig eth0 up
> >> ifconfig eth0 down
> > 
> > I would very much prefer cond_resched() at a more appropriate place.
> > 
> > touch_nmi_watchdog() does not fundamentally solve the issue, as some
> > process is holding one cpu for a very long time.
> > 
> > Probably in addrconf_ifdown(), as if you have 100,000 IPv6 addresses on
> > a single netdev, this function might also trigger a soft lockup, without
> > playing with 4096 vlans...
> > 
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index a1f6b7b315317f811cafbf386cf21dfc510c2010..13b675f79a751db45af28fc0474ddb17d9b69b06 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -3566,6 +3566,7 @@ restart:
> >  			}
> >  		}
> >  		spin_unlock_bh(&addrconf_hash_lock);
> > +		cond_resched();
> >  	}
> >  
> >  	write_lock_bh(&idev->lock);
> > 
> > 
> it looks like not enough, I still got this calltrace,
> 
> <4>[ 7618.596184]3840: ffffffbfa101a0a0 00000000000007f0
> <4>[ 7618.596187][<ffffffc000203780>] el1_irq+0x80/0x100
> <4>[ 7618.596255][<ffffffbfa1019d74>] fib6_walk_continue+0x1d4/0x200 [ipv6]
> <4>[ 7618.596275][<ffffffbfa1019ed4>] fib6_walk+0x3c/0x70 [ipv6]
> <4>[ 7618.596295][<ffffffbfa1019f70>] fib6_clean_tree+0x68/0x90 [ipv6]
> <4>[ 7618.596314][<ffffffbfa101a020>] __fib6_clean_all+0x88/0xc0 [ipv6]
> <4>[ 7618.596334][<ffffffbfa101c7f0>] fib6_run_gc+0x88/0x148 [ipv6]
> <4>[ 7618.596354][<ffffffbfa1021678>] ndisc_netdev_event+0x80/0x140 [ipv6]
> <4>[ 7618.596358][<ffffffc00023f83c>] notifier_call_chain+0x5c/0xa0
> <4>[ 7618.596361][<ffffffc00023f9e0>] raw_notifier_call_chain+0x20/0x28
> <4>[ 7618.596366][<ffffffc0005cbab4>] call_netdevice_notifiers_info+0x4c/0x80
> <4>[ 7618.596369][<ffffffc0005cbfc8>] dev_close_many+0xd0/0x138
> <4>[ 7618.596378][<ffffffbfa33be6e8>] vlan_device_event+0x4a8/0x6a0 [8021q]
> <4>[ 7618.596381][<ffffffc00023f83c>] notifier_call_chain+0x5c/0xa0
> <4>[ 7618.596384][<ffffffc00023f9e0>] raw_notifier_call_chain+0x20/0x28
> <4>[ 7618.596387][<ffffffc0005cbab4>] call_netdevice_notifiers_info+0x4c/0x80
> <4>[ 7618.596390][<ffffffc0005d5148>] __dev_notify_flags+0xb8/0xe0
> <4>[ 7618.596393][<ffffffc0005d5994>] dev_change_flags+0x54/0x68
> <4>[ 7618.596397][<ffffffc00064a620>] devinet_ioctl+0x650/0x700
> <4>[ 7618.596400][<ffffffc00064bea4>] inet_ioctl+0xa4/0xc8
> <4>[ 7618.596405][<ffffffc0005b1094>] sock_do_ioctl+0x44/0x88
> <4>[ 7618.596408][<ffffffc0005b1a3c>] sock_ioctl+0x23c/0x308
> <4>[ 7618.596413][<ffffffc000393bc4>] do_vfs_ioctl+0x48c/0x620
> 
> 

Follow the stack trace and add another cond_resched() where it is needed
then ?

Lot of this code was written decade ago where nobody expected a root
user was going to try hard to crash its host ;)

I did not check if the following is valid (Maybe __fib6_clean_all() is
called with some spinlock/rwlock held)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1bcef2369d64e6f1325dcab50c14601e6ca5a40a..a2bb59b29dc1629aca1f7997bacb431f00c79227 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1680,17 +1680,18 @@ static void __fib6_clean_all(struct net *net,
 	struct hlist_head *head;
 	unsigned int h;
 
-	rcu_read_lock();
 	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
 		head = &net->ipv6.fib_table_hash[h];
+		rcu_read_lock();
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
 					func, false, sernum, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
+		rcu_read_unlock();
+		cond_resched();
 	}
-	rcu_read_unlock();
 }
 
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *),
