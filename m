From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/7] Big C99 style initializer rework
Date: Tue, 21 Jun 2016 18:18:34 +0200
Message-ID: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51875 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbcFUQ1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 12:27:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v2 of my C99-style initializer related patch series. The changes
since v1 are:

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

I have a follow-up series of patches which get rid of every warning
gcc-3.4.6 emits, but am not sure whether they make sense to keep. I would
appreciate if you could review them here:
http://nwl.cc/cgi-bin/git/gitweb.cgi?p=iproute2.git;a=shortlog;h=refs/heads/c99_init

Phil Sutter (7):
  tc: m_action: Improve conversion to C99 style initializers
  Use C99 style initializers everywhere
  Replace malloc && memset by calloc
  No need to initialize rtattr fields before parsing
  Makefile: Allow to override CC
  misc/ifstat: simplify unsigned value comparison
  ip/tcp_metrics: Simplify process_msg a bit

 Makefile           |   4 +-
 bridge/fdb.c       |  29 ++++++------
 bridge/link.c      |  16 +++----
 bridge/mdb.c       |  19 ++++----
 bridge/vlan.c      |  19 ++++----
 genl/ctrl.c        |  48 +++++++++-----------
 genl/genl.c        |   3 +-
 ip/ip6tunnel.c     |  10 ++---
 ip/ipaddress.c     |  33 ++++++--------
 ip/ipaddrlabel.c   |  23 +++++-----
 ip/iplink.c        |  67 +++++++++++++---------------
 ip/iplink_can.c    |   4 +-
 ip/ipmaddr.c       |  27 +++++------
 ip/ipmroute.c      |   8 +---
 ip/ipneigh.c       |  36 +++++++--------
 ip/ipnetconf.c     |  12 ++---
 ip/ipnetns.c       |  45 ++++++++++---------
 ip/ipntable.c      |  27 +++++------
 ip/iproute.c       |  85 +++++++++++++++--------------------
 ip/iprule.c        |  26 +++++------
 ip/iptoken.c       |  21 ++++-----
 ip/iptunnel.c      |  31 ++++---------
 ip/ipxfrm.c        |  26 +++--------
 ip/link_gre.c      |  22 ++++-----
 ip/link_gre6.c     |  22 ++++-----
 ip/link_ip6tnl.c   |  29 ++++++------
 ip/link_iptnl.c    |  26 +++++------
 ip/link_vti.c      |  22 ++++-----
 ip/link_vti6.c     |  22 ++++-----
 ip/tcp_metrics.c   |  45 ++++++++-----------
 ip/xfrm_policy.c   | 110 +++++++++++++++++++++------------------------
 ip/xfrm_state.c    | 128 ++++++++++++++++++++++++++---------------------------
 lib/libnetlink.c   |  74 +++++++++++++------------------
 lib/ll_map.c       |   1 -
 lib/names.c        |   7 +--
 misc/arpd.c        |  68 ++++++++++++++--------------
 misc/ifstat.c      |   2 +-
 misc/lnstat.c      |   6 +--
 misc/lnstat_util.c |   4 +-
 misc/ss.c          |  41 ++++++++---------
 tc/e_bpf.c         |   7 +--
 tc/em_canid.c      |   3 +-
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
 tc/f_u32.c         |  12 ++---
 tc/m_action.c      |  20 +++------
 tc/m_bpf.c         |   5 +--
 tc/m_csum.c        |   4 +-
 tc/m_ematch.c      |   4 +-
 tc/m_gact.c        |   5 +--
 tc/m_ife.c         |   5 +--
 tc/m_ipt.c         |  13 ++----
 tc/m_mirred.c      |   7 +--
 tc/m_nat.c         |   4 +-
 tc/m_pedit.c       |  11 ++---
 tc/m_police.c      |   5 +--
 tc/q_atm.c         |   3 +-
 tc/q_cbq.c         |  22 +++------
 tc/q_choke.c       |   4 +-
 tc/q_codel.c       |   3 +-
 tc/q_dsmark.c      |   1 -
 tc/q_fifo.c        |   4 +-
 tc/q_fq_codel.c    |   3 +-
 tc/q_hfsc.c        |  13 ++----
 tc/q_htb.c         |  15 +++----
 tc/q_netem.c       |  16 +++----
 tc/q_red.c         |   4 +-
 tc/q_sfb.c         |  17 ++++---
 tc/q_sfq.c         |   4 +-
 tc/q_tbf.c         |   4 +-
 tc/tc.c            |   9 ++--
 tc/tc_bpf.c        |  51 +++++++++------------
 tc/tc_class.c      |  40 +++++++----------
 tc/tc_exec.c       |   6 +--
 tc/tc_filter.c     |  35 ++++++---------
 tc/tc_qdisc.c      |  35 ++++++---------
 tc/tc_stab.c       |   4 +-
 tc/tc_util.c       |   3 +-
 86 files changed, 706 insertions(+), 984 deletions(-)

-- 
2.8.2
