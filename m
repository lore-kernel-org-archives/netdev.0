From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFT: virtio_net: limit xmit polling
Date: Wed, 29 Jun 2011 11:42:06 +0300
Message-ID: <20110629084206.GA14627@redhat.com>
References: <20110619102700.GA11198@redhat.com>
	<201106281108.09285.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	roprabhu-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
To: Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201106281108.09285.tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2011 at 11:08:07AM -0500, Tom Lendacky wrote:
> On Sunday, June 19, 2011 05:27:00 AM Michael S. Tsirkin wrote:
> > OK, different people seem to test different trees.  In the hope to get
> > everyone on the same page, I created several variants of this patch so
> > they can be compared. Whoever's interested, please check out the
> > following, and tell me how these compare:
> > 
> > kernel:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git
> > 
> > virtio-net-limit-xmit-polling/base - this is net-next baseline to test
> > against virtio-net-limit-xmit-polling/v0 - fixes checks on out of capacity
> > virtio-net-limit-xmit-polling/v1 - previous revision of the patch
> > 		this does xmit,free,xmit,2*free,free
> > virtio-net-limit-xmit-polling/v2 - new revision of the patch
> > 		this does free,xmit,2*free,free
> > 
> 
> Here's a summary of the results.  I've also attached an ODS format spreadsheet
> (30 KB in size) that might be easier to analyze and also has some pinned VM
> results data.  I broke the tests down into a local guest-to-guest scenario
> and a remote host-to-guest scenario.
> 
> Within the local guest-to-guest scenario I ran:
>   - TCP_RR tests using two different messsage sizes and four different
>     instance counts among 1 pair of VMs and 2 pairs of VMs.
>   - TCP_STREAM tests using four different message sizes and two different
>     instance counts among 1 pair of VMs and 2 pairs of VMs.
> 
> Within the remote host-to-guest scenario I ran:
>   - TCP_RR tests using two different messsage sizes and four different
>     instance counts to 1 VM and 4 VMs.
>   - TCP_STREAM and TCP_MAERTS tests using four different message sizes and
>     two different instance counts to 1 VM and 4 VMs.
> over a 10GbE link.

roprabhu, Tom,

Thanks very much for the testing. So on the first glance
one seems to see a significant performance gain in V0 here,
and a slightly less significant in V2, with V1
being worse than base. But I'm afraid that's not the
whole story, and we'll need to work some more to
know what really goes on, please see below.


Some comments on the results: I found out that V0 because of mistake
on my part was actually almost identical to base.
I pushed out virtio-net-limit-xmit-polling/v1a instead that
actually does what I intended to check. However,
the fact we get such a huge distribution in the results by Tom
most likely means that the noise factor is very large.


>From my experience one way to get stable results is to
divide the throughput by the host CPU utilization
(measured by something like mpstat).
Sometimes throughput doesn't increase (e.g. guest-host)
by CPU utilization does decrease. So it's interesting.


Another issue is that we are trying to improve the latency
of a busy queue here. However STREAM/MAERTS tests ignore the latency
(more or less) while TCP_RR by default runs a single packet per queue.
Without arguing about whether these are practically interesting
workloads, these results are thus unlikely to be significantly affected
by the optimization in question.

What we are interested in, thus, is either TCP_RR with a -b flag
(configure with  --enable-burst) or multiple concurrent
TCP_RRs.



