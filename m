From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next rfc V2 0/2] basic busy polling support for
 vhost_net
Date: Tue, 3 Nov 2015 15:46:09 +0800
Message-ID: <56386641.30402@redhat.com>
References: <1446108326-37765-1-git-send-email-jasowang@redhat.com>
 <56335B66.9050705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <56335B66.9050705@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/30/2015 07:58 PM, Jason Wang wrote:
>
> On 10/29/2015 04:45 PM, Jason Wang wrote:
>> Hi all:
>>
>> This series tries to add basic busy polling for vhost net. The idea is
>> simple: at the end of tx processing, busy polling for new tx added
>> descriptor and rx receive socket for a while. The maximum number of
>> time (in us) could be spent on busy polling was specified through
>> module parameter.
>>
>> Test were done through:
>>
>> - 50 us as busy loop timeout
>> - Netperf 2.6
>> - Two machines with back to back connected mlx4
>> - Guest with 8 vcpus and 1 queue
>>
>> Result shows very huge improvement on both tx (at most 158%) and rr
>> (at most 53%) while rx is as much as in the past. Most cases the cpu
>> utilization is also improved:
>>
> Just notice there's something wrong in the setup. So the numbers are
> incorrect here. Will re-run and post correct number here.
>
> Sorry.

Here's the updated testing result:

1) 1 vcpu 1 queue:

TCP_RR
size/session/+thu%/+normalize%
    1/     1/    0%/  -25%
    1/    50/  +12%/    0%
    1/   100/  +12%/   +1%
    1/   200/   +9%/   -1%
   64/     1/   +3%/  -21%
   64/    50/   +8%/    0%
   64/   100/   +7%/    0%
   64/   200/   +9%/    0%
  256/     1/   +1%/  -25%
  256/    50/   +7%/   -2%
  256/   100/   +6%/   -2%
  256/   200/   +4%/   -2%
  512/     1/   +2%/  -19%
  512/    50/   +5%/   -2%
  512/   100/   +3%/   -3%
  512/   200/   +6%/   -2%
 1024/     1/   +2%/  -20%
 1024/    50/   +3%/   -3%
 1024/   100/   +5%/   -3%
 1024/   200/   +4%/   -2%
Guest RX
size/session/+thu%/+normalize%
   64/     1/   -4%/   -5%
   64/     4/   -3%/  -10%
   64/     8/   -3%/   -5%
  512/     1/  +15%/   +1%
  512/     4/   -5%/   -5%
  512/     8/   -2%/   -4%
 1024/     1/   -5%/  -16%
 1024/     4/   -2%/   -5%
 1024/     8/   -6%/   -6%
 2048/     1/  +10%/   +5%
 2048/     4/   -8%/   -4%
 2048/     8/   -1%/   -4%
 4096/     1/   -9%/  -11%
 4096/     4/   +1%/   -1%
 4096/     8/   +1%/    0%
16384/     1/  +20%/  +11%
16384/     4/    0%/   -3%
16384/     8/   +1%/    0%
65535/     1/  +36%/  +13%
65535/     4/  -10%/   -9%
65535/     8/   -3%/   -2%
Guest TX
size/session/+thu%/+normalize%
   64/     1/   -7%/  -16%
   64/     4/  -14%/  -23%
   64/     8/   -9%/  -20%
  512/     1/  -62%/  -56%
  512/     4/  -62%/  -56%
  512/     8/  -61%/  -53%
 1024/     1/  -66%/  -61%
 1024/     4/  -77%/  -73%
 1024/     8/  -73%/  -67%
 2048/     1/  -74%/  -75%
 2048/     4/  -77%/  -74%
 2048/     8/  -72%/  -68%
 4096/     1/  -65%/  -68%
 4096/     4/  -66%/  -63%
 4096/     8/  -62%/  -57%
16384/     1/  -25%/  -28%
16384/     4/  -28%/  -17%
16384/     8/  -24%/  -10%
65535/     1/  -17%/  -14%
65535/     4/  -22%/   -5%
65535/     8/  -25%/   -9%

- obvious improvement on TCP_RR (at most 12%)
- improvement on guest RX
- huge decreasing on Guest TX (at most -75%), this is probably because
virtio-net driver suffers from buffer bloat by orphaning skb before
transmission. The faster vhost it is, the smaller packet it could
produced. To reduce the impact on this, turning off gso in guest can
result the following result:

size/session/+thu%/+normalize%
   64/     1/   +3%/  -11%
   64/     4/   +4%/  -10%
   64/     8/   +4%/  -10%
  512/     1/   +2%/   +5%
  512/     4/    0%/   -1%
  512/     8/    0%/    0%
 1024/     1/  +11%/    0%
 1024/     4/    0%/   -1%
 1024/     8/   +3%/   +1%
 2048/     1/   +4%/   -1%
 2048/     4/   +8%/   +3%
 2048/     8/    0%/   -1%
 4096/     1/   +4%/   -1%
 4096/     4/   +1%/    0%
 4096/     8/   +2%/    0%
16384/     1/   +2%/   -2%
16384/     4/   +3%/   +1%
16384/     8/    0%/   -1%
65535/     1/   +9%/   +7%
65535/     4/    0%/   -3%
65535/     8/   -1%/   -1%

2) 8 vcpus 1 queue:

