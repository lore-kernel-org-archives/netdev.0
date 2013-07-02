From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: rate overflow fix
Date: Tue, 02 Jul 2013 08:32:21 -0700
Message-ID: <1372779141.4979.7.camel@edumazet-glaptop>
References: <51D2ADFA.1090208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	chenweilong@huawei.com, David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D2ADFA.1090208@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-07-02 at 18:39 +0800, Yang Yingliang wrote:
> Use bonding to aggregate two 82599 nics which have 4 ports and max rate is 40gbit.
> Then set rate to 35gbit, the rate is overflow.
> 
> tc qdisc add dev $bond root handle 1: \
> tbf latency 50ms burst 35mb rate 35gbit mtu 64k
> 
> tc qdisc show dev $bond
> qdisc tbf 1: root refcnt 2 rate 640262Kbit burst 35Mb lat 50.0ms
> 
> iperf -c host -t 30 -i 10
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec   764 MBytes   641 Mbits/sec
> [  3] 10.0-20.0 sec   730 MBytes   612 Mbits/sec
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  include/uapi/linux/pkt_sched.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> index 32aef0a..261042c 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -79,7 +79,7 @@ struct tc_ratespec {
>         unsigned short  overhead;
>         short           cell_align;
>         unsigned short  mpu;
> -       __u32           rate;
> +       __u64           rate;
>  };
> 
>  #define TC_RTAB_SIZE   1024

OK, you just broke all previous tc binaries.

I wonder why people keep posting such buggy patches, while we are slowly
doing all the right changes for this problem, in the kernel and
userland.

Guys, if it was that simple, we would have done it years ago.

In the mean time, I suggest you update your iproute2 package to include
the fix for this problem (commit a303853e844ce4
"get_rate: detect 32bit overflows")
