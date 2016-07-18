From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v5 0/5] Big C99 style initializer rework
Date: Mon, 18 Jul 2016 16:48:40 +0200
Message-ID: <1468853325-9260-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39712 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbcGROta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 10:49:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v5 of my C99-style initializer related patch series. The changes
since v4 are:

- Rebased to current origin/master with just a minor context conflict in
  patch 2.

For reference, here's the v4 changelog:

- Use empty initializer instead of the universal zero initializer:
  The latter one triggers warnings in older GCCs, and this appears to
  be the least intrusive workaround. Plus, empty initializers are used
  all over the code already, so it won't make things worse. (GCC in
  pedantic mode does not like them, but that is a can of worms by
  itself.)

- Dropped patch 6 (unsigned value comparison simplification):
  It unintendedly changes that comparison's semantics, and I am not
  completely sure the change is correct - therefore rather leave it as
  is.

- Rebased onto current origin/master again (no conflicts).

For reference, here's the v3 changelog:

- Flattened embedded struct's initializers:
  Since the field names are very short, I figured it makes more sense to
  keep indenting low. Also, the same style is already used in
  ip/xfrm_policy.c so take that as an example.

- Moved leftover nlmsg_seq initializing into the common place as well:
  I was unsure whether this is a good idea at first (due to the
  increment), but again it's done in ip/xfrm_policy.c as well so should
  be fine.

- Added a comma after the last field initializer as suggested by Jakub.

- Dropped patch 7 since it was NACKed.

- Eliminated checkpatch non-compliance.

- Second go at union bpf_attr in tc/tc_bpf.c:
  I figured that while it is not possible to initialize fields, gcc-3.4.6
  does not complain when setting the whole union to zero using '= {0}'.
  So I did this and thereby at least got rid of the memset calls.

For reference, here's the v2 changelog:

- Rebased onto current upstream master:
  My own commit a0a73b298a579 ("tc: m_action: Use C99 style initializers
  for struct req") contains most of the changes to tc/m_action.c already,
  so I put the remaining ones into a dedicated patch (the first one here)
  with a better description.

- Tested against gcc-3.4.6:
  This is the oldest gcc version I was able to install locally. It indeed
  does not like the former changes in tc/tc_bpf.c, so I reverted them.
  Apart from emitting many warnings, it successfully compiles the
  sources.

In the process of compatibility testing, I made a few more changes which
make sense to have:

- New patch 5 allows to conveniently override the compiler via command
  line.

- New patch 6 eliminates a warning with old gcc but looks valid in
  general.

- A warning made me look at ip/tcp_metrics.c and I found a minor code
  simplification (patch 7).


Phil Sutter (5):
  tc: m_action: Improve conversion to C99 style initializers
  Use C99 style initializers everywhere
  Replace malloc && memset by calloc
  No need to initialize rtattr fields before parsing
  Makefile: Allow to override CC

 Makefile           |   4 +-
 bridge/fdb.c       |  25 ++++++------
 bridge/link.c      |  14 +++----
 bridge/mdb.c       |  17 ++++-----
 bridge/vlan.c      |  17 ++++-----
 genl/ctrl.c        |  44 +++++++++------------
 genl/genl.c        |   3 +-
 ip/ip6tunnel.c     |  10 ++---
 ip/ipaddress.c     |  33 +++++++---------
 ip/ipaddrlabel.c   |  21 ++++------
 ip/iplink.c        |  61 ++++++++++++-----------------
 ip/iplink_can.c    |   4 +-
 ip/ipmaddr.c       |  25 ++++--------
 ip/ipmroute.c      |   8 +---
 ip/ipneigh.c       |  30 ++++++---------
 ip/ipnetconf.c     |  10 ++---
 ip/ipnetns.c       |  39 +++++++++----------
 ip/ipntable.c      |  25 ++++--------
 ip/iproute.c       |  78 +++++++++++++------------------------
 ip/iprule.c        |  22 +++++------
 ip/iptoken.c       |  19 ++++-----
 ip/iptunnel.c      |  31 +++++----------
 ip/ipxfrm.c        |  26 ++++---------
 ip/link_gre.c      |  18 ++++-----
 ip/link_gre6.c     |  18 ++++-----
 ip/link_ip6tnl.c   |  25 +++++-------
 ip/link_iptnl.c    |  22 +++++------
 ip/link_vti.c      |  18 ++++-----
 ip/link_vti6.c     |  18 ++++-----
 ip/xfrm_policy.c   |  99 +++++++++++++++++++----------------------------
 ip/xfrm_state.c    | 110 ++++++++++++++++++++++-------------------------------
 lib/libnetlink.c   |  77 ++++++++++++++-----------------------
 lib/ll_map.c       |   1 -
 lib/names.c        |   7 +---
 misc/arpd.c        |  64 ++++++++++++++-----------------
 misc/lnstat.c      |   6 +--
 misc/lnstat_util.c |   4 +-
 misc/ss.c          |  37 +++++++-----------
 tc/e_bpf.c         |   7 +---
 tc/em_canid.c      |   4 +-
 tc/em_cmp.c        |   4 +-
 tc/em_ipset.c      |   4 +-
 tc/em_meta.c       |   4 +-
 tc/em_nbyte.c      |   4 +-
 tc/em_u32.c        |   4 +-
 tc/f_flow.c        |   3 --
 tc/f_flower.c      |   3 +-
 tc/f_fw.c          |   6 +--
 tc/f_route.c       |   3 --
 tc/f_rsvp.c        |   6 +--
 tc/f_u32.c         |  12 ++----
 tc/m_action.c      |  26 ++++---------
 tc/m_bpf.c         |   5 +--
 tc/m_csum.c        |   4 +-
 tc/m_ematch.c      |   4 +-
 tc/m_gact.c        |   5 +--
 tc/m_ife.c         |   5 +--
 tc/m_ipt.c         |  13 ++-----
 tc/m_mirred.c      |   7 +---
 tc/m_nat.c         |   4 +-
 tc/m_pedit.c       |  11 ++----
 tc/m_police.c      |   5 +--
 tc/q_atm.c         |   3 +-
 tc/q_cbq.c         |  22 +++--------
 tc/q_choke.c       |   4 +-
 tc/q_codel.c       |   3 +-
 tc/q_dsmark.c      |   1 -
 tc/q_fifo.c        |   4 +-
 tc/q_fq_codel.c    |   3 +-
 tc/q_hfsc.c        |  13 ++-----
 tc/q_htb.c         |  15 +++-----
 tc/q_netem.c       |  16 +++-----
 tc/q_red.c         |   4 +-
 tc/q_sfb.c         |  17 ++++-----
 tc/q_sfq.c         |   4 +-
 tc/q_tbf.c         |   4 +-
 tc/tc.c            |   9 ++---
 tc/tc_bpf.c        |  58 ++++++++++------------------
 tc/tc_class.c      |  38 +++++++-----------
 tc/tc_exec.c       |   6 +--
 tc/tc_filter.c     |  33 ++++++----------
 tc/tc_qdisc.c      |  33 ++++++----------
 tc/tc_stab.c       |   4 +-
 tc/tc_util.c       |   3 +-
 84 files changed, 564 insertions(+), 976 deletions(-)

-- 
2.8.2
