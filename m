From: Hangbin Liu <haliu@redhat.com>
Subject: [PATCHv4 iproute2 0/2] libnetlink: malloc correct buff at run time
Date: Thu, 28 Sep 2017 21:33:44 +0800
Message-ID: <1506605626-1744-1-git-send-email-haliu@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52734 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753181AbdI1NeA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 09:34:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

With commit 72b365e8e0fd ("libnetlink: Double the dump buffer size") and
460c03f3f3cc ("iplink: double the buffer size also in iplink_get()"), we
extend the buffer size to avoid truncated message with large numbers of
VFs. But just as Michal said, this is not future-proof since the NIC
number is increasing. We have customer even has 220+ VFs now.

This is not make sense to hard code the buffer and increase it all the time.
So let's just malloc the correct buff size at run time.

Tested with most ip cmds and all look good.

---
v3 -> v4:
* rtnl_recvmsg():
  * As Michal suggested, use zero iov len at the first time to avoid
    copy same data from kernel to userspace.
  * As Stephen suggested, remove loops via goto to make the logic more clear.
* With Phil's help, add __rtnl_recvmsg() to reduce duplicate code.

v2 -> v3:
* rtnl_recvmsg():
  * free buf before each return.
  * return errno when recvmsg failed.

v1 -> v2 by Phil:
* rtnl_recvmsg():
  * Rename output buffer pointer arg to 'answer'.
  * Use realloc() and make sure old buffer is freed on error.
  * Always return a newly allocated buffer for caller to free.
  * Retry on EINTR or EAGAIN so caller doesn't have to.
  * Return well-known negative error codes instead of just -1 on error.
  * Simplify goto label names.
  * If no answer pointer was passed, just free the buffer.
* rtnl_dump_filter_l():
  * Don't retry if rtnl_recvmsg() returns 0 as this can't happen
    anymore.
  * Free buffer returned by rtnl_recvmsg().
* __rtnl_talk():
  * Don't retry if rtnl_recvmsg() returns 0 as this can't happen
    anymore.
  * Free buffer returned by rtnl_recvmsg().
  * Return a newly allocated buffer for callers to free.
* genl_ctrl_resolve_family()
  * Replace 'ghdr + GENL_HDRLEN' to 'answer + NLMSG_LENGTH(GENL_HDRLEN)'
* tc_action_gd()
  * Call print_action() only if cmd == RTM_GETACTION
* Change callers of rtnl_talk*() to always free the answer buffer if
  they passed one.
* Drop extra request buffer space in callers if only used for holding
  output data.
* Drop initialization of answer pointer if not necessary.
* Change callers to pass NULL instead of answer pointer if they don't
  use it afterwards.

Hangbin Liu (2):
  lib/libnetlink: re malloc buff if size is not enough
  lib/libnetlink: update rtnl_talk to support malloc buff at run time

 bridge/fdb.c         |   2 +-
 bridge/link.c        |   2 +-
 bridge/mdb.c         |   2 +-
 bridge/vlan.c        |   2 +-
 genl/ctrl.c          |  19 +++++---
 include/libnetlink.h |   6 +--
 ip/ipaddress.c       |   4 +-
 ip/ipaddrlabel.c     |   4 +-
 ip/ipfou.c           |   4 +-
 ip/ipila.c           |   4 +-
 ip/ipl2tp.c          |   8 +--
 ip/iplink.c          |  38 +++++++--------
 ip/iplink_vrf.c      |  44 ++++++++---------
 ip/ipmacsec.c        |   2 +-
 ip/ipneigh.c         |   2 +-
 ip/ipnetns.c         |  23 +++++----
 ip/ipntable.c        |   2 +-
 ip/iproute.c         |  26 ++++++----
 ip/iprule.c          |   6 +--
 ip/ipseg6.c          |   8 +--
 ip/iptoken.c         |   2 +-
 ip/link_gre.c        |  11 +++--
 ip/link_gre6.c       |  11 +++--
 ip/link_ip6tnl.c     |  11 +++--
 ip/link_iptnl.c      |  10 ++--
 ip/link_vti.c        |  11 +++--
 ip/link_vti6.c       |  11 +++--
 ip/tcp_metrics.c     |   8 +--
 ip/xfrm_policy.c     |  25 +++++-----
 ip/xfrm_state.c      |  30 ++++++------
 lib/libgenl.c        |   9 +++-
 lib/libnetlink.c     | 134 ++++++++++++++++++++++++++++++++++-----------------
 misc/ss.c            |   2 +-
 tc/m_action.c        |  12 ++---
 tc/tc_class.c        |   2 +-
 tc/tc_filter.c       |   8 +--
 tc/tc_qdisc.c        |   2 +-
 37 files changed, 298 insertions(+), 209 deletions(-)

-- 
2.5.5
