From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 2/2] net/netlabel: Avoid call to genlmsg_cancel
Date: Fri, 28 Jan 2011 15:58:09 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101281541030.8546@pc-004.diku.dk>
References: <1296224232-8115-2-git-send-email-julia@diku.dk>
 <1296225364.5511.6.camel@sifl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58194 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab1A1O6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 09:58:16 -0500
In-Reply-To: <1296225364.5511.6.camel@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Jan 2011, Paul Moore wrote:

> On Fri, 2011-01-28 at 15:17 +0100, Julia Lawall wrote:
> > genlmsg_cancel subtracts some constants from its second argument before
> > calling nlmsg_cancel.  nlmsg_cancel then calls nlmsg_trim on the same
> > arguments.  nlmsg_trim tests for NULL before doing any computation, but a
> > NULL second argument to genlmsg_cancel is no longer NULL due to the initial
> > subtraction.  Nothing else happens in this execution, so the call to
> > genlmsg_cancel is simply unnecessary in this case.
> > 
> > The semantic match that finds this problem is as follows:
> > (http://coccinelle.lip6.fr/)
> > 
> > // <smpl>
> > @@
> > expression data;
> > @@
> > 
> > if (data == NULL) { ...
> > * genlmsg_cancel(..., data);
> >   ...
> >   return ...;
> > }
> > // </smpl>
> > 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> In all of the cases below, these functions are called multiple times to
> generate data chunks (additional netlink attributes) which are appended
> to an existing skbuff.  I believe that the calls to genlmsg_cancel() are
> still needed to help cleanup in the case where the functions fail on the
> Nth call.
> 
> If I'm wrong, feel free to enlighten me.

Perhaps something is needed, but I don't see how the current code can 
work.  The call is genlmsg_cancel(cb_arg->skb, NULL) in each case.

The definition of genlmsg_cancel is:

static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
{
	nlmsg_cancel(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
}

Now the second argument to nlmsg_cancel is essentially a negative integer 
(or a very large pointer).

nlmsg_cancel will call nlmsg_trim, which is defined as follows:

static inline void nlmsg_trim(struct sk_buff *skb, const void *mark)
{
	if (mark)
		skb_trim(skb, (unsigned char *) mark - skb->data);
}

I guess that the subtraction is going to result in an even larger negative 
number.  The whole process is likely to end in doing nothing in the 
definition of skb_trim, which is as follows:

void skb_trim(struct sk_buff *skb, unsigned int len)
{
	if (skb->len > len)
		__skb_trim(skb, len);
}

since the result of casting a negative number to unsigned is likely to be 
larger than skb->len.


> > ---
> >  net/netlabel/netlabel_cipso_v4.c  |    2 +-
> >  net/netlabel/netlabel_mgmt.c      |    4 ++--
> >  net/netlabel/netlabel_unlabeled.c |    2 +-
> >  3 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
> > index 5f14c84..0a1f77b 100644
> > --- a/net/netlabel/netlabel_cipso_v4.c
> > +++ b/net/netlabel/netlabel_cipso_v4.c
> > @@ -635,7 +635,7 @@ static int netlbl_cipsov4_listall_cb(struct cipso_v4_doi *doi_def, void *arg)
> >  			   cb_arg->seq, &netlbl_cipsov4_gnl_family,
> >  			   NLM_F_MULTI, NLBL_CIPSOV4_C_LISTALL);
> >  	if (data == NULL)
> > -		goto listall_cb_failure;
> > +		return ret_val;
> >  
> >  	ret_val = nla_put_u32(cb_arg->skb, NLBL_CIPSOV4_A_DOI, doi_def->doi);
> >  	if (ret_val != 0)
> > diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
> > index 998e85e..daaa01d 100644
> > --- a/net/netlabel/netlabel_mgmt.c
> > +++ b/net/netlabel/netlabel_mgmt.c
> > @@ -452,7 +452,7 @@ static int netlbl_mgmt_listall_cb(struct netlbl_dom_map *entry, void *arg)
> >  			   cb_arg->seq, &netlbl_mgmt_gnl_family,
> >  			   NLM_F_MULTI, NLBL_MGMT_C_LISTALL);
> >  	if (data == NULL)
> > -		goto listall_cb_failure;
> > +		return ret_val;
> >  
> >  	ret_val = netlbl_mgmt_listentry(cb_arg->skb, entry);
> >  	if (ret_val != 0)
> > @@ -617,7 +617,7 @@ static int netlbl_mgmt_protocols_cb(struct sk_buff *skb,
> >  			   &netlbl_mgmt_gnl_family, NLM_F_MULTI,
> >  			   NLBL_MGMT_C_PROTOCOLS);
> >  	if (data == NULL)
> > -		goto protocols_cb_failure;
> > +		return ret_val;
> >  
> >  	ret_val = nla_put_u32(skb, NLBL_MGMT_A_PROTOCOL, protocol);
> >  	if (ret_val != 0)
> > diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
> > index e2b0a68..b5d3945 100644
> > --- a/net/netlabel/netlabel_unlabeled.c
> > +++ b/net/netlabel/netlabel_unlabeled.c
> > @@ -1141,7 +1141,7 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
> >  			   cb_arg->seq, &netlbl_unlabel_gnl_family,
> >  			   NLM_F_MULTI, cmd);
> >  	if (data == NULL)
> > -		goto list_cb_failure;
> > +		return ret_val;
> >  
> >  	if (iface->ifindex > 0) {
> >  		dev = dev_get_by_index(&init_net, iface->ifindex);
> > 
> 
> -- 
> paul moore
> linux @ hp
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
