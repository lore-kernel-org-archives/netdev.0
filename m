From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V4 PATCH 0/4] Multiqueue virtio-net
Date: Mon, 25 Jun 2012 17:16:48 +0800
Message-ID: <20120625090829.7263.65026.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org
To: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mst@redhat.com, netdev@vger.kernel.org, mashirle@us.ibm.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr, akong@redhat.com,
	davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hello All:

This series is an update version of multiqueue virtio-net driver based on
Krishna Kumar's work to let virtio-net use multiple rx/tx queues to do the
packets reception and transmission. Please review and comments.

Test Environment:
- Intel(R) Xeon(R) CPU E5620 @ 2.40GHz, 8 cores 2 numa nodes
- Two directed connected 82599

Test Summary:

- Highlights: huge improvements on TCP_RR test
- Lowlights: regression on small packet transmission, higher cpu utilization
             than single queue, need further optimization

Analysis of the performance result:

- I count the number of packets sending/receiving during the test, and
  multiqueue show much more ability in terms of packets per second.

- For the tx regression, multiqueue send about 1-2 times of more packets
  compared to single queue, and the packets size were much smaller than single
  queue does. I suspect tcp does less batching in multiqueue, so I hack the
  tcp_write_xmit() to forece more batching, multiqueue works as well as
  singlequeue for both small transmission and throughput

- I didn't pack the accelerate RFS with virtio-net in this sereis as it still
  need further shaping, for the one that interested in this please see:
  http://www.mail-archive.com/kvm@vger.kernel.org/msg64111.html

Detail result:

Test results: smp = 2 pin vhosts and vcpus in the same node - 1 sq 2 mq(q=2)
- TCP_MAERTS (Guest to external Host):

sessions size throughput1 throughput2   norm1 norm2:
1 64 424.91 401.49 94% 13.20 12.35 93%
2 64 1211.06 878.31 72% 24.35 15.80 64%
4 64 1292.46 1081.78 83% 26.46 20.14 76%
8 64 1355.57 826.06 60% 27.88 15.32 54%
1 256 1489.37 1406.51 94% 46.93 43.72 93%
2 256 4936.19 2688.46 54% 100.24 46.39 46%
4 256 5251.10 2900.08 55% 107.98 50.47 46%
8 256 5270.11 3562.10 67% 108.26 66.19 61%
1 512 1877.57 2697.64 143% 57.29 83.02 144%
2 512 9183.49 5056.33 55% 205.26 86.43 42%
4 512 9349.59 8918.77 95% 212.78 176.99 83%
8 512 9318.29 8947.69 96% 216.55 176.34 81%
1 1024 4746.47 4669.10 98% 143.87 140.63 97%
2 1024 7406.49 4738.58 63% 245.16 131.04 53%
4 1024 8955.70 9337.82 104% 254.49 208.66 81%
8 1024 9384.48 9378.41 99% 260.24 197.77 75%
1 2048 8947.29 8955.98 100% 338.39 338.60 100%
2 2048 9259.04 9383.77 101% 326.02 224.92 68%
4 2048 9043.04 9325.38 103% 305.09 214.77 70%
8 2048 9358.04 8413.21 89% 291.07 189.74 65%
1 4096 8882.55 8885.40 100% 329.83 326.42 98%
2 4096 9247.07 9387.49 101% 345.55 240.51 69%
4 4096 9365.30 9341.82 99% 333.40 211.97 63%
8 4096 9397.64 8472.35 90% 312.21 182.51 58%
1 16384 8843.82 8725.50 98% 315.06 312.29 99%
2 16384 7978.70 9176.16 115% 280.34 317.62 113%
4 16384 8906.91 9251.15 103% 312.85 226.13 72%
8 16384 9385.36 9401.39 100% 341.53 207.53 60%

- TCP_RR

sessions size trans1 trans2   norm1 norm2
50 1 63021.83 93003.57 147% 2360.36 1972.08 83%
100 1 54599.87 93724.43 171% 2042.64 2119.50 103%
250 1 86546.75 119738.71 138% 2414.80 2508.14 103%
50 64 59785.19 97761.24 163% 2264.59 2136.85 94%
100 64 56028.20 103233.18 184% 2063.65 2260.91 109%
250 64 99116.82 113948.86 114% 2452.77 2393.88 97%
50 128 58025.96 84971.26 146% 2284.48 1907.75 83%
100 128 66302.76 83110.60 125% 2579.87 1881.60 72%
250 128 109262.23 137571.13 125% 2603.96 2911.55 111%
50 256 59766.57 77370.93 129% 2393.53 2018.02 84%
100 256 60862.02 80737.50 132% 2426.71 2024.51 83%
250 256 90076.66 141780.44 157% 2453.06 3056.27 124%

