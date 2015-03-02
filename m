From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Mon,  2 Mar 2015 18:40:14 +0100
Message-ID: <1425318028-26531-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54103 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbbCBRkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches shrink all in-tree users of skb->cb[] so that kernel
still builds with skb->cb[] set to 44 bytes.

This would create a 4-byte hole, it would be easy to reorder skb
members so this hole is filled.

pahole dump for vmlinux with allyesconfig (+this patch series):

http://www.strlen.de/fw/pahole.txt.gz

remarks/known issues:
- adds __packet attribute to a few structures.
  Its needed to not have padding at end of the structure, else
  we get build assertion errors even if all members fit into cb[].
- checkpatch isn't happy yet.
- dccp changes are untested (its on my todo list)
- rxrpc change is untested (on todo list).
- wireless changes are untested, I don't own any of the affected hw.

The idea is to figure out what needs to be done to make build_skb() and
friends only touch the first 3 cachelines of the skb on all architectures.

We'd need to reduce skbuff by 40 bytes to achieve this for allyesconfig.

Other sk_buff reduction ideas being worked:

- move truesize to shinfo (which has 4 byte hole)
- turn ->data into offset on 64bit platforms (intrusive, > 1000 files
  affected)
- move pointers that are ususally not needed (nf_bridge, secpath) to the end,
  with flag field that tells us when pointer is valid (so we don't have
  to memset() them unconditionally at allocation time).
- seems we could already to this for the inner header fields since the're only
  valid once ->encapsulation / inner_protocol_type is set.

Comments and more ideas welcome.
