From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 15 Sep 2010 07:33:28 +0200
Message-ID: <20100915053328.GA25566@redhat.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
 <20100908081011.GC23051@redhat.com>
 <OF70542242.6CAA236A-ON65257798.0044A4E0-65257798.005C0E7C@LocalDomain>
 <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@in.ibm.com>
 <20100912114024.GA22982@redhat.com>
 <OF7E84392C.8FAA20F2-ON6525779D.00112DE2-6525779D.0016E2C5@in.ibm.com>
 <20100913115054.GA5584@redhat.com>
 <OF5A57530E.4E8C0A65-ON6525779D.00591022-6525779D.0059D5BB@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, avi@redhat.com, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	rick.jones2@hp.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab0IOFkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 01:40:17 -0400
Content-Disposition: inline
In-Reply-To: <OF5A57530E.4E8C0A65-ON6525779D.00591022-6525779D.0059D5BB@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 13, 2010 at 09:53:40PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 09/13/2010 05:20:55 PM:
> 
> > > Results with the original kernel:
> > > _____________________________
> > > #       BW      SD      RSD
> > > ______________________________
> > > 1       20903   1       6
> > > 2       21963   6       25
> > > 4       22042   23      102
> > > 8       21674   97      419
> > > 16      22281   379     1663
> > > 24      22521   857     3748
> > > 32      22976   1528    6594
> > > 40      23197   2390    10239
> > > 48      22973   3542    15074
> > > 64      23809   6486    27244
> > > 80      23564   10169   43118
> > > 96      22977   14954   62948
> > > 128     23649   27067   113892
> > > ________________________________
> > >
> > > With higher number of threads running in parallel, SD
> > > increased. In this case most threads run in parallel
> > > only till __dev_xmit_skb (#numtxqs=1). With mq TX patch,
> > > higher number of threads run in parallel through
> > > ndo_start_xmit. I *think* the increase in SD is to do
> > > with higher # of threads running for larger code path
> > > >From the numbers I posted with the patch (cut-n-paste
> > > only the % parts), BW increased much more than the SD,
> > > sometimes more than twice the increase in SD.
> >
> > Service demand is BW/CPU, right? So if BW goes up by 50%
> > and SD by 40%, this means that CPU more than doubled.
> 
> I think the SD calculation might be more complicated,
> I think it does it based on adding up averages sampled
> and stored during the run. But, I still don't see how CPU
> can double?? e.g.
> 	BW: 1000 -> 1500 (50%)
> 	SD: 100 -> 140 (40%)
> 	CPU: 10 -> 10.71 (7.1%)

Hmm. Time to look at the source. Which netperf version did you use?

> > > N#      BW%     SD%      RSD%
> > > 4       54.30   40.00    -1.16
> > > 8       71.79   46.59    -2.68
> > > 16      71.89   50.40    -2.50
> > > 32      72.24   34.26    -14.52
> > > 48      70.10   31.51    -14.35
> > > 64      69.01   38.81    -9.66
> > > 96      70.68   71.26    10.74
> > >
> > > I also think SD calculation gets skewed for guest->local
> > > host testing.
> >
> > If it's broken, let's fix it?
> >
> > > For this test, I ran a guest with numtxqs=16.
> > > The first result below is with my patch, which creates 16
> > > vhosts. The second result is with a modified patch which
> > > creates only 2 vhosts (testing with #netperfs = 64):
> >
> > My guess is it's not a good idea to have more TX VQs than guest CPUs.
> 
> Definitely, I will try to run tomorrow with more reasonable
> values, also will test with my second version of the patch
> that creates restricted number of vhosts and post results.
> 
> > I realize for management it's easier to pass in a single vhost fd, but
> > just for testing it's probably easier to add code in userspace to open
> > /dev/vhost multiple times.
> >
> > >
> > > #vhosts  BW%     SD%        RSD%
> > > 16       20.79   186.01     149.74
> > > 2        30.89   34.55      18.44
> > >
> > > The remote SD increases with the number of vhost threads,
> > > but that number seems to correlate with guest SD. So though
> > > BW% increased slightly from 20% to 30%, SD fell drastically
> > > from 186% to 34%. I think it could be a calculation skew
> > > with host SD, which also fell from 150% to 18%.
> >
> > I think by default netperf looks in /proc/stat for CPU utilization data:
> > so host CPU utilization will include the guest CPU, I think?
> 
> It appears that way to me too, but the data above seems to
> suggest the opposite...
> 
> > I would go further and claim that for host/guest TCP
> > CPU utilization and SD should always be identical.
> > Makes sense?
> 
> It makes sense to me, but once again I am not sure how SD
> is really done, or whether it is linear to CPU. Cc'ing Rick
> in case he can comment....

Me neither. I should rephrase: I think we should always
use host CPU utilization always.

> >
> > >
> > > I am planning to submit 2nd patch rev with restricted
> > > number of vhosts.
> > >
> > > > > Likely cause for the 1 stream degradation with multiple
> > > > > vhost patch:
> > > > >
> > > > > 1. Two vhosts run handling the RX and TX respectively.
> > > > >    I think the issue is related to cache ping-pong esp
> > > > >    since these run on different cpus/sockets.
> > > >
> > > > Right. With TCP I think we are better off handling
> > > > TX and RX for a socket by the same vhost, so that
> > > > packet and its ack are handled by the same thread.
> > > > Is this what happens with RX multiqueue patch?
> > > > How do we select an RX queue to put the packet on?
> > >
> > > My (unsubmitted) RX patch doesn't do this yet, that is
> > > something I will check.
> > >
> > > Thanks,
> > >
> > > - KK
> >
> > You'll want to work on top of net-next, I think there's
> > RX flow filtering work going on there.
> 
> Thanks Michael, I will follow up on that for the RX patch,
> plus your suggestion on tying RX with TX.
> 
> Thanks,
> 
> - KK
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
