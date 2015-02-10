From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH 0/3] nft hash set expansion fixes
Date: Mon,  9 Feb 2015 19:48:28 -0500
Message-ID: <1423529311-26050-1-git-send-email-johunt@akamai.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Josh Hunt <johunt@akamai.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:15891 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756380AbbBJAsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 19:48:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset resolves some issues I've come across while investigating nft hash
sets.

The first patch requires users of rhashtable to define a max_shift as suggested
by Daniel Borkmann and Thomas Graf. One side-effect of not setting max_shift is
that tables are not allowed to expand. I was observing this behavior with nft
hash sets prior to these changes.

The next patch implements this requirement for nft hash sets using desc->size as
the max_shift if it's provided by the user. If not, it falls back to a newly
defined default of 1024 elements. This value is somewhat arbitrary, but seems
like a reasonable default to me.

I used 'size' above for max_shift because it appears to be used as a ceiling for
the number of elements in a set in nft_add_set_elem(). It's also used in the
estimate fn. Prior to the next patch 'size' was also being used as the nelem_hint
to pass to rhashtable_init(). This seems incorrect since nelem_hint is meant to
provide a hint for how many hash buckets to initially allocate.

Instead of using 'size' for nelem_hint, the final patch introduces a new set
parameter named 'init_size'. If this approach is acceptable I can provide the
userspace patches to fully implement the new parameter.

The patchset is against net-next.

Josh Hunt (3):
  rhashtable: require max_shift definition
  nft_hash: define max_shift rhashtable param
  nft_hash: introduce init_size set parameter

 include/net/netfilter/nf_tables.h        |    4 +++-
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 lib/rhashtable.c                         |    3 ++-
 net/netfilter/nf_tables_api.c            |    4 ++++
 net/netfilter/nft_hash.c                 |    7 ++++++-
 5 files changed, 17 insertions(+), 3 deletions(-)

-- 
1.7.9.5
