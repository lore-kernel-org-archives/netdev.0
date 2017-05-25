From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 6/6] net: mpls: minor cleanups
Date: Thu, 25 May 2017 12:46:07 -0700
Message-ID: <1495741567.29207.18.camel@perches.com>
References: <20170525035442.51407-1-dsahern@gmail.com>
         <20170525035442.51407-7-dsahern@gmail.com>
         <20170525.145631.1427287907712541949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0051.hostedemail.com ([216.40.44.51]:42382 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1036675AbdEYTqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 15:46:12 -0400
In-Reply-To: <20170525.145631.1427287907712541949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-25 at 14:56 -0400, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Wed, 24 May 2017 21:54:42 -0600
> 
> > Noticed these doing the extack support:
> > - nla_get_via is only used in af_mpls.c so remove from internal.h
>  ...
> > @@ -43,6 +43,9 @@ static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
> >                      struct nlmsghdr *nlh, struct net *net, u32 portid,
> >                      unsigned int nlm_flags);
> >  
> > +static int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
> > +                    u8 via[], struct netlink_ext_ack *extack);
> > +
> >  static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
> >  {
> >       struct mpls_route *rt = NULL;
> 
> David, please mark the actual defintion static as well.
> 
> I'm surprised the compiler accepts this, but it does :-)

As well, the function should be reordered
in the file to avoid the prototype.

Something like:
---
 net/mpls/af_mpls.c  | 84 ++++++++++++++++++++++++++---------------------------
 net/mpls/internal.h |  2 --
 2 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 257ec66009da..9b534dc25b9b 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -718,6 +718,48 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 	return err;
 }
 
+static int nla_get_via(const struct nlattr *nla, u8 *via_alen,
+		       u8 *via_table, u8 via_addr[])
+{
+	struct rtvia *via = nla_data(nla);
+	int err = -EINVAL;
+	int alen;
+
+	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
+		goto errout;
+	alen = nla_len(nla) -
+			offsetof(struct rtvia, rtvia_addr);
+	if (alen > MAX_VIA_ALEN)
+		goto errout;
+
+	/* Validate the address family */
+	switch (via->rtvia_family) {
+	case AF_PACKET:
+		*via_table = NEIGH_LINK_TABLE;
+		break;
+	case AF_INET:
+		*via_table = NEIGH_ARP_TABLE;
+		if (alen != 4)
+			goto errout;
+		break;
+	case AF_INET6:
+		*via_table = NEIGH_ND_TABLE;
+		if (alen != 16)
+			goto errout;
+		break;
+	default:
+		/* Unsupported address family */
+		goto errout;
+	}
+
+	memcpy(via_addr, via->rtvia_addr, alen);
+	*via_alen = alen;
+	err = 0;
+
+errout:
+	return err;
+}
+
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 			 struct mpls_nh *nh, int oif, struct nlattr *via,
 			 struct nlattr *newdst, u8 max_labels)
@@ -1594,48 +1636,6 @@ int nla_get_labels(const struct nlattr *nla,
 }
 EXPORT_SYMBOL_GPL(nla_get_labels);
 
-int nla_get_via(const struct nlattr *nla, u8 *via_alen,
-		u8 *via_table, u8 via_addr[])
-{
-	struct rtvia *via = nla_data(nla);
-	int err = -EINVAL;
-	int alen;
-
-	if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
-		goto errout;
-	alen = nla_len(nla) -
-			offsetof(struct rtvia, rtvia_addr);
-	if (alen > MAX_VIA_ALEN)
-		goto errout;
-
-	/* Validate the address family */
-	switch (via->rtvia_family) {
-	case AF_PACKET:
-		*via_table = NEIGH_LINK_TABLE;
-		break;
-	case AF_INET:
-		*via_table = NEIGH_ARP_TABLE;
-		if (alen != 4)
-			goto errout;
-		break;
-	case AF_INET6:
-		*via_table = NEIGH_ND_TABLE;
-		if (alen != 16)
-			goto errout;
-		break;
-	default:
-		/* Unsupported address family */
-		goto errout;
-	}
-
-	memcpy(via_addr, via->rtvia_addr, alen);
-	*via_alen = alen;
-	err = 0;
-
-errout:
-	return err;
-}
-
 static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			       struct mpls_route_config *cfg)
 {
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 4db6a5971322..b431c6d3893f 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -204,8 +204,6 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 		   u32 label[]);
-int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
-		u8 via[]);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
