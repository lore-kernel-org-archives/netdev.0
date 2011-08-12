From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 0/7] multiqueue support for tun/tap
Date: Fri, 12 Aug 2011 10:11:31 +0800
Message-ID: <20036.35795.314019.270841@gargle.gargle.HOWL>
References: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	qemu-devel@nongnu.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	mirq-linux@rere.qmqm.pl, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Jason Wang writes:
 > As multi-queue nics were commonly used for high-end servers,
 > current single queue based tap can not satisfy the
 > requirement of scaling guest network performance as the
 > numbers of vcpus increase. So the following series
 > implements multiple queue support in tun/tap.
 > 
 > In order to take advantages of this, a multi-queue capable
 > driver and qemu were also needed. I just rebase the latest
 > version of Krishna's multi-queue virtio-net driver into this
 > series to simplify the test. And for multiqueue supported
 > qemu, you can refer the patches I post in
 > http://www.spinics.net/lists/kvm/msg52808.html. Vhost is
 > also a must to achieve high performance and its code could
 > be used for multi-queue without modification. Alternatively,
 > this series can be also used for Krishna's M:N
 > implementation of multiqueue but I didn't test it.
 > 
 > The idea is simple: each socket were abstracted as a queue
 > for tun/tap, and userspace may open as many files as
 > required and then attach them to the devices. In order to
 > keep the ABI compatibility, device creation were still
 > finished in TUNSETIFF, and two new ioctls TUNATTACHQUEUE and
 > TUNDETACHQUEUE were added for user to manipulate the numbers
 > of queues for the tun/tap.
 > 
 > I've done some basic performance testing of multi queue
 > tap. For tun, I just test it through vpnc.
 > 
 > Notes:
 > - Test shows improvement when receving packets from
 > local/external host to guest, and send big packet from guest
 > to local/external host.
 > - Current multiqueue based virtio-net/tap introduce a
 > regression of send small packet (512 byte) from guest to
 > local/external host. I suspect it's the issue of queue
 > selection in both guest driver and tap. Would continue to
 > investigate.
 > - I would post the perforamnce numbers as a reply of this
 > mail.
 > 
 > TODO:
 > - solve the issue of packet transmission of small packets.
 > - addressing the comments of virtio-net driver
 > - performance tunning
 > 
 > Please review and comment it, Thanks.
 > 
 > ---
 > 
 > Jason Wang (5):
 >       tuntap: move socket/sock related structures to tun_file
 >       tuntap: categorize ioctl
 >       tuntap: introduce multiqueue related flags
 >       tuntap: multiqueue support
 >       tuntap: add ioctls to attach or detach a file form tap device
 > 
 > Krishna Kumar (2):
 >       Change virtqueue structure
 >       virtio-net changes
 > 
 > 
 >  drivers/net/tun.c           |  738 ++++++++++++++++++++++++++-----------------
 >  drivers/net/virtio_net.c    |  578 ++++++++++++++++++++++++----------
 >  drivers/virtio/virtio_pci.c |   10 -
 >  include/linux/if_tun.h      |    5 
 >  include/linux/virtio.h      |    1 
 >  include/linux/virtio_net.h  |    3 
 >  6 files changed, 867 insertions(+), 468 deletions(-)
 > 
 > -- 
 > Jason Wang
 > --
 > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
 > Please read the FAQ at  http://www.tux.org/lkml/

Here are some performance result for multiqueue tap

For multiqueue, the test use qemu-kvm + mq patches, net-next-2.6+
tap mq patches + mq driver,
For single queue, the test use qemu-kvm, net-next-2.6, rfs
were also enabled in the guest during the test.

All test were done by netperf in two i7(Intel(R) Xeon(R) CPU
E5620 2.40GHz) with direct connected 82599 cards.

Quick Notes to the result:
- Regression with Guest to External/Local host of 512 bytes.
- For the External host to guest, could scale or at least
the same as the single queue implementation.

1 Guest to External Host TCP 512 byte

Multiqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2054.11                23.43       87
2          2037.32                22.64       89
4          2007.53                22.87       87
8          1993.41                23.82       83
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          1960.58                24.30       80
2          9250.41                32.19       287
4          3897.49                49.31       79
8          4088.44                46.85       87
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          1986.87                23.17       85
2          4431.79                44.64       99
4          8705.83                51.89       167
8          9420.63                45.96       204
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          1820.38                20.17       90
2          3707.64                42.19       87
4          8930.71                63.65       140
8          9391.13                51.90       180

