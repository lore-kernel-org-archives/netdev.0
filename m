From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 13:39:49 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <87he70re62.fsf@deneb.enyo.de>
References: <87adda6uro.fsf@deneb.enyo.de>
	<20030526.002934.132904126.davem@redhat.com>
	<87wuge59w2.fsf@deneb.enyo.de>
	<20030526.233211.54217447.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030526.233211.54217447.davem@redhat.com> (David S. Miller's
 message of "Mon, 26 May 2003 23:32:11 -0700 (PDT)")
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

>    Of course, this will result in vastly decreased functionality (no
>    arbitary netmasks, no policy-based routing, code will be fine-tuned
>    for typical Internet routing tables), so this proposal definitely
>    comes at a price.
>
> As a general purpose operating system, where people DO in fact use
> these features quite regularly,

Even non-CIDR netmasks?  AFAIK, it's hard to find dedicated networking
devices (and routing protocols!) which support them. 8-/

Anyway, I've played a bit with something inspired by CEF (more
precisely speaking, one diagram in the IOS internals book and some IOS
diagnostic output).

Basically, it's a 256-way trie, with "adjacency information" at the
leaves (consisting of L2 addressing information and the prefix
length).  The leaves contain a full list of child nodes which
reference to the leaf itself.  This allows for branch-free routing
(see below). (A further optimization would not allocate the
self-referencing pointers for leaves which are at the fourth layer of
the trie, but this is unlikely to have a hughe performance impact.)

The trie has 7862 internal nodes for my copy of the Internet routing
table, which amounts to 8113584 bytes (excluding memory management
overhead, twice the value for 64 bit architectures).  The numer of
internal nodes does not depend on the number of interfaces/peerings,
and prefix filtering based on their lengths (/27 or even /24) doesn't
make a huge difference either.

For each adjacency, space for the L2 addressing information is
required plus 256 pointers for the self-references (of course, for
each relevant prefix length, so you have a few kilobytes for a typical
peering).

The routing function looks like this:

struct cef_entry *
cef_route (struct cef_table *table, ipv4_t address)
{
	unsigned char octet1 = address >> 24;
	unsigned char octet2 = (address >> 16) & 0xFF;
	unsigned char octet3 = (address >> 8) & 0xFF;
	unsigned char octet4 = address & 0xFF;
			
	struct cef_entry * entry1 = table->children[octet1];
	struct cef_entry * entry2 = entry1->table[octet2];
	struct cef_entry * entry3 = entry2->table[octet3];
	struct cef_entry * entry4 = entry3->table[octet4];

	return entry4;
}

For the full routing table with "maximum" adjacency information
(different L2 addressing information for each origin AS) and
"real-world" addresses (captured at the border of a medium-size
network, local addresses filtered), the function needs about 82 cycles
per routing decision on my Athlon XP (including function call
overhead).  For random addresses, we have 155 cycles.  In a simulation
of a moderate peering (only 94 adjacencies, simulated interfaces to
half a dozen AS concentrated in Germany), I measured 45 cycles per
routing decision for real-world traffic, and 70 cycles for random
addresses.  (More peerings result in more adjacencies which lead to
fewer cache hits.)

You can save 1K (or 2K on 64-bit architectures) per adjacency if you
introduce data-dependent branches:

struct cef_entry *
cef_route (struct cef_table *table, ipv4_t address)
{
	unsigned char octet1 = address >> 24;
	struct cef_entry * entry1 = table->children[octet1];

	if (entry1->prefix_length < 0) {
		unsigned char octet2 = (address >> 16) & 0xFF;
		struct cef_entry * entry2 = entry1->table[octet2];
		if (entry2->prefix_length < 0) {
			unsigned char octet3 = (address >> 8) & 0xFF;
			struct cef_entry * entry3 = entry2->table[octet3];
			if (entry3->prefix_length < 0) {
				unsigned char octet4 = address & 0xFF;
				struct cef_entry * entry4 = entry3->table[octet4];
				return entry4;
			} else {
				return entry3;
			}
		} else {
			return entry2;
		}
	} else {
		return entry1;
	}
}

However, this decreases performance (even on my Athlon XP with just
256 KB cache).

At the moment, I've got a userspace prototype for simulations which
can build the trie and make routing decisions.  Removing entries is a
bit tricky and requires more data because formerly overridden prefixes
might have to be resurrected.  I'm unsure which data structures should
be used to solve this problem.  Memory management is a related
question, too.  And locking. *sigh*
