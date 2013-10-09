From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2013-10-09
Date: Wed,  9 Oct 2013 12:59:04 +0200
Message-ID: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51327 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819Ab3JIK71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) We used the wrong netlink attribute to verify the
   lenght of the replay window on async events. Fix this by
   using the right netlink attribute.

2) Policy lookups can not match the output interface on forwarding.
   Add the needed informations to the flow informations.

3) We update the pmtu when we receive a ICMPV6_DEST_UNREACH message
   on IPsec with ipv6. This is wrong and leads to strange fragmented
   packets, only ICMPV6_PKT_TOOBIG messages should update the pmtu.
   Fix this by removing the ICMPV6_DEST_UNREACH check from the IPsec
   protocol error handlers.

4) The legacy IPsec anti replay mechanism supports anti replay
   windows up to 32 packets. If a user requests for a bigger
   anti replay window, we use 32 packets but pretend that we use
   the requested window size. Fix from Fan Du.

5) If asynchronous events are enabled and replay_maxdiff is set to
   zero, we generate an async event for every received packet instead
   of checking whether a timeout occurred. Fix from Thomas Egerer.

6) Policies need a refcount when the state resolution timer is armed.
   Otherwise the timer can fire after the policy is deleted.

7) We might dreference a NULL pointer if the hold_queue is empty,
   add a check to avoid this.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 73a695f8572e4c46a2aecdbb63f26f36a43e6873:

  cxgb4: remove workqueue when driver registration fails (2013-09-15 22:28:58 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 2bb53e2557964c2c5368a0392cf3b3b63a288cd0:

  xfrm: check for a vaild skb in xfrm_policy_queue_process (2013-10-08 10:49:51 +0200)

----------------------------------------------------------------
Fan Du (1):
      xfrm: Guard IPsec anti replay window against replay bitmap

Steffen Klassert (5):
      xfrm: Fix replay size checking on async events
      xfrm: Decode sessions with output interface.
      ipsec: Don't update the pmtu on ICMPV6_DEST_UNREACH
      xfrm: Add refcount handling to queued policies
      xfrm: check for a vaild skb in xfrm_policy_queue_process

Thomas Egerer (1):
      xfrm: Fix aevent generation for each received packet

 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/ah6.c          |    3 +--
 net/ipv6/esp6.c         |    3 +--
 net/ipv6/ipcomp6.c      |    3 +--
 net/ipv6/xfrm6_policy.c |    1 +
 net/key/af_key.c        |    3 ++-
 net/xfrm/xfrm_policy.c  |   28 ++++++++++++++++++------
 net/xfrm/xfrm_replay.c  |   54 ++++++++++++++++++++++++-----------------------
 net/xfrm/xfrm_user.c    |    5 +++--
 9 files changed, 59 insertions(+), 42 deletions(-)
