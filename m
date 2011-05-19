From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 10:14:01 +0200
Message-ID: <201105191014.02274.hans.schillstrom@ericsson.com>
References: <20110518201915.GB20475@redhat.com> <alpine.LFD.2.00.1105190930480.1993@ja.ssi.bg> <20110519075557.GB3922@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linuxvirtualserver.org>,
	Hans Schillstrom <hans@schillstrom.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:57095 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756378Ab1ESIOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 04:14:10 -0400
In-Reply-To: <20110519075557.GB3922@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Simon
On Thursday 19 May 2011 09:55:57 Simon Horman wrote:
> On Thu, May 19, 2011 at 09:33:55AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Thu, 19 May 2011, Simon Horman wrote:
> > 
> > > > >  Call Trace:
> > > > >   [<ffffffff8107be36>] raw_notifier_chain_register+0xe/0x10
> > > > >   [<ffffffff81403058>] register_netdevice_notifier+0x2d/0x1b6
> > > > >   [<ffffffffa0432106>] ? ip_vs_conn_init+0x106/0x106 [ip_vs]
> > > > >   [<ffffffffa04322c7>] ip_vs_control_init+0xa5/0xce [ip_vs]
> > > > >   [<ffffffffa0432106>] ? ip_vs_conn_init+0x106/0x106 [ip_vs]
> > > > >   [<ffffffffa0432116>] ip_vs_init+0x10/0x11c [ip_vs]
> > > > >   [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
> > > > >   [<ffffffff81096524>] sys_init_module+0x132/0x281
> > > > >   [<ffffffff814cc702>] system_call_fastpath+0x16/0x1b
> > > > >  Code: 07 ff c8 89 43 48 eb 08 48 89 df e8 dc 95 44 00 4c 89 e6 48 89 df e8 a7 a5 44 00 5b 41 5c 5d c3 55 48 89 e5 66 66 66 66 90 eb 0c <8b> 50 10 39 56 10 7f 0c 48 8d 78 08 48 8b 07 48 85 c0 75 ec 48 
> > > > >  RIP  [<ffffffff8107bddb>] notifier_chain_register+0xb/0x2a
> > > > >   RSP <ffff880114139e68>
> > > > >  ---[ end trace e90d7053ad1a7a5b ]---
> > > > > 
> > > > > 
> > > > > This script replicates the bug.
> > > > > (it usually oopses after just a few loops)
> > > > > 
> > > > > #!/bin/sh
> > > > > while [ 1 ];
> > > > > do
> > > > > 	modprobe ip_vs_ftp
> > > > > 	modprobe -r ip_vs_ftp
> > > > > done
> > > > > 
> > > > > Looks like something isn't getting cleaned up on module exit
> > > > > that we fall over when we encounter it next time it gets loaded ?
> > > > 
> > > > Thanks Dave, I will look into this.
> > > 
> > > Hi Dave,
> > > 
> > > I'm not having much luck reproducing this in KVM.
> > > I will try this evening on real hardware.
> > > 
> > > Just to make sure we are testing the same thing, are you using Linus's tree?
> > 
> > 	One unregister_netdevice_notifier(&ip_vs_dst_notifier);
> > is missing in ip_vs_control_cleanup for sure.
> 
> Like this?

Yes,
we need this patch and the ip_vs_ftp patch in some format.

> 
> From 840edfcc48e5b98d928ee9d66def761a808945b3 Mon Sep 17 00:00:00 2001
> From: Simon Horman <horms@verge.net.au>
> Date: Thu, 19 May 2011 16:54:26 +0900
> Subject: [PATCH] IPVS: Free resources on module removal
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 37890f2..9b9039b 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3774,6 +3774,7 @@ err_sock:
>  void ip_vs_control_cleanup(void)
>  {
>  	EnterFunction(2);
> +	unregister_netdevice_notifier(&ip_vs_dst_notifier);
>  	ip_vs_genl_unregister();
>  	nf_unregister_sockopt(&ip_vs_sockopts);
>  	LeaveFunction(2);

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
