From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] datapath: 16bit inner_network_header field in struct
 ovs_gso_cb
Date: Wed, 21 May 2014 08:31:47 +0900
Message-ID: <20140520233145.GA30260@verge.net.au>
References: <1400582464-2917-1-git-send-email-horms@verge.net.au>
 <CAEP_g=-1OfxGfRt58TtamGC955f7fG4z9tti3j0crYM73mJ2ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43497 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaETXbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 19:31:52 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=-1OfxGfRt58TtamGC955f7fG4z9tti3j0crYM73mJ2ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 12:54:32PM -0700, Jesse Gross wrote:
> On Tue, May 20, 2014 at 3:41 AM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
> > index b83a4c3..f459c18 100644
> > --- a/datapath/linux/compat/gso.h
> > +++ b/datapath/linux/compat/gso.h
> >  #ifdef NET_SKBUFF_DATA_USES_OFFSET
> > -#define skb_inner_network_header rpl_skb_inner_network_header
> > -static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
> > -{
> > -       return skb->head + OVS_GSO_CB(skb)->inner_network_header;
> > -}
> > -
> >  #define skb_inner_mac_header rpl_skb_inner_mac_header
> >  static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
> >  {
> >         return skb->head + OVS_GSO_CB(skb)->inner_mac_header;
> >  }
> >
> > +#define skb_inner_network_header rpl_skb_inner_network_header
> > +static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
> > +{
> > +       return skb_inner_mac_header(skb) +
> > +               OVS_GSO_CB(skb)->inner_network_header;
> > +}
> > +
> >  #else
> 
> This looks mostly fine to me but doesn't this need to be outside the
> #ifdef NET_SKBUFF_DATA_USES_OFFSET block? Otherwise we will treat the
> offset as a pointer on 32 bit kernels.

Thanks, Somehow I completely missed that.
How about this?


From: Simon Horman <horms@verge.net.au>

[PATCH v1.1] datapath: 16bit inner_network_header field in struct ovs_gso_cb

The motivation for this is to create a 16bit hole in struct ovs_gso_cb
which may be used for the inner_protocol field which is needed
for the proposed implementation of compatibility for MPLS GSO segmentation.

This should be safe as inner_network_header is now an offset to
the inner_mac_header rather than skb->head.

As pointed out by Thomas Graf simply making both inner offsets 16bis is not
safe as there have been cases of overflow with "with collapsed TCP frames
on IB when the headroom grew beyond 64K. See commit 50bceae9bd ``tcp:
Reallocate headroom if it would overflow csum_start'' for additional
details."

This patch is based on suggestions by Thomas Graf and Jesse Gross.

Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---
v1.1
* Move skb_inner_network_header outside #ifdef NET_SKBUFF_DATA_USES_OFFSET
  block so that the 16bit offset is not treated as a pointer on
  32bit kernels.
---
 datapath/linux/compat/gso.h | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
index b83a4c3..3041e88 100644
--- a/datapath/linux/compat/gso.h
+++ b/datapath/linux/compat/gso.h
@@ -11,8 +11,10 @@
 
 struct ovs_gso_cb {
 	struct ovs_skb_cb dp_cb;
-	sk_buff_data_t	inner_network_header;
-	sk_buff_data_t	inner_mac_header;
+	u16		inner_network_header;	/* Offset from
+						 * inner_mac_header */
+	/* 16bit hole */
+	sk_buff_data_t	inner_mac_header;	/* Offset from skb->head */
 	void (*fix_segment)(struct sk_buff *);
 };
 #define OVS_GSO_CB(skb) ((struct ovs_gso_cb *)(skb)->cb)
@@ -20,12 +22,6 @@ struct ovs_gso_cb {
 #define skb_inner_network_header rpl_skb_inner_network_header
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-#define skb_inner_network_header rpl_skb_inner_network_header
-static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
-{
-	return skb->head + OVS_GSO_CB(skb)->inner_network_header;
-}
-
 #define skb_inner_mac_header rpl_skb_inner_mac_header
 static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
 {
@@ -34,12 +30,6 @@ static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
 
 #else
 
-#define skb_inner_network_header rpl_skb_inner_network_header
-static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
-{
-	return OVS_GSO_CB(skb)->inner_network_header;
-}
-
 #define skb_inner_mac_header rpl_skb_inner_mac_header
 static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
 {
@@ -48,6 +38,13 @@ static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
 
 #endif
 
+#define skb_inner_network_header rpl_skb_inner_network_header
+static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
+{
+	return skb_inner_mac_header(skb) +
+		OVS_GSO_CB(skb)->inner_network_header;
+}
+
 #define skb_inner_network_offset rpl_skb_inner_network_offset
 static inline int skb_inner_network_offset(const struct sk_buff *skb)
 {
@@ -64,7 +61,8 @@ static inline int skb_inner_mac_offset(const struct sk_buff *skb)
 static inline void skb_reset_inner_headers(struct sk_buff *skb)
 {
 	BUILD_BUG_ON(sizeof(struct ovs_gso_cb) > FIELD_SIZEOF(struct sk_buff, cb));
-	OVS_GSO_CB(skb)->inner_network_header = skb->network_header;
+	OVS_GSO_CB(skb)->inner_network_header = skb->network_header -
+		skb->mac_header;
 	OVS_GSO_CB(skb)->inner_mac_header = skb->mac_header;
 
 	OVS_GSO_CB(skb)->fix_segment = NULL;
-- 
1.8.4
