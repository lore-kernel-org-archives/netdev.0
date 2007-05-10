From: Patrick McHardy <kaber@trash.net>
Subject: Re: Questions about IPsec and Netfilter
Date: Thu, 10 May 2007 17:29:00 +0200
Message-ID: <46433A3C.2000400@trash.net>
References: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Networking development <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38494 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275AbXEJP3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 11:29:46 -0400
In-Reply-To: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Stern wrote:
> I've got a few questions about the relationship between the IPsec 
> implementation and Netfilter.
> 
> Q1: At what points during packet processing do the IPsec transformations 
> occur?  In particular, which netfilter hooks do they come before and 
> after?  And likewise, which routing operations do they come before and 
> after?


Similar to regular tunnels, hooks occur

at output:

(plain packet) NF_IP_LOCAL_OUT/NF_IP_FORWARD -> NF_IP_POST_ROUTING
IPsec
(encapsulated packet) NF_IP_LOCAL_OUT -> NF_IP_POST_ROUTING

at input:

(encapsulated packet) NF_IP_PRE_ROUTING -> NF_IP_LOCAL_IN
IPsec
(plain packet) NF_IP_PRE_ROUTING -> NF_IP_LOCAL_IN/NF_IP_FORWARD

> Q2: When a packet using IPsec tunnel mode is encapsulated or 
> de-encapsulated, does the newly-formed packet return to some earlier point 
> in the stack for further netfilter processing or routing?  What about 
> transport mode?


At output not, at input decapsulated tunnel mode packets go through
the stack again. In transport mode it only goes through the netfilter
hooks again, except when it is rerouted, in which case it is passed
to dst_input again.

> Q3: How can iptables rules determine whether they are dealing with a 
> packet which has been de-encapsulated from (or encapsulated within) an 
> IPsec wrapper?


It can't determine that a packet has been encapsulated afterwards,
before it can look at skb->dst->xfrm. For decapsulated packets
it looks at skb->sp.

> Q4: Is it true that NAT-Traversal isn't implemented for transport mode?


The code seems to support it, altough I don't think I've ever tried it.

> In RFC 2401 (Security Architecture for the Internet Protocol), section 5
> includes this text:
> 
>    As mentioned in Section 4.4.1 "The Security Policy Database (SPD)",
>    the SPD must be consulted during the processing of all traffic
>    (INBOUND and OUTBOUND), including non-IPsec traffic.  If no policy is
>    found in the SPD that matches the packet (for either inbound or
>    outbound traffic), the packet MUST be discarded.
> 
> But on Linux systems, by default the SPD is normally empty (as shown by
> "setkey -DP") and all packets are allowed to pass unhindered.
> 
> Q5: Isn't this a violation of the RFC?  Or is there some implicit policy 
> entry which accepts all packets without applying any security association?


Sort of, the end of the policy list is treated as "no ipsec" policy.
Strictly speaking this seems to be a violation, but I haven't seen
any other implementation that behaves differently.
