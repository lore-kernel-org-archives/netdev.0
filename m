From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC net-next 5/8] nfp: bpf: take a reference on offloaded
 programs
Date: Mon, 19 Jun 2017 16:34:41 -0700
Message-ID: <20170619163441.17c29f77@cakuba.netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
        <20170616235746.16337-6-jakub.kicinski@netronome.com>
        <59485CD9.10003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kafai@fb.com,
        brouer@redhat.com, oss-drivers@netronome.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35618 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752289AbdFSXeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:34:44 -0400
Received: by mail-pf0-f172.google.com with SMTP id c73so584253pfk.2
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 16:34:44 -0700 (PDT)
In-Reply-To: <59485CD9.10003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jun 2017 01:23:05 +0200, Daniel Borkmann wrote:
> On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
> > The xdp_prog member of the adapter's data path structure is used
> > for XDP in driver mode.  In case a XDP program is loaded with in
> > HW-only mode, we need to store it somewhere else.  Add a new XDP
> > prog pointer in the main structure and use that when we need to
> > know whether any XDP program is loaded, not only a driver mode
> > one.  Only release our reference on adapter free instead of
> > immediately after netdev unregister to allow offload to be disabled
> > first.
> >
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>  
> [...]
> > @@ -3327,6 +3323,10 @@ nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog 
> >   		return err;
> >
> >   	nfp_app_xdp_offload(nn->app, nn, offload_prog);
> > +
> > +	if (nn->xdp_prog)
> > +		bpf_prog_put(nn->xdp_prog);
> > +	nn->xdp_prog = prog;
> >   	nn->xdp_flags = flags;
> >
> >   	return 0;  
> 
> Can you elaborate on the extra reference on the prog? 

Sorry, this patch went through a few revisions and the subject doesn't
express the intent too well any more :S  Originally it was about making
sure we have a reference on the program when it's offloaded but not
loaded in the driver, but I realized the we have the reference from 
dev_change_xdp_fd() already, so now the patch just releases the
reference on the offloaded program.

> So in nfp_net_xdp_setup(), assuming a prog was already loaded on
> driver side: after your set, nfp_net_xdp_setup_drv() will then
> do the xchg() on nn->dp.xdp_prog, bpf_prog_put() this one and
> later back in nfp_net_xdp_setup() we check nn->xdp_prog and
> bpf_prog_put() it if it existed before and update nn->xdp_prog
> to the current prog. So you end up with two puts on the same
> program, but I don't see where you take the one additional ref
> aside from the ref that you already get from dev_change_xdp_fd().
> What am I missing?

You are right, I missed there were two spots where I was doing a
bpf_prog_put() in nfp_net_xdp_setup_drv(), thanks!
