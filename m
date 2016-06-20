From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [PATCH v4 00/19] CALIPSO Implementation
Date: Mon, 20 Jun 2016 14:36:40 +0100
Message-ID: <1466429819-12707-1-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patch series implements RFC 5570 - Common Architecture Label IPv6
Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
on IPv6 packets using a hop-by-hop option.  CALIPSO is very similar to
its IPv4 cousin CIPSO and much of this series is based on that code.

To use this you'll need some patches to netlabel-tools that are
available on the 'working-calipso-v3' branch at:
https://github.com/netlabel/netlabel_tools .  The protocol has
changed very slightly from the v2 patches, so please update to the
latest if you haven't already done so.

This implementation has been tested against the CALIPSO implementation
of Solaris Trusted Extensions.

This patch series is based off v4.6.

Thanks to Paul Moore, Hannes Frederic Sowa, Casey Schaufler and Julia
Lawall for their comments so far.

Changes between v4 and v3:
* Fix function header comment for calipso_validate().
* Rebased to v4.6.

Changes between v3 and v2:

* Change CALIPSO_MAP_PASS to 2.
* Move calipso_init() before ipv6_sysctl_register().
* Rewrite calipso_tlv_len() to check for overflows.
* Simplify calispo_opt_find().
* Simplify calipso_opt_insert().
* Use calipso_tlv_len() in calipso_sock_getattr().
* Simplify calipso_skbuff_setattr().
* Return early from netlbl_domhsh_search_def() when a match is found.
* Remove nested if from netlbl_domhsh_validate().
* Don't return from netlbl_domhsh_add() with lock held.
* Various style changes.
* Rebased to v4.5-rc4.

Changes between v2 and v1:

* Simplify ipv6_renew_options_kern() to use set_fs(KERNEL_DS).
  Thanks to Hannes Frederic Sowa for suggesting this.
* Use the parent socket to account for the listener socket
  option's memory usage.  Again, thanks for Hannes for this.
* Added netlbl_cfg_calipso_* functions for SMACK.
* Rebased to v4.4-rc8.

Huw Davies (19):
  netlabel: Mark rcu pointers with __rcu.
  netlabel: Add an address family to domain hash entries.
  netlabel: Initial support for the CALIPSO netlink protocol.
  netlabel: Add support for querying a CALIPSO DOI.
  netlabel: Add support for enumerating the CALIPSO DOI list.
  netlabel: Add support for creating a CALIPSO protocol domain mapping.
  netlabel: Add support for removing a CALIPSO DOI.
  ipv6: Add ipv6_renew_options_kern() that accepts a kernel mem pointer.
  netlabel: Move bitmap manipulation functions to the NetLabel core.
  calipso: Set the calipso socket label to match the secattr.
  netlabel: Prevent setsockopt() from changing the hop-by-hop option.
  ipv6: Allow request socks to contain IPv6 options.
  calipso: Allow request sockets to be relabelled by the lsm.
  ipv6: constify the skb pointer of ipv6_find_tlv().
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
 net/ipv6/calipso.c                  | 1473 +++++++++++++++++++++++++++++++++++
 net/ipv6/exthdrs.c                  |   76 ++
 net/ipv6/exthdrs_core.c             |    2 +-
 net/ipv6/ipv6_sockglue.c            |    1 -
 net/ipv6/sysctl_net_ipv6.c          |   19 +
 net/ipv6/tcp_ipv6.c                 |   12 +-
 net/netlabel/Kconfig                |    1 +
 net/netlabel/Makefile               |    2 +-
 net/netlabel/netlabel_calipso.c     |  740 ++++++++++++++++++
 net/netlabel/netlabel_calipso.h     |  151 ++++
 net/netlabel/netlabel_domainhash.c  |  293 +++++--
 net/netlabel/netlabel_domainhash.h  |   17 +-
 net/netlabel/netlabel_kapi.c        |  385 ++++++++-
 net/netlabel/netlabel_mgmt.c        |   85 +-
 net/netlabel/netlabel_mgmt.h        |   27 +-
 net/netlabel/netlabel_unlabeled.c   |    5 +-
 net/netlabel/netlabel_user.c        |    5 +
 security/selinux/hooks.c            |   21 +-
 security/selinux/include/netlabel.h |    4 +-
 security/selinux/netlabel.c         |   36 +-
 security/smack/smack_lsm.c          |    2 +-
 32 files changed, 3479 insertions(+), 203 deletions(-)
 create mode 100644 include/net/calipso.h
 create mode 100644 net/ipv6/calipso.c
 create mode 100644 net/netlabel/netlabel_calipso.c
 create mode 100644 net/netlabel/netlabel_calipso.h

-- 
2.7.4

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
