From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 14:22:18 -0500
Message-ID: <20160129192218.GB17127@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mwdalton@google.com, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45582 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbcA2TWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:22:31 -0500
Content-Disposition: inline
In-Reply-To: <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/29/16 10:54), Eric Dumazet wrote:
> > Why ipv6 stack itself does not trigger the issue ?
> > Maybe the driver itself does not properly align IP headers on sparc ?
> > Make sure NET_IP_ALIGN is 2 on your build.
> > Note that x86 does not care, but a driver should always align Ethernet
> > header to NET_IP_ALIGN, so that IP headers are aligned to 4 bytes
> > boundaries.

Consolidating a few responses:

NET_IP_ALIGN is 2, of course, or else I would have seen errors about unaligned
access in many more places. The issue is being triggered by ipv6
stack (I'm running iperf over ipv6) so I'm not sure I understand the
first question.

I tried out the suggested patch of setting page_offset to NET_IP_ALIGN
in ixgbe_main.c - and yes, it kills the unaligned errors, so that's a
Good Thing. (though I see davem just responded to the patch)

However, the patch itself is not arch specific, and the unaligned 
address issue should have impacted other archs (silently) as well - 
even for ipv4, 

It would also impact other logic in __skb_flow_dissect: 
e.g., the access to iph->saddr for ipv4 frags would be
unaligned in __skb_flow_dissect? (And Ias I mentioned in my original
mail, the comments in __skb_get_poff seem to indicate that others
have tripped up on this before - and yes, casting is not a good thing
but seems like that's what they did to paper over the problem)

> Hmmm.... it seems that flow dissector can "support L2 GRE", leading to
> unaligned accesses since a header is 14 bytes (not multiple of 4)
  :
> IP stacks in linux assume IP headers are always aligned to 4 bytes,
> so it means having a GRE header like this would align trap on some
> arches.

I'm not sure I see how the above commit could have been impacting me,
I dont have any l2 gre invovled (simple p2p Ethernet II + ipv6 + tcp, 
no vlans, gre or other exotic stuff).

--Sowmini
