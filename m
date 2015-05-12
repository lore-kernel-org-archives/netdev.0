From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 5/5] net: Add GRE keyid in flow_keys
Date: Mon, 11 May 2015 21:50:37 -0700
Message-ID: <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	 <1431401204-731380-6-git-send-email-tom@herbertland.com>
	 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37415 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbbELEuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 00:50:39 -0400
Received: by igbsb11 with SMTP id sb11so92719375igb.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 21:50:38 -0700 (PDT)
In-Reply-To: <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-11 at 21:33 -0700, Eric Dumazet wrote:
> On Mon, 2015-05-11 at 20:26 -0700, Tom Herbert wrote:
> > In flow dissector if a GRE header contains a keyid this is saved in the
> > new extra entropy field of flow_keys. The GRE keyid is then represented
> > in the flow hash function input.
> > 
> > Signed-off-by: Tom Herbert <tom@herbertland.com>
> > ---
> >  include/net/flow_keys.h   |  1 +
> >  net/core/flow_dissector.c | 15 ++++++++++++++-
> >  2 files changed, 15 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> > index 906d47a..779e42f 100644
> > --- a/include/net/flow_keys.h
> > +++ b/include/net/flow_keys.h
> > @@ -28,6 +28,7 @@ struct flow_keys {
> >  	u8	padding;
> >  	u32	vlan_id:12,
> >  		flow_label:20;
> > +	u32	extra_entropy;
> >  
> >  	union {
> >  		__be32 ports;
> > diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> > index de71e42..025b91f 100644
> > --- a/net/core/flow_dissector.c
> > +++ b/net/core/flow_dissector.c
> > @@ -195,8 +195,21 @@ ipv6:
> >  			nhoff += 4;
> >  			if (hdr->flags & GRE_CSUM)
> >  				nhoff += 4;
> > -			if (hdr->flags & GRE_KEY)
> > +			if (hdr->flags & GRE_KEY) {
> > +				const __be32 *keyid;
> > +				__be32 _keyid;
> > +
> > +				keyid = __skb_header_pointer(skb, nhoff,
> > +							     sizeof(_keyid),
> > +							     data, hlen,
> > +							     &_keyid);
> > +				if (!keyid)
> > +					return false;
> > +
> > +				flow->extra_entropy ^= *keyid;
> 
> 
> This probably should not please sparse ?
> 
> make C=2 CF=-D__CHECK_ENDIAN__  net/core/flow_dissector.o
> 

BTW, you never addressed prior feedback about sparse errors :

include/linux/skbuff.h:3054:24: warning: incorrect type in return expression (different base types)
include/linux/skbuff.h:3054:24:    expected restricted __sum16
include/linux/skbuff.h:3054:24:    got int
include/linux/skbuff.h:3054:24: warning: incorrect type in return expression (different base types)
include/linux/skbuff.h:3054:24:    expected restricted __sum16
include/linux/skbuff.h:3054:24:    got int
include/linux/skbuff.h:3362:14: warning: incorrect type in assignment (different base types)
include/linux/skbuff.h:3362:14:    expected unsigned short [unsigned] [usertype] csum
include/linux/skbuff.h:3362:14:    got restricted __sum16
include/linux/skbuff.h:3367:16: warning: incorrect type in return expression (different base types)
include/linux/skbuff.h:3367:16:    expected restricted __sum16
include/linux/skbuff.h:3367:16:    got unsigned short [unsigned] [usertype] csum

commit 7e2b10c1e52ca37f ("net: Support for multiple checksums with gso")

Thanks
