From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: the TSO packet mangling issue
Date: Fri, 28 Jan 2005 23:25:42 +0300
Message-ID: <20050128202542.GA23670@yakov.inr.ac.ru>
References: <20050121204024.6f94fc26.davem@davemloft.net> <20050122054346.GA1635@gondor.apana.org.au> <20050122170533.GB11499@yakov.inr.ac.ru> <20050123071027.GA20296@gondor.apana.org.au> <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au> <20050127110946.GA20494@gondor.apana.org.au> <20050127111201.GB20494@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050127111201.GB20494@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This patch adds tcp_skb_cow() and uses it in e1000/tg3.

Looks almost nice to me.

Actually, I would prefer to unbind this from tcp, it can be used
for something else, sctp or anything else who sends clones of skbs
and wants to protect only data part.

Also, tcp_skb_cow() is not good. F.e. the first thing, which I thought
of, was WLAN drivers which rewrite ethernet header and either screw up
tcpdumps (and break net/bridge) or have to copy each tcp skb.
I used to patch it with:

diff -ru ../madwifi-cvs.current/madwifi/driver/if_ath.c madwifi/driver/if_ath.c
--- ../madwifi-cvs.current/madwifi/driver/if_ath.c      2004-06-08 17:38:20.587760856 +0400
+++ madwifi/driver/if_ath.c     2004-06-04 11:06:43.000000000 +0400
@@ -759,7 +759,9 @@

        if (ic->ic_flags & IEEE80211_F_WEPON)
                len += IEEE80211_WEP_IVLEN + IEEE80211_WEP_KIDLEN;
-       if ((skb_headroom(skb) < len) &&
+
+       if (len < skb_headroom(skb)) len=skb_headroom(skb);
+       if ((skb_cloned(skb) || (skb_headroom(skb) < len)) &&
            pskb_expand_head(skb, len - skb_headroom(skb), 0, GFP_ATOMIC)) {
                dev_kfree_skb(skb);
                return -ENOMEM;

I think it would be good to make a function sort of:

static inline int skb_header_cloned(struct sk_buff *skb)
{
	int dataref;

	if (!skb->cloned)
		return 0;

	dataref = atomic_read(&skb_shinfo(skb)->dataref);
	dataref -= !!(dataref & SKB_DATAREF_TCP);
	dataref &= SKB_DATAREF_MASK;
	return (dataref != 1);
}

In this case many of skb_cloned() could be just replaced with
skb_header_cloned().

Alexey
