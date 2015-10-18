From: Florian Westphal <fw@strlen.de>
Subject: Re: linux 3.4.43 : kernel crash at __nf_conntrack_confirm
Date: Sun, 18 Oct 2015 23:40:50 +0200
Message-ID: <20151018214050.GD4386@breakpoint.cc>
References: <CAOxq_8PF91fpX9jYTgBbXnOVeVfSu3tytu-3P_Zr5OodGRoz+g@mail.gmail.com>
 <CAOxq_8Pt7VMwkV8+wdjS9vj=-L0L8Xxkd3Beit0zZN_oR6ixhw@mail.gmail.com>
 <20151018080702.GA14564@breakpoint.cc>
 <CAOxq_8NLLFyNCSDJ68+VjxFGpNSex8ShdhGFNBHK29g_+UBW6g@mail.gmail.com>
 <alpine.OSX.2.20.1510181409060.87917@athabasca.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.OSX.2.20.1510181409060.87917@athabasca.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ani Sinha <ani@arista.com> wrote:
> Indeed. So it seems to me that we have run into one another such case.
> In patch c6825c0976fa7893692, I see we have added an additional check (along with comparing tuple and zone) to verify that if the conntrack is confirmed.
>  
> +       return nf_ct_tuple_equal(tuple, &h->tuple) &&
> +               nf_ct_zone(ct) == zone &&
> +               nf_ct_is_confirmed(ct);
> 
> This is necessary since it's possible that a conntrack can be recreated with the same zone.
> Unfortunately, we leave a hole open in __nf_conntrack_confirm() because this routine _is_ responsible
> for confirming the conntrack. We cannot use the same logic here.

Hmm, why?

I don't understand why we need to change __nf_conntrack_confirm(), can
you elaborate?

At __nf_conntrack_confirm call time, only one cpu can see this nfct entry.
Other cpus on read-side can see it due to object re-use but any of the
following tests should fail:

1. different tuples
2. differnet zones
3. CONFIRMED not set

So they would skip entry and restart lookup (NULs value mismatch).

> Should I send a patch along the lines of :
>  
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 71935fc..6ff4088 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -535,6 +535,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
>  			goto out;
>  
> +	/* we might be racing against a case where the conntrack was deleted 
> +	   and a new conntrack was initialized with the exact same zone. We
> +	   need to make sure that the conntrack node is in the hashtable */

?

The conntrack is NOT in the hashtable at this point.  Its not even on
the unconfirmed list since we already removed it in preparation of
hashtable insertion.

> +	if (hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode))
> +	  goto out;

That would be a bug, how can ->nfct be confirmed twice?

If you're talking about IPS_CONFIRMED getting set -- that should be
harmless.  In some theoretical condition we could indeed observe this
nfct on another cpu, just before we actually insert this but this does
not cause a problem on the read-side since the conntrack matches the
tuple exactly and all extensions have been initialized.

And if we create two conntracks with identical tuples on different CPUs
which is possible regardless of RCU this will be detected during
confirm step (we search ht for a colliding tuple).

So, if there is a problem please describe in more detail, I don't see
anything wrong so far.
