From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3] gre: fix a regression in ioctl
Date: Sat, 29 Jun 2013 12:02:59 +0800
Message-ID: <1372478579-6548-1-git-send-email-amwang@redhat.com>
References: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab3F2EDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 00:03:11 -0400
In-Reply-To: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

When testing GRE tunnel, I got:

 # ip tunnel show
 get tunnel gre0 failed: Invalid argument
 get tunnel gre1 failed: Invalid argument

This is a regression introduced by commit c54419321455631079c7d
("GRE: Refactor GRE tunneling code.") because previously we
only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
after that commit, the check is moved for all commands.

So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.

After this patch I got:

 # ip tunnel show
 gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
 gre1: gre/ip  remote 192.168.122.101  local 192.168.122.45  ttl inherit 

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v2: check TUNNEL_* flags
v3: the check should be kept in gre module

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c326e86..1f6eab6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -314,10 +314,11 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
 
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
-	if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
-	    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
-	    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING))) {
-		return -EINVAL;
+	if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
+		if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
+		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
+		    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING)))
+			return -EINVAL;
 	}
 	p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
 	p.o_flags = gre_flags_to_tnl_flags(p.o_flags);
