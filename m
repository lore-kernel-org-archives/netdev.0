From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Wed,  4 Mar 2015 10:39:58 -0800
Message-ID: <1425494404-24114-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:42035 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758660AbbCDSkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 13:40:15 -0500
Received: by igkb16 with SMTP id b16so39137116igk.1
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 10:40:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In several qdiscs, we currently compute packet hashes primarily as part
of queue selection. This is done by calling flow_dissect and then
performing a jhash.

There are several problems with this:

- The functionality of doing a packet hash is replicated in the qdiscs.
- The hashing algorithm is not consistent, for instance in hhf an
  attempt is made to get the hash out of sk_hash, but other qdiscs
  don't do that. Some qdiscs XOR ip_proto into the source before
  jhash, some don't.
- Without a common infrastructure, if we want to use a new (potentially
  stronger) hash function or wanted to add more input to the hash,
  we would need to address this in each qdisc.
- Flow dissector is potentially called multiple times for a single
  packet.
- The flow keys are passed in cb[] structure. This severely limits
  our ability to increase the key space. For instance, the folding
  of IPv6 addresses in flow_dissector to make a 32-bit value
  represents a significant loss of information (it would be easy
  to create millions of different 4-tuples that would always produce the
  same hash value). 

This patch set consolidates the packet hashing in the qdiscs to use the
common skb_get_hash function. Specifically:

- Add skb_get_hash_perturb. This allows a caller to perturb the
  skb->hash value for a local use. This support the pertubation
  feature in qdiscs.
- Call skb_get_hash or skb_get_hash_perturb from the qdiscs

There are at least two caveats to mention:

- The probability that two different flows randomly match to the same
  hash from skb_get_hash is 1/2^32. If such a collision were to happen,
  then the flows potentially also map to the same qdisc queue in
  perpetuity despite perturbation being performed. Given the very low
  probability of this occurring, this may in practice only be an
  academic issue. If it is a real concern, rekeying of the underlying
  mechanisms of skb->hash could be done.
- skb_get_hash may return a value from the hardware. There are two
  questions around that:
  1) Does this produce predicatable hash values that can be exploited
     by an attacker? The answer for this is that we need to enforce
     that any device returning a hash to host must be initialized
     with a random hash key.
  2) Is the quality of the hash done in HW poorer than what host can
     do? Hardware typically provides a Toeplitz hash which was
     originally specified by MS for RSS. The application of Toeplitz
     hash was only specified for TCP and IPv4/v6, although some NICs
     have extrapolated the algorithm to apply to UDP also. Toeplitz
     is fairly well known at this point, it doesn't seem like there
     is evidence that this is poorer quality than Jenkin's hash, and
     in fact in the case of TCP/IPv6 the hash quality is probably
     better since the fully 40 bytes of 4-tuple are used as input.
     However, if there are concerns about the quality of HW hash,
     we do have the option of turning it off.

Tom Herbert (6):
  net: Add skb_get_hash_perturb
  sched: Eliminate use of flow_keys in sch_choke
  sched: Eliminate use of flow_keys in sch_fq_codel
  sched: Eliminate use of flow_keys in sch_hhf
  sched: Eliminate use of flow_keys in sch_sfb
  sched: Eliminate use of flow_keys in sch_sfq

 include/linux/skbuff.h   | 15 +++++++++++++++
 net/sched/sch_choke.c    | 32 ++------------------------------
 net/sched/sch_fq_codel.c | 11 ++---------
 net/sched/sch_hhf.c      | 19 +------------------
 net/sched/sch_sfb.c      | 24 ++++++++----------------
 net/sched/sch_sfq.c      | 29 +++--------------------------
 6 files changed, 31 insertions(+), 99 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
