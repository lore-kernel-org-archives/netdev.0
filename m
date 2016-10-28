From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] [rfc, netfilter-next] netfilter: nf_tables: fib warnings
Date: Fri, 28 Oct 2016 18:21:49 +0200
Message-ID: <20161028162149.GA23891@breakpoint.cc>
References: <20161028153124.3773180-1-arnd@arndb.de>
 <20161028155031.GI23011@breakpoint.cc>
 <18995804.9DSMHNUO14@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <18995804.9DSMHNUO14@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> On Friday, October 28, 2016 5:50:31 PM CEST Florian Westphal wrote:
> > Arnd Bergmann <arnd@arndb.de> wrote:
> > > The newly added nft fib code produces two warnings:
> > > 
> > > net/ipv4/netfilter/nft_fib_ipv4.c: In function 'nft_fib4_eval':
> > > net/ipv4/netfilter/nft_fib_ipv4.c:80:6: error: unused variable 'i' [-Werror=unused-variable]
> > > net/ipv4/netfilter/nft_fib_ipv4.c: In function ‘nft_fib4_eval’:
> > > net/ipv4/netfilter/nft_fib_ipv4.c:137:6: error: ‘oif’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > 
> > > The first one is obvious as the only user of that variable is
> > > inside of an #ifdef, but the second one is a bit trickier.
> > > It is clear that 'oif' is uninitialized here if neither
> > > NFTA_FIB_F_OIF nor NFTA_FIB_F_IIF are set.
> > > 
> > > I have no idea how that should be handled, this patch just
> > > returns without doing anything, which may or may not be
> > > the right thing to do.
> > 
> > It should be initialized to NULL.
> 
> Ok, I had considered that, but wasn't sure if ->nh_dev could
> ever be NULL, as that would then get dereferenced.

Good point.  In case oif is NULL we don't have to search the result
list for a match anyway, so we could do this (not even build tested):

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -130,6 +130,11 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
                break;
        }
 
+       if (!oif) {
+               found = FIB_RES_DEV(res);
+               goto ok;
+       }
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
        for (i = 0; i < res.fi->fib_nhs; i++) {
                struct fib_nh *nh = &res.fi->fib_nh[i];
@@ -139,16 +144,12 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
                        goto ok;
                }
        }
-#endif
-       if (priv->flags & NFTA_FIB_F_OIF) {
-               found = FIB_RES_DEV(res);
-               if (found == oif)
-                       goto ok;
-               return;
-       }
-
-       *dest = FIB_RES_DEV(res)->ifindex;
        return;
+#else
+       found = FIB_RES_DEV(res);
+       if (found != oif)
+               return;
+#endif
 ok:
        switch (priv->result) {


I can take care of this as a followup.
