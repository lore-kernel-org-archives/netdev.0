From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting skb->dev
 in receive path
Date: Wed, 13 May 2015 19:04:28 -0700
Message-ID: <20150514020316.1635.50870.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, tgraf@suug.ch,
	herbert@gondor.apana.org.au, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289AbbENCEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 22:04:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we clear the skb->mark field when we pass
through the receive path of the IPv4 or IPv6 virtual tunnel interface.  The
reason for clearing these fields is to resolve an apparent regression for
the behavior before skb_scrub_packet was modified.  Without this patch I
have to set disable_policy for the vti tunnel endpoint in order to be able
to receive traffic.

Fixes: 213dd74aee76 ("skbuff: Do not scrub skb mark within the same name space")
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

I have only tested the ipv4 side of this patch as I have yet to be able to
get a message to successfully pass between to ipv6 vti endpoints.

 net/ipv4/ip_vti.c  |    1 +
 net/ipv6/ip6_vti.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index ee479495f5a3..d853e78742d3 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -112,6 +112,7 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(skb->dev)));
 	skb->dev = dev;
+	skb->mark = 0;
 
 	tstats = this_cpu_ptr(dev->tstats);
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ed9d681207fa..c245fb8298e5 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -363,6 +363,7 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
 
 	skb_scrub_packet(skb, !net_eq(t->net, dev_net(skb->dev)));
 	skb->dev = dev;
+	skb->mark = 0;
 
 	tstats = this_cpu_ptr(dev->tstats);
 	u64_stats_update_begin(&tstats->syncp);
