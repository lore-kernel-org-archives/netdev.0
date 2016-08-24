From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [RFC PATCH] net: ip_finish_output_gso: Attempt gso_size
 clamping if segments exceed mtu
Date: Wed, 24 Aug 2016 17:53:50 +0300
Message-ID: <20160824175350.34df9f3b@pixies>
References: <1471867570-1406-1-git-send-email-shmulik.ladkani@gmail.com>
        <20160822125842.GF6199@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34778 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756452AbcHXOx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 10:53:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so3008040wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 07:53:56 -0700 (PDT)
In-Reply-To: <20160822125842.GF6199@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 22 Aug 2016 14:58:42 +0200, fw@strlen.de wrote:
> >  Florian, in fe6cc55f you described a BUG due to gso_size decrease.
> >  I've tested both bridged and routed cases, but in my setups failed to
> >  hit the issue; Appreciate if you can provide some hints.
> 
> Still get the BUG, I applied this patch on top of net-next.
> 
> On hypervisor:
> 10.0.0.2 via 192.168.7.10 dev tap0 mtu lock 1500
> ssh root@10.0.0.2 'cat > /dev/null' < /dev/zero
> 
> On vm1 (which dies instantly, see below):
> eth0 mtu 1500 (192.168.7.10)
> eth1 mtu 1280 (10.0.0.1)
> 
> On vm2
> eth0 mtu 1280 (10.0.0.2)
> 
> Normal ipv4 routing via vm1, no iptables etc. present, so
> 
> we have  hypervisor 1500 -> 1500 VM1 1280 -> 1280 VM2
> 
> Turning off gro avoids this problem.

I hit the BUG only when VM2's mtu is not set to 1280 (kept to the 1500
default).

Otherwise, Hypervisor's TCP stack (sender) uses TCP MSS advertised by
VM2 (which is 1240 if VM2 mtu properly configured), thus GRO taking
place in VM1's eth0 is based on arriving segments (sized 1240).
Meaning, "ingress" gso_size is actually 1240, and no "gso clamping"
occurs.

Only if VM2 has mtu of 1500, the MSS seen by Hypervisor during handshake
is 1460, thus GRO acting on VM1's eth0 is based on 1460 byte segments.
This leads to "gso clamping" taking place, with the BUG in skb_segment
(which btw, seems sensitive to change in gso_size only if GRO was
merging into frag_list).

Can you please acknowledge our setup and reproduction are aligned?

Thanks,
Shmulik
