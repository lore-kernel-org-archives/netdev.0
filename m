From: Apollon Oikonomopoulos <apollon@noc.grnet.gr>
Subject: [PATCH] X.25: decrement netdev reference counts on unload
Date: Tue, 7 Dec 2010 21:43:30 +0200
Message-ID: <20101207194330.GA22608@noc.grnet.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.noc.grnet.gr ([83.212.9.3]:45071 "EHLO mail.noc.grnet.gr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754422Ab0LGTuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 14:50:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We came across this bug when we accidentally loaded and unloaded the x25 
kernel module on a host with KVM virtual machines. All subsequent 
attempts to stop a KVM instance resulted in the KVM process entering D 
state. Reproducing this behaviour can be done in the following way:

1. modprobe x25
2. tunctl && ifconfig tap0 up
3. rmmod x25
4. tunctl -d tap0 (hangs)

A patch follows - we don't use X.25 ourselves so I'm not sure it won't 
panic someone's system.

Regards,
Apollon

PS: I am not subscribed to the list, so please copy any replies to my 
address. Thanks!
----
x25 does not decrement the network device reference counts on module unload.
Thus unregistering any pre-existing interface after unloading the x25 module
hangs and results in

 unregister_netdevice: waiting for tap0 to become free. Usage count = 1

This patch decrements the reference counts of all interfaces in x25_link_free,
the way it is already done in x25_link_device_down for NETDEV_DOWN events.

Signed-off-by: Apollon Oikonomopoulos <apollon@noc.grnet.gr>
---
 net/x25/x25_link.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
index 73e7b95..b25c646 100644
--- a/net/x25/x25_link.c
+++ b/net/x25/x25_link.c
@@ -394,6 +394,7 @@ void __exit x25_link_free(void)
 	list_for_each_safe(entry, tmp, &x25_neigh_list) {
 		nb = list_entry(entry, struct x25_neigh, node);
 		__x25_remove_neigh(nb);
+		dev_put(nb->dev);
 	}
 	write_unlock_bh(&x25_neigh_list_lock);
 }
--
1.7.1
