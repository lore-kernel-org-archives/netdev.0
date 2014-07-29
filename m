From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] netlink: Convert netlink_lookup() to use RCU
 protected hash table
Date: Tue, 29 Jul 2014 17:34:20 +0100
Message-ID: <20140729163420.GA14314@casper.infradead.org>
References: <cover.1406633945.git.tgraf@suug.ch>
 <b73872eab661f28345085dbd4bd477a50d7042f6.1406633945.git.tgraf@suug.ch>
 <20140729155801.GB10301@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	challa@noironetworks.com, walpole@cs.pdx.edu, dev@openvswitch.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140729155801.GB10301@distanz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/29/14 at 05:58pm, Tobias Klauser wrote:
> On 2014-07-29 at 13:41:33 +0200, Thomas Graf <tgraf@suug.ch> wrote:
> > Heavy Netlink users such as Open vSwitch spend a considerable amount of
> > time in netlink_lookup() due to the read-lock on nl_table_lock. Use of
> > RCU relieves the lock contention.
> > 
> > Makes use of the new resizable hash table to avoid locking on the
> > lookup.
> > 
> > The hash table will grow if entries exceeds 75% of table size up to a
> > total table size of 64K. It will automatically shrink if usage falls
> > below 50%.
> > 
> > Also splits nl_table_lock into a separate spinlock to protect hash table
> > mutations. This avoids a possible deadlock when the hash table growing
> > waits on RCU readers to complete via synchronize_rcu() while readers
> > holding RCU read lock are waiting on the nl_table_lock() to be released
> > to lock the table for broadcasting.
> > 
> > Before:
> >    9.16%  kpktgend_0  [openvswitch]      [k] masked_flow_lookup
> >    6.42%  kpktgend_0  [pktgen]           [k] mod_cur_headers
> >    6.26%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
> >    6.23%  kpktgend_0  [kernel.kallsyms]  [k] memset
> >    4.79%  kpktgend_0  [kernel.kallsyms]  [k] netlink_lookup
> >    4.37%  kpktgend_0  [kernel.kallsyms]  [k] memcpy
> >    3.60%  kpktgend_0  [openvswitch]      [k] ovs_flow_extract
> >    2.69%  kpktgend_0  [kernel.kallsyms]  [k] jhash2
> > 
> > After:
> >   15.26%  kpktgend_0  [openvswitch]      [k] masked_flow_lookup
> >    8.12%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
> >    7.92%  kpktgend_0  [pktgen]           [k] mod_cur_headers
> >    5.11%  kpktgend_0  [kernel.kallsyms]  [k] memset
> >    4.11%  kpktgend_0  [openvswitch]      [k] ovs_flow_extract
> >    4.06%  kpktgend_0  [kernel.kallsyms]  [k] _raw_spin_lock
> >    3.90%  kpktgend_0  [kernel.kallsyms]  [k] jhash2
> >    [...]
> >    0.67%  kpktgend_0  [kernel.kallsyms]  [k] netlink_lookup
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ---
> >  net/netlink/af_netlink.c | 285 ++++++++++++++++++-----------------------------
> >  net/netlink/af_netlink.h |  18 +--
> >  net/netlink/diag.c       |  11 +-
> >  3 files changed, 119 insertions(+), 195 deletions(-)
> > 
> > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > index 1b38f7f..7f44468 100644
> > --- a/net/netlink/af_netlink.c
> > +++ b/net/netlink/af_netlink.c
> [...]
> > @@ -2996,28 +2939,26 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> >  
> >  	net = seq_file_net(seq);
> >  	iter = seq->private;
> > -	s = v;
> > -	do {
> > -		s = sk_next(s);
> > -	} while (s && !nl_table[s->sk_protocol].compare(net, s));
> > -	if (s)
> > -		return s;
> > +	nlk = v;
> > +
> > +	rht_for_each_entry_rcu(nlk, nlk->node.next, node)
> > +		if (net_eq(sock_net((struct sock *)nlk), net))
> > +			return nlk;
> >  
> >  	i = iter->link;
> >  	j = iter->hash_idx + 1;
> >  
> >  	do {
> > -		struct nl_portid_hash *hash = &nl_table[i].hash;
> > -
> > -		for (; j <= hash->mask; j++) {
> > -			s = sk_head(&hash->table[j]);
> > +		struct rhashtable *ht = &nl_table[i].hash;
> > +		const struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
> >  
> > -			while (s && !nl_table[s->sk_protocol].compare(net, s))
> > -				s = sk_next(s);
> > -			if (s) {
> > -				iter->link = i;
> > -				iter->hash_idx = j;
> > -				return s;
> > +		for (; j <= tbl->size; j++) {
> 
> Should the condition j < tbl->size here, since the bucket table only
> contains `size' buckets?

Good catch, thanks

>
> 
> > +			rht_for_each_entry_rcu(nlk, tbl->buckets[j], node) {
> > +				if (net_eq(sock_net((struct sock *)nlk), net)) {
> > +					iter->link = i;
> > +					iter->hash_idx = j;
> > +					return nlk;
> > +				}
> >  			}
> >  		}
> [...]
> > diff --git a/net/netlink/diag.c b/net/netlink/diag.c
> > index 1af29624..7588f34 100644
> > --- a/net/netlink/diag.c
> > +++ b/net/netlink/diag.c
> [...]
> > @@ -101,16 +102,20 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
> >  				int protocol, int s_num)
> >  {
> >  	struct netlink_table *tbl = &nl_table[protocol];
> > -	struct nl_portid_hash *hash = &tbl->hash;
> > +	struct rhashtable *ht = &tbl->hash;
> > +	const struct bucket_table *htbl = rht_dereference(ht->tbl, ht);
> >  	struct net *net = sock_net(skb->sk);
> >  	struct netlink_diag_req *req;
> > +	struct netlink_sock *nlsk;
> >  	struct sock *sk;
> >  	int ret = 0, num = 0, i;
> >  
> >  	req = nlmsg_data(cb->nlh);
> >  
> > -	for (i = 0; i <= hash->mask; i++) {
> > -		sk_for_each(sk, &hash->table[i]) {
> > +	for (i = 0; i <= htbl->size; i++) {
> 
> Same here, condition should be i < htbl->size
> 
> > +		rht_for_each_entry(nlsk, htbl->buckets[i], ht, node) {
> > +			sk = (struct sock *)nlsk;
> > +
> >  			if (!net_eq(sock_net(sk), net))
> >  				continue;
> >  			if (num < s_num) {
> > -- 
> > 1.9.3
> 