- TCP_STREAM (External Host to Guest)

sessions size throughput1 throughput2   norm1 norm2
1 64 373.53 575.24 154% 15.37 33.44 217%
2 64 1314.17 1087.49 82% 54.21 32.97 60%
4 64 3352.93 2404.70 71% 136.35 53.72 39%
8 64 6866.17 6587.17 95% 252.06 147.03 58%
1 256 677.37 767.65 113% 26.59 29.80 112%
2 256 4386.83 4550.40 103% 164.17 174.81 106%
4 256 8446.27 8814.95 104% 307.02 186.95 60%
8 256 6529.46 9370.44 143% 237.52 207.77 87%
1 512 2542.48 1371.31 53% 102.14 51.68 50%
2 512 9183.10 9354.81 101% 319.85 333.62 104%
4 512 8488.12 9230.58 108% 303.14 258.55 85%
8 512 8115.66 9393.33 115% 293.83 219.82 74%
1 1024 2653.16 2507.78 94% 100.88 96.56 95%
2 1024 6490.12 5033.35 77% 316.74 102.74 32%
4 1024 7582.51 9183.60 121% 298.87 210.48 70%
8 1024 8304.13 9341.48 112% 298.06 242.32 81%
1 2048 2495.06 2508.12 100% 99.60 102.96 103%
2 2048 8968.12 7554.57 84% 324.57 175.56 54%
4 2048 8627.85 9192.90 106% 310.91 205.98 66%
8 2048 7781.72 9422.10 121% 284.31 208.77 73%
1 4096 6067.46 4489.04 73% 233.63 171.01 73%
2 4096 9029.43 8684.09 96% 323.17 191.19 59%
4 4096 8284.30 9253.33 111% 306.93 268.67 87%
8 4096 7789.39 9388.32 120% 283.97 238.28 83%
1 16384 8660.90 9313.87 107% 318.88 315.61 98%
2 16384 8646.37 8871.30 102% 318.81 318.88 100%
4 16384 8386.02 9397.13 112% 306.28 205.44 67%
8 16384 8006.27 9404.98 117% 288.41 224.83 77%

Test results: smp = 4 no pinning - 1 sq 2 mq(q=4)

- TCP_MAERTS - Guest to External Host

sessions size throughput1 throughput2   norm1 norm2
1 64 513.13 331.27 64% 15.86 10.39 65%
2 64 1325.72 543.38 40% 26.54 12.59 47%
4 64 2735.18 1168.01 42% 37.61 12.63 33%
8 64 3084.53 2278.38 73% 41.20 27.01 65%
1 256 1313.25 996.64 75% 41.23 28.59 69%
2 256 3425.64 3337.68 97% 71.57 61.69 86%
4 256 8174.33 4252.54 52% 126.63 49.68 39%
8 256 9365.96 8411.91 89% 145.00 101.64 70%
1 512 2363.07 2370.35 100% 73.00 73.52 100%
2 512 6047.23 3636.29 60% 135.43 61.02 45%
4 512 9330.76 7165.99 76% 184.18 95.50 51%
8 512 8178.20 9221.16 112% 162.52 122.44 75%
1 1024 3196.63 4016.30 125% 98.41 120.75 122%
2 1024 4940.41 9296.51 188% 140.03 191.95 137%
4 1024 5696.43 9018.76 158% 147.30 150.01 101%
8 1024 9355.07 9342.43 99% 216.90 140.48 64%
1 2048 4248.99 5189.24 122% 131.95 157.01 118%
2 2048 9021.22 9262.81 102% 242.37 198.21 81%
4 2048 8357.81 9241.94 110% 225.88 180.61 79%
8 2048 8024.56 9327.27 116% 205.75 145.76 70%
1 4096 9270.51 8199.32 88% 326.88 269.53 82%
2 4096 9151.10 9348.33 102% 257.92 214.46 83%
4 4096 9243.34 9294.30 100% 281.20 164.35 58%
8 4096 9020.35 9339.32 103% 249.87 143.54 57%
1 16384 9357.69 9355.69 99% 319.15 322.94 101%
2 16384 9319.39 9076.63 97% 319.26 215.64 67%
4 16384 9352.99 9183.41 98% 308.98 145.26 47%
8 16384 9384.67 9353.54 99% 322.49 155.78 48%

