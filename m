From: Timo Teras <timo.teras@iki.fi>
Subject: ip_forward_use_pmtu and forwarding to xfrm'ed gre
Date: Wed, 8 Jul 2015 16:30:32 +0300
Message-ID: <20150708163032.5b5df2ec@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:36863 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932672AbbGHNai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 09:30:38 -0400
Received: by lagc2 with SMTP id c2so222508143lag.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 06:30:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems ip_forward_use_pmtu commit log says:
    Tunnel and ipsec output paths clear IPCB again, thus IPSKB_FORWARDED
    won't be set and further fragmentation logic will use the path mtu
    to determine the fragmentation size. They also recheck packet size
    with help of path mtu discovery and report appropriate errors.

But this does not seem to be true in all paths. For example, I'm
forwarding from ethX -> greX (with gre having ttl 64; and thus
setting DF on tunnel always) and then gre output is finally IPsec
encrypted. But fragmentation does not work. Setting ip_forward_use_pmtu
makes it work again. tcpdump says the packet is fragmented based on the
greX device mtu, not the path mtu in this case.

This probably is due to the way how the xfrm+gre work together. On
first packet, the gre tunnel driver updates pmtu for the inner flow,
which is expected to be honored always. And if the 'ttl' value is set
for gre tunnel, no re-fragmentation is allowed as the inner flow
should know better. This does how the side effect that if the very
first packet is large, it'll be dropped to 'learn' the pmtu. 

It's probably not possible to detect this kind of target easily, as the
xfrm can be applied or not even on per inner target IP basis (as then
tunnel destination IP can be dynamic for nbma tunnels).

So I wonder if ip_gre driver can workaround this somehow, by e.g.
refragmenting if necessary. Or if we just should update the sysctl's
help text to say that this another scenario where it needs to be
turned on.

Thanks,
Timo
 
