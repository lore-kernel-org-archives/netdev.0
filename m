From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 4 Feb 2005 15:48:55 -0800
Message-ID: <20050204154855.79340cdb.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
	<20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
	<20050203150821.2321130b.davem@davemloft.net>
	<20050204113305.GA12764@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, okir@suse.de, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050204113305.GA12764@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005 22:33:05 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I think you should probably note that some sort of locking or RCU
> scheme is required to make this safe.  As it is the atomic_inc
> and the list_add can be reordered such that the atomic_inc occurs
> after the atomic_dec_and_test.
>
> Either that or you can modify the example to add an
> smp_mb__after_atomic_inc().  That'd be a good way to
> demonstrate its use.

Yeah, this example is totally bogus.  I'll make it match the
neighbour cache case which started this discussion.  Which is
something like:

static void obj_list_add(struct obj *obj)
{
	obj->active = 1;
	list_add(&obj->list);
}

static void obj_list_del(struct obj *obj)
{
	list_del(&obj->list);
	obj->active = 0;
}

static void obj_destroy(struct obj *obj)
{
	BUG_ON(obj->active);
	kfree(obj);
}

struct obj *obj_list_peek(struct list_head *head)
{
	if (!list_empty(head)) {
		struct obj *obj;

		obj = list_entry(head->next, struct obj, list);
		atomic_inc(&obj->refcnt);
		return obj;
	}
	return NULL;
}

void obj_poke(void)
{
	struct obj *obj;

	spin_lock(&global_list_lock);
	obj = obj_list_peek(&global_list);
	spin_unlock(&global_list_lock);

	if (obj) {
		obj->ops->poke(obj);
		if (atomic_dec_and_test(&obj->refcnt))
			obj_destroy(obj);
	}
}

void obj_timeout(struct obj *obj)
{
	spin_lock(&global_list_lock);
	obj_list_del(obj);
	spin_unlock(&global_list_lock);

	if (atomic_dec_and_test(&obj->refcnt))
		obj_destroy(obj);
}

Something like that.  I'll update the atomic_ops.txt
doc and post and updated version later tonight.
