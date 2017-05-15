From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bpf: Track alignment of MAP pointers in verifier.
Date: Mon, 15 May 2017 11:34:19 -0400 (EDT)
Message-ID: <20170515.113419.1265777991542814689.davem@davemloft.net>
References: <59186A2E.2010904@iogearbox.net>
        <20170514.210005.2210026226038557615.davem@davemloft.net>
        <5919A8AA.9010401@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934637AbdEOPeY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 11:34:24 -0400
In-Reply-To: <5919A8AA.9010401@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 15 May 2017 15:10:02 +0200

>>> What are the semantics of using id here? In ptr_to_pkt, we have it,
>>> so that eventually, in find_good_pkt_pointers() we can match on id
>>> and update the range for all such regs with the same id. I'm just
>>> wondering as the side effect of this is that this makes state
>>> pruning worse.

Daniel, I looked at the state pruning for maps.  The situation is
quite interesting.

Once we have env->varlen_map_value_access (and load or store via a
PTR_TO_MAP_VALUE_ADJ pointer), the state pruning gets more strict, the
relevant tests are:

		if (memcmp(rold, rcur, sizeof(*rold)) == 0)
			continue;

		/* If the ranges were not the same, but everything else was and
		 * we didn't do a variable access into a map then we are a-ok.
		 */
		if (!varlen_map_access &&
		    memcmp(rold, rcur, offsetofend(struct bpf_reg_state, id)) == 0)
			continue;

The first memcmp() is not going to match any time we adjust any
component of a MAP pointer reg.  The offset, the alignment, anything.
That means any side effect whatsoever performed by check_pointer_add()
even if we changed the code to not modify reg->id

The second check elides:

	s64 min_value;
	u64 max_value;
	u32 min_align;
	u32 aux_off;
	u32 aux_off_align;

from the comparison but only if we haven't done a variable length
MAP access.

The only conclusion I can come to is that changing reg->id for
PTR_TO_MAP_VALUE_ADJ has no side effect for state pruning, unless we
perform PTR_TO_MAP_VALUE_ADJ register adjustments without ever
accessing the map via that pointer in the entire program.

I could add some new state to avoid the reg->id change, but given
the above I don't think that it is really necessary.