TCP_RR
size/session/+thu%/+normalize%
    1/     1/   +5%/  -14%
    1/    50/   +2%/   +1%
    1/   100/    0%/   -1%
    1/   200/    0%/    0%
   64/     1/    0%/  -25%
   64/    50/   +5%/   +5%
   64/   100/    0%/    0%
   64/   200/    0%/   -1%
  256/     1/    0%/  -30%
  256/    50/    0%/    0%
  256/   100/   -2%/   -2%
  256/   200/    0%/    0%
  512/     1/   +1%/  -23%
  512/    50/   +1%/   +1%
  512/   100/   +1%/    0%
  512/   200/   +1%/   +1%
 1024/     1/   +1%/  -23%
 1024/    50/   +5%/   +5%
 1024/   100/    0%/   -1%
 1024/   200/    0%/    0%
Guest RX
size/session/+thu%/+normalize%
   64/     1/   +1%/   +1%
   64/     4/   -2%/   +1%
   64/     8/   +6%/  +19%
  512/     1/   +5%/   -7%
  512/     4/   -4%/   -4%
  512/     8/    0%/    0%
 1024/     1/   +1%/   +2%
 1024/     4/   -2%/   -2%
 1024/     8/   -1%/   +7%
 2048/     1/   +8%/   -2%
 2048/     4/    0%/   +5%
 2048/     8/   -1%/  +13%
 4096/     1/   -1%/   +2%
 4096/     4/    0%/   +6%
 4096/     8/   -2%/  +15%
16384/     1/   -1%/    0%
16384/     4/   -2%/   -1%
16384/     8/   -2%/   +2%
65535/     1/   -2%/    0%
65535/     4/   -3%/   -3%
65535/     8/   -2%/   +2%
Guest TX
size/session/+thu%/+normalize%
   64/     1/   +6%/   +3%
   64/     4/  +11%/   +8%
   64/     8/    0%/    0%
  512/     1/  +19%/  +18%
  512/     4/   -4%/   +1%
  512/     8/   -1%/   -1%
 1024/     1/    0%/   +8%
 1024/     4/   -1%/   -1%
 1024/     8/    0%/   +1%
 2048/     1/   +1%/    0%
 2048/     4/   -1%/   -2%
 2048/     8/    0%/    0%
 4096/     1/  +12%/  +14%
 4096/     4/    0%/   -1%
 4096/     8/   -2%/   -1%
16384/     1/   +9%/   +6%
16384/     4/   +3%/   -1%
16384/     8/   +2%/   -1%
65535/     1/   +1%/   -2%
65535/     4/    0%/   -4%
65535/     8/    0%/   -2%

- latency get improved a little bit
- small improvement on single session rx
- no other obvious changes
- this may because 8 vcpu could give enough stress on a single vhost
thread. Then the busy polling was not trigged enough (unless on light
load case e.g 1 session TCP_RR).

3) 8 vcpus 8 queues

8 vcpu 8 queue
TCP_RR
size/session/+thu%/+normalize%
    1/     1/   +6%/  -16%
    1/    50/  +14%/   +1%
    1/   100/  +17%/   +3%
    1/   200/  +16%/   +2%
   64/     1/   +2%/  -19%
   64/    50/  +10%/    0%
   64/   100/  +17%/   +5%
   64/   200/  +15%/   +3%
  256/     1/    0%/  -19%
  256/    50/   +5%/   -3%
  256/   100/   +4%/   -3%
  256/   200/   +2%/   -4%
  512/     1/   +4%/  -19%
  512/    50/   +7%/   -2%
  512/   100/   +4%/   -4%
  512/   200/   +3%/   -4%
 1024/     1/   +9%/  -19%
 1024/    50/   +6%/   -2%
 1024/   100/   +5%/   -3%
 1024/   200/   +5%/   -3%
Guest RX
size/session/+thu%/+normalize%
   64/     1/  +18%/  +13%
   64/     4/    0%/   -1%
   64/     8/   -4%/  -11%
  512/     1/   +3%/   -6%
  512/     4/   +1%/  -11%
  512/     8/   -1%/   -7%
 1024/     1/    0%/   -9%
 1024/     4/   +9%/  -16%
 1024/     8/   -1%/  -11%
 2048/     1/    0%/   -2%
 2048/     4/    0%/  -16%
 2048/     8/   -1%/   -2%
 4096/     1/   +3%/    0%
 4096/     4/   -1%/  -12%
 4096/     8/    0%/   -5%
16384/     1/   -2%/   -6%
16384/     4/    0%/   -6%
16384/     8/    0%/   -6%
65535/     1/    0%/    0%
65535/     4/    0%/   -9%
65535/     8/    0%/   +1%
Guest TX
size/session/+thu%/+normalize%
   64/     1/   +7%/   +3%
   64/     4/   +6%/    0%
   64/     8/  +10%/   +5%
  512/     1/    0%/  +14%
  512/     4/   +9%/   -1%
  512/     8/  +14%/   +4%
 1024/     1/  +44%/  +37%
 1024/     4/   +6%/   +2%
 1024/     8/  +19%/  +12%
 2048/     1/  -14%/  -16%
 2048/     4/  +11%/   +8%
 2048/     8/  +26%/  +28%
 4096/     1/  +21%/  +19%
 4096/     4/   +2%/  +10%
 4096/     8/  +14%/   +7%
16384/     1/  +12%/   +4%
16384/     4/   +7%/   +2%
16384/     8/   +2%/   +9%
65535/     1/   -3%/   -5%
65535/     4/   +9%/   +5%
65535/     8/    0%/   -8%

- TCP_RR get obviously improved (at most 17%)
- obvious improvement on Guest TX (at most 44%)