Single-queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2032.64                22.96       88
2          2058.76                23.22       88
4          2028.97                22.84       88
8          1989.41                23.89       83
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2444.50                25.00       97
2          9298.64                30.76       302
4          8788.58                30.82       285
8          9158.28                30.45       300
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2359.50                25.10       94
2          9325.88                29.83       312
4          9198.29                32.96       279
8          8980.73                32.25       278
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2170.15                23.77       91
2          8329.73                28.79       289
4          8152.25                36.11       225
8          9121.11                40.08       227

2 Guest to external host TCP with default size

Multiqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          7767.87                18.43       421
2          9399.18                21.48       437
4          8373.23                21.37       391
8          9310.84                21.91       424
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          9358.75                20.27       461
2          9405.25                30.67       306
4          9407.63                26.24       358
8          9412.77                28.75       327
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          9358.39                22.11       423
2          9401.27                27.29       344
4          9414.98                28.75       327
8          9420.93                31.09       303
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          9057.52                20.09       450
2          8486.72                28.18       301
4          9330.96                40.13       232
8          9377.99                59.41       157

Single Queue Result

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8192.58                19.30       424
2          9400.31                22.55       416
4          8771.94                21.75       403
8          8922.61                22.50       396
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          9387.28                23.13       405
2          8322.94                24.58       338
4          9404.86                26.22       358
8          9145.79                26.57       344
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2377.83                9.86       241
2          9403.32                26.96       348
4          8822.57                27.23       324
8          9380.85                26.90       348
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          7275.95                21.47       338
2          9407.34                27.39       343
4          8365.05                25.99       321
8          9150.65                27.78       329

3 External Host to guest TCP, default packet size

Multiqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8944.69                25.59       349
2          8503.67                24.95       340
4          7910.54                25.88       305
8          7455.13                26.35       282
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          9370.11                23.70       395
2          9365.97                31.91       293
4          9389.83                34.99       268
8          9405.52                34.83       270
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          9061.71                23.45       386
2          9373.92                22.38       418
4          9399.83                40.89       229
8          9412.92                48.99       192
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          8203.61                24.64       332
2          9286.28                32.68       284
4          9403.61                49.33       190
8          9411.42                64.38       146

Single Queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8999.39                26.24       342
2          8921.23                25.00       356
4          7918.52                26.60       297
8          6901.77                25.92       266
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          9016.77                25.82       349
2          8572.92                33.19       258
4          7962.34                28.88       275
8          6959.10                32.77       212
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8951.43                25.76       347
2          8411.78                35.51       236
4          7874.05                35.99       218
8          6869.55                36.80       186
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          9332.84                25.95       359
2          9103.57                30.37       299
4          7907.03                33.94       232
8          6919.99                38.82       178

4 External Host to guest TCP with 512 byte packet size

Multiqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          3354.22                15.75       212
2          6419.73                22.59       284
4          7545.04                25.06       301
8          7550.39                26.32       286
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          3146.17                14.08       223
2          6414.55                21.01       305
4          9389.08                37.86       247
8          9402.39                40.24       233
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          3247.65                14.91       217
2          6528.78                29.89       218
4          9402.89                37.79       248
8          9404.06                47.87       196
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          4367.90                14.16       308
2          6962.76                27.99       248
4          9404.83                41.26       227
8          9412.09                57.74       163

Single Queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          3253.88                14.53       223
2          6385.90                20.83       306
4          7581.40                26.07       290
8          7025.62                26.54       264
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          3257.61                13.85       235
2          6385.06                20.66       309
4          7465.50                32.27       231
8          7021.31                31.42       223
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          3186.60                15.88       200
2          6298.92                27.40       229
4          7474.69                32.53       229
8          6985.72                33.36       209
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          3279.81                17.63       186
2          6513.77                29.78       218
4          7413.30                35.44       209
8          6936.96                32.68       212


5 Guest to Local host TCP with 512 byte packet size

Multuqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          1961.31                35.43       55
2          1974.04                34.76       56
4          1906.74                34.04       56
8          1907.94                34.75       54
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          1971.22                31.95       61
2          2484.96                58.75       42
4          3290.77                53.18       61
8          3031.99                54.11       56
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          1107.56                31.22       35
2          2811.83                59.57       47
4          10276.05                79.79       128
8          12760.93                96.93       131
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          1888.28                32.15       58
2          2335.03                56.72       41
4          9785.72                82.22       119
8          11274.42                95.60       117

