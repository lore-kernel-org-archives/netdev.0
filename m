From: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] bluetooth: 6lowpan: fix delay work init in
 add_peer_chan()
Date: Fri, 31 Mar 2017 12:37:07 +0300
Message-ID: <1490953027.4892.14.camel@linux.intel.com>
References: <20170329061054.4300-1-michael.scott@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Scott <michael.scott-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170329061054.4300-1-michael.scott-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On Tue, 2017-03-28 at 23:10 -0700, Michael Scott wrote:
> When adding 6lowpan devices very rapidly we sometimes see a crash:
> [23122.306615] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.9.0-43-
> arm64 #1 Debian 4.9.9.linaro.43-1
> [23122.315400] Hardware name: HiKey Development Board (DT)
> [23122.320623] task: ffff800075443080 task.stack: ffff800075484000
> [23122.326551] PC is at expire_timers+0x70/0x150
> [23122.330907] LR is at run_timer_softirq+0xa0/0x1a0
> [23122.335616] pc : [<ffff000008142dd8>] lr : [<ffff000008142f58>]
> pstate: 600001c5
> 
> This was due to add_peer_chan() unconditionally initializing the
> lowpan_btle_dev->notify_peers delayed work structure, even if the
> lowpan_btle_dev passed into add_peer_chan() had previously been
> initialized.
> 
> Normally, this would go unnoticed as the delayed work timer is set
> for
> 100 msec, however when calling add_peer_chan() faster than 100 msec
> it
> clears out a previously queued delay work causing the crash above.
> 
> To fix this, let add_peer_chan() know when a new lowpan_btle_dev is
> passed
> in so that it only performs the delay work initialization when
> needed.
> 
> Signed-off-by: Michael Scott <michael.scott-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  net/bluetooth/6lowpan.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index e27be3ca0a0c..c282482edc2c 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -754,7 +754,8 @@ static void set_ip_addr_bits(u8 addr_type, u8
> *addr)
>  }
>  
>  static struct l2cap_chan *add_peer_chan(struct l2cap_chan *chan,
> -					struct lowpan_btle_dev *dev)
> +					struct lowpan_btle_dev *dev,
> +					bool new_netdev)
>  {
>  	struct lowpan_peer *peer;
>  
> @@ -785,7 +786,8 @@ static struct l2cap_chan *add_peer_chan(struct
> l2cap_chan *chan,
>  	spin_unlock(&devices_lock);
>  
>  	/* Notifying peers about us needs to be done without locks
> held */
> -	INIT_DELAYED_WORK(&dev->notify_peers, do_notify_peers);
> +	if (new_netdev)
> +		INIT_DELAYED_WORK(&dev->notify_peers,
> do_notify_peers);
>  	schedule_delayed_work(&dev->notify_peers,
> msecs_to_jiffies(100));
>  
>  	return peer->chan;
> @@ -842,6 +844,7 @@ static int setup_netdev(struct l2cap_chan *chan,
> struct lowpan_btle_dev **dev)
>  static inline void chan_ready_cb(struct l2cap_chan *chan)
>  {
>  	struct lowpan_btle_dev *dev;
> +	bool new_netdev = false;
>  
>  	dev = lookup_dev(chan->conn);
>  
> @@ -852,12 +855,13 @@ static inline void chan_ready_cb(struct
> l2cap_chan *chan)
>  			l2cap_chan_del(chan, -ENOENT);
>  			return;
>  		}
> +		new_netdev = true;
>  	}
>  
>  	if (!try_module_get(THIS_MODULE))
>  		return;
>  
> -	add_peer_chan(chan, dev);
> +	add_peer_chan(chan, dev, new_netdev);
>  	ifup(dev->netdev);
>  }
>  

Good catch!

Acked-by: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Cheers,
Jukka
