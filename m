From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 09 Sep 2010 16:00:24 -0700
Message-ID: <4C896708.1050607@us.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com> <OF70542242.6CAA236A-ON65257798.0044A4E0-65257798.005C0E7C@LocalDomain> <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:42954 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912Ab0IIXA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 19:00:59 -0400
In-Reply-To: <OF8043B2B7.7048D739-ON65257799.0021A2EE-65257799.00356B3E@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 9/9/2010 2:45 AM, Krishna Kumar2 wrote:
>> Krishna Kumar2/India/IBM wrote on 09/08/2010 10:17:49 PM:
> Some more results and likely cause for single netperf
> degradation below.
>
>
>> Guest ->  Host (single netperf):
>> I am getting a drop of almost 20%. I am trying to figure out
>> why.
>>
>> Host ->  guest (single netperf):
>> I am getting an improvement of almost 15%. Again - unexpected.
>>
>> Guest ->  Host TCP_RR: I get an average 7.4% increase in #packets
>> for runs upto 128 sessions. With fewer netperf (under 8), there
>> was a drop of 3-7% in #packets, but beyond that, the #packets
>> improved significantly to give an average improvement of 7.4%.
>>
>> So it seems that fewer sessions is having negative effect for
>> some reason on the tx side. The code path in virtio-net has not
>> changed much, so the drop in some cases is quite unexpected.
> The drop for the single netperf seems to be due to multiple vhost.
> I changed the patch to start *single* vhost:
>
> Guest ->  Host (1 netperf, 64K): BW: 10.79%, SD: -1.45%
> Guest ->  Host (1 netperf)     : Latency: -3%, SD: 3.5%
I remember seeing similar issue when using a separate vhost thread for 
TX and
RX queues.  Basically, we should have the same vhost thread process a 
TCP flow
in both directions. I guess this allows the data and ACKs to be 
processed in sync.


Thanks
Sridhar
> Single vhost performs well but hits the barrier at 16 netperf
> sessions:
>
> SINGLE vhost (Guest ->  Host):
> 	1 netperf:    BW: 10.7%     SD: -1.4%
> 	4 netperfs:   BW: 3%        SD: 1.4%
> 	8 netperfs:   BW: 17.7%     SD: -10%
>        16 netperfs:  BW: 4.7%      SD: -7.0%
>        32 netperfs:  BW: -6.1%     SD: -5.7%
> BW and SD both improves (guest multiple txqs help). For 32
> netperfs, SD improves.
>
> But with multiple vhosts, guest is able to send more packets
> and BW increases much more (SD too increases, but I think
> that is expected). From the earlier results:
>
> N#      BW1     BW2    (%)      SD1     SD2    (%)      RSD1    RSD2    (%)
> _______________________________________________________________________________
> 4       26387   40716 (54.30)   20      28   (40.00)    86      85
> (-1.16)
> 8       24356   41843 (71.79)   88      129  (46.59)    372     362
> (-2.68)
> 16      23587   40546 (71.89)   375     564  (50.40)    1558    1519
> (-2.50)
> 32      22927   39490 (72.24)   1617    2171 (34.26)    6694    5722
> (-14.52)
> 48      23067   39238 (70.10)   3931    5170 (31.51)    15823   13552
> (-14.35)
> 64      22927   38750 (69.01)   7142    9914 (38.81)    28972   26173
> (-9.66)
> 96      22568   38520 (70.68)   16258   27844 (71.26)   65944   73031
> (10.74)
> _______________________________________________________________________________
> (All tests were done without any tuning)
>
>  From my testing:
>
> 1. Single vhost improves mq guest performance upto 16
>     netperfs but degrades after that.
> 2. Multiple vhost degrades single netperf guest
>     performance, but significantly improves performance
>     for any number of netperf sessions.
>
> Likely cause for the 1 stream degradation with multiple
> vhost patch:
>
> 1. Two vhosts run handling the RX and TX respectively.
>     I think the issue is related to cache ping-pong esp
>     since these run on different cpus/sockets.
> 2. I (re-)modified the patch to share RX with TX[0]. The
>     performance drop is the same, but the reason is the
>     guest is not using txq[0] in most cases (dev_pick_tx),
>     so vhost's rx and tx are running on different threads.
>     But whenever the guest uses txq[0], only one vhost
>     runs and the performance is similar to original.
>
> I went back to my *submitted* patch and started a guest
> with numtxq=16 and pinned every vhost to cpus #0&1. Now
> whether guest used txq[0] or txq[n], the performance is
> similar or better (between 10-27% across 10 runs) than
> original code. Also, -6% to -24% improvement in SD.
>
> I will start a full test run of original vs submitted
> code with minimal tuning (Avi also suggested the same),
> and re-send. Please let me know if you need any other
> data.
>
> Thanks,
>
> - KK
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


