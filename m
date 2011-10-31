From: akpm@linux-foundation.org
Subject: [patch 1/1] net/netfilter/nf_conntrack_netlink.c: fix Oops on container destroy
Date: Mon, 31 Oct 2011 14:33:12 -0700
Message-ID: <201110312133.p9VLXDUu003535@hpaq6.eem.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	alex@alex.org.uk, stable@kernel.org, stable@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Bligh <alex@alex.org.uk>
Subject: net/netfilter/nf_conntrack_netlink.c: fix Oops on container destroy

Problem:

A repeatable Oops can be caused if a container with networking
unshared is destroyed when it has nf_conntrack entries yet to expire.

A copy of the oops follows below. A perl program generating the oops
repeatably is attached inline below.

Analysis:

The oops is called from cleanup_net when the namespace is
destroyed. conntrack iterates through outstanding events and calls
death_by_timeout on each of them, which in turn produces a call to
ctnetlink_conntrack_event. This calls nf_netlink_has_listeners, which
oopses because net->nfnl is NULL.

The perl program generates the container through fork() then
clone(NS_NEWNET). I does not explicitly	set up netlink
explicitly set up netlink, but I presume it was set up else net->nfnl
would have been NULL earlier (i.e. when an earlier connection
timed out). This would thus suggest that net->nfnl is made NULL
during the destruction of the container, which I think is done by
nfnetlink_net_exit_batch.

I can see that the various subsystems are deinitialised in the opposite
order to which the relevant register_pernet_subsys calls are called,
and both nf_conntrack and nfnetlink_net_ops register their relevant
subsystems. If nfnetlink_net_ops registered later than nfconntrack,
then its exit routine would have been called first, which would cause
the oops described. I am not sure there is anything to prevent this
happening in a container environment.

Whilst there's perhaps a more complex problem revolving around ordering
of subsystem deinit, it seems to me that missing a netlink event on a
container that is dying is not a disaster. An early check for net->nfnl
being non-NULL in ctnetlink_conntrack_event appears to fix this. There
may remain a potential race condition if it becomes NULL immediately
after being checked (I am not sure any lock is held at this point or
how synchronisation for subsystem deinitialization works).

Patch:

The patch attached should apply on everything from 2.6.26 (if not before)
onwards; it appears to be a problem on all kernels. This was taken against
Ubuntu-3.0.0-11.17 which is very close to 3.0.4. I have torture-tested it
with the above perl script for 15 minutes or so; the perl script hung the
machine within 20 seconds without this patch.

Applicability:

If this is the right solution, it should be applied to all stable kernels
as well as head. Apart from the minor overhead of checking one variable
against NULL, it can never 'do the wrong thing', because if net->nfnl
is NULL, an oops will inevitably result. Therefore, checking is a reasonable
thing to do unless it can be proven than net->nfnl will never be NULL.

Check net->nfnl for NULL in ctnetlink_conntrack_event to avoid Oops on
container destroy

Signed-off-by: Alex Bligh <alex@alex.org.uk>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>
Cc: <stable@kernel.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/netfilter/nf_conntrack_netlink.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -puN net/netfilter/nf_conntrack_netlink.c~net-netfilter-nf_conntrack_netlinkc-fix-oops-on-container-destroy net/netfilter/nf_conntrack_netlink.c
--- a/net/netfilter/nf_conntrack_netlink.c~net-netfilter-nf_conntrack_netlinkc-fix-oops-on-container-destroy
+++ a/net/netfilter/nf_conntrack_netlink.c
@@ -570,6 +570,11 @@ ctnetlink_conntrack_event(unsigned int e
 		return 0;
 
 	net = nf_ct_net(ct);
+
+	/* container deinit, netlink may have died before death_by_timeout */
+	if (!net->nfnl)
+		return 0;
+
 	if (!item->report && !nfnetlink_has_listeners(net, group))
 		return 0;
 
_