- TCP_RR
sessions size throughput1 throughput2   norm1 norm2
50 1 59677.80 71761.59 120% 2020.92 1585.19 78%
100 1 55324.42 81302.10 146% 1889.49 1439.22 76%
250 1 73973.48 155031.82 209% 2495.73 2195.91 87%
50 64 53093.57 67893.59 127% 1879.41 1266.19 67%
100 64 59186.33 60128.69 101% 2044.43 1084.57 53%
250 64 64159.90 137389.38 214% 2186.02 1994.61 91%
50 128 54323.45 51615.38 95% 1924.99 908.08 47%
100 128 57543.49 69999.21 121% 2049.99 1266.95 61%
250 128 71541.81 123915.35 173% 2448.38 1845.62 75%
50 256 57184.12 68314.09 119% 2204.47 1393.02 63%
100 256 51983.40 61931.00 119% 1897.89 1216.24 64%
250 256 66542.32 119435.53 179% 2267.97 1887.71 83%

- TCP_STREAM - External Host to Guest
sessions size throughput1 throughput2   norm1 norm2
1 64 589.10 634.81 107% 27.01 34.51 127%
2 64 1805.57 1442.49 79% 70.44 39.59 56%
4 64 3066.91 3869.26 126% 121.89 84.96 69%
8 64 6602.37 7626.61 115% 211.07 116.27 55%
1 256 775.25 2092.37 269% 26.38 115.47 437%
2 256 6213.63 3527.24 56% 191.89 84.18 43%
4 256 7333.13 9190.87 125% 230.74 218.05 94%
8 256 6776.23 9396.71 138% 216.14 153.14 70%
1 512 4308.25 3536.38 82% 160.93 140.38 87%
2 512 7159.09 9212.97 128% 240.80 201.42 83%
4 512 7095.49 9241.70 130% 229.77 193.26 84%
8 512 6935.59 9398.09 135% 221.37 152.36 68%
1 1024 5566.68 6155.74 110% 250.52 245.05 97%
2 1024 7303.83 9212.72 126% 299.33 229.91 76%
4 1024 7179.31 9334.93 130% 233.62 192.51 82%
8 1024 7080.91 9396.46 132% 226.37 173.81 76%
1 2048 7477.66 2671.34 35% 250.25 96.85 38%
2 2048 6743.70 8986.82 133% 295.51 230.07 77%
4 2048 7186.19 9239.56 128% 228.13 219.78 96%
8 2048 6883.19 9375.34 136% 221.11 164.59 74%
1 4096 7582.83 5040.55 66% 291.98 178.36 61%
2 4096 7617.98 9345.37 122% 245.74 197.78 80%
4 4096 7157.87 9383.81 131% 226.80 188.65 83%
8 4096 5916.83 9401.45 158% 189.64 147.61 77%
1 16384 8417.28 5351.11 63% 309.57 301.47 97%
2 16384 8426.42 9303.45 110% 302.13 197.14 65%
4 16384 5695.26 8678.73 152% 180.68 192.30 106%
8 16384 6761.33 9374.67 138% 214.50 160.25 74%

Changes from V3:

- Rebase to the net-next
- Let queue 2 to be the control virtqueue to obey the spec
- Prodives irq affinity
- Choose txq based on processor id

References:

- V3: http://lwn.net/Articles/467283/

---

Jason Wang (3):
      virtio_ring: move queue_index to vring_virtqueue
      virtio: introduce a method to get the irq of a specific virtqueue
      virtio_net: multiqueue support

Krishna Kumar (1):
      virtio_net: Introduce VIRTIO_NET_F_MULTIQUEUE


 drivers/lguest/lguest_device.c |    8 
 drivers/net/virtio_net.c       |  695 +++++++++++++++++++++++++++++-----------
 drivers/s390/kvm/kvm_virtio.c  |    6 
 drivers/virtio/virtio_mmio.c   |   13 +
 drivers/virtio/virtio_pci.c    |   24 +
 drivers/virtio/virtio_ring.c   |   17 +
 include/linux/virtio.h         |    4 
 include/linux/virtio_config.h  |    4 
 include/linux/virtio_net.h     |    3 
 9 files changed, 572 insertions(+), 202 deletions(-)

-- 
Jason Wang
