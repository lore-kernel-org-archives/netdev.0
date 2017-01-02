From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH nf-next 0/7] xtables: use dedicated copy_to_user helpers
Date: Mon,  2 Jan 2017 17:19:39 -0500
Message-ID: <1483395586-105774-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de,
        dborkman@iogearbox.net, pablo@netfilter.org,
        Willem de Bruijn <willemb@google.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:32998 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933434AbdABWT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

xtables list and save interfaces share xt_match and xt_target state
with userspace. The kernel and userspace definitions of these structs
differ. Currently, the structs are copied wholesale, then patched up.
The match and target structs contain a kernel pointer. Type-specific
data may contain additional kernel-only state.

Introduce xt_match_to_user and xt_target_to_user helper functions to
copy only fields intended to be shared with userspace.

Introduce xt_data_to_user to do the same for type-specific state. Add
a field .usersize to xt_match and xt_target to define the range of
bytes in .matchsize that should be shared with userspace. All matches
and targets that define kernel-only data store this at the tail of
their struct.

Tested:

  Ran iptables-test.py from iptables.git, with both a 64-bit and
  32-bit compat binary. 603/603 tests passed both before and after
  the patches (out of 705, but some CONFIGs were not enabled).

  Also ran the following example queries manually, again using 64-bit
  and 32-bit compat paths:

  iptables -A INPUT  -m string --algo bm --string 'xxx' -j LOG
  iptables -L
  iptables-save

  ip6tables -A INPUT  -m string --algo bm --string 'xxx' -j LOG
  ip6tables -L
  ip6tables-save

  ebtables -A INPUT --limit 3 -j ACCEPT
  ebtables -L

  arptables -A INPUT --source-mac 00:11:22:33:44:55 -j ACCEPT
  arptables -L

  An instrumented binary that initializes its buffer with 0x66 bytes
  shows the result of the patchset.

  iptables LOG target in hex before and after. The xt_target struct
  only has its size, name and revision specified. Trailing bytes in
  the name field are not zeroed:

    40 00 4c 4f 47 00 00 00
    40 e1 0a a0 ff ff ff ff
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    04 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00

    40 00 4c 4f 47 00 66 66
    66 66 66 66 66 66 66 66
    66 66 66 66 66 66 66 66
    66 66 66 66 66 66 66 00
    04 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00

  ebtables limit match in hex before and after. Only the avg and burst
  fields of ebt_limit_info are shared.

    6c 69 6d 69 74 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    20 00 00 00 00 00 00 00
    05 0d 00 00 05 00 00 00
    66 de fc ff 00 00 00 00
    50 d0 00 00 50 d0 00 00
    a9 29 00 00 00 00 00 00

    6c 69 6d 69 74 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    20 00 00 00 00 00 00 00
    05 0d 00 00 05 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00


Willem de Bruijn (7):
  xtables: add xt_match, xt_target and data copy_to_user functions
  iptables: use match, target and data copy_to_user helpers
  ip6tables: use match, target and data copy_to_user helpers
  arptables: use match, target and data copy_to_user helpers
  ebtables: use match, target and data copy_to_user helpers
  xtables: use match, target and data copy_to_user helpers in compat
  xtables: extend matches and targets with .usersize

 include/linux/netfilter/x_tables.h |  9 +++++
 net/bridge/netfilter/ebt_limit.c   |  1 +
 net/bridge/netfilter/ebtables.c    | 78 +++++++++++++++++++++++---------------
 net/ipv4/netfilter/arp_tables.c    | 15 +++-----
 net/ipv4/netfilter/ip_tables.c     | 21 +++-------
 net/ipv4/netfilter/ipt_CLUSTERIP.c |  1 +
 net/ipv6/netfilter/ip6_tables.c    | 21 +++-------
 net/ipv6/netfilter/ip6t_NPT.c      |  2 +
 net/netfilter/x_tables.c           | 68 ++++++++++++++++++++++++++++-----
 net/netfilter/xt_CT.c              |  3 ++
 net/netfilter/xt_RATEEST.c         |  1 +
 net/netfilter/xt_TEE.c             |  2 +
 net/netfilter/xt_bpf.c             |  2 +
 net/netfilter/xt_cgroup.c          |  1 +
 net/netfilter/xt_connlimit.c       |  1 +
 net/netfilter/xt_hashlimit.c       |  4 ++
 net/netfilter/xt_limit.c           |  2 +
 net/netfilter/xt_quota.c           |  1 +
 net/netfilter/xt_rateest.c         |  1 +
 net/netfilter/xt_string.c          |  1 +
 20 files changed, 154 insertions(+), 81 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
