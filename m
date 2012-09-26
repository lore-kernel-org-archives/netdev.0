From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gre: Support GRE over IPv6
Date: Wed, 26 Sep 2012 13:39:20 +0200
Message-ID: <1348659560.5093.337.camel@edumazet-glaptop>
References: <20120913160105.GA29205@elgon.mountain>
	 <20120926110258.GP13767@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43250 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2IZLjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 07:39:24 -0400
Received: by bkcjk13 with SMTP id jk13so252831bkc.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 04:39:23 -0700 (PDT)
In-Reply-To: <20120926110258.GP13767@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Wed, 2012-09-26 at 14:02 +0300, Dan Carpenter wrote:
> Hi Dmitry,
> 
> I never heard back on this whether it was memory corruption bug or
> not?
> 
> regards,
> dan carpenter
> 
> On Thu, Sep 13, 2012 at 07:01:05PM +0300, Dan Carpenter wrote:
> > Hello Dmitry Kozlov,
> > 
> > The patch c12b395a4664: "gre: Support GRE over IPv6" from Aug 10, 
> > 2012, leads to the following warning:
> > net/ipv6/ip6_gre.c:1299 ip6gre_header_parse()
> > 	 error: memcpy() 'haddr' too small (8 vs 16)
> > 
> > net/ipv6/ip6_gre.c
> >   1296  static int ip6gre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
> >   1297  {
> >   1298          const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)skb_mac_header(skb);
> >   1299          memcpy(haddr, &ipv6h->saddr, sizeof(struct in6_addr));
> >                        ^^^^^
> > Smatch thinks this buffer is only 8 characters sometimes.
> > 
> >   1300          return sizeof(struct in6_addr);
> >   1301  }
> > 
> > One call tree where this would happen would be the
> > (struct sockaddr_ll *)sll->sll_addr[] in packet_rcv().
> > 
> > -> packet_rcv()
> >    -> dev_parse_header()
> >       -> ip6gre_header_parse()
> > 
> > I don't know the code well enough to say if this is a bug or not.  Could
> > you take a look?


All dev_parse_header() callers provide 8 bytes of storage.

By the way net/netfilter/nfnetlink_log.c and
net/netfilter/nfnetlink_queue_core.c leaks the _pad field to userspace,
I will send a separate patch to netfilter guys.

I would just remove this stuff, as it was copied/pasted from
ipv4/ip_gre.c without thinking of its use.

Thanks

[PATCH net-next] ipv6: gre: remove ip6gre_header_parse()

dev_parse_header() callers provide 8 bytes of storage,
so it's not possible to store an IPv6 address.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/ipv6/ip6_gre.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 424d11a..796f5d5 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1293,16 +1293,8 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 	return -t->hlen;
 }
 
-static int ip6gre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
-{
-	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)skb_mac_header(skb);
-	memcpy(haddr, &ipv6h->saddr, sizeof(struct in6_addr));
-	return sizeof(struct in6_addr);
-}
-
 static const struct header_ops ip6gre_header_ops = {
 	.create	= ip6gre_header,
-	.parse	= ip6gre_header_parse,
 };
 
 static const struct net_device_ops ip6gre_netdev_ops = {
