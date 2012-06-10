From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Sun, 10 Jun 2012 15:38:17 +0200
Message-ID: <1339335497.6001.478.camel@edumazet-glaptop>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	 <20120607205356.GA2491@electric-eye.fr.zoreil.com>
	 <1339104606.6001.4.camel@edumazet-glaptop>
	 <20120607223752.GA4475@electric-eye.fr.zoreil.com>
	 <1339134438.6001.13.camel@edumazet-glaptop>
	 <20120608154106.GD5024@kvack.org>
	 <67d8beaf421874815145fdefc69b3366@visp.net.lb>
	 <1339171495.6001.118.camel@edumazet-glaptop>
	 <CAA7+ByWEZDqzZhzH0FZoapqfUrujUrxyjwp6qb1SSfWBTZ=4AA@mail.gmail.com>
	 <1339335061.6001.466.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Denys Fedoryshchenko <denys@visp.net.lb>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339335061.6001.466.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-06-10 at 15:31 +0200, Eric Dumazet wrote:

>  include/linux/netdevice.h |   40 ++++++++++++++++++++++++++++--------
>  net/l2tp/l2tp_eth.c       |   29 +++++++++++++-------------
>  2 files changed, 47 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d94cb14..1dee75a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -171,14 +171,38 @@ static inline bool dev_xmit_complete(int rc)
>   */
>  
>  struct net_device_stats {
> -	unsigned long	rx_packets;
> -	unsigned long	tx_packets;
> -	unsigned long	rx_bytes;
> -	unsigned long	tx_bytes;
> -	unsigned long	rx_errors;
> -	unsigned long	tx_errors;
> -	unsigned long	rx_dropped;
> -	unsigned long	tx_dropped;
> +	union {
> +		unsigned long	rx_packets;
> +		atomic_long_t   rx_packets_atomic;
> +	};
> +	union {
> +		unsigned long	tx_packets;
> +		atomic_long_t	tx_packets_atomic;
> +	};
> +	union {
> +		unsigned long	rx_bytes;
> +		atomic_long_t	rx_bytes_atomic;
> +	};
> +	union {
> +		unsigned long	tx_bytes;
> +		atomic_long_t	tx_bytes_atomic;
> +	};
> +	union {
> +		unsigned long	rx_errors;
> +		atomic_long_t	rx_errors_atomic;
> +	};
> +	union {
> +		unsigned long	tx_errors;
> +		atomic_long_t	tx_errors_atomic;
> +	};
> +	union {
> +		unsigned long	rx_dropped;
> +		atomic_long_t	rx_dropped_atomic;
> +	};
> +	union {
> +		unsigned long	tx_dropped;
> +		atomic_long_t	tx_dropped_atomic;
> +	};

Other choice would be to have a new structure

struct net_device_atomic_stats {
	atomic_long_t rx_packets;
	atomic_long_t tx_packets;
	atomic_long_t rx_bytes;
	atomic_long_t tx_bytes;
	atomic_long_t rx_errors;
	atomic_long_t tx_errors;
	atomic_long_t rx_dropped;
	atomic_long_t tx_dropped;
...
};

and to union it in :

struct net_device {
	...
	union {
		struct net_device_stats	       stats;
		struct net_device_atomic_stats atom_stats;
	};
	...
};
