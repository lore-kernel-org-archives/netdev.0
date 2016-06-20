From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: rcu locking issue in mpls output code?
Date: Mon, 20 Jun 2016 20:44:08 +0300
Message-ID: <20160620174408.GT20238@wantstofly.org>
References: <20160620004546.GP20238@wantstofly.org>
 <8d325ab7-bc46-dd69-288a-571d56efc545@cumulusnetworks.com>
 <20160620063055.GR20238@wantstofly.org>
 <7d7097bc-ce10-d8e1-4a90-36045c7d2041@cumulusnetworks.com>
 <CAJieiUi8WX1=Yri_b8aZpP2sEkQ6CqARcX29M94Qdf4gczFDjg@mail.gmail.com>
 <20160620163317.GS20238@wantstofly.org>
 <e84c7422-c688-faec-54ac-e0a5607d6c3d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:53508 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbcFTS0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 14:26:41 -0400
Content-Disposition: inline
In-Reply-To: <e84c7422-c688-faec-54ac-e0a5607d6c3d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 10:38:39AM -0600, David Ahern wrote:

> > OK, patch coming up.  Thanks!
> 
> can you build a kernel with rcu debugging enabled as well and run
> it through your tests?

git HEAD with CONFIG_DEBUG_RT_MUTEXES=y CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y CONFIG_DEBUG_LOCK_ALLOC=y CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y CONFIG_PROVE_RCU=y gives me a lockdep splat on the
machine under my desk when I cause mpls_output() to be called.

The script I use for that is this one -- it creates a namespace that
accepts MPLS tagged packets for one of its local IPs and then sends
an MPLS tagged packet into that namespace.  If you run the script on
an unpatched kernel with lock debugging enabled, you should be able
to see the issue as well, the lockdep splat happens on the very first
packet.

=====
#!/bin/sh

ip link add tons type veth peer name tempitf

ifconfig tons 172.16.20.20 netmask 255.255.255.0

ip netns add ns1
ip netns exec ns1 ifconfig lo 127.0.0.1 up
ip link set tempitf netns ns1
ip netns exec ns1 ip link set tempitf name eth0
ip netns exec ns1 ifconfig eth0 172.16.20.21 netmask 255.255.255.0

modprobe mpls_iptunnel

ip route add 10.10.10.10/32 encap mpls 100 via inet 172.16.20.21

ip netns exec ns1 sysctl -w net.ipv4.conf.all.rp_filter=0
ip netns exec ns1 sysctl -w net.ipv4.conf.lo.rp_filter=0
ip netns exec ns1 sysctl -w net.mpls.conf.eth0.input=1
ip netns exec ns1 sysctl -w net.mpls.platform_labels=1000
ip netns exec ns1 ip addr add 10.10.10.10/32 dev lo
ip netns exec ns1 ip -f mpls route add 100 dev lo

ping -c 1 10.10.10.10
=====

The patch below (which I'll submit shortly with a proper commit
message) makes this lockdep splat go away.

Enabling lock/rcu debugging gives you a lockdep splat on the first
packet going out through mpls_output(), but then makes the packet
loss / memory corruption issue stop appearing, both on my local
space heater and on much more serious hardware, probably due to
timing differences.

But, with lock/rcu debugging disabled and the patch below included,
I don't see packet loss anymore in a production environment during a
test that would fairly reliably show it before.



diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f18ae91..769cece 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2467,13 +2467,17 @@ int neigh_xmit(int index, struct net_device *dev,
 		tbl = neigh_tables[index];
 		if (!tbl)
 			goto out;
+		rcu_read_lock_bh();
 		neigh = __neigh_lookup_noref(tbl, addr, dev);
 		if (!neigh)
 			neigh = __neigh_create(tbl, addr, dev, false);
 		err = PTR_ERR(neigh);
-		if (IS_ERR(neigh))
+		if (IS_ERR(neigh)) {
+			rcu_read_unlock_bh();
 			goto out_kfree_skb;
+		}
 		err = neigh->output(neigh, skb);
+		rcu_read_unlock_bh();
 	}
 	else if (index == NEIGH_LINK_TABLE) {
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