> *** Local Guest-to-Guest ***
> 
> Here's the local guest-to-guest summary for 1 VM pair doing TCP_RR with
> 256/256 request/response message size in transactions per second:
> 
> Instances	Base		V0		V1		V2
> 1		 8,151.56	 8,460.72	 8,439.16	 9,990.37
> 25		48,761.74	51,032.62	51,103.25	49,533.52
> 50		55,687.38	55,974.18	56,854.10	54,888.65
> 100		58,255.06	58,255.86	60,380.90	59,308.36
> 
> Here's the local guest-to-guest summary for 2 VM pairs doing TCP_RR with
> 256/256 request/response message size in transactions per second:
> 
> Instances	Base		V0		V1		V2
> 1		18,758.48	19,112.50	18,597.07	19,252.04
> 25		80,500.50	78,801.78	80,590.68	78,782.07
> 50		80,594.20	77,985.44	80,431.72	77,246.90
> 100		82,023.23	81,325.96	81,303.32	81,727.54
> 
> Here's the local guest-to-guest summary for 1 VM pair doing TCP_STREAM with
> 256, 1K, 4K and 16K message size in Mbps:
> 
> 256:
> Instances	Base		V0		V1		V2
> 1		   961.78	 1,115.92	   794.02	   740.37
> 4		 2,498.33	 2,541.82	 2,441.60	 2,308.26
> 
> 1K:					
> 1		 3,476.61	 3,522.02	 2,170.86	 1,395.57
> 4		 6,344.30	 7,056.57	 7,275.16	 7,174.09
> 
> 4K:					
> 1		 9,213.57	10,647.44	 9,883.42	 9,007.29
> 4		11,070.66	11,300.37	11,001.02	12,103.72
> 
> 16K:
> 1		12,065.94	 9,437.78	11,710.60	 6,989.93
> 4		12,755.28	13,050.78	12,518.06	13,227.33
> 
> Here's the local guest-to-guest summary for 2 VM pairs doing TCP_STREAM with
> 256, 1K, 4K and 16K message size in Mbps:
> 
> 256:
> Instances	Base		V0		V1		V2
> 1		 2,434.98	 2,403.23	 2,308.69	 2,261.35
> 4		 5,973.82	 5,729.48	 5,956.76	 5,831.86
> 
> 1K:
> 1		 5,305.99	 5,148.72	 4,960.67	 5,067.76
> 4		10,628.38	10,649.49	10,098.90	10,380.09
> 
> 4K:
> 1		11,577.03	10,710.33	11,700.53	10,304.09
> 4		14,580.66	14,881.38	14,551.17	15,053.02
> 
> 16K:
> 1		16,801.46	16,072.50	15,773.78	15,835.66
> 4		17,194.00	17,294.02	17,319.78	17,121.09
> 
> 
> *** Remote Host-to-Guest ***
> 
> Here's the remote host-to-guest summary for 1 VM doing TCP_RR with
> 256/256 request/response message size in transactions per second:
> 
> Instances	Base		V0		V1		V2
> 1		 9,732.99	10,307.98	10,529.82	 8,889.28
> 25		43,976.18	49,480.50	46,536.66	45,682.38
> 50		63,031.33	67,127.15	60,073.34	65,748.62
> 100		64,778.43	65,338.07	66,774.12	69,391.22
> 
> Here's the remote host-to-guest summary for 4 VMs doing TCP_RR with
> 256/256 request/response message size in transactions per second:
> 
> Instances	Base		V0		V1		V2
> 1		 39,270.42	 38,253.60	 39,353.10	 39,566.33
> 25		207,120.91	207,964.50	211,539.70	213,882.21
> 50		218,801.54	221,490.56	220,529.48	223,594.25
> 100		218,432.62	215,061.44	222,011.61	223,480.47
> 
> Here's the remote host-to-guest summary for 1 VM doing TCP_STREAM with
> 256, 1K, 4K and 16K message size in Mbps:
> 
> 256:
> Instances	Base		V0		V1		V2
> 1		2,274.74	2,220.38	2,245.26	2,212.30
> 4		5,689.66	5,953.86	5,984.80	5,827.94
> 
> 1K:
> 1		7,804.38	7,236.29	6,716.58	7,485.09
> 4		7,722.42	8,070.38	7,700.45	7,856.76
> 
> 4K:
> 1		8,976.14	9,026.77	9,147.32	9,095.58
> 4		7,532.25	7,410.80	7,683.81	7,524.94
> 
> 16K:
> 1		8,991.61	9,045.10	9,124.58	9,238.34
> 4		7,406.10	7,626.81	7,711.62	7,345.37
> 
> Here's the remote host-to-guest summary for 1 VM doing TCP_MAERTS with
> 256, 1K, 4K and 16K message size in Mbps:
> 
> 256:
> Instances	Base		V0		V1		V2
> 1		1,165.69	1,181.92	1,152.20	1,104.68
> 4		2,580.46	2,545.22	2,436.30	2,601.74
> 
> 1K:
> 1		2,393.34	2,457.22	2,128.86	2,258.92
> 4		7,152.57	7,606.60	8,004.64	7,576.85
> 
> 4K:
> 1		9,258.93	8,505.06	9,309.78	9,215.05
> 4		9,374.20	9,363.48	9,372.53	9,352.00
> 
> 16K:
> 1		9,244.70	9,287.72	9,298.60	9,322.28
> 4		9,380.02	9,347.50	9,377.46	9,372.98
> 
> Here's the remote host-to-guest summary for 4 VMs doing TCP_STREAM with
> 256, 1K, 4K and 16K message size in Mbps:
> 
> 256:
> Instances	Base		V0		V1		V2
> 1		9,392.37	9,390.74	9,395.58	9,392.46
> 4		9,394.24	9,394.46	9,395.42	9,394.05
> 
> 1K:
> 1		9,396.34	9,397.46	9,396.64	9,443.26
> 4		9,397.14	9,402.25	9,398.67	9,391.09
> 
> 4K:
> 1		9,397.16	9,398.07	9,397.30	9,396.33
> 4		9,395.64	9,400.25	9,397.54	9,397.75
> 
> 16K:
> 1		9,396.58	9,397.01	9,397.58	9,397.70
> 4		9,399.15	9,400.02	9,399.66	9,400.16
> 
> 
> Here's the remote host-to-guest summary for 4 VMs doing TCP_MAERTS with
> 256, 1K, 4K and 16K message size in Mbps:
> 
> 256:
> Instances	Base		V0		V1		V2
> 1		5,048.66	5,007.26	5,074.98	4,974.86
> 4		9,217.23	9,245.14	9,263.97	9,294.23
> 
> 1K:
> 1		9,378.32	9,387.12	9,386.21	9,361.55
> 4		9,384.42	9,384.02	9,385.50	9,385.55
> 
> 4K:
> 1		9,391.10	9,390.28	9,389.70	9,391.02
> 4		9,384.38	9,383.39	9,384.74	9,384.19
> 
> 16K:
> 1		9,390.77	9,389.62	9,388.07	9,388.19
> 4		9,381.86	9,382.37	9,385.54	9,383.88
> 
> 
> Tom
> 
> > There's also this on top:
> > virtio-net-limit-xmit-polling/v3 -> don't delay avail index update
> > I don't think it's important to test this one, yet
> > 
> > Userspace to use: event index work is not yet merged upstream
> > so the revision to use is still this:
> > git://git.kernel.org/pub/scm/linux/kernel/git/mst/qemu-kvm.git
> > virtio-net-event-idx-v3
