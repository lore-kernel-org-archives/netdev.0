From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Tue, 25 Apr 2017 11:40:15 -0400
Message-ID: <1493134815.3041.72.camel@redhat.com>
References: <1493114155-12101-1-git-send-email-honli@redhat.com>
         <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
         <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
         <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com>
         <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
         <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-04-25 at 17:39 +0300, Or Gerlitz wrote:
> On Tue, Apr 25, 2017 at 2:43 PM, Erez Shitrit <erezsh-LDSdmyG8hGUWn1LaSxwUnA@public.gmane.org
> .il> wrote:
> > 
> > On Tue, Apr 25, 2017 at 2:14 PM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > wrote:
> 
> > 
> > > 
> > > thanks for the info. Is this bug there since ipoib/bonding day
> > > one (and hence my bug...)
> > > or was indeed introduced later? if later, can you explain how
> > > fc791b633515 introduced that or you only know it by bisection?
> 
> > 
> > commit "fc791b633515" changes the size of the dev_hardlen to be 24
> > and
> > required 24 extra bytes in the skb, before it was only 4, if skb is
> > aligned to eth "mode" it already has 14 bytes for hard-header.
> > So only after that commit we have the issue.
> 
> If got you right, Paolo's commit introduced a regression, so we (I
> guess you and
> Paolo) need to either solve it or we (community) should consider a
> revert, please suggest.

It's a little more complex than that.  Paolo's commit *re-introduced* a
regression.  If you recall, long ago the IPoIB layer stuck the dgid
into the skb, then pulled it out later.  However, we didn't actually
declare things properly back then, but it worked anyway.  Then we had
the commit you authored to start using the skb->cb to store the dgid,
and our usage of hard header dropped to only 4 bytes.  Paolo's commit
went back to the old way of doing things, but also did the proper
accounting and setup to tell the netstack what we were doing (which the
initial implementation never did IIRC).  So, this issue should be
reproducible either after Paolo's commit or with any kernel prior to
your commit to use the skb->cb area to store the DGID, but it probably
requires the specific series of actions in this bug to trigger it.  A
normal, clean shutdown of the interface doesn't demonstrate the issue.

> The bug is now in stable and distro kernels, so please act.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
