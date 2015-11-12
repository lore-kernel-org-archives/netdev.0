From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC V3 0/3] basic busy polling support for
	vhost_net
Date: Thu, 12 Nov 2015 18:20:25 +0800
Message-ID: <564467E9.9080409@redhat.com>
References: <1447323395-28052-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1447323395-28052-1-git-send-email-jasowang@redhat.com>
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



On 11/12/2015 06:16 PM, Jason Wang wrote:
> Hi all:
>
> This series tries to add basic busy polling for vhost net. The idea is
> simple: at the end of tx/rx processing, busy polling for new tx added
> descriptor and rx receive socket for a while. The maximum number of
> time (in us) could be spent on busy polling was specified ioctl.
>
> Test were done through:
>
> - 50 us as busy loop timeout
> - Netperf 2.6
> - Two machines with back to back connected ixgbe
> - Guest with 1 vcpu and 1 queue
>
> Results:
> - For stream workload, ioexits were reduced dramatically in medium
>   size (1024-2048) of tx (at most -39%) and almost all rx (at most
>   -79%) as a result of polling. This compensate for the possible
>   wasted cpu cycles more or less. That porbably why we can still see
>   some increasing in the normalized throughput in some cases.
> - Throughput of tx were increased (at most 105%) expect for the huge
>   write (16384). And we can send more packets in the case (+tpkts were
>   increased).
> - Very minor rx regression in some cases.
> - Improvemnt on TCP_RR (at most 16%).

Forget to mention, the following test results by order are:

1) Guest TX
2) Guest RX
3) TCP_RR

> size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
>    64/     1/   +9%/  -17%/   +5%/  +10%/   -2%
>    64/     2/   +8%/  -18%/   +6%/  +10%/   -1%
>    64/     4/   +4%/  -21%/   +6%/  +10%/   -1%
>    64/     8/   +9%/  -17%/   +6%/   +9%/   -2%
>   256/     1/  +20%/   -1%/  +15%/  +11%/   -9%
>   256/     2/  +15%/   -6%/  +15%/   +8%/   -8%
>   256/     4/  +17%/   -4%/  +16%/   +8%/   -8%
>   256/     8/  -61%/  -69%/  +16%/  +10%/  -10%
>   512/     1/  +15%/   -3%/  +19%/  +18%/  -11%
>   512/     2/  +19%/    0%/  +19%/  +13%/  -10%
>   512/     4/  +18%/   -2%/  +18%/  +15%/  -10%
>   512/     8/  +17%/   -1%/  +18%/  +15%/  -11%
>  1024/     1/  +25%/   +4%/  +27%/  +16%/  -21%
>  1024/     2/  +28%/   +8%/  +25%/  +15%/  -22%
>  1024/     4/  +25%/   +5%/  +25%/  +14%/  -21%
>  1024/     8/  +27%/   +7%/  +25%/  +16%/  -21%
>  2048/     1/  +32%/  +12%/  +31%/  +22%/  -38%
>  2048/     2/  +33%/  +12%/  +30%/  +23%/  -36%
>  2048/     4/  +31%/  +10%/  +31%/  +24%/  -37%
>  2048/     8/ +105%/  +75%/  +33%/  +23%/  -39%
> 16384/     1/    0%/  -14%/   +2%/    0%/  +19%
> 16384/     2/    0%/  -13%/  +19%/  -13%/  +17%
> 16384/     4/    0%/  -12%/   +3%/    0%/   +2%
> 16384/     8/    0%/  -11%/   -2%/   +1%/   +1%
> size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
>    64/     1/   -7%/  -23%/   +4%/   +6%/  -74%
>    64/     2/   -2%/  -12%/   +2%/   +2%/  -55%
>    64/     4/   +2%/   -5%/  +10%/   -2%/  -43%
>    64/     8/   -5%/   -5%/  +11%/  -34%/  -59%
>   256/     1/   -6%/  -16%/   +9%/  +11%/  -60%
>   256/     2/   +3%/   -4%/   +6%/   -3%/  -28%
>   256/     4/    0%/   -5%/   -9%/   -9%/  -10%
>   256/     8/   -3%/   -6%/  -12%/   -9%/  -40%
>   512/     1/   -4%/  -17%/  -10%/  +21%/  -34%
>   512/     2/    0%/   -9%/  -14%/   -3%/  -30%
>   512/     4/    0%/   -4%/  -18%/  -12%/   -4%
>   512/     8/   -1%/   -4%/   -1%/   -5%/   +4%
>  1024/     1/    0%/  -16%/  +12%/  +11%/  -10%
>  1024/     2/    0%/  -11%/    0%/   +5%/  -31%
>  1024/     4/    0%/   -4%/   -7%/   +1%/  -22%
>  1024/     8/   -5%/   -6%/  -17%/  -29%/  -79%
>  2048/     1/    0%/  -16%/   +1%/   +9%/  -10%
>  2048/     2/    0%/  -12%/   +7%/   +9%/  -26%
>  2048/     4/    0%/   -7%/   -4%/   +3%/  -64%
>  2048/     8/   -1%/   -5%/   -6%/   +4%/  -20%
> 16384/     1/    0%/  -12%/  +11%/   +7%/  -20%
> 16384/     2/    0%/   -7%/   +1%/   +5%/  -26%
> 16384/     4/    0%/   -5%/  +12%/  +22%/  -23%
> 16384/     8/    0%/   -1%/   -8%/   +5%/   -3%
> size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
>     1/     1/   +9%/  -29%/   +9%/   +9%/   +9%
>     1/    25/   +6%/  -18%/   +6%/   +6%/   -1%
>     1/    50/   +6%/  -19%/   +5%/   +5%/   -2%
>     1/   100/   +5%/  -19%/   +4%/   +4%/   -3%
>    64/     1/  +10%/  -28%/  +10%/  +10%/  +10%
>    64/    25/   +8%/  -18%/   +7%/   +7%/   -2%
>    64/    50/   +8%/  -17%/   +8%/   +8%/   -1%
>    64/   100/   +8%/  -17%/   +8%/   +8%/   -1%
>   256/     1/  +10%/  -28%/  +10%/  +10%/  +10%
>   256/    25/  +15%/  -13%/  +15%/  +15%/    0%
>   256/    50/  +16%/  -14%/  +18%/  +18%/   +2%
>   256/   100/  +15%/  -13%/  +12%/  +12%/   -2%
>
> Changes from V2:
> - poll also at the end of rx handling
> - factor out the polling logic and optimize the code a little bit
> - add two ioctls to get and set the busy poll timeout
> - test on ixgbe (which can give more stable and reproducable numbers)
>   instead of mlx4.
>
> Changes from V1:
> - Add a comment for vhost_has_work() to explain why it could be
>   lockless
> - Add param description for busyloop_timeout
> - Split out the busy polling logic into a new helper
> - Check and exit the loop when there's a pending signal
> - Disable preemption during busy looping to make sure lock_clock() was
>   correctly used.
>
> Jason Wang (3):
>   vhost: introduce vhost_has_work()
>   vhost: introduce vhost_vq_more_avail()
>   vhost_net: basic polling support
>
>  drivers/vhost/net.c        | 77 +++++++++++++++++++++++++++++++++++++++++++---
>  drivers/vhost/vhost.c      | 48 +++++++++++++++++++++++------
>  drivers/vhost/vhost.h      |  3 ++
>  include/uapi/linux/vhost.h | 11 +++++++
>  4 files changed, 125 insertions(+), 14 deletions(-)
>
