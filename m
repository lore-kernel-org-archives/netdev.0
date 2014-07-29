From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH 1/2] lib: Resizable, Scalable,
	Concurrent Hash Table
Date: Tue, 29 Jul 2014 17:55:46 +0100
Message-ID: <20140729165546.GB14314@casper.infradead.org>
References: <cover.1406633945.git.tgraf@suug.ch>
 <1cd2f98b8362052eff24d481b7c9622eb770d091.1406633945.git.tgraf@suug.ch>
 <20140729153016.GC1437@jtriplet-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140729153016.GC1437@jtriplet-mobl1>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 07/29/14 at 08:30am, Josh Triplett wrote:
> On Tue, Jul 29, 2014 at 01:41:32PM +0200, Thomas Graf wrote:
> > Generic implementation of a resizable, scalable, concurrent hash table
> > based on [0]. The implementation supports both, fixed size keys specified
> > via an offset and length, or arbitrary keys via own hash and compare
> > functions.
> > 
> > Lookups are lockless and protected as RCU read side critical sections.
> > Automatic growing/shrinking based on user configurable watermarks is
> > available while allowing concurrent lookups to take place.
> > 
> > Objects to be hashed must include a struct rhash_head. The reason for not
> > using the existing struct hlist_head is that the expansion and shrinking
> > will have two buckets point to a single entry which would lead in obscure
> > reverse chaining behaviour.
> > 
> > Code includes a boot selftest if CONFIG_TEST_RHASHTABLE is defined.
> > 
> > [0] https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
> > 
> > Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> 
> Thanks for working on this!
> 
> Currently reading the algorithm implementation in more detail.  A couple
> of minor issues below.

Thanks for the initial review!

> 
> > --- /dev/null
> > +++ b/include/linux/rhashtable.h
> [...]
> > +struct rhash_head {
> > +	struct rhash_head		*next;
> > +};
> 
> Arguably this could become a new singly-linked list type in list.h;
> we don't currently have one.

No objections and I'm very open to this if there is use for it
aside from this hash table implementation.

> > +/**
> > + * rht_for_each_entry_safe - safely iterate over hash chain of given type
> > + * @pos:	type * to use as a loop cursor.
> > + * @n:		type * to use for temporary next object storage
> > + * @head:	head of the hash chain (struct rhash_head *)
> > + * @ht:		pointer to your struct rhashtable
> > + * @member:	name of the rhash_head within the hashable struct.
> > + *
> > + * This hash chain list-traversal primitive allows for the looped code to
> > + * remove the loop cursor from the list.
> > + */
> > +#define rht_for_each_entry_safe(pos, n, head, ht, member)		\
> > +	for (pos = rht_entry_safe(rht_dereference(head, ht), \
> > +				   typeof(*(pos)), member), \
> > +	     n = rht_entry_safe(rht_dereference((pos)->member.next, ht), \
> > +				 typeof(*(pos)), member); \
> > +	     pos; \
> > +	     pos = n, \
> > +	     n = rht_entry_safe(rht_dereference((pos)->member.next, ht), \
> > +				 typeof(*(pos)), member))
> 
> Given that removal requires special care, is this something actually
> needed in the public interface, or only internally?  You don't
> necessarily need to define a full set of list primitives.  (Unless of
> course you make this a new list type in list.h.)

The main purpose of the safe variant is to allow API users to easily
destruct all table entries in the end and do something like this:

tbl = rht_dereference(ht->tbl, ht);
for (i = 0; i < tbl->size; i++)
	rht_for_each_entry_safe(obj, next, tbl->buckets[i], ht, node)
                kfree(obj);

> > --- /dev/null
> > +++ b/lib/rhashtable.c
> [...]
> > +#define ASSERT_RHT_MUTEX(HT) BUG_ON(unlikely(!lockdep_rht_mutex_is_held(HT)))
> 
> BUG_ON and WARN_ON already include unlikely(); you don't need to add it
> yourself.

Thanks, will fix.

> > +/**
> > + * rht_obj - cast hash head to outer object
> > + * @ht:		hash table
> > + * @he:		hashed node
> > + */
> > +void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
> > +{
> > +	return (void *) he - ht->p.head_offset;
> > +}
> > +EXPORT_SYMBOL_GPL(rht_obj);
> 
> Should this be a static inline?  And, will the runtime indirection
> involved in head_offset add unnecessary overhead for tables of a known
> type?  (I'd expect a head_offset of 0 in common cases.)

I left the optimization to the compiler here as I would expect it to
inline this automatically. As for the overhead of the head_offset, I
think it is minimal and justified by the added flexibility. The
overhead is basically the same as for lists.
