From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 2/3] [NET]: Pack struct hh_cache
Date: Mon, 27 Nov 2006 18:05:06 -0200
Message-ID: <20061127200505.GY11605@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:39043 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1758550AbWK0UF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 15:05:27 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[acme@newtoy net-2.6.20]$ pahole net/ipv4/tcp.o hh_cache
/* /pub/scm/linux/kernel/git/acme/net-2.6.20/include/linux/netdevice.h:190 */
struct hh_cache {
        struct hh_cache *          hh_next;              /*     0     4 */
        atomic_t                   hh_refcnt;            /*     4     4 */
        __be16                     hh_type;              /*     8     2 */

        /* XXX 2 bytes hole, try to pack */

        int                        hh_len;               /*    12     4 */
        int                        (*hh_output)();       /*    16     4 */
        rwlock_t                   hh_lock;              /*    20    36 */
        long unsigned int          hh_data[24];          /*    56    96 */
}; /* size: 152, sum members: 150, holes: 1, sum holes: 2 */

[acme@newtoy net-2.6.20]$ find net -name "*.[ch]" | xargs grep 'hh_len.\+=' | sort -u
net/atm/br2684.c:               hh->hh_len = PADLEN + ETH_HLEN;
net/ethernet/eth.c:     hh->hh_len = ETH_HLEN;
net/ipv4/ipconfig.c:    int hh_len = LL_RESERVED_SPACE(dev);
net/ipv4/ip_output.c:   hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
net/ipv4/ip_output.c:   int hh_len = LL_RESERVED_SPACE(dev);
net/ipv4/netfilter.c:   hh_len = (*pskb)->dst->dev->hard_header_len;
net/ipv4/raw.c: hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
net/ipv6/ip6_output.c:  hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
net/ipv6/netfilter/ip6t_REJECT.c:       hh_len = (dst->dev->hard_header_len + 15)&~15;
net/ipv6/raw.c: hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
[acme@newtoy net-2.6.20]$

[acme@newtoy net-2.6.20]$ find include -name "*.h" | xargs grep 'define ETH_HLEN'
include/linux/if_ether.h:#define ETH_HLEN       14              /* Total octets in header.       */

        (((dev)->hard_header_len&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)

[acme@newtoy net-2.6.20]$ pahole net/ipv4/tcp.o net_device | grep hard_header_len
        short unsigned int         hard_header_len;      /*   106     2 */
[acme@newtoy net-2.6.20]$

So I think we're safe in turning hh_len an u16, end result:

[acme@newtoy net-2.6.20]$ codiff -sV /tmp/tcp.o.before net/ipv4/tcp.o
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/tcp.c:
  struct hh_cache |   -4
    hh_len;
     from: int                   /*    12(0)     4(0) */
     to:   u16                   /*    10(0)     2(0) */
 1 struct changed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 50d95ac..ce4df7b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -194,7 +194,7 @@ struct hh_cache
                                          *  NOTE:  For VLANs, this will be the
                                          *  encapuslated type. --BLG
                                          */
-	int		hh_len;		/* length of header */
+	u16		hh_len;		/* length of header */
 	int		(*hh_output)(struct sk_buff *skb);
 	rwlock_t	hh_lock;
 
-- 
1.4.2.1.g3d5c

