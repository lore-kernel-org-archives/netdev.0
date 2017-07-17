From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net 1/2] net: set skb hash for IP6 TCP reset packet
Date: Mon, 17 Jul 2017 01:51:51 -0700
Message-ID: <1500281511.5566.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1499967945.git.shli@fb.com>
         <5595e60068d7c18c7f0749d8a355a008123ca0d8.1499967945.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34173 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbdGQIvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 04:51:54 -0400
Received: by mail-wm0-f68.google.com with SMTP id p204so21778554wmg.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 01:51:54 -0700 (PDT)
In-Reply-To: <5595e60068d7c18c7f0749d8a355a008123ca0d8.1499967945.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-07-13 at 10:56 -0700, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> Please see below tcpdump output:

> The tcp reset packet has a different flowlabel, which causes our router
> doesn't correctly close tcp connection.

This looks a bug in your router, because (IPv6 only) flowlabel is not
part of the tuple identifying a TCP flow.


>   The reason is the normal packet
> gets the skb->hash from sk->sk_txhash, which is generated randomly.
> ip6_make_flowlabel then uses the hash to create a flowlabel. The reset
> packet doesn't get assigned a hash, so the flowlabel is calculated with
> flowi6.
> 
> The solution is to save the hash value for timeout sock and use it for
> reset packet.

I am a bit unsure why we need to add yet another field in TCP timewait
structure, since :

1) flowlabel can vary during a TCP flow lifetime.
2) flowlabel is different unde synflood (each syncookie gets a random
flowlabel), and if 3rd packet comes back from the client to finish 3WHS,
the flowlabel will again be different from the one that SYNACK used.
