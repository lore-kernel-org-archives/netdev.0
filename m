From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Mon, 25 Oct 2010 21:20:38 +0530
Message-ID: <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Krishna Kumar2/India/IBM@IBMIN wrote on 10/20/2010 02:24:52 PM:

Any feedback, comments, objections, issues or bugs about the
patches? Please let me know if something needs to be done.

Some more test results:
_____________________________________________________
         Host->Guest BW (numtxqs=2)
#       BW%     CPU%    RCPU%   SD%     RSD%
_____________________________________________________
1       5.53    .31     .67     -5.88   0
2       -2.11   -1.01   -2.08   4.34    0
4       13.53   10.77   13.87   -1.96   0
8       34.22   22.80   30.53   -8.46   -2.50
16      30.89   24.06   35.17   -5.20   3.20
24      33.22   26.30   43.39   -5.17   7.58
32      30.85   27.27   47.74   -.59    15.51
40      33.80   27.33   48.00   -7.42   7.59
48      45.93   26.33   45.46   -12.24  1.10
64      33.51   27.11   45.00   -3.27   10.30
80      39.28   29.21   52.33   -4.88   12.17
96      32.05   31.01   57.72   -1.02   19.05
128     35.66   32.04   60.00   -.66    20.41
_____________________________________________________
BW: 23.5%  CPU/RCPU: 28.6%,51.2%  SD/RSD: -2.6%,15.8%

____________________________________________________
Guest->Host 512 byte (numtxqs=2):
#       BW%     CPU%    RCPU%   SD%     RSD%
_____________________________________________________
1       3.02    -3.84   -4.76   -12.50  -7.69
2       52.77   -15.73  -8.66   -45.31  -40.33
4       -23.14  13.84   7.50    50.58   40.81
8       -21.44  28.08   16.32   63.06   47.43
16      33.53   46.50   27.19   7.61    -6.60
24      55.77   42.81   30.49   -8.65   -16.48
32      52.59   38.92   29.08   -9.18   -15.63
40      50.92   36.11   28.92   -10.59  -15.30
48      46.63   34.73   28.17   -7.83   -12.32
64      45.56   37.12   28.81   -5.05   -10.80
80      44.55   36.60   28.45   -4.95   -10.61
96      43.02   35.97   28.89   -.11    -5.31
128     38.54   33.88   27.19   -4.79   -9.54
_____________________________________________________
BW: 34.4%  CPU/RCPU: 35.9%,27.8%  SD/RSD: -4.1%,-9.3%


Thanks,

- KK



