From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Tue, 12 Aug 2003 15:29:13 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030812142913.GB18802@mail.jlokier.co.uk>
References: <200307141045.40999.nf@hipac.org> <1058328537.1797.24.camel@jzny.localdomain> <3F16A0E5.1080007@hipac.org> <1059934468.1103.41.camel@jzny.localdomain> <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain> <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain> <3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Bellion and Thomas Heinz <nf@hipac.org>, hadi@cyberus.ca,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030811224050.59bc36fe.davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 12 Aug 2003 00:39:58 +0200
> Michael Bellion and Thomas Heinz <nf@hipac.org> wrote:
> 
> > This is a fundamental issue related to the use of hashes in this
> > context. It shows that it is _impossible_ to create a hash which
> > meets the requirement of O(1) rules per bucket in the setting
> > described above regardless how clever you choose the hash function.
> > 
> > What do you think about it? Do you agree?
> 
> The ipv4 FIB hash tables tackle exactly this problem.  The resulting
> worse cast complexity is O(n_bits_in_prefix_mask).
> 
> The problem you've described is exactly the same as trying to use
> hashing for routing tables.

You can do it in O(log(n_bits_in_prefix_mask)).

This is achieved using binary search on the prefix lengths which
appear in the table.  (So if only a few prefix lengths are used, the
tree is small).

Illustrated by an example.  The example assumes 32 bits total and
every prefix length appears in the table.  Each node in the search
tree has one or more of these fields:

   - TABLE: Sparse (hash) or dense (direct) mapping of some
     subset of input bits to subtree nodes.
   - SHORTER: Subtree node, for matching shorter prefixes than the
     one which lead to the current node.
   - BEST: Best matching result given the prefix that lead to this node.
     This is either an exact match for that prefix, or the best
     shorter-prefix match for it.
     (On the root node, this will be the default value).

In the worst case of N bits in the prefix, and every prefix length is
actually used, there would by N tree nodes, however the depth of the
search tree is ceil(log2(N)).

This is the lookup algorithm:

   - Start with the root tree node.
     Note that this isn't the shortest prefix matcher.
     It will match the "middle" prefix length, given your set of lengths.
     E.g. on a 32-bit address, with rules of all prefix lenghts, the root
     tree node would match 16 bits.
LOOP:
   - If NODE->TABLE exists, lookup the appropriate subset of input bits in it.
     For sparse tables, this involves a hash lookup.
     If a match is found, select that as the new tree node and goto LOOP.
   - Otherwise there is no table or no match in the table.
   - If NODE->SHORTER exists, select that as the new tree node and goto LOOP.
   - Otherwise, return NODE->BEST.

This generalises to multiple dimensions e.g. for doing multiple
prefixes on source+target + different combinations of other bits such
as protocol, TOS etc. - i.e. arbitrary bit-subset classifiers.  The
basic principle and the algorithm are the same.

In some cases it is worth reducing the tree size a little, e.g. if
prefix lengths P and P+1 appear, you may as well just hash on P+1 bits
and insert all the P prefix matches into the P+1 table, instead of
having a P table.  The cost is up to twice the number of entries in
the P+1 table (depending on how dense your set of P+1 rules is), but
this may be better than the cost of a extra hash lookup.  Naturally,
there are other optimisations too.

-- Jamie
