From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 0/9] netlink: strict attribute checking option
Date: Thu, 15 Oct 2015 18:39:05 +0200
Message-ID: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbJOQjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending a netlink request (NLM_F_REQUEST), any unknown attributes are
ignored. This behavior is problematic in some situations. For example if the
user asks for a particular config, the request finishes successfully, yet
the configuraton applied does not work because some of the attributes are
not supported by the kernel (e.g. because it's older than the user space
tool).

We're hitting this when configuring metadata based lwtunnels from user space
applications: it would be surely nice if iproute2 warned about this, as the
resulting tunnel silently won't work with encap routes. Worse, it's quite
crucial for openvswitch and similar programs when deciding what kernel API
(lwtunnel vs. legacy) to use.

This patchset tries to solve this. Everything should be compatible with old
kernels that don't have this patchset.

Before using this new facility, the application should check whether it is
supported by the kernel. This is done by sending a NLMSG_NOOP message with
NLM_F_REQUEST | NLM_F_STRICT | NLM_F_ACK flags set. If the returned message
has NLM_F_STRICT set, the kernel does support NLM_F_STRICT flag; otherwise,
the flag should not be used.

When NLM_F_STRICT is set in a request, the request undergoes stricter
checking for compatibility with the current kernel. Presence of any
attribute unknown to the kernel will mean the message will be rejected and
error returned. In case of success, the request has been performed in the
same way as if NLM_F_STRICT was not set.

However, the sole fact that NLM_F_STRICT is supported by the kernel does not
yet mean it is supported for the particular netlink family and/or message
type. If EPROTO is returned in an error reply, it means that the particular
netlink family/message does not support NLM_F_STRICT (yet). In such case,
the application could fall back to operation without using NLM_F_STRICT
(which is needed for older kernels anyway), possibly warning users that some
options may have been ignored by the kernel, if appropriate.

Another option for using this facility is just set NLM_F_STRICT with
NLM_F_ACK in a request. There are four results that could happen:

1. Request succeeds and NLM_F_STRICT is set in the reply. Everything is good
   and verified in this case.
2. Request succeeds but NLM_F_STRICT is not set in the reply. The request
   was processed but some attributes might (or might not) be ignored because
   the kernel does not understand NLM_F_STRICT. Warn user if appropriate.
3. Request fails with EPROTO. This means NLM_F_STRICT is not supported for
   this request. Depending on the needs of the application, either fail hard
   or try again without NLM_F_STRICT, warning user if appropriate.
4. Request fails with other error code. The request did not succeed.

Applications with hard depency on new kernel features that implement strict
checking may choose to abort if NLM_F_STRICT is not set in the reply to
NLMSG_NOOP, always use NLM_F_STRICT and treat EPROTO as any other error
code.

Note that this RFC patchset is completely untested and may not compile on
all configs. I'd like to get feedback on whether this makes sense. For
example, I'm not thrilled about the EPROTO error code. Suggestions for
a better one are welcome - it needs to be one that is never returned by
any netlink operation, though.

Jiri Benc (9):
  netlink: add NLM_F_STRICT for strict attribute checking
  netlink: remove unnecesary goto's
  netlink: strict attribute parsing
  netlink: strict attribute validation
  rtnetlink: support strict attribute checking
  rtnetlink: add strict parameter to validate callbacks
  rtnetlink: add strict parameter to validate_link_af
  rtnetlink: support strict checking for newlink, setlink and dellink
  veth: validate nested attributes

 crypto/crypto_user.c               |   2 +-
 drivers/infiniband/core/netlink.c  |   2 +-
 drivers/net/bonding/bond_netlink.c |   3 +-
 drivers/net/dummy.c                |   3 +-
 drivers/net/geneve.c               |   3 +-
 drivers/net/ifb.c                  |   3 +-
 drivers/net/ipvlan/ipvlan_main.c   |   3 +-
 drivers/net/macvlan.c              |   3 +-
 drivers/net/nlmon.c                |   3 +-
 drivers/net/team/team.c            |   3 +-
 drivers/net/tun.c                  |   3 +-
 drivers/net/veth.c                 |  13 +++-
 drivers/net/vrf.c                  |   3 +-
 drivers/net/vxlan.c                |   3 +-
 include/net/netlink.h              | 144 ++++++++++++++++++++++++++++++++-----
 include/net/rtnetlink.h            |  37 ++++++++--
 include/uapi/linux/netlink.h       |   1 +
 lib/nlattr.c                       |  56 +++++++++------
 net/8021q/vlan_netlink.c           |  12 ++--
 net/bridge/br_netlink.c            |   3 +-
 net/core/rtnetlink.c               | 143 ++++++++++++++++++++++--------------
 net/core/sock_diag.c               |   2 +-
 net/ieee802154/6lowpan/core.c      |   3 +-
 net/ipv4/devinet.c                 |   6 +-
 net/ipv4/ip_gre.c                  |   8 ++-
 net/ipv4/ip_vti.c                  |   3 +-
 net/ipv6/addrconf.c                |   6 +-
 net/ipv6/ip6_gre.c                 |   8 ++-
 net/ipv6/ip6_tunnel.c              |   3 +-
 net/ipv6/ip6_vti.c                 |   3 +-
 net/ipv6/sit.c                     |   3 +-
 net/netfilter/nfnetlink.c          |   6 +-
 net/netlink/af_netlink.c           |  14 +++-
 net/netlink/genetlink.c            |   2 +-
 net/xfrm/xfrm_user.c               |   2 +-
 35 files changed, 371 insertions(+), 144 deletions(-)

-- 
1.8.3.1
