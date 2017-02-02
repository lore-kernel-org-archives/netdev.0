From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 3/6] gtp: unify genl_find_pdp and prepare for
 per socket lookup
Date: Thu, 2 Feb 2017 15:31:52 +0100
Message-ID: <20170202143152.GA19708@salvia>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-4-aschultz@tpip.net>
 <20170202141951.GA3883@salvia>
 <1732401345.730492.1486045637611.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, laforge <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36608 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751640AbdBBOcB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 09:32:01 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 61420E04CA
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:31:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 533FEA0FC2
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:31:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2543EA0FCE
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:31:57 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1732401345.730492.1486045637611.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 03:27:17PM +0100, Andreas Schultz wrote:
> 
> 
> ----- On Feb 2, 2017, at 3:19 PM, pablo pablo@netfilter.org wrote:
> 
> > On Mon, Jan 30, 2017 at 05:37:10PM +0100, Andreas Schultz wrote:
> >> This unifies duplicate code into a helper. It also prepares the
> >> groundwork to add a lookup version that uses the socket to find
> >> attache pdp contexts.
> >> 
> >> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> >> ---
> >>  drivers/net/gtp.c | 120 +++++++++++++++++++++++-------------------------------
> >>  1 file changed, 51 insertions(+), 69 deletions(-)
> >> 
> >> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> >> index c96c71f..6b7a3c2 100644
> >> --- a/drivers/net/gtp.c
> >> +++ b/drivers/net/gtp.c
> > [...]
> >> +static struct pdp_ctx *gtp_genl_find_pdp(struct sk_buff *skb,
> >> +					 struct genl_info *info)
> >> +{
> >> +	struct pdp_ctx *pctx;
> >> +
> >> +	if (info->attrs[GTPA_LINK])
> >> +		pctx = gtp_genl_find_pdp_by_link(skb, info);
> >> +	else
> >> +		pctx = ERR_PTR(-EINVAL);
> >> +	if (!pctx)
> >> +		pctx = ERR_PTR(-ENOENT);
> >> +
> >> +	return pctx;
> >> +}
> > 
> > For gtp_genl_find_pdp(),  I think this is easier to read:
> > 
> >        if (!info->attrs[GTPA_LINK])
> >                return ERR_PTR(-EINVAL);
> > 
> >        pctx = gtp_genl_find_pdp_by_link(skb, info);
> >	if (!pctx)
> >		return ERR_PTR(-ENOENT);
> > 
> >         return pctx;
> 
> Yes, but a later patch (will be submitted after this series is
> accepted) will change that to:
> 
>         if (info->attrs[GTPA_LINK])
>                 pctx = gtp_genl_find_pdp_by_link(skb, info);
>         else if (info->attrs[GTPA_FD])
>                 pctx = gtp_genl_find_pdp_by_socket(skb, info);
>         else
>                 pctx = ERR_PTR(-EINVAL);
> 
>         if (!pctx)
>                 pctx = ERR_PTR(-ENOENT);
> 
>         return pctx;
> 
> I can use your form for this change, but have a larger change
> later. Which way do you prefer it?

I see, then leave this as it is.
