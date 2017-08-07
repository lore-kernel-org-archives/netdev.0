From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/1] netvsc: fix rtnl deadlock on unregister of
 vf
Date: Mon, 7 Aug 2017 08:21:00 -0700
Message-ID: <20170807082100.7ba56ac9@xeon-e3>
References: <20170804191400.22471-1-sthemmin@microsoft.com>
        <20170804191400.22471-2-sthemmin@microsoft.com>
        <874ltjedaf.fsf@vitty.brq.redhat.com>
        <87y3qvcxci.fsf@vitty.brq.redhat.com>
        <87a83bcsqo.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
        sthemmin@microsoft.com, netdev@vger.kernel.org
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34259 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdHGPVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:21:03 -0400
Received: by mail-pf0-f179.google.com with SMTP id o86so2882829pfj.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 08:21:02 -0700 (PDT)
In-Reply-To: <87a83bcsqo.fsf@vitty.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Aug 2017 17:17:19 +0200
Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> Vitaly Kuznetsov <vkuznets@redhat.com> writes:
> 
> > Vitaly Kuznetsov <vkuznets@redhat.com> writes:
> >  
> >> Stephen Hemminger <stephen@networkplumber.org> writes:
> >>  
> >>> With new transparent VF support, it is possible to get a deadlock
> >>> when some of the deferred work is running and the unregister_vf
> >>> is trying to cancel the work element. The solution is to use
> >>> trylock and reschedule (similar to bonding and team device).
> >>>
> >>> Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> >>> Fixes: 0c195567a8f6 ("netvsc: transparent VF management")
> >>> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> >>> ---
> >>>  drivers/net/hyperv/netvsc_drv.c | 12 ++++++++++--
> >>>  1 file changed, 10 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> >>> index c71728d82049..e75c0f852a63 100644
> >>> --- a/drivers/net/hyperv/netvsc_drv.c
> >>> +++ b/drivers/net/hyperv/netvsc_drv.c
> >>> @@ -1601,7 +1601,11 @@ static void netvsc_vf_setup(struct work_struct *w)
> >>>  	struct net_device *ndev = hv_get_drvdata(ndev_ctx->device_ctx);
> >>>  	struct net_device *vf_netdev;
> >>>
> >>> -	rtnl_lock();
> >>> +	if (!rtnl_trylock()) {
> >>> +		schedule_work(w);
> >>> +		return;
> >>> +	}
> >>> +
> >>>  	vf_netdev = rtnl_dereference(ndev_ctx->vf_netdev);
> >>>  	if (vf_netdev)
> >>>  		__netvsc_vf_setup(ndev, vf_netdev);
> >>> @@ -1655,7 +1659,11 @@ static void netvsc_vf_update(struct work_struct *w)
> >>>  	struct net_device *vf_netdev;
> >>>  	bool vf_is_up;
> >>>
> >>> -	rtnl_lock();
> >>> +	if (!rtnl_trylock()) {
> >>> +		schedule_work(w);
> >>> +		return;
> >>> +	}
> >>> +  
> >>
> >> So in the situation when we're currently in netvsc_unregister_vf() and
> >> trying to do
> >>         cancel_work_sync(&net_device_ctx->vf_takeover);
> >> 	cancel_work_sync(&net_device_ctx->vf_notify);
> >>
> >> we'll end up not executing netvsc_vf_update() at all, right? Wouldn't it
> >> create an issue as nobody is switching the datapath back to netvsc?
> >>  
> >
> > Actually, looking more at this I think we have additional issues:
> >
> > netvsc_unregister_vf() may get executed _before_ netvsc_vf_update() gets
> > a chance and we just cancel it so the data path is never switched
> > back. I actually have a VM where I suppose it happens ...
> >
> > [    7.235566] hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF up: enP2p0s2
> > [    7.235569] hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: Datapath switched to VF: enP2p0s2
> >
> > On VF removal:
> >
> > [   17.675885] mlx4_en: enP2p0s2: Close port called
> > [   17.727005] hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF unregistering: enP2p0s2
> > <and nothing after - so the data path is not switched>
> >
> > We need to make sure netvsc_vf_update() is always processed on removal.  
> 
> So the question I have is: why do we need to call netvsc_vf_update()
> from a work? I tried calling it directly from netvsc_netdev_event() (and
> with rtnl_lock()/unlock() calls dropped from it as we already have it,
> of course) and everything seems to work for me.

Switching datapath needs to be waiting for ack and isn't

> 
> Shall I send a patch removing the work?

I will take care of that.
