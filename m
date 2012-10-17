From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3] ipv6: Enable enough of the code to handle GSO when
 disabled.
Date: Wed, 17 Oct 2012 18:13:17 +0200
Message-ID: <1350490397.26103.647.camel@edumazet-glaptop>
References: <1350488802-24071-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59555 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab2JQQNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 12:13:23 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so3692732bkc.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 09:13:22 -0700 (PDT)
In-Reply-To: <1350488802-24071-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-17 at 11:46 -0400, Vlad Yasevich wrote:

> This patch attempts to solve this by enabling just enough code so GSO
> is correctly processed.  However, I should point out that if IPv6 is
> simply blacklisted or not built for the kernel, this problem will
> still persist.

So I guess this should be done in a different way ?

We currently use a single structure (struct packet_type) to hold 
pointers to different methods. (The .func() field, and the gso/gro
stuff)

We probably need to split it in two parts, and make one part linked into
kernel, even if CONFIG_IPV6=n, so that GRO/GSO is fully IPv4/IPv6
functional.

By the way, do we really need a hash table for this ?
It seems we only have IPv4 (ETH_P_IP) and IPv6 (ETH_P_IPV6) to take care
of ?

This would remove some tests we currently have in GRO stack, and some
RCU stuff as well.
(GRO is slower if we have many af_packet sockets)

list_for_each_entry_rcu(ptype, head, list) {
    if (ptype->type != type || ptype->dev || !ptype->gro_receive)
        continue;
...

Adding a hook/test in ipv6_rcv() is ugly.
