From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] openvswitch: Pad OVS_PACKET_ATTR_PACKET if linear
 copy was performed
Date: Tue, 14 Jan 2014 16:16:40 +0000
Message-ID: <20140114161640.GA24121@casper.infradead.org>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
 <52CD657F.7080806@citrix.com>
 <CAEP_g=_pQpH--V+7GSrjGP2z=0TBD_37yXjzTdeKG+2OF3aRaw@mail.gmail.com>
 <52D42A9E.1030805@citrix.com>
 <52D4857C.7020902@citrix.com>
 <CAEP_g=8nG6AHV9Y+5=48nPhkf5Oe=mG8EiyaKSqN4omnmGhv4A@mail.gmail.com>
 <52D50767.6050906@redhat.com>
 <52D52E0A.4050700@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@redhat.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43489 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaANQQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 11:16:44 -0500
Content-Disposition: inline
In-Reply-To: <52D52E0A.4050700@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the zerocopy method is correctly omitted if user space
does not support unaligned Netlink messages. The attribute is
still not padded correctly as skb_zerocopy() will not ensure
padding and the attribute size is no longer pre calculated
though nla_reserve() which ensured padding previously.

This patch applies appropriate padding if a linear data copy
was performed in skb_zerocopy().

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index df46928..24e93f5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -396,7 +396,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		.dst_sk = ovs_dp_get_net(dp)->genl_sock,
 		.snd_portid = upcall_info->portid,
 	};
-	size_t len;
+	size_t len, plen;
 	unsigned int hlen;
 	int err, dp_ifindex;
 
@@ -466,6 +466,11 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
+	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
+	if (!(dp->user_features & OVS_DP_F_UNALIGNED) &&
+	    (plen = (ALIGN(user_skb->len, NLA_ALIGNTO) - user_skb->len)) > 0)
+		skb_put(user_skb, plen);
+
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
 	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
