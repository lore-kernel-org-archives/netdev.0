From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Mon, 13 Sep 2010 09:42:22 +0530
Message-ID: <OF7E84392C.8FAA20F2-ON6525779D.00112DE2-6525779D.0016E2C5@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com> <OF70542242.6CAA236A-ON65257798.0044A4E0-65257798.005C0E7C@LocalDomain> <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@in.ibm.com> <20100912114024.GA22982@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:38284 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab0IMEKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 00:10:06 -0400
In-Reply-To: <20100912114024.GA22982@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 09/12/2010 05:10:25 PM:

> > SINGLE vhost (Guest -> Host):
> >    1 netperf:    BW: 10.7%     SD: -1.4%
> >    4 netperfs:   BW: 3%        SD: 1.4%
> >    8 netperfs:   BW: 17.7%     SD: -10%
> >       16 netperfs:  BW: 4.7%      SD: -7.0%
> >       32 netperfs:  BW: -6.1%     SD: -5.7%
> > BW and SD both improves (guest multiple txqs help). For 32
> > netperfs, SD improves.
> >
> > But with multiple vhosts, guest is able to send more packets
> > and BW increases much more (SD too increases, but I think
> > that is expected).
>
> Why is this expected?

Results with the original kernel:
_____________________________
#       BW      SD      RSD
______________________________
1       20903   1       6
2       21963   6       25
4       22042   23      102
8       21674   97      419
16      22281   379     1663
24      22521   857     3748
32      22976   1528    6594
40      23197   2390    10239
48      22973   3542    15074
64      23809   6486    27244
80      23564   10169   43118
96      22977   14954   62948
128     23649   27067   113892
________________________________

With higher number of threads running in parallel, SD
increased. In this case most threads run in parallel
only till __dev_xmit_skb (#numtxqs=1). With mq TX patch,
higher number of threads run in parallel through
ndo_start_xmit. I *think* the increase in SD is to do
with higher # of threads running for larger code path
>From the numbers I posted with the patch (cut-n-paste
only the % parts), BW increased much more than the SD,
sometimes more than twice the increase in SD.

N#      BW%     SD%      RSD%
4       54.30   40.00    -1.16
8       71.79   46.59    -2.68
16      71.89   50.40    -2.50
32      72.24   34.26    -14.52
48      70.10   31.51    -14.35
64      69.01   38.81    -9.66
96      70.68   71.26    10.74

I also think SD calculation gets skewed for guest->local
host testing. For this test, I ran a guest with numtxqs=16.
The first result below is with my patch, which creates 16
vhosts. The second result is with a modified patch which
creates only 2 vhosts (testing with #netperfs = 64):

#vhosts  BW%     SD%        RSD%
16       20.79   186.01     149.74
2        30.89   34.55      18.44

The remote SD increases with the number of vhost threads,
but that number seems to correlate with guest SD. So though
BW% increased slightly from 20% to 30%, SD fell drastically
from 186% to 34%. I think it could be a calculation skew
with host SD, which also fell from 150% to 18%.

I am planning to submit 2nd patch rev with restricted
number of vhosts.

> > Likely cause for the 1 stream degradation with multiple
> > vhost patch:
> >
> > 1. Two vhosts run handling the RX and TX respectively.
> >    I think the issue is related to cache ping-pong esp
> >    since these run on different cpus/sockets.
>
> Right. With TCP I think we are better off handling
> TX and RX for a socket by the same vhost, so that
> packet and its ack are handled by the same thread.
> Is this what happens with RX multiqueue patch?
> How do we select an RX queue to put the packet on?

My (unsubmitted) RX patch doesn't do this yet, that is
something I will check.

Thanks,

- KK

