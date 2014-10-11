From: Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next RFC 0/3] virtio-net: Conditionally enable tx interrupt
Date: Sat, 11 Oct 2014 15:16:43 +0800
Message-ID: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello all:

We free old transmitted packets in ndo_start_xmit() currently, so any
packet must be orphaned also there. This was used to reduce the overhead of
tx interrupt to achieve better performance. But this may not work for some
protocols such as TCP stream. TCP depends on the value of sk_wmem_alloc to
implement various optimization for small packets stream such as TCP small
queue and auto corking. But orphaning packets early in ndo_start_xmit()
disable such things more or less since sk_wmem_alloc was not accurate. This
lead extra low throughput for TCP stream of small writes.

This series tries to solve this issue by enable tx interrupts for all TCP
packets other than the ones with push bit or pure ACK. This is done through
the support of urgent descriptor which can force an interrupt for a
specified packet. If tx interrupt was enabled for a packet, there's no need
to orphan it in ndo_start_xmit(), we can free it tx napi which is scheduled
by tx interrupt. Then sk_wmem_alloc was more accurate than before and TCP
can batch more for small write. More larger skb was produced by TCP in this
case to improve both throughput and cpu utilization.

Test shows great improvements on small write tcp streams. For most of the
other cases, the throughput and cpu utilization are the same in the
past. Only few cases, more cpu utilization was noticed which needs more
investigation.

Review and comments are welcomed.

Thanks

Test result:

- Two Intel Corporation Xeon 5600s (8 cores) with back to back connected
  82599ES:
- netperf test between guest and remote host
- 1 queue 2 vcpus with zercopy enabled vhost_net
- both host and guest are net-next.git with the patches.
- Value with '[]' means obvious difference (the significance is greater
  than 95%).
- he significance of the differences between the two averages is calculated
  using unpaired T-test that takes into account the SD of the averages.

Guest RX
size/sessions/throughput-+%/cpu-+%/per cpu throughput -+%/
64/1/+3.7872%/+3.2307%/+0.5390%/
64/2/-0.2325%/+2.9552%/-3.0962%/
64/4/[-2.0296%]/+2.2955%/[-4.2280%]/
64/8/+0.0944%/[+2.2654%]/-2.4662%/
256/1/+1.1947%/-2.5462%/+3.8386%/
256/2/-1.6477%/+3.4421%/-4.9301%/
256/4/[-5.9526%]/[+6.8861%]/[-11.9951%]/
256/8/-3.6470%/-1.5887%/-2.0916%/
1024/1/-4.2225%/-1.3238%/-2.9376%/
1024/2/+0.3568%/+1.8439%/-1.4601%/
1024/4/-0.7065%/-0.0099%/-2.3483%/
1024/8/-1.8620%/-2.4774%/+0.6310%/
4096/1/+0.0115%/-0.3693%/+0.3823%/
4096/2/-0.0209%/+0.8730%/-0.8862%/
4096/4/+0.0729%/-7.0303%/+7.6403%/
4096/8/-2.3720%/+0.0507%/-2.4214%/
16384/1/+0.0222%/-1.8672%/+1.9254%/
16384/2/+0.0986%/+3.2968%/-3.0961%/
16384/4/-1.2059%/+7.4291%/-8.0379%/
16384/8/-1.4893%/+0.3403%/-1.8234%/
65535/1/-0.0445%/-1.4060%/+1.3808%/
65535/2/-0.0311%/+0.9610%/-0.9827%/
65535/4/-0.7015%/+0.3660%/-1.0637%/
65535/8/-3.1585%/+11.1302%/[-12.8576%]/

Guest TX
size/sessions/throughput-+%/cpu-+%/per cpu throughput -+%/
64/1/[+75.2622%]/[-14.3928%]/[+104.7283%]/
64/2/[+68.9596%]/[-12.6655%]/[+93.4625%]/
64/4/[+68.0126%]/[-12.7982%]/[+92.6710%]/
64/8/[+67.9870%]/[-12.6297%]/[+92.2703%]/
256/1/[+160.4177%]/[-26.9643%]/[+256.5624%]/
256/2/[+48.4357%]/[-24.3380%]/[+96.1825%]/
256/4/[+48.3663%]/[-24.1127%]/[+95.5087%]/
256/8/[+47.9722%]/[-24.2516%]/[+95.3469%]/
1024/1/[+54.4474%]/[-52.9223%]/[+228.0694%]/
1024/2/+0.0742%/[-12.7444%]/[+14.6908%]/
1024/4/[+0.5524%]/-0.0327%/+0.5853%/
1024/8/[-1.2783%]/[+6.2902%]/[-7.1206%]/
4096/1/+0.0778%/-13.1121%/+15.1804%/
4096/2/+0.0189%/[-11.3176%]/[+12.7832%]/
4096/4/+0.0218%/-1.0389%/+1.0718%/
4096/8/-1.3774%/[+12.7396%]/[-12.5218%]/
16384/1/+0.0136%/-2.5043%/+2.5826%/
16384/2/+0.0509%/[-15.3846%]/[+18.2420%]/
16384/4/-0.0163%/[-4.8808%]/[+5.1141%]/
16384/8/[-1.7249%]/[+13.9174%]/[-13.7313%]/
65535/1/+0.0686%/-5.4942%/+5.8862%/
65535/2/+0.0043%/[-7.5816%]/[+8.2082%]/
65535/4/+0.0080%/[-7.2993%]/[+7.8827%]/
65535/8/[-1.3669%]/[+16.6536%]/[-15.4479%]/

Guest TCP_RR
size/sessions/throughput-+%/cpu-+%/per cpu throughput -+%/
256/1/-0.2914%/+12.6457%/-11.4848%/
256/25/-0.5968%/-5.0531%/+4.6935%/
256/50/+0.0262%/+0.2079%/-0.1813%/
4096/1/+2.6965%/[+16.1248%]/[-11.5636%]/
4096/25/-0.5002%/+0.5449%/-1.0395%/
4096/50/[-2.0987%]/-0.0330%/[-2.0664%]/

Tests on mlx4 was ongoing, will post the result in next week.

Jason Wang (3):
  virtio: support for urgent descriptors
  vhost: support urgent descriptors
  virtio-net: conditionally enable tx interrupt

 drivers/net/virtio_net.c         | 164 ++++++++++++++++++++++++++++++---------
 drivers/vhost/net.c              |  43 +++++++---
 drivers/vhost/scsi.c             |  23 ++++--
 drivers/vhost/test.c             |   5 +-
 drivers/vhost/vhost.c            |  44 +++++++----
 drivers/vhost/vhost.h            |  19 +++--
 drivers/virtio/virtio_ring.c     |  75 +++++++++++++++++-
 include/linux/virtio.h           |  14 ++++
 include/uapi/linux/virtio_ring.h |   5 +-
 9 files changed, 308 insertions(+), 84 deletions(-)

-- 
1.8.3.1
