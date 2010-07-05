From: mark gross <markgross@thegnar.org>
Subject: Re: [PATCH 3/3] pm_qos: get rid of the allocation in
 pm_qos_add_request()
Date: Mon, 5 Jul 2010 12:16:42 -0700
Message-ID: <20100705191642.GA1693@gvim.org>
References: <1277746434.10879.191.camel@mulgrave.site>
 <1277747088.10879.201.camel@mulgrave.site>
 <s5hvd8ubfcz.wl%tiwai@suse.de>
 <1278338568.2850.1.camel@mulgrave.site>
Reply-To: markgross@thegnar.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Takashi Iwai <tiwai@suse.de>,
	Linux PM <linux-pm@lists.linux-foundation.org>,
	markgross@thegnar.org, netdev@vger.kernel.org
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64839 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab0GETQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 15:16:48 -0400
Received: by pwi5 with SMTP id 5so1591094pwi.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 12:16:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1278338568.2850.1.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 05, 2010 at 09:02:48AM -0500, James Bottomley wrote:
> On Mon, 2010-07-05 at 08:41 +0200, Takashi Iwai wrote:
> > sorry for the late reply, as I've been on vacation in the last week
> > (and shut off mails intentionally :)
> 
> Envy forbids me from saying that's OK.
> 
> > At Mon, 28 Jun 2010 12:44:48 -0500,
> > James Bottomley wrote:
> > > 
> > > Since every caller has to squirrel away the returned pointer anyway,
> > > they might as well supply the memory area.  This fixes a bug in a few of
> > > the call sites where the returned pointer was dereferenced without
> > > checking it for NULL (which gets returned if the kzalloc failed).
> > > 
> > > I'd like to hear how sound and netdev feels about this: it will add
> > > about two more pointers worth of data to struct netdev and struct
> > > snd_pcm_substream .. but I think it's worth it.  If you're OK, I'll add
> > > your acks and send through the pm tree.
> > > 
> > > This also looks to me like an android independent clean up (even though
> > > it renders the request_add atomically callable).  I also added include
> > > guards to include/linux/pm_qos_params.h
> > 
> > I like the patch very well, too.
> > But, just wondering...
> > 
> > > @@ -262,6 +260,11 @@ void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
> > >  	if (!pm_qos_req) /*guard against callers passing in null */
> > >  		return;
> > >  
> > > +	if (pm_qos_request_active(pm_qos_req)) {
> > > +		WARN(1, KERN_ERR "pm_qos_update_request() called for unknown object\n");
> > > +		return;
> > > +	}
> > > +
> > 
> > Is this correct...?  Shouldn't it be a negative check?
> 
> Yes, it should be a negative check ... I'll update the patch.  I guess
> this still means that no-one has managed to test it on a functional
> system ...
> 

well I guess that explains the warning I got on my back port of this
patch.


[   62.944788] ------------[ cut here ]------------                                        
[   62.944788] WARNING: at kernel/pm_qos_params.c:266                                      
pm_qos_update_request+0x21/0x46)                                                           
[   62.944788] pm_qos_update_request() called for unknown object                           
[   62.944788] Modules linked in: mrst_sspi cfspi_slave chnl_chr                           
caif_chr chnl_net caf                                                                      
[   62.944788] Pid: 91, comm: mrst/0 Tainted: G        W  2.6.31.6-mrst
#30                
[   62.944788] Call Trace:                                                                 
[   62.944788]  [<c0145b2e>] ? pm_qos_update_request+0x21/0x46                             
[   62.944788]  [<c012fff3>] warn_slowpath_common+0x60/0x77                                
[   62.944788]  [<c013003e>] warn_slowpath_fmt+0x24/0x27                                   
[   62.944788]  [<c0145b2e>] pm_qos_update_request+0x21/0x46                               
[   62.944788]  [<c03029f2>] int_transfer_complete_work+0x19/0x65                          
[   62.944788]  [<c013f02a>] worker_thread+0x153/0x1df                                     
[   62.944788]  [<c03029d9>] ? int_transfer_complete_work+0x0/0x65                         
[   62.944788]  [<c0141df1>] ? autoremove_wake_function+0x0/0x30                           
[   62.944788]  [<c0141c7c>] kthread+0x64/0x69                                             
[   62.944788]  [<c013eed7>] ? worker_thread+0x0/0x1df                                     
[   62.944788]  [<c0141c18>] ? kthread+0x0/0x69                                            
[   62.944788]  [<c01034df>] kernel_thread_helper+0x7/0x10                                 
[   62.944788] ---[ end trace 1723851b79e06c5d ]---                                        
[   62.944788] ------------[ cut here ]------------                                        
[   62.944788] WARNING: at kernel/pm_qos_params.c:266          

Sorry, I've been swamped by work and personal things the past 2 weeks.

--mgross

