From: Florian Westphal <fw@strlen.de>
Subject: [PATCH V2 -next 0/5] don't exceed original maximum fragment size when refragmenting
Date: Mon,  4 May 2015 22:54:43 +0200
Message-ID: <1430772888-5682-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, jesse@nicira.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47167 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751716AbbEDUy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:54:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We would like to propose this patchset again. Only minor details
changed since the last version, we incorporated the suggestion from
Jesse to always store the size of the largest fragment received,
regardless of the DF bit.

Thus we never generate bigger fragments as originally received
regardless if DF is set ot not.

We would like to summarize the current discussion on this topic and
again would like you to consider applying this patchset to net-next:

Several proposals were suggested:

#1 employ GRO engine
	- Reassembly would only work within one napi poll run. But
	  reassembly must happen even independently of the interface
	  the frame gets received. Delays cause single fragments to
	  arrive in different napi runs, which wouldn't be aggregated.

	- We would have to kill the 1:1 correspondence between
          aggregation and segmentation: within the TCP protocol we can
          stop aggregating frames at any point without any harm
          because of it being a streaming protocol. Fragmentation is
          different in the way that we need to reassemble the complete
          packet before processing, we cannot make sense of 'half skbs'.

#2 keep fragments attached to reassembled

The idea is to attach the original skbs to the reassembled one, so the
networking stack can choose which ones to use depending on the use
case. Forwarding would operate on the original ones while code dealing
with PACKET_HOST frames would use the reassembled one.

	- We have the overhead to carry more skbs around, which we
          currently don't do.

	- This information cannot be stored in any of the currently
          available fields in the skb or shared_info. That said, a new
          pointer would be necessary in every skb, independently if it
          is fragmented or not. This change does impact fast path and
          skb size.

	- sometimes using reassembled skb or the original ones could
          lead to TOCTTOU attacks in some situations, like packet is
          split in the TCP header, core stacks sees complete
          reassembled TCP packet but netfilter only part of the
          header, so different decisions might be done

	- it does impact fast path in netfilter for every packet:
	  pskb_may_pull is not enough to check if we can eat enough of
	  the header, actually because of overlapping or duplicate
	  fragments we have to touch all those fragments, thus
	  creating new slow paths in netfilter

	- all netfilter helpers would need to adapt in case e.g. a
          udp packet containing a sip message is fragmented.

	- in case we change fragment size, we don't have clear
          semantics and the only behaviour which makes sense is what
          this patchset does (i.e., refragment).

	- still, even such complex change does not allow us to act as
          transparent router/bridge: we still have to queue up
          fragments; in case we cannot reassemble we have to drop
          them (else firewall bypass is possible).

#3 max_frag_size vector

As it is based on the idea of keep fragments attached to reassembly it
inherits a lot of the problems stated in section #2.

	- Still needs an additional way to store this information in
          the skb, thus enlarging a structure we try to shrink.

	- TOCTTOU attacks are not possible because we do inspect the
          same data all the time

	- ... but at the same time, we cannot deal with overlapping or
          duplicated fragments (without making this complex again)

For years the linux kernel never correctly handled fragmented packets
in forwarding L3 or L2 cases. We never heard any complaints. These
patches try to make Linux a better internet citizen, correctly
handling some edge cases, without harming core code and affecting
performance.

Thus we consider our proposed patches superior in all aspects. We are
happy to discuss any ideas how to solve this otherwise.

We investigated alternate approaches to allow transparent refragmentation
for the common case of "well-formed" (i.e., non-overlapping, no duplicates, ..)
fragments.  Unfortunately it involves removing an ip defragmentation
optimization in case netfilter conntrack is active.

The two patches that enable this are included as [RFC] as part of this series
so they can be discussed.

Thanks,
Hannes, Florian
