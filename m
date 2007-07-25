From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Tc filtering: broken 802_3 classifier?
Date: Wed, 25 Jul 2007 16:34:51 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329034BFCD2@orsmsx414.amr.corp.intel.com>
References: <46A7D892.3020505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34533 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbXGYXfp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 19:35:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A7D892.3020505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In case of prio, if your manually installed filters don't 
> match, it will fall back to the skb->priority based 
> classification, which is based on tos and is probably 
> responsible for what you're seeing. Feel free to investigate, 
> but you could save us all some time by simply posting what 
> you're doing, what you're expecting and what is actually 
> happening, there's probably a good explanation.

I thought I did that before, but I probably wasn't clear.  I'll try
again (and if I'm still not clear, please pop me in the head).  I am
aware that skb->priority is used if no filter matches, and that is
derived from tos (and gets set in ipsockglue).

This is my setup.  8 bands with prio, with a priomap that is nice and
simple:

# tc qdisc add dev eth0 root handle 1: prio bands 8 priomap 0 0 1 1 2 2
3 3 4 4 5 5 6 6 7 7

With this configuration, ICMP will default to flowid 1:1 (band 0), and
ssh will default to flowid 1:4 (band 3) based on TOS.  I add this filter
(802_3) and all traffic starts flowing into flowid 1:1 (including ssh),
even though it should never match:

# tc filter add dev eth0 protocol 802_3 parent 1: prio 2 u32 match u32
0x00000800 0x0000ffff at 12 flowid 1:6

As soon as I remove the filter:

# tc filter del dev eth0 protocol 802_3 prio 2

ssh flows back into flowid 1:4.  No filters of protocol ip were added,
only the 802.3 filter.

I hope this is more clear as to what I'm seeing.

Thanks,
-PJ
