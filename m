From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Potential u32 classifier bug.
Date: Thu, 9 Aug 2007 18:07:55 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290365C9A8@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34695 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756636AbXHJBH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 21:07:57 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've recently been trying to use tc with u32 classifiers to filter
ethernet traffic based on ethertype.  Although we found and fixed an
issue in the sch_prio call to tc_classify() (thanks Patrick!), this
didn't fix the actual filtering issue.  For those of you who are curious
or are tc-savy, I'm really in a bind and need some help.  This is what I
have so far:
 
Filter to identify and move traffic to a different flow:
 
# tc qdisc add dev eth2 root handle 1: rr bands 8 priomap 7 7 6 6 5 5 4
4 3 3 2 2 1 1 0 0 multiqueue
# tc filter add dev eth2 parent 1: protocol 802_3 prio 1 u32 match u32
0x00000800 0x0000ffff at 12 flowid 1:6

Now this hits tc_classify(), and tp->protocol and skb->protocol match
(be16 of 8 - ETH_P_802_3, which is what I expect), so u32_classify() is
called through the tp->classify() func pointer.  This is where things
get weird.

In net/sched/cls_u32.c, u32_classify() grabs a reference to part of the
network header.  This is question number one: how can the filter look at
the ethernet (mac) header if it's grabbing a reference to the network
header:

	u8 *ptr = skb_network_header(skb);

I would think that for a protocol of 802.3, one would want:

	u8 *ptr = skb_mac_header(skb);

Changing this though doesn't fix the filter.  Further down is a rather
horrible match criteria to make sure the filter is looking at the right
data before it applies the whole filter list on the skb:

	if
((*(u32*)(ptr+key->off+(off2&key->offmask))^key->val)&key->mask) {

Now if this matches (meaning it evaluates to zero), we can move on.  If
not, we go to the next key node and try again.  Run out of key nodes, we
return -1 and take the default mapping from IP TOS to Linux priority,
and get queued to a band.

My big question is: Has anyone recently used the 802_3 protocol in tc
with u32 and actually gotten it to work?  I can't see how the
u32_classify() code can look at the mac header, since it is using the
network header accessor to start looking.  I think this is an issue with
the classification code, but I'm looking to see if I'm doing something
stupid before I really start digging into this mess.

Thanks in advance,

PJ Waskiewicz
Intel Corporation
peter.p.waskiewicz.jr@intel.com <mailto:peter.p.waskiewicz.jr@intel.com>
