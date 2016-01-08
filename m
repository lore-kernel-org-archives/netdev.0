From: Huw Davies <huw@codeweavers.com>
Subject: [RFC PATCH v2 00/18] CALIPSO Implementation
Date: Fri,  8 Jan 2016 09:52:36 +0000
Message-ID: <1452246774-13241-1-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series implements RFC 5570 - Common Architecture Label IPv6
Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
on IPv6 packets using a hop-by-hop option.  CALIPSO is very similar to
its IPv4 cousin CIPSO and much of this series is based on that code.

I'm particularly interested in feedback relating to adding
struct ipv6_txoptions* to struct inet_request_sock.
(ipv6: Allow request socks to contain IPv6 options.)

Thoughts about this or any of the other patches are most welcome.

If anybody actually wants to play with this, then you'll need some patches
to netlabel-tools that are currently available on the 'calipso' branch at:
https://github.com/hdmdavies/netlabel_tools.git

Thanks to Paul Moore, Hannes Frederic Sowa and Casey Schaufler for their
comments so far.

Changes between v2 and v1:

* Simplify ipv6_renew_options_kern() to use set_fs(KERNEL_DS).
  Thanks to Hannes Frederic Sowa for suggesting this.

* Use the parent socket to account for the listener socket
  option's memory usage.  Again, thanks for Hannes for this.

* Added netlbl_cfg_calipso_* functions for SMACK.

* Rebased to v4.4-rc8.

Huw Davies (18):
  netlabel: Mark rcu pointers with __rcu.
  netlabel: Add an address family to domain hash entries.
  netlabel: Initial support for the CALIPSO netlink protocol.
  netlabel: Add support for querying a CALIPSO DOI.
  netlabel: Add support for enumerating the CALIPSO DOI list.
  netlabel: Add support for creating a CALIPSO protocol domain mapping.
  netlabel: Add support for removing a CALIPSO DOI.
  ipv6: Add ipv6_renew_options_kern() that accepts a kernel mem
    pointer.
  netlabel: Move bitmap manipulation functions to the NetLabel core.
  calipso: Set the calipso socket label to match the secattr.
  netlabel: Prevent setsockopt() from changing the hop-by-hop option.
  ipv6: Allow request socks to contain IPv6 options.
  calipso: Allow request sockets to be relabelled by the lsm.
  calipso: Allow the lsm to label the skbuff directly.
  netlabel: Pass a family parameter to netlbl_skbuff_err().
  calipso: Add validation of CALIPSO option.
  calipso: Add a label cache.
  netlabel: Implement CALIPSO config functions for SMACK.

 include/net/calipso.h               |   91 +++
 include/net/inet_sock.h             |    7 +-
 include/net/ipv6.h                  |   10 +-
 include/net/netlabel.h              |  101 ++-
 include/uapi/linux/audit.h          |    2 +
 include/uapi/linux/in6.h            |    1 +
 net/dccp/ipv6.c                     |   12 +-
 net/ipv4/cipso_ipv4.c               |   88 +--
 net/ipv4/tcp_input.c                |    3 +
 net/ipv6/Makefile                   |    1 +
 net/ipv6/af_inet6.c                 |    9 +-
 net/ipv6/calipso.c                  | 1487 +++++++++++++++++++++++++++++++++++
 net/ipv6/exthdrs.c                  |   76 ++
 net/ipv6/exthdrs_core.c             |    2 +-
 net/ipv6/ipv6_sockglue.c            |    1 -
 net/ipv6/sysctl_net_ipv6.c          |   19 +
 net/ipv6/tcp_ipv6.c                 |   12 +-
 net/netlabel/Kconfig                |    1 +
 net/netlabel/Makefile               |    2 +-
 net/netlabel/netlabel_calipso.c     |  744 ++++++++++++++++++
 net/netlabel/netlabel_calipso.h     |  153 ++++
 net/netlabel/netlabel_domainhash.c  |  281 +++++--
 net/netlabel/netlabel_domainhash.h  |   17 +-
 net/netlabel/netlabel_kapi.c        |  385 ++++++++-
 net/netlabel/netlabel_mgmt.c        |   86 +-
 net/netlabel/netlabel_mgmt.h        |   27 +-
 net/netlabel/netlabel_unlabeled.c   |    5 +-
 net/netlabel/netlabel_user.c        |    5 +
 security/selinux/hooks.c            |   21 +-
 security/selinux/include/netlabel.h |    4 +-
 security/selinux/netlabel.c         |   36 +-
 security/smack/smack_lsm.c          |    2 +-
 32 files changed, 3492 insertions(+), 199 deletions(-)
 create mode 100644 include/net/calipso.h
 create mode 100644 net/ipv6/calipso.c
 create mode 100644 net/netlabel/netlabel_calipso.c
 create mode 100644 net/netlabel/netlabel_calipso.h

-- 
1.8.0

