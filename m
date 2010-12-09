From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: ctnetlink loop
Date: Thu, 09 Dec 2010 11:56:13 +0100
Message-ID: <4D00B5CD.3050406@netfilter.org>
References: <20101203133903.GG13225@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000904020006080003040508"
Cc: "David S. Miller" <davem@davemloft.net>
To: netfilter-devel <netfilter-devel@lists.netfilter.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36069 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756225Ab0LIK4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 05:56:18 -0500
In-Reply-To: <20101203133903.GG13225@mail.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000904020006080003040508
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Sorry, I finally found your email reporting this:

> nfnetlink: avoid unbound loop on busy Netlink socket
> 
> I see a problem with how ctnetlink GET requests are being
> processed in the kernel (2.6.32.24) under high load.
> 
> The sympton is Netlink looping around nfnetlink_rcv_msg(), which
> is just because netlink_unicast() came back with EAGAIN when
> trying to write the newly created Netlink skb to the SK receive
> buffer in ctnetlink_get_conntrack().  In this case a (possibly)
> infinit loop is entered.  Mostly infinit I think in case the
> userland party trying to receive those messages may be stuck in
> the sendmsg() call, being unable to read anything if being single
> threaded.
> 
> I tried to reproduce several times, a few times the loop
> disappeared and the box proceeded normally after some minutes.
> I have no explanation for this.
> 
> The attached patch tries to solve it by simple not trying again
> to netlink_unicast() the reply skb and just fail with -ENOBUFS.
> The reasoning is that at the point a Netlink overrun is detected
> it seems counter intuitive to insist on sending one more Netlink
> message.

We still need EAGAIN, and it doesn't necessarily means ENOBUFS for the
general case in nfnetlink.

The following patch covers the case that you're reporting.

--------------000904020006080003040508
Content-Type: text/x-patch;
 name="f.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="f.patch"

netfilter: ctnetlink: fix loop in ctnetlink_get_conntrack()

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes a loop in ctnetlink_get_conntrack() that can be
triggered if you use the same socket to receive events and to
perform a GET operation. Under heavy load, netlink_unicast()
may return -EAGAIN, this error code is reserved in nfnetlink for
the module load-on-demand. Instead, we return -ENOBUFS which is
the appropriate error code that has to be propagated to
user-space.

Reported-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b729ace..a84fa6f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -973,7 +973,8 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 free:
 	kfree_skb(skb2);
 out:
-	return err;
+	/* this avoids a loop in nfnetlink. */
+	return err == -EAGAIN ? -ENOBUFS : err;
 }
 
 #ifdef CONFIG_NF_NAT_NEEDED

--------------000904020006080003040508--
