From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: ctnetlink loop
Date: Fri, 3 Dec 2010 14:39:03 +0100
Message-ID: <20101203133903.GG13225@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: netfilter-devel <netfilter-devel@lists.netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I see a problem with how ctnetlink GET requests are being
processed in the kernel (2.6.32.24) under high load.

Initially I saw this problem on a large performance testing
system when getting HTTP proxy performance numbers, but lately
there have been two reports on large customers boxes (both
many-core with 10G NICs).

The sympton is Netlink looping around nfnetlink_rcv_msg(),
which is just because netlink_unicast() came back with -EAGAIN
when trying to write the newly created Netlink skb to the SK
receive buffer in ctnetlink_get_conntrack().  In this case a
(possibly) infinit loop is entered.  Mostly infinit in fact in
case the userland party trying to receive those messages may
be stuck in the sendmsg() call, being unable to read anything
if being single threaded.

I tried to reproduce several times, a few times the loop
disappeared and the box proceeded normally after some time.
I have no explanation for this.

The attached patch tries to solve it by simple not trying
again to netlink_unicast() the reply skb and just fail with
-ENOBUFS.  The reasoning is that at the point a Netlink overrun
is observed it seems counter intuitive to insist on sending
one more Netlink message.

I checked for possible side effects to other Netlink requests,
please check.

The patch applies to net-next-2.6.

Feedback appreciated.

 /holger


--AhhlLboLdkugWU4S
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: inline; filename="nfnl-fix.diff"

nfnetlink: avoid unbound loop on busy Netlink socket

I see a problem with how ctnetlink GET requests are being
processed in the kernel (2.6.32.24) under high load.

The sympton is Netlink looping around nfnetlink_rcv_msg(), which
is just because netlink_unicast() came back with EAGAIN when
trying to write the newly created Netlink skb to the SK receive
buffer in ctnetlink_get_conntrack().  In this case a (possibly)
infinit loop is entered.  Mostly infinit I think in case the
userland party trying to receive those messages may be stuck in
the sendmsg() call, being unable to read anything if being single
threaded.

I tried to reproduce several times, a few times the loop
disappeared and the box proceeded normally after some minutes.
I have no explanation for this.

The attached patch tries to solve it by simple not trying again
to netlink_unicast() the reply skb and just fail with -ENOBUFS.
The reasoning is that at the point a Netlink overrun is detected
it seems counter intuitive to insist on sending one more Netlink
message.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/net/netfilter/nfnetlink.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nfnetlink.c	2010-12-03 14:33:32.000000000 +0100
+++ net-next-2.6/net/netfilter/nfnetlink.c	2010-12-03 14:34:21.000000000 +0100
@@ -138,7 +138,6 @@
 		return 0;
 
 	type = nlh->nlmsg_type;
-replay:
 	ss = nfnetlink_get_subsys(type);
 	if (!ss) {
 #ifdef CONFIG_MODULES
@@ -169,7 +168,7 @@
 
 		err = nc->call(net->nfnl, skb, nlh, (const struct nlattr **)cda);
 		if (err == -EAGAIN)
-			goto replay;
+			err = -ENOBUFS;
 		return err;
 	}
 }

--AhhlLboLdkugWU4S--
