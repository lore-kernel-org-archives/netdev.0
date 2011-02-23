From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 23 Feb 2011 10:52:09 +0530
Message-ID: <OFAAA32513.A5D0FB9F-ON65257840.001ACE50-65257840.001D5B76@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <20110222074709.GA18880@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Simon Horman <horms@verge.net.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110222074709.GA18880@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman <horms@verge.net.au> wrote on 02/22/2011 01:17:09 PM:

Hi Simon,


> I have a few questions about the results below:
>
> 1. Are the (%) comparisons between non-mq and mq virtio?

Yes - mainline kernel with transmit-only MQ patch.

> 2. Was UDP or TCP used?

TCP. I had done some initial testing on UDP, but don't have
the results now as it is really old. But I will be running
it again.

> 3. What was the transmit size (-m option to netperf)?

I didn't use the -m option, so it defaults to 16K. The
script does:

netperf -t TCP_STREAM -c -C -l 60 -H $SERVER

> Also, I'm interested to know what the status of these patches is.
> Are you planing a fresh series?

Yes. Michael Tsirkin had wanted to see how the MQ RX patch
would look like, so I was in the process of getting the two
working together. The patch is ready and is being tested.
Should I send a RFC patch at this time?

The TX-only patch helped the guest TX path but didn't help
host->guest much (as tested using TCP_MAERTS from the guest).
But with the TX+RX patch, both directions are getting
improvements. Remote testing is still to be done.

Thanks,

- KK

