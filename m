From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Wed, 26 Apr 2017 09:27:38 -0400
Message-ID: <1493213258.3041.98.camel@redhat.com>
References: <1493114155-12101-1-git-send-email-honli@redhat.com>
         <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
         <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
         <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com>
         <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
         <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
         <1493134815.3041.72.camel@redhat.com>
         <CAJ3xEMjqkJrKi+6ronuPBn2P6y8p6sdhVppDzFtMwQrhL13bzg@mail.gmail.com>
         <1493192794.2409.3.camel@redhat.com>
         <20170426125230.GB19179@dhcp-13-42.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170426125230.GB19179-Y5OA6DF/u0nid9cnFhDO8BcY2uh10dtjAL8bYrjMMd8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-26 at 20:52 +0800, Honggang LI wrote:
> On Wed, Apr 26, 2017 at 09:46:34AM +0200, Paolo Abeni wrote:
> > 
> > On Wed, 2017-04-26 at 00:50 +0300, Or Gerlitz wrote:
> > > 
> > > so maybe @ least for the time being, we should be picking Hong's
> > > patch
> > > with proper change log and without the giant stack dump till we
> > > have
> > > something better. If you agree, can you do the re-write of the
> > > change
> > > log?
> > 
> > I think that Hong's patch is following the correct way to fix the
> > issue: ipoib_hard_header() can't assume that the skb headroom is at
> > least IPOIB_HARD_LEN bytes, as wrongly implied by commit
> > fc791b633515
> > (my fault, I'm sorry).
> > 
> > Perhaps we can make the code a little more robust with something
> > alongside the following (only compile tested):
> > ---
> > diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > index d1d3fb7..d53d2e1 100644
> > --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > @@ -1160,6 +1160,11 @@ static int ipoib_hard_header(struct sk_buff
> > *skb,
> >                              const void *daddr, const void *saddr,
> > unsigned len)
> >  {
> >         struct ipoib_header *header;
> > +       int ret;
> > +
> > +       ret = skb_cow_head(skb, IPOIB_HARD_LEN);
> 
> I don't think so. When this skb_under_panic arise, all slaves had
> been
> removed from a busy bonding interface,

I'm not sure this entirely makes sense.  If all slaves had been
removed, then we should never end up in ipoib_hard_header.  That should
only be called as long as there is at least one slave still attached to
the bond.  It might be during the process of removing the final slave,
but I don't think it can be after the final slave has been fully
removed from the bond.  Paolo, what should the bond driver be doing
once the slaves are gone?  Wouldn't it just be dropping every skb on
the floor without calling anyone's hard header routine?

>  so it is better to immediately
> give up and return error.
> 
> > 
> > +       if (ret)
> > +               return ret;
> >  
> >         header = (struct ipoib_header *) skb_push(skb, sizeof
> > *header);
> > ---
> > 
> > Paolo
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-
> > rdma" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
