From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Thu, 13 Jul 2017 13:14:30 +0200
Message-ID: <20170713131430.7032b5fa@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
        <20170710203050.54b2d8eb@redhat.com>
        <596422E5.6010100@gmail.com>
        <20170711162344.6fd8fb39@redhat.com>
        <5965186E.8060409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdGMLOl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 07:14:41 -0400
In-Reply-To: <5965186E.8060409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jul 2017 11:26:54 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 07/11/2017 07:23 AM, Jesper Dangaard Brouer wrote:
> > On Mon, 10 Jul 2017 17:59:17 -0700
> > John Fastabend <john.fastabend@gmail.com> wrote:
> >   
> >> On 07/10/2017 11:30 AM, Jesper Dangaard Brouer wrote:  
> >>> On Sat, 8 Jul 2017 21:06:17 +0200
> >>> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >>>     
> >>>> On Sat, 08 Jul 2017 10:46:18 +0100 (WEST)
> >>>> David Miller <davem@davemloft.net> wrote:
> >>>>    
> >>>>> From: John Fastabend <john.fastabend@gmail.com>
> >>>>> Date: Fri, 07 Jul 2017 10:48:36 -0700
> >>>>>       
> >>>>>> On 07/07/2017 10:34 AM, John Fastabend wrote:        
> >>>>>>> This series adds two new XDP helper routines bpf_redirect() and
> >>>>>>> bpf_redirect_map(). The first variant bpf_redirect() is meant
> >>>>>>> to be used the same way it is currently being used by the cls_bpf
> >>>>>>> classifier. An xdp packet will be redirected immediately when this
> >>>>>>> is called.        
> >>>>>>
> >>>>>> Also other than the typo in the title there ;) I'm going to CC
> >>>>>> the driver maintainers working on XDP (makes for a long CC list but)
> >>>>>> because we would want to try and get support in as many as possible in
> >>>>>> the next merge window.
> >>>>>>
> >>>>>> For this rev I just implemented on ixgbe because I wrote the
> >>>>>> original XDP support there. I'll volunteer to do virtio as well.        
> >>>>>
> >>>>> I went over this series a few times and it looks great to me.
> >>>>> You didn't even give me some coding style issues to pick on :-)      
> >>>>
> >>>> We (Daniel, Andy and I) have been reviewing and improving on this
> >>>> patchset the last couple of weeks ;-).  We had some stability issues,
> >>>> which is why it wasn't published earlier. My plan is to test this
> >>>> latest patchset again, Monday and Tuesday. I'll try to assess stability
> >>>> and provide some performance numbers.    
> >>>
> >>>
> >>> Damn, I though it was stable, I have been running a lot of performance
> >>> tests, and then this just happened :-(    
> >>
> >> Thanks, I'll take a look through the code and see if I can come up with
> >> why this might happen. I haven't hit it on my tests yet though.  
> > 
> > I've figured out why this happens, and I have a fix, see patch below
> > with some comments with questions.
> >   
> 
> Awesome!
> 
> > The problem is that we can leak map_to_flush in an error path, the fix:
> > 
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 2ccd6ff09493..7f1f48668dcf 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -2497,11 +2497,14 @@ int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
> >         ri->map = NULL;
> >  
> >         trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
> > -
> > +       // Q: Should we also trace "goto out" (failed lookup)?
> > +       //    like bpf_warn_invalid_xdp_redirect();  
> 
> Maybe another trace event? trace_xdp_redirect_failed()
> 
> >         return __bpf_tx_xdp(fwd, map, xdp, index);
> >  out:
> >         ri->ifindex = 0;
> > -       ri->map = NULL;
> > +       // XXX: here we could leak ri->map_to_flush, which could be
> > +       //      picked up later by xdp_do_flush_map()
> > +       xdp_do_flush_map(); /* Clears ri->map_to_flush + ri->map */  
> 
> +1 
> 
> ah map lookup failed and we need to do the flush nice catch.

I'm still getting crashes (but much harder to provoke), but I figured
out why.  We sort of missed one case, where map_to_flush gets set, when
the ndo_xdp_xmit() call starts to fail, and the ixgbe driver then
forgets to call xdp_do_flush_map, if all packets in that NAPI cycle
failed.  We could blame the driver, but yhe clean solution is making
sure, that we don't set map_to_flush when the __bpf_tx_xdp() call
fails. It should also handle the other case I fixed .... I'll cleanup
my PoC-fix patch, test it and provide it here.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
