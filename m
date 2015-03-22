From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 3/5] mpls: Differentiate implicit-null and unlabeled neighbours
Date: Sun, 22 Mar 2015 14:49:32 -0500
Message-ID: <87fv8w95ir.fsf@x220.int.ebiederm.org>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-4-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56606 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbbCVTxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:53:22 -0400
In-Reply-To: <1426866170-28739-4-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Fri, 20 Mar 2015 15:42:48 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> The control plane can advertise labels for neighbours that don't have
> an outgoing label. RFC 3032 s3.22 states that either the remaining
> labels should be popped (if the control plane can determine that it's
> safe to do so, which in light of MPLS-VPN, RFC 4364, is never the case
> now) or that the packet should be discarded.

I can not figure out what you are referring to.  There is no section 3.2
in RFC3022.

> Therefore, if the peer is unlabeled and the last label wasn't popped
> then drop the packet. The peer being unlabeled is signalled by an
> empty label stack. However, implicit-null still needs to be supported
> (i.e. penultimate hop popping) where the incoming label is popped and
> no labels are put on and the packet can still go out labeled with the
> unpopped part of the stack. This is achieved by the control plane
> specifying a label stack consisting of the single special
> implicit-null value.

As I understand it you want to handle the case for a label for which
there is no next hop, and the packet should be black-holed.

In struct mpls_route such routes are currently represented by routes
that have no network device.  And in rtnetlink should be represented
with routes of type RTN_BLACKHOLE which I do not currently support
parsing.  But that should be simple enough to correc.t

With respect to Implicit NULL it should be an error to accept a route
that has an RTA_NEWDST that includes an implicit NULL.

The rtnetlink is not ldp nor should it have ldp semantics and be made
complicated by those semantics.

The semantics of RTA_NEWDST are the labels to push on after the top most
label has been popped off.  I see no reason to include other mechanisms
into that processing when it is easy enough to add or tweak other
attributes to have those semantics.

Certainly it is not something that I think is worth special casing on
the fast path in mpls_forward.

> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 21 +++++++++++++++++----
>  1 file changed, 17 insertions(+), 4 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index bf3459a..e3586a7 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -28,7 +28,8 @@ struct mpls_route { /* next hop label forwarding entry */
>  	struct rcu_head		rt_rcu;
>  	u32			rt_label[MAX_NEW_LABELS];
>  	u8			rt_protocol; /* routing protocol that set this entry */
> -	u8			rt_labels;
> +	u8                      rt_unlabeled : 1;
> +	u8			rt_labels : 7;
>  	u8			rt_via_alen;
>  	u8			rt_via_table;
>  	u8			rt_via[0];
> @@ -201,6 +202,11 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  	if (unlikely(!new_header_size && dec.bos)) {
>  		if (!mpls_egress(rt, skb, dec))
>  			goto drop;
> +	} else if (rt->rt_unlabeled) {
> +		/* Labeled traffic destined to unlabeled peer should
> +		 * be discarded
> +		 */
> +		goto drop;
>  	} else {
>  		bool bos;
>  		int i;
> @@ -385,9 +391,16 @@ static int mpls_route_add(struct mpls_route_config *cfg)
>  	if (!rt)
>  		goto errout;
>  
> -	rt->rt_labels = cfg->rc_output_labels;
> -	for (i = 0; i < rt->rt_labels; i++)
> -		rt->rt_label[i] = cfg->rc_output_label[i];
> +	if (cfg->rc_output_labels == 1 &&
> +	    cfg->rc_output_label[0] == LABEL_IMPLICIT_NULL) {
> +		rt->rt_labels = 0;
> +	} else {
> +		rt->rt_labels = cfg->rc_output_labels;
> +		for (i = 0; i < rt->rt_labels; i++)
> +			rt->rt_label[i] = cfg->rc_output_label[i];
> +		if (!rt->rt_labels)
> +			rt->rt_unlabeled = true;
> +	}
>  	rt->rt_protocol = cfg->rc_protocol;
>  	RCU_INIT_POINTER(rt->rt_dev, dev);
>  	rt->rt_via_table = cfg->rc_via_table;
