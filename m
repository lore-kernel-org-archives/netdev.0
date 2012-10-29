From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v7 10/16] dlm: use new hashtable implementation
Date: Mon, 29 Oct 2012 11:53:54 -0400
Message-ID: <CA+1xoqfxgB+8BybPpf+jwT-ObfGPxnbKvkz1MUMuJuR8NDSNaw@mail.gmail.com>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
	<1351450948-15618-10-git-send-email-levinsasha928@gmail.com>
	<20121029124655.GD11733@Krystal> <20121029130736.GF11733@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20121029130736.GF11733@Krystal>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2012 at 9:07 AM, Mathieu Desnoyers
<mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org> wrote:
> * Mathieu Desnoyers (mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org) wrote:
>> * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
>> [...]
>> > @@ -158,34 +159,21 @@ static int dlm_allow_conn;
>> >  static struct workqueue_struct *recv_workqueue;
>> >  static struct workqueue_struct *send_workqueue;
>> >
>> > -static struct hlist_head connection_hash[CONN_HASH_SIZE];
>> > +static struct hlist_head connection_hash[CONN_HASH_BITS];
>> >  static DEFINE_MUTEX(connections_lock);
>> >  static struct kmem_cache *con_cache;
>> >
>> >  static void process_recv_sockets(struct work_struct *work);
>> >  static void process_send_sockets(struct work_struct *work);
>> >
>> > -
>> > -/* This is deliberately very simple because most clusters have simple
>> > -   sequential nodeids, so we should be able to go straight to a connection
>> > -   struct in the array */
>> > -static inline int nodeid_hash(int nodeid)
>> > -{
>> > -   return nodeid & (CONN_HASH_SIZE-1);
>> > -}
>>
>> There is one thing I dislike about this change: you remove a useful
>> comment. It's good to be informed of the reason why a direct mapping
>> "value -> hash" without any dispersion function is preferred here.

Yes, I've removed the comment because it's no longer true with the patch :)

> And now that I come to think of it: you're changing the behavior : you
> will now use a dispersion function on the key, which goes against the
> intent expressed in this comment.

The comment gave us the information that nodeids are mostly
sequential, we no longer need to rely on that.

> It might be good to change hash_add(), hash_add_rcu(),
> hash_for_each_possible*() key parameter for a "hash" parameter, and let
> the caller provide the hash value computed by the function they like as
> parameter, rather than enforcing hash_32/hash_64.

Why? We already proved that hash_32() is more than enough as a hashing
function, why complicate things?

Even doing hash_32() on top of another hash is probably a good idea to
keep things simple.

Thanks,
Sasha
