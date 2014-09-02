From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] ipv6: add sysctl_mld_qrv to configure query
 robustness variable
Date: Tue, 02 Sep 2014 11:32:22 +0200
Message-ID: <1409650342.22584.14.camel@localhost>
References: <aa72acbd19015e6db6b2d425fb6ebf6a8fa9c3b5.1409601046.git.hannes@stressinduktion.org>
	 <20140902000554.GA7909@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38690 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753178AbaIBJcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 05:32:25 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id D68DA203BB
	for <netdev@vger.kernel.org>; Tue,  2 Sep 2014 05:32:24 -0400 (EDT)
In-Reply-To: <20140902000554.GA7909@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Flavio,

On Mo, 2014-09-01 at 21:05 -0300, Flavio Leitner wrote:
> Hi Hannes,
> 
> On Mon, Sep 01, 2014 at 09:55:34PM +0200, Hannes Frederic Sowa wrote:
> > This patch adds a new sysctl_mld_qrv knob to configure the mldv1/v2 query
> > robustness variable. It specifies how many retransmit of unsolicited mld
> > retransmit should happen. Admins might want to tune this on lossy links.
> > 
> > Also reset mld state on interface down/up, so we pick up new sysctl
> > settings during interface up event.
> > 
> > IPv6 certification requests this knob to be available.
> > 
> > I didn't make this knob netns specific, as it is mostly a setting in a
> > physical environment and should be per host.
> > 
> > Cc: Flavio Leitner <fbl@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> > v2) no changes to original version
> > 
> >  Documentation/networking/ip-sysctl.txt |  3 +++
> >  include/net/ipv6.h                     |  1 +
> >  net/ipv6/mcast.c                       | 20 ++++++++++++--------
> >  net/ipv6/sysctl_net_ipv6.c             | 10 ++++++++++
> >  4 files changed, 26 insertions(+), 8 deletions(-)
> > 
> > diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> > index 3cce8ea..b7fe844 100644
> > --- a/Documentation/networking/ip-sysctl.txt
> > +++ b/Documentation/networking/ip-sysctl.txt
> > @@ -1152,6 +1152,9 @@ anycast_src_echo_reply - BOOLEAN
> >  	FALSE: disabled
> >  	Default: FALSE
> >  
> > +mld_qrv - INTEGER
> > +	Controls the MLD query robustness variable (see RFC3810 9.1).
> > +
> >  IPv6 Fragmentation:
> >  
> >  ip6frag_high_thresh - INTEGER
> > diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> > index a2db816..7e247e9 100644
> > --- a/include/net/ipv6.h
> > +++ b/include/net/ipv6.h
> > @@ -121,6 +121,7 @@ struct frag_hdr {
> >  
> >  /* sysctls */
> >  extern int sysctl_mld_max_msf;
> > +extern int sysctl_mld_qrv;
> >  
> >  #define _DEVINC(net, statname, modifier, idev, field)			\
> >  ({									\
> > diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> > index 7088179..6efb0e5 100644
> > --- a/net/ipv6/mcast.c
> > +++ b/net/ipv6/mcast.c
> > @@ -121,6 +121,7 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
> >  #define IPV6_MLD_MAX_MSF	64
> >  
> >  int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
> > +int sysctl_mld_qrv __read_mostly = MLD_QRV_DEFAULT;
> >  
> >  /*
> >   *	socket join on multicast group
> > @@ -1196,7 +1197,7 @@ static void mld_update_qrv(struct inet6_dev *idev,
> >  	if (mlh2->mld2q_qrv > 0)
> >  		idev->mc_qrv = mlh2->mld2q_qrv;
> >  
> > -	if (unlikely(idev->mc_qrv < 2)) {
> > +	if (unlikely(idev->mc_qrv < MLD_QRV_DEFAULT)) {
> >  		net_warn_ratelimited("IPv6: MLD: clamping QRV from %u to %u!\n",
> >  				     idev->mc_qrv, MLD_QRV_DEFAULT);
> >  		idev->mc_qrv = MLD_QRV_DEFAULT;
> 
> You allow the sysctl to be 1, but here it is limited to 2?

I wanted to keep limiting the remotely set value to at least 2.

Is this more reasonable?

const int min_qrv = min(MLD_QRV_DEFAULT, sysctl_mld_qrv);
if (unlikely(idev->mc_qrv < min_qrv)) {
  net_warn_ratelimited(...);
  idev->mc_qrv = min_qrv;
}

> > @@ -2478,6 +2479,14 @@ void ipv6_mc_down(struct inet6_dev *idev)
> >  	mld_clear_delrec(idev);
> >  }
> >  
> > +static void ipv6_mc_reset(struct inet6_dev *idev)
> > +{
> > +	idev->mc_qrv = sysctl_mld_qrv;
> > +	idev->mc_qi = MLD_QI_DEFAULT;
> > +	idev->mc_qri = MLD_QRI_DEFAULT;
> > +	idev->mc_v1_seen = 0;
> > +	idev->mc_maxdelay = unsolicited_report_interval(idev);
> > +}
> >  
> >  /* Device going up */
> >  
> > @@ -2488,6 +2497,7 @@ void ipv6_mc_up(struct inet6_dev *idev)
> >  	/* Install multicast list, except for all-nodes (already installed) */
> >  
> >  	read_lock_bh(&idev->lock);
> > +	ipv6_mc_reset(idev);
> 
> ok, up and down the interface to get the sysctl value applied.
> 
> >  	for (i = idev->mc_list; i; i = i->next)
> >  		igmp6_group_added(i);
> >  	read_unlock_bh(&idev->lock);
> > @@ -2508,13 +2518,7 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
> >  			(unsigned long)idev);
> >  	setup_timer(&idev->mc_dad_timer, mld_dad_timer_expire,
> >  		    (unsigned long)idev);
> > -
> > -	idev->mc_qrv = MLD_QRV_DEFAULT;
> > -	idev->mc_qi = MLD_QI_DEFAULT;
> > -	idev->mc_qri = MLD_QRI_DEFAULT;
> > -
> > -	idev->mc_maxdelay = unsolicited_report_interval(idev);
> > -	idev->mc_v1_seen = 0;
> > +	ipv6_mc_reset(idev);
> 
> looks good to me.
> 
> 
> >  	write_unlock_bh(&idev->lock);
> >  }
> >  
> > diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
> > index 0c56c93..c5c10fa 100644
> > --- a/net/ipv6/sysctl_net_ipv6.c
> > +++ b/net/ipv6/sysctl_net_ipv6.c
> > @@ -16,6 +16,8 @@
> >  #include <net/addrconf.h>
> >  #include <net/inet_frag.h>
> >  
> > +static int one = 1;
> > +
> 
> Although that can be reused later for other purposes, it's nice to
> have a comment telling where that value came from. Since you have
> defined MLD_QRV_DEFAULT, it helps. Still I didn't know about 
> rfc6636#section-4.5, so I'd appreciate if you include that info
> either in ip-sysctl.txt or close to MLD_QRV_DEFAULT.

I think ip-sysctl.txt is a good place, do you agree?

> E.g.:
> 
> /* See RFC3810 9.1 and rfc6636 4.5 */
> +int sysctl_mld_qrv __read_mostly = MLD_QRV_DEFAULT;
> 
> Actually, maybe that int could be something not specific to ipv6
> because I believe there are more users of the same thing. That's ok,
> just a comment and it's not part of this patch.

Sorry, I did not understand that. ;)
Do you propose to use one sysctl variable for igmp and mld?

Bye,
Hannes
