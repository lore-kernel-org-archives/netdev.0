From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv4: ip_send_unicast_reply should set oif only if
 it is L3 master
Date: Wed, 9 Nov 2016 15:38:34 +0900
Message-ID: <CAKD1Yr3v8qYn0eRwJttBr_1KpPBLrPbDLp0+WanQSBKDkD6+0Q@mail.gmail.com>
References: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:38555 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbcKIGi4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 01:38:56 -0500
Received: by mail-it0-f51.google.com with SMTP id q124so253638573itd.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 22:38:55 -0800 (PST)
In-Reply-To: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 7:50 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> @@ -1577,7 +1577,8 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,

Tested-by: Lorenzo Colitti <lorenzo@google.com>

This fixes the IPv4 test, thanks. I notice that 4.8 didn't have
e0d56fdd73, so if this patch can get into 4.9 then there will be no
release that had the behaviour change. Not sure if that's possible any
more though.

Can you also fix tcp_v6_send_response, which suffers from the same
problem? Perhaps revert this hunk of e0d56fdd73 ("net: l3mdev: remove
redundant calls"):

@@ -818,12 +818,8 @@ static void tcp_v6_send_response(const struct
sock *sk, struct sk_buff *skb, u32
        fl6.flowi6_proto = IPPROTO_TCP;
        if (rt6_need_strict(&fl6.daddr) && !oif)
                fl6.flowi6_oif = tcp_v6_iif(skb);
-       else {
-               if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
-                       oif = skb->skb_iif;
-
-               fl6.flowi6_oif = oif;
-       }
+       else
+               fl6.flowi6_oif = oif ? : skb->skb_iif;

        fl6.flowi6_mark = IP6_REPLY_MARK(net, skb->mark);
        fl6.fl6_dport = t1->dest;
