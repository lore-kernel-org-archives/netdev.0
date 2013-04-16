From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 0/3] Shrink sk_buff and add a security blob
Date: Tue, 16 Apr 2013 16:39:02 -0400
Message-ID: <20130416202437.10474.45713.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965238Ab3DPUjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 16:39:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a follow-up to the recent discussion around sk_buff
size and the desire to add a LSM security blob to the sk_buff.  The
patches proposed here do indeed shrink the size of the sk_buff from
256 bytes down to 248 bytes on my x86_64 system while adding a LSM
security blob, but there is a tradeoff in that the patches overload
the skb_shared_info->destructor_arg field (more info/detail in the
description of patch 3/3).  The overloading only takes place for LSMs
which make use of the blob, all other cases behave as they currently
do.  I wouldn't say this solution is perfect, but it does both shrink
the sk_buff and add a security blob through what I believe to be the
least invasive approach.

I'm posting this to restart the discussion around these changes now
that we have a set of patches to discuss, critique, etc.  Hopefully
we can find some middle ground that gets everyone enough of what they
want, if not all.

The standard disclaimers apply.  This is a RFC patch; it builds,
boots, and passes the basic unit tests I've thrown at it, but I can't
say I've tested it throughly.  This includes building the kernel with
all the different, relevant CONFIG options.  YMMV.

---

Paul Moore (3):
      skb: wrap skb_shared_info->destructor_arg access with set and get functions
      net: wrap skb->secmark access with set and get functions
      net: move sk_buff->secmark into a security blob in skb_shared_info


 drivers/net/macvtap.c             |    2 -
 drivers/net/tun.c                 |    2 -
 include/linux/security.h          |   91 ++++++++++++++++++++++++++-
 include/linux/skbuff.h            |   73 ++++++++++++++-------
 net/core/skbuff.c                 |   28 +++++++-
 net/ipv4/ip_output.c              |    2 -
 net/ipv6/ip6_output.c             |    2 -
 net/netfilter/xt_AUDIT.c          |    8 +-
 net/netfilter/xt_CONNSECMARK.c    |   10 ++-
 net/netfilter/xt_SECMARK.c        |    2 -
 net/packet/af_packet.c            |    4 +
 security/capability.c             |   38 +++++++++++
 security/security.c               |   63 +++++++++++++++++++
 security/selinux/hooks.c          |  126 +++++++++++++++++++++++++++++++++----
 security/selinux/include/objsec.h |    6 ++
 15 files changed, 397 insertions(+), 60 deletions(-)
