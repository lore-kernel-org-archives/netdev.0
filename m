From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: nf_sockopt_find() / nf_register_sockopt()
 should not return EINTR
Date: Thu, 31 Jul 2014 12:55:25 +0200
Message-ID: <20140731105525.GA4680@salvia>
References: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com>
 <1406234495.3363.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1yeeQ81UyVL57Vl7"
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406234495.3363.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 24, 2014 at 10:41:35PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> getsockopt() or setsockopt() sometimes returns -EINTR instead of
> -ENOPROTOOPT, causing headaches to application developers.
> 
> This is because unsupported commands might go through nf_sockopt_find()
> and this function returns -EINTR if a signal is pending.
> 
> Just use non interruptible mutex functions, as there is no reason
> we should sleep for a long time here.

On top of this patch, I think that at least we can also ged rid of
these interruptible mutex from the netfilter/core code too (see
preliminary patch attached).

I can also adapt the callers so they don't check anymore the return
value as they will always succeed.

Comments? Thanks.

--1yeeQ81UyVL57Vl7
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="x.patch"

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 1fbab0c..a93c97f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -35,11 +35,7 @@ EXPORT_SYMBOL_GPL(nf_ipv6_ops);
 
 int nf_register_afinfo(const struct nf_afinfo *afinfo)
 {
-	int err;
-
-	err = mutex_lock_interruptible(&afinfo_mutex);
-	if (err < 0)
-		return err;
+	mutex_lock(&afinfo_mutex);
 	RCU_INIT_POINTER(nf_afinfo[afinfo->family], afinfo);
 	mutex_unlock(&afinfo_mutex);
 	return 0;
@@ -68,11 +64,8 @@ static DEFINE_MUTEX(nf_hook_mutex);
 int nf_register_hook(struct nf_hook_ops *reg)
 {
 	struct nf_hook_ops *elem;
-	int err;
 
-	err = mutex_lock_interruptible(&nf_hook_mutex);
-	if (err < 0)
-		return err;
+	mutex_lock(&nf_hook_mutex);
 	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
 		if (reg->priority < elem->priority)
 			break;

--1yeeQ81UyVL57Vl7--
