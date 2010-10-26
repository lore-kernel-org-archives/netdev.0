From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 26 Oct 2010 14:38:53 +0530
Message-ID: <OFBB51646E.01CC3630-ON652577C8.0030D6EF-652577C8.0031DA3C@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101025161718.GA19559@redhat.com> <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2/India/IBM wrote on 10/26/2010 10:40:35 AM:

> > I am trying to wrap my head around kernel/user interface here.
> > E.g., will we need another incompatible change when we add multiple RX
> > queues?
>
> Though I added a 'mq' option to qemu, there shouldn't be
> any incompatibility between old and new qemu's wrt vhost
> and virtio-net drivers. So the old qemu will run new host
> and new guest without issues, and new qemu can also run
> old host and old guest. Multiple RXQ will also not add
> any incompatibility.
>
> With MQ RX, I will be able to remove the hueristic (idea
> from David Stevens).  The idea is: Guest sends out packets
> on, say TXQ#2, vhost#2 processes the packets but packets
> going out from host to guest might be sent out on a
> different RXQ, say RXQ#4.  Guest receives the packet on
> RXQ#4, and all future responses on that connection are sent
> on TXQ#4.  Now vhost#4 processes both RX and TX packets for
> this connection.  Without needing to hash on the connection,
> guest can make sure that the same vhost thread will handle
> a single connection.
>
> > Also need to think about how robust our single stream heuristic is,
> > e.g. what are the chances it will misdetect a bidirectional
> > UDP stream as a single TCP?

> I think it should not happen. The hueristic code gets
> called for handling just the transmit packets, packets
> that vhost sends out to the guest skip this path.
>
> I tested unidirectional and bidirectional UDP to confirm:
>
> 8 iterations of iperf tests, each iteration of 15 secs,
> result is the sum of all 8 iterations in Gbits/sec
> __________________________________________
> Uni-directional          Bi-directional
>   Org      New             Org      New
> __________________________________________
>   71.78    71.77           71.74   72.07
> __________________________________________


Results for UDP BW tests (unidirectional, sum across
3 iterations, each iteration of 45 seconds, default
netperf, vhosts bound to cpus 0-3; no other tuning):

------ numtxqs=8, vhosts=5 ---------
#     BW%    CPU%    SD%
------------------------------------
1     .49    1.07     0
2    23.51   52.51    26.66
4    75.17   72.43    8.57
8    86.54   80.21    27.85
16   92.37   85.99    6.27
24   91.37   84.91    8.41
32   89.78   82.90    3.31
48   89.85   79.95   -3.57
64   85.83   80.28    2.22
80   88.90   79.47   -23.18
96   90.12   79.98    14.71
128  86.13   80.60    4.42
------------------------------------
BW: 71.3%, CPU: 80.4%, SD: 1.2%


------ numtxqs=16, vhosts=5 --------
#    BW%      CPU%     SD%
------------------------------------
1    1.80     0        0
2    19.81    50.68    26.66
4    57.31    52.77    8.57
8    108.44   88.19   -5.21
16   106.09   85.03   -4.44
24   102.34   84.23   -.82
32   102.77   82.71   -5.81
48   100.00   79.62   -7.29
64   96.86    79.75   -6.10
80   99.26    79.82   -27.34
96   94.79    80.02   -5.08
128  98.14    81.15   -15.25
------------------------------------
BW: 77.9%,  CPU: 80.4%,  SD: -13.6%

Thanks,

- KK

