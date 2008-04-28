From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Mon, 28 Apr 2008 08:21:28 +0100
Message-ID: <20080428072128.GB5379@gerrit.erg.abdn.ac.uk>
References: <20080421131253.GB12221@ghostprotocols.net> <200804211817.01189.tomasz@grobelny.oswiecenia.net> <20080422174152.GD6039@gerrit.erg.abdn.ac.uk> <20080422.154212.108914213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tomasz@grobelny.oswiecenia.net, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51312 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751605AbYD1HVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 03:21:38 -0400
Content-Disposition: inline
In-Reply-To: <20080422.154212.108914213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >  * skb->priority now cleared before passing the skb onto layer 3;
<snip>
| 
| If this usage of skb->priority is going to override the
| IP_TOS socket option setting, I don't think it's a good
| idea.
| 
| Right now every packet output goes through ip_output.c
| which sets skb->priority to sk->sk_priority, which is set
| by the user via the IP_TOS socket option in ip_sockglue.c

That is actually the key point I wanted to ask about. 

The patch exploits that the assignment happens later, on layer3,
with these conditions:

 * Output path only (sent by the DCCP output module on this host).
 
 * It is not clear which value skb->priority has until reaching the
   output functions in ipv4/ip_output.c and ipv6/ip6_output.c. There
   is no memset on this field in net/core/skbuff.c and the skb comes
   from a cache, so presumably skb->priority is undefined until it
   is assigned from sk->sk_priority.
   
 * The assignment for appletalk (net/appletalk/aarp.c), econet,
   IPv4/6 raw sockets, packet sockets (af_packet.c) is similar, so
   the assumption was that the 4 bytes of skb->priority are not
   used while the skb is on layer 4.

 * The only place where I can see mischief happen is when there is
   a fork where the skb is not passed on to layer 3, using either
   __copy_skb_header (copies the priority field) or skb_segment.

Since I can currently not see the last point happen within DCCP, I think
that the use of skb->priority for layer 4 (DCCP) is safe.

So the remaining question was whether maintainers would be okay with
this "overloading" of the field (Arnaldo seems ok with it). 

Part of the patch tried to make this use obvious, by aligning the 
"prio" policy with the semantics of SO_PRIORITY.

Gerrit


The University of Aberdeen is a charity registered in Scotland, No SC013683.

