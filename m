From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error
 unwinding
Date: Fri, 13 May 2016 22:04:42 +0200
Message-ID: <20160513200442.GA29941@breakpoint.cc>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
 <20160512094725.GB1777@salvia>
 <87twi3qmlf.fsf@x220.int.ebiederm.org>
 <20160512164000.GA9815@breakpoint.cc>
 <87a8jtrbk3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, dale.4d@gmail.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43291 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932211AbcEMUEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 16:04:50 -0400
Content-Disposition: inline
In-Reply-To: <87a8jtrbk3.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
> > AFAICS no other callers do something similar, but yes,
> > we'd need this all over the place if there are others.
> >
> > Maybe we need a saner fix, e.g. by adding bounds check to net_generic(),
> > and making sure that net_generic() returns non-NULL only if the per
> > netns memory was allocated properly.
> 
> As a first approximiation I am thinking we should fix by making
> nf_queue_register_handler a per netns operation.

We can do that but then we'd end up storing the very same address
for each namespace which I think isn't nice either.

> Either that or give nfnetlink_queue it's own dedicated place in
> struct net for struct nfnl_queue_net.

That would work too, but then I don't see why that is preferrable
to this proposed patch. We could add a helper for this so that
we have something like

static bool netns_was_inited(const struct net *n)
{
	return net->list.next != NULL;
}

Another alternative is this patch (not even compile tested, just to
illustrate the idea):

diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -38,7 +38,11 @@ static inline void *net_generic(const struct net *net, int id)
 
 	rcu_read_lock();
 	ng = rcu_dereference(net->gen);
-	ptr = ng->ptr[id - 1];
+
+	if (ng->len < id)
+		ptr = ng->ptr[id - 1];
+	else
+		ptr = NULL;
 	rcu_read_unlock();
 
 	return ptr;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -111,6 +111,7 @@ static int ops_init(const struct pernet_operations *ops, struct net *net)
 		return 0;
 
 cleanup:
+	net_assign_generic(net, *ops->id, NULL);
 	kfree(data);
 
 out:
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -927,6 +927,9 @@ static void nfqnl_nf_hook_drop(struct net *net, struct nf_hook_ops *hook)
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 	int i;
 
+	if (!q)
+		return;
+
 	rcu_read_lock();
 	for (i = 0; i < INSTANCE_BUCKETS; i++) {
 		struct nfqnl_instance *inst;

What do you think?
