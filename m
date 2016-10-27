From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Subject: ICMP redirects behavior
Date: Thu, 27 Oct 2016 11:01:21 -0400
Message-ID: <20161027150121.GB30102@ssuryaputra-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35080 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932442AbcJ0PBZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 11:01:25 -0400
Received: by mail-qt0-f196.google.com with SMTP id 23so999799qtp.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 08:01:25 -0700 (PDT)
Received: from ssuryaputra-desktop ([12.38.14.193])
        by smtp.gmail.com with ESMTPSA id i5sm3798564qtb.14.2016.10.27.08.01.23
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 08:01:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, All,

I noticed through code inspection that ICMP redirects behavior is
different after commit 5943634fc5592037db0693b261f7f4bea6bb9457.

In v2.6 kernel, it used to be that ip_rt_redirect() calls
arp_bind_neighbour() which returns 0 and then the state of the neigh for
the new_gw is checked. If the state isn't valid then the redirected
route is deleted. From what I can tell, this behavior is maintained up
to v3.5.7 by check_peer_redirect() because rt->rt_gateway is assigned to
peer->redirect_learned.a4 before calling ipv4_neigh_lookup().

After the commit, ipv4_neigh_lookup() is performed without the
rt_gateway assigned to the new_gw. In my case since rt_gateway (old_gw)
isn't zero, the function uses it as the key. The neigh is valid since
that gateway is the one that sends the ICMP redirect message. Then the
new_gw is assigned. The problem is: the new_gw ARP never gets resolved 
and the traffic is blackholed. My version is v3.18.24.

Is there a justification for this behavioral change? I traced the origin
of the code to v2.1.15 where the check is performed when
rfc1620_redirects is set. I propose the following patch to restore the
previous behavior.

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 62d4d90..510045c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -753,7 +753,9 @@ static void __ip_do_redirect(struct rtable *rt,
struct sk_buff *skb, struct flow
                        goto reject_redirect;
        }

+       rt->rt_gateway = 0;
        n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
+       rt->rt_gateway = old_gw;
        if (!IS_ERR(n)) {
                if (!(n->nud_state & NUD_VALID)) {
                        neigh_event_send(n, NULL);

Regards,

Stephen.
