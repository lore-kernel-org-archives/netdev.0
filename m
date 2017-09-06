From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] xdp: implement xdp_redirect_map for generic
 XDP
Date: Wed, 6 Sep 2017 18:01:39 +0200
Message-ID: <20170906180139.1764ca77@redhat.com>
References: <150471158528.3727.12324542627400287360.stgit@firesoul>
        <CAHashqBPDDETq2qdj3n8uL3hE61f=a5cv_eF6a9apoRzNVqaxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        John Fastabend <john.fastabend@gmail.com>, brouer@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34762 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753586AbdIFQBp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 12:01:45 -0400
In-Reply-To: <CAHashqBPDDETq2qdj3n8uL3hE61f=a5cv_eF6a9apoRzNVqaxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Sep 2017 11:44:18 -0400
Andy Gospodarek <andy@greyhouse.net> wrote:

> On Wed, Sep 6, 2017 at 11:26 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > Using bpf_redirect_map is allowed for generic XDP programs, but the
> > appropriate map lookup was never performed in xdp_do_generic_redirect().
> >
> > Instead the map-index is directly used as the ifindex.  For the
> > xdp_redirect_map sample in SKB-mode '-S', this resulted in trying
> > sending on ifindex 0 which isn't valid, resulting in getting SKB
> > packets dropped.  Thus, the reported performance numbers are wrong in
> > commit 24251c264798 ("samples/bpf: add option for native and skb mode
> > for redirect apps") for the 'xdp_redirect_map -S' case.
> >
> > It might seem innocent this was lacking, but it can actually crash the
> > kernel.  The potential crash is caused by not consuming redirect_info->map.
> > The bpf_redirect_map helper will set this_cpu_ptr(&redirect_info)->map
> > pointer, which will survive even after unloading the xdp bpf_prog and
> > deallocating the devmap data-structure.  This leaves a dead map
> > pointer around.  The kernel will crash when loading the xdp_redirect
> > sample (in native XDP mode) as it doesn't reset map (via bpf_redirect)
> > and returns XDP_REDIRECT, which will cause it to dereference the map
> > pointer.  
> 
> Nice catch!
> 
> Since 'net-next' is closed and this is a bugfix it seems like this is
> a good candidate for 'net' right?

Yes, I know 'net-next' is closed, but 'net' doesn't contain the
XDP_REDIRECT code yet... thus I had to base it on net-next ;-)


> >
> > Fixes: 6103aa96ec07 ("net: implement XDP_REDIRECT for xdp generic")
> > Fixes: 24251c264798 ("samples/bpf: add option for native and skb mode for redirect apps")
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> Acked-by: Andy Gospodarek <andy@greyhouse.net>

Thanks
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
