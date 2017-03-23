From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: NULL timer crash
Date: Thu, 23 Mar 2017 09:00:58 -0700
Message-ID: <1490284858.16816.205.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+Yb9BvzcRT84EriUCqx6hnz_kciYNHjHNX56y1jDb70vw@mail.gmail.com>
         <CANn89i+_+da3PBYjk-KwcUpa6qr0MdqVXOmrsQUM7_VzgBurnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34742 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754542AbdCWQBB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 12:01:01 -0400
In-Reply-To: <CANn89i+_+da3PBYjk-KwcUpa6qr0MdqVXOmrsQUM7_VzgBurnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-23 at 07:53 -0700, Eric Dumazet wrote:

> Nice !
> 
> Looks like neigh->ops->solicit is NULL

Apparently we allow admins to do really stupid things with neighbours
on tunnels.

Following patch should avoid the crash.

Anyone has better ideas ?


 net/ipv4/arp.c   |    5 +++++
 net/ipv6/ndisc.c |    4 ++++
 2 files changed, 9 insertions(+)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 51b27ae09fbd725bcd8030982e5850215ac4ce5c..963191b12e28041bf5df6f37f222a7155f83a414 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -146,8 +146,13 @@ static const struct neigh_ops arp_hh_ops = {
 	.connected_output =	neigh_resolve_output,
 };
 
+static void arp_no_solicit(struct neighbour *neigh, struct sk_buff *skb)
+{
+}
+
 static const struct neigh_ops arp_direct_ops = {
 	.family =		AF_INET,
+	.solicit =		arp_no_solicit,
 	.output =		neigh_direct_output,
 	.connected_output =	neigh_direct_output,
 };
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7ebac630d3c603186be2fc0dcbaac7d7e74bfde6..86f290b749d5ca0db4310b17ebeff35d847540c7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -99,9 +99,13 @@ static const struct neigh_ops ndisc_hh_ops = {
 	.connected_output =	neigh_resolve_output,
 };
 
+static void ndisc_no_solicit(struct neighbour *neigh, struct sk_buff *skb)
+{
+}
 
 static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
+	.solicit =		ndisc_no_solicit,
 	.output =		neigh_direct_output,
 	.connected_output =	neigh_direct_output,
 };
