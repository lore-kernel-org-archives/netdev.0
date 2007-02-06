From: linux@horizon.com
Subject: Re: [RFC/TOY]Extensible hashing and RCU
Date: 6 Feb 2007 14:09:11 -0500
Message-ID: <20070206190911.23405.qmail@science.horizon.com>
References: <Pine.LNX.4.61.0702051030550.26852@localhost.localdomain>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: akepner@sgi.com, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:13317 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S965329AbXBFTJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 14:09:13 -0500
In-Reply-To: <Pine.LNX.4.61.0702051030550.26852@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For purposes of discussion, I've attached a "toy" implementation
> for doing dynamic resizing of a hashtable. It is useless, except
> as a proof of concept.
> 
> I think this is very similar to what you are describing, no?

Er... not quite; that has a lot more overhead than what I was
thinking about.

I have used the trick of distinguishable sentinel values in a
doubly-linked list to maintain read cursors while it's being updated,
but I don't think that's necessary here.

(You can also encode the nh_type flag in the lsbit of the pointer
if you're being sneaky.  That will attract curses from the
memleak detector, though.)

In particular, I was imagining a singly linked list.  To delete
an item, use the hash to find the head pointer and walk it
to find the pointer to be fixed up.  Since the chains are short
anyway, this is entirely reasonable.

Less fundamental comments include:

1) Is the seqlock in get_nh() and nh_replace() really required?
   Is there any architecture that doesn't have atomic pointer stores?
   If you wanted to store the table size in a fixed location as
   well, I could see the need...

2) I think the whole __nh_sort_chain business will royally confuse
   anyone walking the chain while it happens.  This is exactly
   what I was working to avoid.  The partial sorting in __nh_insert
   isn't good enough.

   Instead, try:

/* Return true if bitrev(x) > bitrev(y) */
static bool bitrev_gt(unsigned long x, unsinged long y)
{
	/* Identify the bits that differ between x and y */
	unsigned long mask = x ^ y;	/* Find the bits that differ */
	mask ^= mask-1;	/* Find lsbit of difference (and all lower bits) */
	return (x & mask) > (y & mask);
}

static void __nh_insert(struct nh_entry *entry, struct nh_head *head)
{
	struct list_head *p, *n;
	unsigned long const hashval = nh_hashval(entry->data);

	/*
	 * Insert the new entry just before the first element of the list
	 * that its hash value is not greater than (bit-reversed).
	 */
	p = &head->list;
	list_for_each_rcu(n, &head->list) {
		struct nh_entry *t = container_of(n, struct nh_entry, nh_list);
		if (t->nh_type == NH_ENTRY &&
		    !bitrev_gt(hashval, nh_hashval(t->data)))
			break;
		p = n;
	}
	__list_add_rcu(&entry->nh_list, p, n);
}

static int nh_add(unsigned long data)
{
	struct nh_entry *entry = kmalloc(sizeof *entry, GFP_KERNEL);
	struct nh *nh;

	if (!entry) return -ENOMEM;

	entry->nh_type = NH_ENTRY;
	entry->data = data;

	rcu_read_lock();

	nh = get_nh();	/* or nh = __nh */

	if (nh) {
		struct nh_head *h = \
			&nh->hash[ nh_bucket(nh_hashval(data), nh->nentries) ];

		spin_lock(&h->lock);
		__nh_insert(entry, h);
		spin_unlock(&h->lock);
	}
	rcu_read_unlock();
		
		
}

   Then there's no need for __nh_sort_chain at all.  Alternatively, if the
   upper bits of nh_hashval are as good as the lower bits, just index the
   hash table on them.

3) Code inside a mutex like nh_resize() can use plain list_for_each();
   the _rcu variant is only required if there can be simultaneous
   mutation.

That's a nice module framework.  I'll see if I can write some code
of the sort I was thinking about.

FWIW, I figured out a way around the need to delay deletion for two
RCU intervals.

Suppose that an expansion is pending, and we have just stretched the
table from 16 entries to 32, and the following hash values are
stored.  (Note the bit-reversed order.)

old[3] --\   
new[3] ---+-> 0x03 -> 0x43 -> 0x23 -> 0x63 -> 0x13 -> 0x53 -> 0x33 -> 0x73
                                             /
                        new[3+16]-----------/

After an RCU period, you can throw away the old[] array and NUL-terminate
the new[i] list after 0x63.  But until then, you need to leave the list alone
to accomodate people who are looking for 0x53 via the old head.

The tricky case comes when you delete 0x13.  If you only delete it from the
new[3+16] list, you can't discard it until the RCU quiescent period
after the one which dicsonnects the 0x63->0x13 link.

The solution is actually very simple: notice when you're
- Deleting the first entry in a list
- While an expension is pending
- And the list is in the second half of the expanded table
then unlink the entry from BOTH the new head and the old list.
It's a bit more work, and requires some lock-ordering care, but
it lets you queue the node for RCU cleanup the normal way.
