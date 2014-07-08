From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v2] netpoll: fix use after free
Date: Tue,  8 Jul 2014 15:14:41 -0700
Message-ID: <96b940137a50e5c387687bb4f57de8b0435a653f.1404857349.git.decot@googlers.com>
References: <cover.1404857349.git.decot@googlers.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <amwang@redhat.com>,
	David Decotigny <decot@googlers.com>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Jiri Pirko <jpirko@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1404857349.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After a bonding master reclaims the netpoll info struct, slaves could
still hold a pointer to the reclaimed data. This patch fixes it: as
soon as netpoll_async_cleanup is called for a slave (eg. when
un-enslaved), we make sure that this slave doesn't point to the data.

Signed-off-by: David Decotigny <decot@googlers.com>
---

Tested:
  One way to reproduce the panic is with netconsole: with the script
  below run in a loop without this patch. Same procedure with this
  patch can run without panic.
    CONFIG_NETCONSOLE=m
    CONFIG_NETCONSOLE_DYNAMIC=y
  Then run in a loop (dual port NIC makes it easier to crash):
    ifconfig eth0 192.168.42.4 up
    ifconfig eth1 192.168.56.4 up
    sleep 10
    modprobe -r netconsole
    modprobe -r bonding
    modprobe netconsole
    modprobe bonding mode=4
    echo +bond0 > /sys/class/net/bonding_masters
    ifconfig bond0 192.168.56.3 up
    mkdir /sys/kernel/config/netconsole/blah
    echo 0 > /sys/kernel/config/netconsole/blah/enabled
    echo bond0 > /sys/kernel/config/netconsole/blah/dev_name
    echo 192.168.56.42 > /sys/kernel/config/netconsole/blah/remote_ip
    echo 1 > /sys/kernel/config/netconsole/blah/enabled
    # npinfo refcnt ->1
    ifenslave bond0 eth1
    # npinfo refcnt ->2
    ifenslave bond0 eth0
    # (this should be optional, preventing ndo_cleanup_nepoll below)
    # npinfo refcnt ->3
    sleep 3
    ifenslave -d bond0 eth1
    # npinfo refcnt ->2, eth1 keeps ptr to npinfo reclaimed later => garbage
    sleep 1
    echo -bond0 > /sys/class/net/bonding_masters
    # netpoll_cleanup(bond0) + dec(refcnt)
    # (should be optional: becomes -> 1 (aka. != 0)
    #                      ==> do not call ndo_cleanup_nepoll)
    # try to increase chance of writing garbage onto npinfo:
    ls -lR / 2>&1 | tail -30
    echo +bond0 > /sys/class/net/bonding_masters
    ifconfig bond0 192.168.56.3 up
    ifenslave bond0 eth1
    # dev_open() called --> netpoll_rx_disable() + npinfo is garbage
    #    -> down(&ni->dev_lock);

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e33937f..907fb5e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -822,7 +822,8 @@ void __netpoll_cleanup(struct netpoll *np)
 
 		RCU_INIT_POINTER(np->dev->npinfo, NULL);
 		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
-	}
+	} else
+		RCU_INIT_POINTER(np->dev->npinfo, NULL);
 }
 EXPORT_SYMBOL_GPL(__netpoll_cleanup);
 
-- 
2.0.0.526.g5318336
