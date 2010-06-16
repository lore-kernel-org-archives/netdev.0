From: Nick Piggin <npiggin@suse.de>
Subject: rt hash table / rt hash locks question
Date: Wed, 16 Jun 2010 20:46:33 +1000
Message-ID: <20100616104633.GW6138@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44813 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0FPKqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 06:46:37 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	by mx2.suse.de (Postfix) with ESMTP id E6BF88980B
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 12:46:35 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm just converting this scalable dentry/inode hash table to a more
compact form. I was previously using a dumb spinlock per bucket,
but this doubles the size of the tables so isn't production quality.

What I've done at the moment is to use a bit_spinlock in bit 0 of each
list pointer of the table. Bit spinlocks are now pretty nice because
we can do __bit_spin_unlock() which gives non-atomic store with release
ordering, so it should be almost as fast as spinlock.

But I look at rt hash and it seems you use a small hash on the side
for spinlocks. So I wonder, pros for each:

- bitlocks have effectively zero storage
- bitlocks hit the same cacheline that the hash walk hits.
- in RCU list, locked hash walks usually followed by hash modification,
  bitlock should have brought in the line for exclusive.
- bitlock number of locks scales with hash size
- spinlocks may be slightly better at the cacheline level (bitops
  sometimes require explicit load which may not acquire exclusive
  line on some archs). On x86 ll/sc architectures, this shouldn't
  be a problem.
- spinlocks better debugging (could be overcome with a LOCKDEP
  option to revert to spinlocks, but a bit ugly).
- in practice, contention due to aliasing in buckets to lock mapping
  is probably fairly minor.

Net code is obviously tested and tuned well, but instinctively I would
have tought bitlocks are the better way to go. Any comments on this?

Thanks,
Nick

