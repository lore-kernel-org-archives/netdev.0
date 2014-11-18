From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net 1/4] net: Add vxlan_gso_check() helper
Date: Mon, 17 Nov 2014 16:26:00 -0800
Message-ID: <201411171626.00771.joestringer@nicira.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com> <1415925495-59312-2-git-send-email-joestringer@nicira.com> <CAJ3xEMhwq2Cuiw8sjY3DHFBEdmgKieNZgxWhGsfZ=Rtz41KhTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:32809 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752823AbaKRA0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 19:26:06 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so4354676pab.6
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 16:26:05 -0800 (PST)
In-Reply-To: <CAJ3xEMhwq2Cuiw8sjY3DHFBEdmgKieNZgxWhGsfZ=Rtz41KhTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, November 16, 2014 01:35:52 Or Gerlitz wrote:
> On Fri, Nov 14, 2014 at 2:38 AM, Joe Stringer <joestringer@nicira.com> 
wrote:
> > Most NICs that report NETIF_F_GSO_UDP_TUNNEL support VXLAN, and not
> > other UDP-based encapsulation protocols where the format and size of the
> > header differs. This patch implements a generic ndo_gso_check() for
> > VXLAN which will only advertise GSO support when the skb looks like it
> > contains VXLAN (or no UDP tunnelling at all).
> > 
> > Implementation shamelessly stolen from Tom Herbert:
> > http://thread.gmane.org/gmane.linux.network/332428/focus=333111
> > 
> > Signed-off-by: Joe Stringer <joestringer@nicira.com>
> > ---
> > v2: Merge helpers for be2net, mlx4, qlcnic
> > 
> >     Use (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
> > 
> > v1: Initial post
> > ---
> > 
> >  drivers/net/vxlan.c |   13 +++++++++++++
> >  include/net/vxlan.h |    2 ++
> >  2 files changed, 15 insertions(+)
> > 
> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> > index fa9dc45..6b65863 100644
> > --- a/drivers/net/vxlan.c
> > +++ b/drivers/net/vxlan.c
> > @@ -1571,6 +1571,19 @@ static bool route_shortcircuit(struct net_device
> > *dev, struct sk_buff *skb)
> > 
> >         return false;
> >  
> >  }
> > 
> > +bool vxlan_gso_check(struct sk_buff *skb)
> > +{
> > +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> > +           (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> > +            skb->inner_protocol != htons(ETH_P_TEB) ||
> > +            (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
> > +             sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
> > +               return false;
> > +
> > +       return true;
> > +}
> > +EXPORT_SYMBOL_GPL(vxlan_gso_check);
> 
> Joe, any chance you can make the extra step and inline that in
> vxlan.h? this is fast path call... you will only need to move struct
> vxlanhdr there too.

Thanks for looking this over, I sent a patch.
