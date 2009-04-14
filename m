From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Tue, 14 Apr 2009 13:32:29 +0200
Message-ID: <49E4744D.5090205@trash.net>
References: <20090410191736.21efab8c@mako-desktop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080301010504090100010307"
Cc: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netfilter Development Mailinglist
	<netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090410191736.21efab8c@mako-desktop>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080301010504090100010307
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Mariusz Kozlowski wrote:
> 	Recent kernels (i.e. 2.6.30-rc1) will panic while doing rmmod of nf_conntrack_irc.
> 
> (gdb) l *(nf_conntrack_helper_unregister+0x158)
> 0x4f8 is in nf_conntrack_helper_unregister (/home/mako/linux/lkt/sources/linux-2.6/include/net/netfilter/nf_conntrack.h:133).
> 128	};
> 129	
> 130	static inline struct nf_conn *
> 131	nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_hash *hash)
> 132	{
> 133		return container_of(hash, struct nf_conn,
> 134				    tuplehash[hash->tuple.dst.dir]);
> 135	}
> 136	
> 137	static inline u_int16_t nf_ct_l3num(const struct nf_conn *ct)
> 
> 
> I bisected it down to
> 
>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()

Thanks for the report. Does this patch fix it?


--------------080301010504090100010307
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 30b8e90..0fa5a42 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -176,7 +176,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
+	hlist_nulls_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)

--------------080301010504090100010307--
