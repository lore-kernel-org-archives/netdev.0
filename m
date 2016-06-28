From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] notifier: Fix soft lockup for notifier_call_chain().
Date: Tue, 28 Jun 2016 07:13:44 +0200
Message-ID: <1467090824.6850.185.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57720369.6040507@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57720369.6040507@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-28 at 12:56 +0800, Ding Tianhong wrote:
> The problem was occurs in my system that a lot of drviers register
> its own handler to the notifiler call chain for netdev_chain, and
> then create 4095 vlan dev for one nic, and add several ipv6 address
> on each one of them, just like this:
> 
> for i in `seq 1 4095`; do ip link add link eth0 name eth0.$i type vlan id $i; done
> for i in `seq 1 4095`; do ip -6 addr add 2001::$i dev eth0.$i; done
> for i in `seq 1 4095`; do ip -6 addr add 2002::$i dev eth0.$i; done
> for i in `seq 1 4095`; do ip -6 addr add 2003::$i dev eth0.$i; done
> 
> ifconfig eth0 up
> ifconfig eth0 down

I would very much prefer cond_resched() at a more appropriate place.

touch_nmi_watchdog() does not fundamentally solve the issue, as some
process is holding one cpu for a very long time.

Probably in addrconf_ifdown(), as if you have 100,000 IPv6 addresses on
a single netdev, this function might also trigger a soft lockup, without
playing with 4096 vlans...

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a1f6b7b315317f811cafbf386cf21dfc510c2010..13b675f79a751db45af28fc0474ddb17d9b69b06 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3566,6 +3566,7 @@ restart:
 			}
 		}
 		spin_unlock_bh(&addrconf_hash_lock);
+		cond_resched();
 	}
 
 	write_lock_bh(&idev->lock);
