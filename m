From: Roopa Prabhu <roprabhu-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: RFT: virtio_net: limit xmit polling
Date: Thu, 14 Jul 2011 12:38:05 -0700
Message-ID: <CA4493AD.2E273%roprabhu@cisco.com>
References: <20110629084206.GA14627@redhat.com>
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
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110629084206.GA14627-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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




On 6/29/11 1:42 AM, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Tue, Jun 28, 2011 at 11:08:07AM -0500, Tom Lendacky wrote:
>> On Sunday, June 19, 2011 05:27:00 AM Michael S. Tsirkin wrote:
>>> OK, different people seem to test different trees.  In the hope to get
>>> everyone on the same page, I created several variants of this patch so
>>> they can be compared. Whoever's interested, please check out the
>>> following, and tell me how these compare:
>>> 
>>> kernel:
>>> 
>>> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git
>>> 
>>> virtio-net-limit-xmit-polling/base - this is net-next baseline to test
>>> against virtio-net-limit-xmit-polling/v0 - fixes checks on out of capacity
>>> virtio-net-limit-xmit-polling/v1 - previous revision of the patch
>>>             this does xmit,free,xmit,2*free,free
>>> virtio-net-limit-xmit-polling/v2 - new revision of the patch
>>>             this does free,xmit,2*free,free
>>> 
>> 
>> Here's a summary of the results.  I've also attached an ODS format
>> spreadsheet
>> (30 KB in size) that might be easier to analyze and also has some pinned VM
>> results data.  I broke the tests down into a local guest-to-guest scenario
>> and a remote host-to-guest scenario.
>> 
>> Within the local guest-to-guest scenario I ran:
>>   - TCP_RR tests using two different messsage sizes and four different
>>     instance counts among 1 pair of VMs and 2 pairs of VMs.
>>   - TCP_STREAM tests using four different message sizes and two different
>>     instance counts among 1 pair of VMs and 2 pairs of VMs.
>> 
>> Within the remote host-to-guest scenario I ran:
>>   - TCP_RR tests using two different messsage sizes and four different
>>     instance counts to 1 VM and 4 VMs.
>>   - TCP_STREAM and TCP_MAERTS tests using four different message sizes and
>>     two different instance counts to 1 VM and 4 VMs.
>> over a 10GbE link.
> 
> roprabhu, Tom,
> 
> Thanks very much for the testing. So on the first glance
> one seems to see a significant performance gain in V0 here,
> and a slightly less significant in V2, with V1
> being worse than base. But I'm afraid that's not the
> whole story, and we'll need to work some more to
> know what really goes on, please see below.
> 
> 
> Some comments on the results: I found out that V0 because of mistake
> on my part was actually almost identical to base.
> I pushed out virtio-net-limit-xmit-polling/v1a instead that
> actually does what I intended to check. However,
> the fact we get such a huge distribution in the results by Tom
> most likely means that the noise factor is very large.
> 
> 
> From my experience one way to get stable results is to
> divide the throughput by the host CPU utilization
> (measured by something like mpstat).
> Sometimes throughput doesn't increase (e.g. guest-host)
> by CPU utilization does decrease. So it's interesting.
> 
> 
> Another issue is that we are trying to improve the latency
> of a busy queue here. However STREAM/MAERTS tests ignore the latency
> (more or less) while TCP_RR by default runs a single packet per queue.
> Without arguing about whether these are practically interesting
> workloads, these results are thus unlikely to be significantly affected
> by the optimization in question.
> 
> What we are interested in, thus, is either TCP_RR with a -b flag
> (configure with  --enable-burst) or multiple concurrent
> TCP_RRs.
> 
> 
> 
Michael, below are some numbers I got from one round of runs.
Thanks,
Roopa

256byte req/response.
Vcpus and irqs were pinned to 4 cores and the cpu utilization is
Avg across 4 cores.

base:
Numof concurrent TCP_RRs    Num of transactions/sec  host cpu-util(%)
1                            7982.93                        15.72
25                           67873                         28.84
50                           112534                        52.25
100                          192057                       86.54


v1
Numof concurrent TCP_RRs    Num of transactions/sec    host cpu-util(%)
1                           7970.94                       10.8
25                          65496.8                       28
50                          109858                        53.22
100                         190155                        87.5


v1a
Numof concurrent TCP_RRs    Num of transactions/sec   host cpu-util (%)
1                           7979.81                       9.5
25                          66786.1                       28
50                          109552                        51
100                         190876                        88


v2
Numof concurrent TCP_RRs    Num of transactions/sec   host cpu-util (%)
1                            7969.87                     16.5
25                           67780.1                     28.44
50                           114966                      54.29
100                          177982                      79.9
