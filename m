From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] [nf-next] netfilter: fix NF_REPEAT handling
Date: Thu, 10 Nov 2016 00:15:55 +0100
Message-ID: <20161109231555.GA12259@salvia>
References: <20161108132914.1495283-1-arnd@arndb.de>
 <20161108132914.1495283-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161108132914.1495283-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 08, 2016 at 02:28:19PM +0100, Arnd Bergmann wrote:
> gcc correctly identified a theoretical uninitialized variable use:
> 
> net/netfilter/nf_conntrack_core.c: In function 'nf_conntrack_in':
> net/netfilter/nf_conntrack_core.c:1125:14: error: 'l4proto' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This could only happen when we 'goto out' before looking up l4proto,
> and then enter the retry, implying that l3proto->get_l4proto()
> returned NF_REPEAT. This does not currently get returned in any
> code path and probably won't ever happen, but is not good to
> rely on.
> 
> Moving the repeat handling up a little should have the same
> behavior as today but avoids the warning by making that case
> impossible to enter.
> 
> Fixes: 08733a0cb7de ("netfilter: handle NF_REPEAT from nf_conntrack_in()")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> The patch causing this is currently only in nf-next, and not yet
> in net-next.
> ---
>  net/netfilter/nf_conntrack_core.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index de4b8a75f30b..610c9de0ce18 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1337,6 +1337,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
>  		NF_CT_STAT_INC_ATOMIC(net, invalid);
>  		if (ret == -NF_DROP)
>  			NF_CT_STAT_INC_ATOMIC(net, drop);
> +		if (ret == -NF_REPEAT && tmpl)
> +			goto repeat;

This is my fault, I'm going to mangle this patch since 08733a0cb7de
really broke the NF_REPEAT handling. We should inconditionally jump
back to repeat if we get NF_REPEAT, no matter if the template is set
or not. I'll include a side node on this mangling.

>  		ret = -ret;
>  		goto out;
>  	}
> @@ -1349,10 +1351,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
>  		 * closed/aborted connection. We have to go back and create a
>  		 * fresh conntrack.
>  		 */

I'm going to move the comment above on top of the NF_REPEAT check, so
it still keeps around as context.

BTW, the revamped patch looks like the one attached.

Thanks a lot for addressing this fallout.

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=x

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index de4b8a75f30b..e9ffe33dc0ca 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1337,6 +1337,12 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
 			NF_CT_STAT_INC_ATOMIC(net, drop);
+		/* Special case: TCP tracker reports an attempt to reopen a
+		 * closed/aborted connection. We have to go back and create a
+		 * fresh conntrack.
+		 */
+		if (ret == -NF_REPEAT)
+			goto repeat;
 		ret = -ret;
 		goto out;
 	}
@@ -1344,16 +1350,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
 		nf_conntrack_event_cache(IPCT_REPLY, ct);
 out:
-	if (tmpl) {
-		/* Special case: TCP tracker reports an attempt to reopen a
-		 * closed/aborted connection. We have to go back and create a
-		 * fresh conntrack.
-		 */
-		if (ret == NF_REPEAT)
-			goto repeat;
-		else
-			nf_ct_put(tmpl);
-	}
+	if (tmpl)
+		nf_ct_put(tmpl);
 
 	return ret;
 }

--cWoXeonUoKmBZSoM--
