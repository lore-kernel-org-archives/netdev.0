From: Ani Sinha <ani@arista.com>
Subject: Re: linux 3.4.43 : kernel crash at __nf_conntrack_confirm
Date: Sun, 18 Oct 2015 14:12:15 -0700 (PDT)
Message-ID: <alpine.OSX.2.20.1510181409060.87917@athabasca.local>
References: <CAOxq_8PF91fpX9jYTgBbXnOVeVfSu3tytu-3P_Zr5OodGRoz+g@mail.gmail.com> <CAOxq_8Pt7VMwkV8+wdjS9vj=-L0L8Xxkd3Beit0zZN_oR6ixhw@mail.gmail.com> <20151018080702.GA14564@breakpoint.cc>
 <CAOxq_8NLLFyNCSDJ68+VjxFGpNSex8ShdhGFNBHK29g_+UBW6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <CAOxq_8NLLFyNCSDJ68+VjxFGpNSex8ShdhGFNBHK29g_+UBW6g@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> 
> On Sun, Oct 18, 2015 at 1:07 AM, Florian Westphal <fw@strlen.de> wrote:
> > Ani Sinha <ani@arista.com> wrote:
> >> Coming back to this crash, I see something interesting in the
> >> conntrack code in linux 3.4.109 (a supported kernel version). I see
> >> that the hash table manipulations are protected by a spinlock. Also
> >> lookups/reads are protected by RCU. However allocation and
> >> deallocation of conntrack objects happen outside of both the locks.
> >> It seems to me that a conntrack object can be deallocated and a new
> >> object can be allocated and initialized within the same RCU grace
> >> period, while the hash table is being read.
> >
> > Yes.  We need to use SLAB_DESTROY_BY_RCU instead of kfree_rcu because
> > there could be hundreds of thousands of alloc/free pairs within a short
> > time period.
> >
> >> It looks like a bug to me.
> >
> > No, as long as readers detect object reuse.
 
Right.
 
> >
> >> > Looking upstream, I see a couple of patches which fixes race condition
> >> > around the use of the conntrack hash table with RCU (lock free read)
> >> > primitives :
> >> >
> >> > commit c6825c0976fa7893692e0e43b09740b419b23c09
> >> > Author: Andrey Vagin <avagin@openvz.org>
> >> > Date:   Wed Jan 29 19:34:14 2014 +0100
> >> >      netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
> >> >
> >> > and a followup patch :
> >> >
> >> > commit e53376bef2cd97d3e3f61fdc677fb8da7d03d0da
> >> > Author: Pablo Neira Ayuso <pablo@netfilter.org>
> >> > Date:   Mon Feb 3 20:01:53 2014 +0100
> >> >         netfilter: nf_conntrack: don't release a conntrack with non-zero refcnt
> >> >
> >
> > These for instance fix such bugs.
> 
Indeed. So it seems to me that we have run into one another such case.
In patch c6825c0976fa7893692, I see we have added an additional check (along with comparing tuple and zone) to verify that if the conntrack is confirmed.
 
+       return nf_ct_tuple_equal(tuple, &h->tuple) &&
+               nf_ct_zone(ct) == zone &&
+               nf_ct_is_confirmed(ct);
 
 
This is necessary since it's possible that a conntrack can be recreated with the same zone.
Unfortunately, we leave a hole open in __nf_conntrack_confirm() because this routine _is_ responsible
for confirming the conntrack. We cannot use the same logic here. 
 
Should I send a patch along the lines of :
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 71935fc..6ff4088 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -535,6 +535,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 
+	/* we might be racing against a case where the conntrack was deleted 
+	   and a new conntrack was initialized with the exact same zone. We
+	   need to make sure that the conntrack node is in the hashtable */
+	if (hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode))
+	  goto out;
+
 	/* Remove from unconfirmed list */
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 


