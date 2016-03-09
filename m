From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net 1/3] net: mvneta: Fix spinlock usage
Date: Wed, 9 Mar 2016 16:13:26 +0800
Message-ID: <20160309161326.708db252@xhacker>
References: <1457441826-6100-1-git-send-email-gregory.clement@free-electrons.com>
	<1457441826-6100-2-git-send-email-gregory.clement@free-electrons.com>
	<20160309144254.3fbf177f@xhacker>	<87wppc2iqz.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Ofer Heifetz <oferh@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Marcin Wojtas <mw@semihalf.com>,
	Dimitri Epshtein <dima@marvell.com>,
	<linux-arm-kernel@lists.infradead.org>,
	"Sebastian Hesselbarth" <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:55370 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbcCIIR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 03:17:58 -0500
In-Reply-To: <87wppc2iqz.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Gregory,

On Wed, 9 Mar 2016 08:49:40 +0100 Gregory CLEMENT wrote:

> Hi Jisheng,
>  
>  On mer., mars 09 2016, Jisheng Zhang <jszhang@marvell.com> wrote:
> 
> > Dear Gregory,
> >
> > On Tue, 8 Mar 2016 13:57:04 +0100 Gregory CLEMENT wrote:
> >  
> >> In the previous patch, the spinlock was not initialized. While it didn't
> >> cause any trouble yet it could be a problem to use it uninitialized.
> >> 
> >> The most annoying part was the critical section protected by the spinlock
> >> in mvneta_stop(). Some of the functions could sleep as pointed when
> >> activated CONFIG_DEBUG_ATOMIC_SLEEP. Actually, in mvneta_stop() we only
> >> need to protect the is_stopped flagged, indeed the code of the notifier
> >> for CPU online is protected by the same spinlock, so when we get the
> >> lock, the notifer work is done.
> >> 
> >> Reported-by: Patrick Uiterwijk <patrick@puiterwijk.org>
> >> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> >> ---
> >>  drivers/net/ethernet/marvell/mvneta.c | 11 ++++++-----
> >>  1 file changed, 6 insertions(+), 5 deletions(-)
> >> 
> >> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> >> index b0ae69f84493..8dc7df2edff6 100644
> >> --- a/drivers/net/ethernet/marvell/mvneta.c
> >> +++ b/drivers/net/ethernet/marvell/mvneta.c
> >> @@ -3070,17 +3070,17 @@ static int mvneta_stop(struct net_device *dev)
> >>  	struct mvneta_port *pp = netdev_priv(dev);
> >>  
> >>  	/* Inform that we are stopping so we don't want to setup the
> >> -	 * driver for new CPUs in the notifiers
> >> +	 * driver for new CPUs in the notifiers. The code of the
> >> +	 * notifier for CPU online is protected by the same spinlock,
> >> +	 * so when we get the lock, the notifer work is done.
> >>  	 */
> >>  	spin_lock(&pp->lock);
> >>  	pp->is_stopped = true;
> >> +	spin_unlock(&pp->lock);  
> >
> > This fix sleep in atomic issue. But
> > I see race here. Let's assume is_stopped is false.  
> 
> You forgot that the lock was hold in the mvneta_percpu_notifier so your
> scenario can't happen.
> 
> >
> > cpu0:                           	cpu1:
> > mvneta_percpu_notifier():		mvneta_stop():
> >  
> 
> spin_lock(&pp->lock);
> 
> > if (pp->is_stopped) {
> > 	spin_unlock(&pp->lock);
> > 	break;
> > }

OOPS, I misread the code here as "the lock will be unlocked" ;)
Sorry for noise.

If you want, feel free to add

Reviewed-by: Jisheng Zhang <jszhang@marvell.com>

> >  
> 
>                                       the lock is hold in
>                                       mvneta_percpu_notifier(), so as
>                                       said in the comment this cpu is
>                                       waiting for on the following
>                                       line:
>                                       spin_lock(&pp->lock);
> 
>                                       This code will be executed only
>                                       when the lock will be released
> > 					pp->is_stopped = true;
> > 					spin_unlock(&pp->lock);
> >
> >
> > netif_tx_stop_all_queues(pp->dev);
> > for_each_online_cpu(other_cpu) {
> > ....
> >  
> So what will happen is:
> cpu0:                           	cpu1:
> mvneta_percpu_notifier():		mvneta_stop():
> 
> spin_lock(&pp->lock);
> if (pp->is_stopped) {
> 	spin_unlock(&pp->lock);
> 	break;
> }
>                                         spin_lock(&pp->lock);
> 
> netif_tx_stop_all_queues(pp->dev);
> for_each_online_cpu(other_cpu) {
> ....
> spin_unlock(&pp->lock);
> 					pp->is_stopped = true;
> 					spin_unlock(&pp->lock);
> 
> 
> Gregory
> 
