From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] netfilter: ctnetlink: support kernel-space dump
 filterings
Date: Sat, 25 Feb 2012 14:26:50 +0100
Message-ID: <20120225132650.GC15774@1984>
References: <1330121648-2956-1-git-send-email-pablo@netfilter.org>
 <1330121648-2956-3-git-send-email-pablo@netfilter.org>
 <alpine.LNX.2.01.1202250153440.17151@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	davem@davemloft.net
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1202250153440.17151@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 25, 2012 at 02:09:09AM +0100, Jan Engelhardt wrote:
> 
> On Friday 2012-02-24 23:14, pablo@netfilter.org wrote:
> >@@ -977,9 +992,25 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
> > 	u16 zone;
> > 	int err;
> > 
> >-	if (nlh->nlmsg_flags & NLM_F_DUMP)
> >+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
> >+		struct ctnetlink_dump_filter *filter = NULL;
> >+
> >+#if defined(CONFIG_NF_CONNTRACK_MARK)
> >+		filter = kzalloc(sizeof(struct ctnetlink_dump_filter),
> >+				 GFP_KERNEL);
> >+		if (filter == NULL)
> >+			return -ENOMEM;
> >+
> >+		if (cda[CTA_MARK])
> >+			filter->mark.value = ntohl(nla_get_be32(cda[CTA_MARK]));
> >+		if (cda[CTA_MARK_MASK]) {
> >+			filter->mark.mask =
> >+				ntohl(nla_get_be32(cda[CTA_MARK_MASK]));
> >+		}
> >+#endif
> > 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
> >-					  ctnetlink_done, NULL, 0);
> >+					  ctnetlink_done, filter, 0);
> >+	}
> 
> I had thought of the following before your patch came up:
> 
> ctnl_dump_any(skb,cb)
> {
> 	...loop over CTs...
> }
> ctnl_dump_foo(skb,cb)
> {
> 	if (cb->args[0] == NULL) {
> 		cb->args[0] = filter = kzalloc(sizeof(struct ctnl_dump_filter));
> 		if (cb->nlh has CTA_MARK) /* [1] */
> 			filter->mark.value = ...

I thought about this at first instance, but I still think that
allowing to pass data to the dump callback makes sense. It's quite
common to provide some interface to pass data pointer to callbacks.

> 	}
> 	return ctnl_dump_any(skb,cb);
> }
> ctnl_dump_bar(skb,cb)
> {
> 	if (cb->args[0] == NULL) {
> 		cb->args[0] = somethingelse;
> 	}
> 	return ctnl_dump_any(skb,cb);
> }
> ctnetlink_get_foo(ctnl,skb,...)
> {
> 	netlink_dump_start(ctnl,skb,nlh,ctnl_dump_foo,ctnl_done,0);
> }
> ctnetlink_get_bar(ctnl,skb,...)
> {
> 	netlink_dump_start(ctnl,skb,nlh,ctnl_dump_bar,ctnl_done,0);
> }
> 
> [1]: Arguably needs a way to put cda into cb.

The main problem is that cda is allocated in the stack. We'd need to
allocate the array in the heap instead. Then, pass it to the dump_cb.
Then, we would need to retrieve the value from the attribute, that
would be slowier than this approach.

Thanks for your comments.
