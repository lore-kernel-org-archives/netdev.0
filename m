From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 14:13:42 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0807241407410.8109@nehalem.linux-foundation.org>
References: <20080724060448.GA10203@elte.hu>  <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>  <20080724.022259.113079007.davem@davemloft.net>  <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>  <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net>
 <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com> <48887A71.5010209@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753457AbYGXVUE@vger.kernel.org>
In-Reply-To: <48887A71.5010209@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 24 Jul 2008, Patrick McHardy wrote:
> 
> To fix this I think we need a __krealloc() that doesn't
> free the old memory, especially since it must not be
> freed immediately because it may still be used in a RCU
> read side (see the last part in the patch attached to
> this mail (based on a kernel without your patch)).

Hmm. Don't you need to fix some of the ordering of the initialization too?

If there are possible readers that happen in parallel with changing this 
thing, don't you need to protect the update of "ext->len" against the 
actual changes? And the readers should probably have a read barrier 
between checking "len" and actually looking at the values? Finally, why do 
the "ct->ext" dereference thing, when we know it has to be equal to "new"?

ie something like this on the writing side (in _addition_ to both the 
patches already seen), but I didn't do the reading side (ie there are no 
"smp_rmb()"'s on the reading side)

And no, I don't know the code, so I don't know who/what can read those 
things with RCU, so maybe there is some reason why the actual data doesn't 
need protecting. But I somehow doubt it.

		Linus

---
 net/netfilter/nf_conntrack_extend.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 3469bc7..135e095 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -115,10 +115,11 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 		ct->ext = new;
 	}
 
-	ct->ext->offset[id] = newoff;
-	ct->ext->len = newlen;
-	memset((void *)ct->ext + newoff, 0, newlen - newoff);
-	return (void *)ct->ext + newoff;
+	new->offset[id] = newoff;
+	memset((void *)new + newoff, 0, newlen - newoff);
+	smp_wmb();
+	new->len = newlen;
+	return (void *)new + newoff;
 }
 EXPORT_SYMBOL(__nf_ct_ext_add);
 
