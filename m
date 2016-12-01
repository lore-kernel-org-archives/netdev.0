From: Artem Savkov <asavkov@redhat.com>
Subject: Re: [PATCH] ip6_offload: check segs for NULL in ipv6_gso_segment.
Date: Thu, 1 Dec 2016 16:07:03 +0100
Message-ID: <20161201150703.dv463hxgqajqo6pm@shodan.usersys.redhat.com>
References: <1480597564-32355-1-git-send-email-asavkov@redhat.com>
 <1480602847.18162.288.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jstancek@redhat.com,
        steffen.klassert@secunet.com, alexander.h.duyck@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480602847.18162.288.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2016 at 06:34:07AM -0800, Eric Dumazet wrote:
> On Thu, 2016-12-01 at 14:06 +0100, Artem Savkov wrote:
> > segs needs to be checked for being NULL in ipv6_gso_segment() before calling
> > skb_shinfo(segs), otherwise kernel can run into a NULL-pointer dereference:
> 
> 
> > Signed-off-by: Artem Savkov <asavkov@redhat.com>
> > ---
> >  
> 
> > diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> > index 1fcf61f..89c59e6 100644
> > --- a/net/ipv6/ip6_offload.c
> > +++ b/net/ipv6/ip6_offload.c
> > @@ -99,7 +99,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
> >  		segs = ops->callbacks.gso_segment(skb, features);
> >  	}
> >  
> > -	if (IS_ERR(segs))
> > +	if (IS_ERR_OR_NULL(segs))
> >  		goto out;
> >  
> >  	gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> 
> Do you know when was this bug added ?

It started to show up with 4.9-rc4, from what I see the culprit is
07b26c9 gso: Support partial splitting at the frag_list pointer

> Are you sure this is the right fix ?

I am not, but this would have the same behavior as pre-07b26c9 code and
IS_ERR_OR_NULL is used in ipv4's inet_gso_segment().

> Which gso_segment() is returning NULL exactly ?

Unfortunatelly I don't know that and I don't have a good reproducer, the
only way to reproduce this that I currently have is calling
virt-install.

-- 
Regards,
  Artem
