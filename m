From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Wed, 12 Mar 2014 10:36:03 +0900
Message-ID: <CAKD1Yr0WAZaUgtDS2CpiNZsB48U6mT9vd+NniV4jrVTB5DhrQg@mail.gmail.com>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com> <alpine.LFD.2.11.1403112242190.1769@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35120 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756203AbaCLBgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 21:36:23 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so12938317igc.2
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 18:36:23 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1403112242190.1769@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 5:52 AM, Julian Anastasov <ja@ssi.bg> wrote:
>         If you can do it with CONNMARK save+restore,
> do not change behavior for existing setups. It is
> hard to predict how the mark is used in ip and
> POST ROUTING rules.

I think CONNMARK save/restore can do some of this but not all of it.

For example, consider the case of mark-based routing ("ip rule add
fwmark 123 lookup 456"). Setting the mark when emitting the packet
from protocol code (i.e., this patch), will cause the right route to
be selected. This will properly follow the routing policy chain
(including match routes like "unreachable" and "prohibit" if present),
use the right MTU, select the right source address for ICMP errors,
pick the right MSS/rwin for inclusion in SYN+ACK packets, and so on.

Some of this can be done after the fact using a combination of the
route target, snat/masquerade, MSS rewriting, and so on. However, that
essentially requires duplicating routing and source address selection
into iptables rules. This is brittle and particularly difficult when
dealing with IPv6, where routes can come from autoconf and source
address selection is more complex than in IPv4. It also requires using
snat/masquerade for IPv6, which is something we should avoid if
possible. In general rule it seems to me that it's better to have the
kernel emit the correct packet the first time around than having to
use iptables CONNTRACK to fix it up after the fact.

How much of a concern is modifying existing behaviour? Personally I
think reflecting the mark is better than just using 0 all the time,
but of course, it's possible that people are explicitly matching mark
0 in firewall rules or routing tables. Would it be better if this was
a sysctl?
