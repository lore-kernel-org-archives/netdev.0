From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] net: Reduce skb_warn_bad_offload() noise.
Date: Mon, 7 Aug 2017 00:42:32 -0400
Message-ID: <CAF=yD-K_nbns=KA_4Acq_PRA=tCP0r+d3fD=jiVx9DkAdkyUYw@mail.gmail.com>
References: <1501852317-11684-1-git-send-email-xiangxia.m.yue@gmail.com>
 <1501853380.25002.38.camel@edumazet-glaptop3.roam.corp.google.com> <CAMDZJNUcqFYQ8c4urSyha+F2C0Z9WzTTw05qLBX9VYpCH4V6Wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Pravin B Shelar <pshelar@ovn.org>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36434 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdHGEnN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:43:13 -0400
Received: by mail-oi0-f66.google.com with SMTP id b130so6639561oii.3
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 21:43:13 -0700 (PDT)
In-Reply-To: <CAMDZJNUcqFYQ8c4urSyha+F2C0Z9WzTTw05qLBX9VYpCH4V6Wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The openvswitch kernel module calls the __skb_gso_segment()(and sets
> tx_path = false) when passing packets to userspace. The UFO will set
> the ip_summed to CHECKSUM_NONE. There are a lot of warn logs. The warn
> log is shown as below. I guess we should revert the patch.

Indeed, the software UFO code computes the checksum and
sets ip_summed to CHECKSUM_NONE, as is correct on the
egress path.

Commit 6e7bc478c9a0 ("net: skb_needs_check() accepts
CHECKSUM_NONE for tx") revised the tx_path case in
skb_needs_check to avoid the warning exactly for the UFO case.

We cannot just make an exception for CHECKSUM_NONE in the
!tx_path case, as the entire statement then becomes false:

       return skb->ip_summed == CHECKSUM_NONE;

Since on egress CHECKSUM_UNNECESSARY is equivalent to
CHECKSUM_NONE, it should be fine to update the UFO code
to set that, instead:

@@ -235,7 +235,7 @@ static struct sk_buff *udp4_ufo_fragment(struct
sk_buff *skb,
        if (uh->check == 0)
                uh->check = CSUM_MANGLED_0;

-       skb->ip_summed = CHECKSUM_NONE;
+       skb->ip_summed = CHECKSUM_UNNECESSARY;
