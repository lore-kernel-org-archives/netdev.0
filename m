From: linux@horizon.com
Subject: Extensible hashing and RCU
Date: 4 Feb 2007 02:41:43 -0500
Message-ID: <20070204074143.26312.qmail@science.horizon.com>
Cc: linux@horizon.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:10576 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752154AbXBDH5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 02:57:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed in an LCA talk mention that apprently extensible hashing
with RCU access is an unsolved problem.  Here's an idea for solving it.

I'm assuming the table is a power of 2 in size with open chaining
for collisions.  When the chains get too long, the table is doubled.
When the chains get too short, the table size is halved.

- Compute a sufficiently large (32-bit?) hash value for each entry.
  "Sufficiently large" is large enough for the largest possible hash table.

- The hash value is stored with each entry.  (Not strictly
  necessary if the update rate is sufficiently low.)

- The table is indexed on the *high* bits of the hash value.
  As it grows, additional bits are appended to the hash value.

- Each chain is stored in sorted order by hash value.
  (This is why storing the hash value is an efficiency win.)

To double the size of a hash table:
- Allocate new, larger, array of head pointers.
- The even slots are copied from the smaller hash table.
- The odd slots are initialized to point to the middle of
  the hash chains pointed to by the odd slots.  However, the
  even chains are NOT terminated yet; a search through one of
  them will go through the full chain length.
- The new table is declared open for business.
- Wait for RCU quiescent period to elapse, so there are no more readers
  of the old table.
- NOW truncate the even chains by setting the next pointers to NULL.
- Deallocate and free the old array of head pointers.

Likewise, to halve the size, copy the even heads to a smaller table,
link the odd heads onto the tails of the even chains, copy to
a smaller table, and declare it open for business.  When an RCU quiescent
period has elapsed, you can delete the old table.

Ths insight is that RCU makes taking stuff out of a linked list
very delicate, and moving it while preserving access is
basically impossible.  But you can append extraneous junk to the
end of a hash chain harmlessly enough and share the structure.

Thus, there is a period of overlap when both the old and the new hash
tables are valid and functional.

Indeed, after each of the above steps, you can actually allow new
insertions into the hash table while waiting for the RCU quiescent period.

If the insertion is at the head of chain, it won't be seen by readers
of the old table, but that's harmless.

The trickiest case I can think of is the deletion of a table
entry at the head of an odd chain while an expansion is pending.
When scanning the even chain afterwards to find where to truncate it,
you can't compare node->next to the odd chain head; you have to
look at the now deleted node's hash code and see that it exceeds
the threshold for the even chain.  (Equivalently, you can test to
see if the appropriate bit of the hash code is set.)

So that hash chain walking has to be done BEFORE the node is actually
deleted.  This requires an ordering guarantee on RCU callbacks, either
a priority system or FIFO.  call_rcu looks like it uses FIFO order,
but it's per-CPU lists.

Ah!  It's worse than that.  Even after the first RCU quiescent period,
there still could be a walker of the even chain holding a pointer to
the newly-deleted odd chain head.  Thus, it can't actually be reclaimed
until a *second* RCU quiescent period has elapsed.

The first RCU period is to get rid of anyone who needs the link, then you
remove it, then you need to wait until there's nobody who's still using it.

Still, it's probably not too horrible.


(You could index the hash table on the low-order bits, but then you
need to keep the chains sorted by bit-reversed hash value, which is
probably more of a pain.  Still pretty easy, though.  To compare x and
y bit-reversed, just let mask = x^y; mask ^= mask-1; compare (x&mask)
to (y&mask).)
