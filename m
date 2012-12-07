From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v4] bridge: export multicast database
 via netlink
Date: Fri, 07 Dec 2012 17:32:24 +0800
Message-ID: <1354872744.5124.11.camel@cr0>
References: <1354850623-31652-1-git-send-email-amwang@redhat.com>
	<20121207084833.GH16122@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121207084833.GH16122@casper.infradead.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-12-07 at 08:48 +0000, Thomas Graf wrote:
> On 12/07/12 at 11:23am, Cong Wang wrote:
> > +static int br_mdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
> > +{
> > +	struct net_device *dev;
> > +	struct net *net = sock_net(skb->sk);
> > +	struct nlmsghdr *nlh;
> 
> Set nlh = NULL
> 
> > +	int idx = 0, s_idx;
> > +
> > +	s_idx = cb->args[0];
> > +
> > +	rcu_read_lock();
> > +
> > +	for_each_netdev_rcu(net, dev) {
> > +		if (dev->priv_flags & IFF_EBRIDGE) {
> > +			struct br_port_msg *bpm;
> > +
> > +			if (idx < s_idx)
> > +				goto skip;
> > +
> > +			nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
> > +					cb->nlh->nlmsg_seq, RTM_GETMDB,
> > +					sizeof(*bpm), NLM_F_MULTI);
> > +			if (nlh == NULL)
> > +				break;
> > +
> > +			bpm = nlmsg_data(nlh);
> > +			bpm->ifindex = dev->ifindex;
> > +			if (br_mdb_fill_info(skb, cb, dev) < 0)
> > +				goto out;
> > +			if (br_rports_fill_info(skb, cb, dev) < 0)
> > +				goto out;
> 
> You need to reset cb->args[1] to 0 here so that when you process the
> next mdb it will not skip any entries.

Good catch! Will fix it.

> 
> > +
> > +			nlmsg_end(skb, nlh);
> > +		skip:
> > +			idx++;
> > +		}
> > +	}
> > +
> > +out:
> 
> You need to call nlmsg_end(skb, nlh) here if nlh != NULL
> because you need to finalize the message in case you come
> from the "goto out" above. Otherwise your partial message
> is corrupt.

Right... I missed this case.

> 
> > +	cb->seq = cb->args[2];
> 
> This can't possibly work if you have multiple bridges unless
> all of them have an identical mdb->seq.
> 

I thought sequence checking is per-message, so I must be wrong, it seems
to be per-dump, then we will need a global seq for all the bridges.

> Maybe leave the consistent dumping problem out for now and just
> set cb->seq = net->dev_base_seq so that you at least cover all
> bridges.
> 
> We don't need to guarantee that no rehash has happened throughout
> the dump, we only need to ensure that no rehash happnened if a
> bridge required more than one netlink message. You could store
> mdb->seq in cb->args[3] and compare it with the current mdb->seq
> after br_rports_fill_info() finished, if they differ you could
> just cb->seq++. I suggst you leave this out for now and work on this
> in a follow-up patch to not complicate this any further.

There is one message per-bridge, but maybe more messages per-dump.

Anyway, I will leave this out for now and put some comment on the code
saying we need to improve this.

Thanks for your review!
