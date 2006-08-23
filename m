From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take13 1/3] kevent: Core files.
Date: Wed, 23 Aug 2006 14:51:06 +0200
Message-ID: <200608231451.07499.dada1@cosmosbay.com>
References: <11563322971212@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:8401 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932449AbWHWMvG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 08:51:06 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11563322971212@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again Evgeniy I really begin to like kevent :)

On Wednesday 23 August 2006 13:24, Evgeniy Polyakov wrote:
+struct kevent
+{
+=A0=A0=A0=A0=A0=A0=A0/* Used for kevent freeing.*/
+=A0=A0=A0=A0=A0=A0=A0struct rcu_head=A0=A0=A0=A0=A0=A0=A0=A0=A0rcu_hea=
d;
+=A0=A0=A0=A0=A0=A0=A0struct ukevent=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0event=
;
+=A0=A0=A0=A0=A0=A0=A0/* This lock protects ukevent manipulations, e.g.=
 ret_flags changes.=20
*/
+=A0=A0=A0=A0=A0=A0=A0spinlock_t=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0ulock;
+
+=A0=A0=A0=A0=A0=A0=A0/* Entry of user's queue. */
+=A0=A0=A0=A0=A0=A0=A0struct list_head=A0=A0=A0=A0=A0=A0=A0=A0kevent_en=
try;
+=A0=A0=A0=A0=A0=A0=A0/* Entry of origin's queue. */
+=A0=A0=A0=A0=A0=A0=A0struct list_head=A0=A0=A0=A0=A0=A0=A0=A0storage_e=
ntry;
+=A0=A0=A0=A0=A0=A0=A0/* Entry of user's ready. */
+=A0=A0=A0=A0=A0=A0=A0struct list_head=A0=A0=A0=A0=A0=A0=A0=A0ready_ent=
ry;
+
+=A0=A0=A0=A0=A0=A0=A0u32=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0flags;
+
+=A0=A0=A0=A0=A0=A0=A0/* User who requested this kevent. */
+=A0=A0=A0=A0=A0=A0=A0struct kevent_user=A0=A0=A0=A0=A0=A0*user;
+=A0=A0=A0=A0=A0=A0=A0/* Kevent container. */
+=A0=A0=A0=A0=A0=A0=A0struct kevent_storage=A0=A0=A0*st;
+
+=A0=A0=A0=A0=A0=A0=A0struct kevent_callbacks=A0callbacks;
+
+=A0=A0=A0=A0=A0=A0=A0/* Private data for different storages.=20
+=A0=A0=A0=A0=A0=A0=A0 * poll()/select storage has a list of wait_queue=
_t containers=20
+=A0=A0=A0=A0=A0=A0=A0 * for each ->poll() { poll_wait()' } here.
+=A0=A0=A0=A0=A0=A0=A0 */
+=A0=A0=A0=A0=A0=A0=A0void=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0*priv;
+};

I wonder if you can reorder fields in this structure, so that 'read mos=
tly'=20
fields are grouped together, maybe in a different cache line.
This should help reduce false sharing in SMP.
read mostly fields are (but you know better than me) : callbacks, rcu_h=
ead,=20
priv, user, event, ...


+#define KEVENT_MAX_EVENTS=A0=A0=A0=A0=A0=A04096

Could you please tell me (Forgive me if you already clarified this poin=
t) ,=20
what happens if the number of queued events reaches this value ?


+int kevent_init(struct kevent *k)
+{
+=A0=A0=A0=A0=A0=A0=A0spin_lock_init(&k->ulock);
+=A0=A0=A0=A0=A0=A0=A0k->flags =3D 0;
+
+=A0=A0=A0=A0=A0=A0=A0if (unlikely(k->event.type >=3D KEVENT_MAX))
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return kevent_break(k);
+

As long you are sure we cannot call kevent_enqueue()/kevent_dequeue() a=
fter a=20
failed kevent_init() it should be fine.

+int kevent_add_callbacks(const struct kevent_callbacks *cb, int pos)
+{
+=A0=A0=A0=A0=A0=A0=A0struct kevent_callbacks *p;
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0if (pos >=3D KEVENT_MAX)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return -EINVAL;

if a negative pos is used here we might crash. KEVENT_MAX is a signed t=
oo, so=20
the compare is done on signed values.
If we consider callers always give a sane value, the test can be suppre=
ssed.
If we consider callers may be wrong, then we must do a correct test.
If you dont want to change function prototype, then change the test to =
:

if ((unsigned)pos >=3D KEVENT_MAX)
              return -EINVAL;

Some people on lkml will prefer:
if (pos < 0 || pos >=3D KEVENT_MAX)
	return -EINVAL;
or
#define KEVENT_MAX 6U /* unsigned constant */

+static kmem_cache_t *kevent_cache;

You probably want to add __read_mostly here to avoid false sharing.

+static kmem_cache_t *kevent_cache __read_mostly;

Same for other caches :
+static kmem_cache_t *kevent_poll_container_cache;
+static kmem_cache_t *kevent_poll_priv_cache;


About the hash table :

+struct kevent_user
+{
+=A0=A0=A0=A0=A0=A0=A0struct list_head=A0=A0=A0=A0=A0=A0=A0=A0kevent_li=
st[KEVENT_HASH_MASK+1];
+=A0=A0=A0=A0=A0=A0=A0spinlock_t=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0kevent_lock;

epoll used to use a hash table too (its size was configurable at init t=
ime),=20
and was converted to a RB-tree for good reasons...(avoid a user to allo=
cate a=20
big hash table in pinned memory and DOS)
Are you sure a process handling one million sockets will succeed using =
kevent=20
instead of epoll ?

Do you have a pointer to sample source code using mmap()/kevent interfa=
ce ?=20
It's not clear to me how we can use it (and notice that a full wrap occ=
ured,=20
user app could miss x*KEVENT_MAX_EVENTS events ?). Do we still must use=
 a=20
syscall to dequeue events ?

In particular you state sizeof(mukevent) is 40, while its 12:

+/*
+ * Note that kevents does not exactly fill the page (each mukevent is =
40=20
bytes),
+ * so we reuse 4 bytes at the begining of the first page to store inde=
x.
+ * Take that into account if you want to change size of struct ukevent=
=2E
+ */

+struct mukevent
+{
+=A0=A0=A0=A0=A0=A0=A0struct kevent_id=A0=A0=A0=A0=A0=A0=A0=A0id;  /* s=
ize()=3D8 */
+=A0=A0=A0=A0=A0=A0=A0__u32=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0ret_flags; /* size()=3D4 */
+};



Thank you
Eric
