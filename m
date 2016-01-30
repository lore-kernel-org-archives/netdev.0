From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 14:12:20 -0500
Message-ID: <20160130191220.GB11601@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <20160130024556.6227.51798.stgit@localhost.localdomain>
 <1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160130161702.GA11601@oracle.com>
 <CALx6S378mozgF0A1iq=Y_LB+_5c=_8_iwOYBgoSArUJW60A6Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50013 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbcA3TMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 14:12:35 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S378mozgF0A1iq=Y_LB+_5c=_8_iwOYBgoSArUJW60A6Ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/30/16 09:43), Tom Herbert wrote:
> That is not the only case, If a GRE TEB packet is ever received and
> flow dissector is called for any reason (like skb_get_hash) there's
> going to be problems-- and this doesn't require GRE to even be
> configured on the host.
> 
> I have a patch that changes the 32-bit accesses in flow_dissector to
> use get_unaligned_be32. I don't have access to any machines that care
> about alignment (only x86). Do you know if there is an alternate way
> to test this other than running on architecture like Sparc?

I can help test this on sparc (would help if you send me any special
config instructions for the GRE TEB case) , but the other way to test
it would be something similar to this:

--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -178,6 +178,8 @@ ip:
 
                ip_proto = iph->protocol;
 
+               WARN_ON_ONCE(!IS_ALIGNED(iph->saddr, 4));
+
                if (!dissector_uses_key(flow_dissector,
                                        FLOW_DISSECTOR_KEY_IPV4_ADDRS))
