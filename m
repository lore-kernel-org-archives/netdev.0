From: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Wed, 26 Apr 2017 20:52:30 +0800
Message-ID: <20170426125230.GB19179@dhcp-13-42.nay.redhat.com>
References: <1493114155-12101-1-git-send-email-honli@redhat.com>
 <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
 <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
 <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com>
 <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
 <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
 <1493134815.3041.72.camel@redhat.com>
 <CAJ3xEMjqkJrKi+6ronuPBn2P6y8p6sdhVppDzFtMwQrhL13bzg@mail.gmail.com>
 <1493192794.2409.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1493192794.2409.3.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 09:46:34AM +0200, Paolo Abeni wrote:
> On Wed, 2017-04-26 at 00:50 +0300, Or Gerlitz wrote:
> > so maybe @ least for the time being, we should be picking Hong's patch
> > with proper change log and without the giant stack dump till we have
> > something better. If you agree, can you do the re-write of the change
> > log?
> 
> I think that Hong's patch is following the correct way to fix the
> issue: ipoib_hard_header() can't assume that the skb headroom is at
> least IPOIB_HARD_LEN bytes, as wrongly implied by commit fc791b633515
> (my fault, I'm sorry).
> 
> Perhaps we can make the code a little more robust with something
> alongside the following (only compile tested):
> ---
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> index d1d3fb7..d53d2e1 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> @@ -1160,6 +1160,11 @@ static int ipoib_hard_header(struct sk_buff *skb,
>                              const void *daddr, const void *saddr, unsigned len)
>  {
>         struct ipoib_header *header;
> +       int ret;
> +
> +       ret = skb_cow_head(skb, IPOIB_HARD_LEN);

I don't think so. When this skb_under_panic arise, all slaves had been
removed from a busy bonding interface, so it is better to immediately
give up and return error.

> +       if (ret)
> +               return ret;
>  
>         header = (struct ipoib_header *) skb_push(skb, sizeof *header);
> ---
> 
> Paolo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
