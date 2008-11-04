From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] ipv6: fix run pending DAD when interface becomes ready
Date: Tue, 04 Nov 2008 14:55:50 +0100
Message-ID: <20081104135551.916564770@nptl.frec.bull.fr>
References: <20081104135549.981972492@nptl.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50773 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbYKDONR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 09:13:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With some net devices types, an IPv6 address configured while the
interface was down can stay 'tentative' forever, even after the interface
is set up. In some case, pending IPv6 DADs are not executed when the
device becomes ready.

I observed this while doing some tests with kvm. If I assign an IPv6 
address to my interface eth0 (kvm driver rtl8139) when it is still down
then the address is flagged tentative (IFA_F_TENTATIVE). Then, I set
eth0 up, and to my surprise, the address stays 'tentative', no DAD is
executed and the address can't be pinged.

I also observed the same behaviour, without kvm, with virtual interfaces
types macvlan and veth.

Some easy steps to reproduce the issue with macvlan:

1. ip link add link eth0 type macvlan
2. ip -6 addr add 2003::ab32/64 dev macvlan0
3. ip addr show dev macvlan0
   ... 
   inet6 2003::ab32/64 scope global tentative
   ...
4. ip link set macvlan0 up
5. ip addr show dev macvlan0
   ...
   inet6 2003::ab32/64 scope global tentative
   ...
   Address is still tentative

I think there's a bug in net/ipv6/addrconf.c, addrconf_notify():
addrconf_dad_run() is not always run when the interface is flagged IF_READY.
Currently it is only run when receiving NETDEV_CHANGE event. Looks like
some (virtual) devices doesn't send this event when becoming up.

For both NETDEV_UP and NETDEV_CHANGE events, when the interface becomes
ready, run_pending should be set to 1. Patch below.

'run_pending = 1' could be moved below the if/else block but it makes 
the code less readable.

Regards,
Benjamin

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/addrconf.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c
+++ net-2.6/net/ipv6/addrconf.c
@@ -2483,8 +2483,10 @@ static int addrconf_notify(struct notifi
 			if (!idev && dev->mtu >= IPV6_MIN_MTU)
 				idev = ipv6_add_dev(dev);
 
-			if (idev)
+			if (idev) {
 				idev->if_flags |= IF_READY;
+				run_pending = 1;
+			}
 		} else {
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is still not ready. */

-- 