> [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
>
> Following set of patches implement transmit MQ in virtio-net.  Also
> included is the user qemu changes.  MQ is disabled by default unless
> qemu specifies it.
>
>                   Changes from rev2:
>                   ------------------
> 1. Define (in virtio_net.h) the maximum send txqs; and use in
>    virtio-net and vhost-net.
> 2. vi->sq[i] is allocated individually, resulting in cache line
>    aligned sq[0] to sq[n].  Another option was to define
>    'send_queue' as:
>        struct send_queue {
>                struct virtqueue *svq;
>                struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
>        } ____cacheline_aligned_in_smp;
>    and to statically allocate 'VIRTIO_MAX_SQ' of those.  I hope
>    the submitted method is preferable.
> 3. Changed vhost model such that vhost[0] handles RX and vhost[1-MAX]
>    handles TX[0-n].
> 4. Further change TX handling such that vhost[0] handles both RX/TX
>    for single stream case.
>
>                   Enabling MQ on virtio:
>                   -----------------------
> When following options are passed to qemu:
>         - smp > 1
>         - vhost=on
>         - mq=on (new option, default:off)
> then #txqueues = #cpus.  The #txqueues can be changed by using an
> optional 'numtxqs' option.  e.g. for a smp=4 guest:
>         vhost=on                   ->   #txqueues = 1
>         vhost=on,mq=on             ->   #txqueues = 4
>         vhost=on,mq=on,numtxqs=2   ->   #txqueues = 2
>         vhost=on,mq=on,numtxqs=8   ->   #txqueues = 8
>
>
>                    Performance (guest -> local host):
>                    -----------------------------------
> System configuration:
>         Host:  8 Intel Xeon, 8 GB memory
>         Guest: 4 cpus, 2 GB memory
> Test: Each test case runs for 60 secs, sum over three runs (except
> when number of netperf sessions is 1, which has 10 runs of 12 secs
> each).  No tuning (default netperf) other than taskset vhost's to
> cpus 0-3.  numtxqs=32 gave the best results though the guest had
> only 4 vcpus (I haven't tried beyond that).
>
> ______________ numtxqs=2, vhosts=3  ____________________
> #sessions  BW%      CPU%    RCPU%    SD%      RSD%
> ________________________________________________________
> 1          4.46    -1.96     .19     -12.50   -6.06
> 2          4.93    -1.16    2.10      0       -2.38
> 4          46.17    64.77   33.72     19.51   -2.48
> 8          47.89    70.00   36.23     41.46    13.35
> 16         48.97    80.44   40.67     21.11   -5.46
> 24         49.03    78.78   41.22     20.51   -4.78
> 32         51.11    77.15   42.42     15.81   -6.87
> 40         51.60    71.65   42.43     9.75    -8.94
> 48         50.10    69.55   42.85     11.80   -5.81
> 64         46.24    68.42   42.67     14.18   -3.28
> 80         46.37    63.13   41.62     7.43    -6.73
> 96         46.40    63.31   42.20     9.36    -4.78
> 128        50.43    62.79   42.16     13.11   -1.23
> ________________________________________________________
> BW: 37.2%,  CPU/RCPU: 66.3%,41.6%,  SD/RSD: 11.5%,-3.7%
>
> ______________ numtxqs=8, vhosts=5  ____________________
> #sessions   BW%      CPU%     RCPU%     SD%      RSD%
> ________________________________________________________
> 1           -.76    -1.56     2.33      0        3.03
> 2           17.41    11.11    11.41     0       -4.76
> 4           42.12    55.11    30.20     19.51    .62
> 8           54.69    80.00    39.22     24.39    -3.88
> 16          54.77    81.62    40.89     20.34    -6.58
> 24          54.66    79.68    41.57     15.49    -8.99
> 32          54.92    76.82    41.79     17.59    -5.70
> 40          51.79    68.56    40.53     15.31    -3.87
> 48          51.72    66.40    40.84     9.72     -7.13
> 64          51.11    63.94    41.10     5.93     -8.82
> 80          46.51    59.50    39.80     9.33     -4.18
> 96          47.72    57.75    39.84     4.20     -7.62
> 128         54.35    58.95    40.66     3.24     -8.63
> ________________________________________________________
> BW: 38.9%,  CPU/RCPU: 63.0%,40.1%,  SD/RSD: 6.0%,-7.4%
>
> ______________ numtxqs=16, vhosts=5  ___________________
> #sessions   BW%      CPU%     RCPU%     SD%      RSD%
> ________________________________________________________
> 1           -1.43    -3.52    1.55      0          3.03
> 2           33.09     21.63   20.12    -10.00     -9.52
> 4           67.17     94.60   44.28     19.51     -11.80
> 8           75.72     108.14  49.15     25.00     -10.71
> 16          80.34     101.77  52.94     25.93     -4.49
> 24          70.84     93.12   43.62     27.63     -5.03
> 32          69.01     94.16   47.33     29.68     -1.51
> 40          58.56     63.47   25.91    -3.92      -25.85
> 48          61.16     74.70   34.88     .89       -22.08
> 64          54.37     69.09   26.80    -6.68      -30.04
> 80          36.22     22.73   -2.97    -8.25      -27.23
> 96          41.51     50.59   13.24     9.84      -16.77
> 128         48.98     38.15   6.41     -.33       -22.80
> ________________________________________________________
> BW: 46.2%,  CPU/RCPU: 55.2%,18.8%,  SD/RSD: 1.2%,-22.0%
>
> ______________ numtxqs=32, vhosts=5  ___________________
> #            BW%       CPU%    RCPU%    SD%     RSD%
> ________________________________________________________
> 1            7.62     -38.03   -26.26  -50.00   -33.33
> 2            28.95     20.46    21.62   0       -7.14
> 4            84.05     60.79    45.74  -2.43    -12.42
> 8            86.43     79.57    50.32   15.85   -3.10
> 16           88.63     99.48    58.17   9.47    -13.10
> 24           74.65     80.87    41.99  -1.81    -22.89
> 32           63.86     59.21    23.58  -18.13   -36.37
> 40           64.79     60.53    22.23  -15.77   -35.84
> 48           49.68     26.93    .51    -36.40   -49.61
> 64           54.69     36.50    5.41   -26.59   -43.23
> 80           45.06     12.72   -13.25  -37.79   -52.08
> 96           40.21    -3.16    -24.53  -39.92   -52.97
> 128          36.33    -33.19   -43.66  -5.68    -20.49
> ________________________________________________________
> BW: 49.3%,  CPU/RCPU: 15.5%,-8.2%,  SD/RSD: -22.2%,-37.0%
>
>
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