Single Queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          1981.08                31.89       62
2          1970.74                32.57       60
4          1944.63                32.02       60
8          1943.50                31.45       61
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2118.23                34.80       60
2          7221.95                45.63       158
4          7924.92                47.06       168
8          8651.28                47.40       182
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2110.70                33.18       63
2          6602.25                42.86       154
4          9715.38                47.38       205
8          20131.98                61.94       325
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          1881.33                40.69       46
2          7631.25                48.56       157
4          13366.28                59.47       224
8          19949.45                68.85       289

6 Guest to Local host with default packet size.

Multuqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8674.81                34.86       248
2          8576.14                34.72       247
4          8503.87                34.62       245
8          8247.43                33.77       244
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          7785.02                32.25       241
2          14696.71                58.14       252
4          12339.64                51.43       239
8          12997.55                52.53       247
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          8557.25                32.38       264
2          12164.88                58.56       207
4          18144.19                73.69       246
8          29756.33                96.15       309
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          6808.67                36.55       186
2          11590.04                61.14       189
4          23667.67                81.50       290
8          25501.89                92.44       275

Single Queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8053.49                36.35       221
2          8493.95                35.21       241
4          8367.26                34.61       241
8          8435.64                35.45       237
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          9259.56                35.24       262
2          17153.83                44.07       389
4          16901.67                45.88       368
8          18180.81                42.34       429
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          8928.11                31.22       285
2          16835.27                47.79       352
4          16923.83                47.78       354
8          18050.62                45.86       393
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2978.88                25.75       115
2          15422.18                41.97       367
4          16137.10                45.90       351
8          16628.30                48.99       339

7 Local host to Guest with defaut 512 packet size

Multiqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          3665.90                31.88       114
2          5709.15                38.16       149
4          8803.25                42.92       205
8          10530.33                45.21       232
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          3390.07                31.28       108
2          7502.21                62.42       120
4          14247.63                67.23       211
8          16766.93                69.66       240
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          3580.96                31.90       112
2          4353.46                62.85       69
4          8264.18                77.94       106
8          16014.00                80.11       199
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          1745.36                41.84       41
2          4472.03                73.50       60
4          12646.92                79.86       158
8          18212.21                89.79       202

Single Queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          4220.96                31.88       132
2          5732.38                37.12       154
4          7006.81                41.60       168
8          10529.09                45.92       229
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2665.41                40.53       65
2          9864.49                59.44       165
4          11678.42                60.20       193
8          16042.60                57.85       277
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2609.10                42.67       61
2          5496.83                68.52       80
4          16848.24                60.49       278
8          14829.66                60.54       244
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          2567.15                44.54       57
2          5902.02                59.32       99
4          13265.99                68.48       193
8          15301.16                63.95       239

8 Local host to Guest with default packet size

Multiqueue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          12531.65                29.95       418
2          12495.93                30.05       415
4          12487.40                31.28       399
8          11501.68                33.51       343
== smp=2 queue=2 ==
sessions  | throughput        | cpu      | normalized
1          12566.08                28.86       435
2          21756.15                54.33       400
4          19899.84                56.37       353
8          19326.62                61.57       313
== smp=4 queue=4 ==
sessions  | throughput        | cpu      | normalized
1          12383.42                28.69       431
2          19714.34                57.62       342
4          20609.45                64.13       321
8          18935.57                95.05       199
== smp=8 queue=8 ==
sessions  | throughput        | cpu      | normalized
1          13736.90                31.95       429
2          26157.13                71.77       364
4          22874.41                78.54       291
8          19960.91                96.08       207

Single Queue Result:

== smp=1 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          12501.11                30.01       416
2          12497.01                28.51       438
4          12429.25                31.09       399
8          12152.53                28.20       430
== smp=2 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          13632.87                35.32       385
2          19900.82                46.28       430
4          17510.87                42.21       414
8          14443.78                35.48       407
== smp=4 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          14584.61                37.70       386
2          12646.50                31.39       402
4          16248.16                49.22       330
8          14131.34                47.48       297
== smp=8 queue=1 ==
sessions  | throughput        | cpu      | normalized
1          16279.89                39.51       412
2          16958.02                53.87       314
4          16906.03                50.35       335
8          14686.25                47.30       310

-- 
Jason Wang