> >                   Changes from rev2:
> >                   ------------------
> > 1. Define (in virtio_net.h) the maximum send txqs; and use in
> >    virtio-net and vhost-net.
> > 2. vi->sq[i] is allocated individually, resulting in cache line
> >    aligned sq[0] to sq[n].  Another option was to define
> >    'send_queue' as:
> >        struct send_queue {
> >                struct virtqueue *svq;
> >                struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
> >        } ____cacheline_aligned_in_smp;
> >    and to statically allocate 'VIRTIO_MAX_SQ' of those.  I hope
> >    the submitted method is preferable.
> > 3. Changed vhost model such that vhost[0] handles RX and vhost[1-MAX]
> >    handles TX[0-n].
> > 4. Further change TX handling such that vhost[0] handles both RX/TX
> >    for single stream case.
> >
> >                   Enabling MQ on virtio:
> >                   -----------------------
> > When following options are passed to qemu:
> >         - smp > 1
> >         - vhost=on
> >         - mq=on (new option, default:off)
> > then #txqueues = #cpus.  The #txqueues can be changed by using an
> > optional 'numtxqs' option.  e.g. for a smp=4 guest:
> >         vhost=on                   ->   #txqueues = 1
> >         vhost=on,mq=on             ->   #txqueues = 4
> >         vhost=on,mq=on,numtxqs=2   ->   #txqueues = 2
> >         vhost=on,mq=on,numtxqs=8   ->   #txqueues = 8
> >
> >
> >                    Performance (guest -> local host):
> >                    -----------------------------------
> > System configuration:
> >         Host:  8 Intel Xeon, 8 GB memory
> >         Guest: 4 cpus, 2 GB memory
> > Test: Each test case runs for 60 secs, sum over three runs (except
> > when number of netperf sessions is 1, which has 10 runs of 12 secs
> > each).  No tuning (default netperf) other than taskset vhost's to
> > cpus 0-3.  numtxqs=32 gave the best results though the guest had
> > only 4 vcpus (I haven't tried beyond that).
> >
> > ______________ numtxqs=2, vhosts=3  ____________________
> > #sessions  BW%      CPU%    RCPU%    SD%      RSD%
> > ________________________________________________________
> > 1          4.46    -1.96     .19     -12.50   -6.06
> > 2          4.93    -1.16    2.10      0       -2.38
> > 4          46.17    64.77   33.72     19.51   -2.48
> > 8          47.89    70.00   36.23     41.46    13.35
> > 16         48.97    80.44   40.67     21.11   -5.46
> > 24         49.03    78.78   41.22     20.51   -4.78
> > 32         51.11    77.15   42.42     15.81   -6.87
> > 40         51.60    71.65   42.43     9.75    -8.94
> > 48         50.10    69.55   42.85     11.80   -5.81
> > 64         46.24    68.42   42.67     14.18   -3.28
> > 80         46.37    63.13   41.62     7.43    -6.73
> > 96         46.40    63.31   42.20     9.36    -4.78
> > 128        50.43    62.79   42.16     13.11   -1.23
> > ________________________________________________________
> > BW: 37.2%,  CPU/RCPU: 66.3%,41.6%,  SD/RSD: 11.5%,-3.7%
> >
> > ______________ numtxqs=8, vhosts=5  ____________________
> > #sessions   BW%      CPU%     RCPU%     SD%      RSD%
> > ________________________________________________________
> > 1           -.76    -1.56     2.33      0        3.03
> > 2           17.41    11.11    11.41     0       -4.76
> > 4           42.12    55.11    30.20     19.51    .62
> > 8           54.69    80.00    39.22     24.39    -3.88
> > 16          54.77    81.62    40.89     20.34    -6.58
> > 24          54.66    79.68    41.57     15.49    -8.99
> > 32          54.92    76.82    41.79     17.59    -5.70
> > 40          51.79    68.56    40.53     15.31    -3.87
> > 48          51.72    66.40    40.84     9.72     -7.13
> > 64          51.11    63.94    41.10     5.93     -8.82
> > 80          46.51    59.50    39.80     9.33     -4.18
> > 96          47.72    57.75    39.84     4.20     -7.62
> > 128         54.35    58.95    40.66     3.24     -8.63
> > ________________________________________________________
> > BW: 38.9%,  CPU/RCPU: 63.0%,40.1%,  SD/RSD: 6.0%,-7.4%
> >
> > ______________ numtxqs=16, vhosts=5  ___________________
> > #sessions   BW%      CPU%     RCPU%     SD%      RSD%
> > ________________________________________________________
> > 1           -1.43    -3.52    1.55      0          3.03
> > 2           33.09     21.63   20.12    -10.00     -9.52
> > 4           67.17     94.60   44.28     19.51     -11.80
> > 8           75.72     108.14  49.15     25.00     -10.71
> > 16          80.34     101.77  52.94     25.93     -4.49
> > 24          70.84     93.12   43.62     27.63     -5.03
> > 32          69.01     94.16   47.33     29.68     -1.51
> > 40          58.56     63.47   25.91    -3.92      -25.85
> > 48          61.16     74.70   34.88     .89       -22.08
> > 64          54.37     69.09   26.80    -6.68      -30.04
> > 80          36.22     22.73   -2.97    -8.25      -27.23
> > 96          41.51     50.59   13.24     9.84      -16.77
> > 128         48.98     38.15   6.41     -.33       -22.80
> > ________________________________________________________
> > BW: 46.2%,  CPU/RCPU: 55.2%,18.8%,  SD/RSD: 1.2%,-22.0%
> >
> > ______________ numtxqs=32, vhosts=5  ___________________
> > #            BW%       CPU%    RCPU%    SD%     RSD%
> > ________________________________________________________
> > 1            7.62     -38.03   -26.26  -50.00   -33.33
> > 2            28.95     20.46    21.62   0       -7.14
> > 4            84.05     60.79    45.74  -2.43    -12.42
> > 8            86.43     79.57    50.32   15.85   -3.10
> > 16           88.63     99.48    58.17   9.47    -13.10
> > 24           74.65     80.87    41.99  -1.81    -22.89
> > 32           63.86     59.21    23.58  -18.13   -36.37
> > 40           64.79     60.53    22.23  -15.77   -35.84
> > 48           49.68     26.93    .51    -36.40   -49.61
> > 64           54.69     36.50    5.41   -26.59   -43.23
> > 80           45.06     12.72   -13.25  -37.79   -52.08
> > 96           40.21    -3.16    -24.53  -39.92   -52.97
> > 128          36.33    -33.19   -43.66  -5.68    -20.49
> > ________________________________________________________
> > BW: 49.3%,  CPU/RCPU: 15.5%,-8.2%,  SD/RSD: -22.2%,-37.0%

