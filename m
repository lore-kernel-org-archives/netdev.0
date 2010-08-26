From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] slip: Use net_device_stats from struct net_device
Date: Thu, 26 Aug 2010 10:39:32 +0200
Message-ID: <1282811972.2476.146.camel@edumazet-laptop>
References: <1282206313-10667-1-git-send-email-tklauser@distanz.ch>
	 <1282811286-19659-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:61550 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab0HZIjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 04:39:37 -0400
Received: by wwd20 with SMTP id 20so1344989wwd.1
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 01:39:35 -0700 (PDT)
In-Reply-To: <1282811286-19659-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 10:28 +0200, Tobias Klauser a =C3=A9c=
rit :
> Use net_device->stats for stats instead of private variable copies in
> struct slip.
>=20
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/slip.c |   47 ++++++++++++++++++++----------------------=
-----
>  drivers/net/slip.h |    9 ---------
>  2 files changed, 20 insertions(+), 36 deletions(-)
>=20
> diff --git a/drivers/net/slip.c b/drivers/net/slip.c
> index d5a36f5..9512da8 100644
> --- a/drivers/net/slip.c
> +++ b/drivers/net/slip.c
> @@ -271,7 +271,7 @@ static int sl_realloc_bufs(struct slip *sl, int m=
tu)
>  			memcpy(sl->xbuff, sl->xhead, sl->xleft);
>  		} else  {
>  			sl->xleft =3D 0;
> -			sl->tx_dropped++;
> +			dev->stats.tx_dropped++;
>  		}
>  	}
>  	sl->xhead =3D sl->xbuff;
> @@ -281,7 +281,7 @@ static int sl_realloc_bufs(struct slip *sl, int m=
tu)
>  			memcpy(sl->rbuff, rbuff, sl->rcount);
>  		} else  {
>  			sl->rcount =3D 0;
> -			sl->rx_over_errors++;
> +			dev->stats.rx_over_errors++;
>  			set_bit(SLF_ERROR, &sl->flags);
>  		}
>  	}
> @@ -319,6 +319,7 @@ static inline void sl_unlock(struct slip *sl)
>  /* Send one completely decapsulated IP datagram to the IP layer. */
>  static void sl_bump(struct slip *sl)
>  {
> +	struct net_device *dev =3D sl->dev;
>  	struct sk_buff *skb;
>  	int count;
> =20
> @@ -329,13 +330,13 @@ static void sl_bump(struct slip *sl)
>  		if (c & SL_TYPE_COMPRESSED_TCP) {
>  			/* ignore compressed packets when CSLIP is off */
>  			if (!(sl->mode & SL_MODE_CSLIP)) {
> -				printk(KERN_WARNING "%s: compressed packet ignored\n", sl->dev->=
name);
> +				printk(KERN_WARNING "%s: compressed packet ignored\n", dev->name=
);
>  				return;
>  			}
>  			/* make sure we've reserved enough space for uncompress
>  			   to use */
>  			if (count + 80 > sl->buffsize) {
> -				sl->rx_over_errors++;
> +				dev->stats.rx_over_errors++;
>  				return;
>  			}
>  			count =3D slhc_uncompress(sl->slcomp, sl->rbuff, count);
> @@ -346,7 +347,7 @@ static void sl_bump(struct slip *sl)
>  				/* turn on header compression */
>  				sl->mode |=3D SL_MODE_CSLIP;
>  				sl->mode &=3D ~SL_MODE_ADAPTIVE;
> -				printk(KERN_INFO "%s: header compression turned on\n", sl->dev->=
name);
> +				printk(KERN_INFO "%s: header compression turned on\n", dev->name=
);
>  			}
>  			sl->rbuff[0] &=3D 0x4f;
>  			if (slhc_remember(sl->slcomp, sl->rbuff, count) <=3D 0)
> @@ -355,20 +356,20 @@ static void sl_bump(struct slip *sl)
>  	}
>  #endif  /* SL_INCLUDE_CSLIP */
> =20
> -	sl->rx_bytes +=3D count;
> +	dev->stats.rx_bytes +=3D count;
> =20
>  	skb =3D dev_alloc_skb(count);
>  	if (skb =3D=3D NULL) {
> -		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n", sl->=
dev->name);
> -		sl->rx_dropped++;
> +		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev-=
>name);
> +		dev->stats.rx_dropped++;
>  		return;
>  	}
> -	skb->dev =3D sl->dev;
> +	skb->dev =3D dev;
>  	memcpy(skb_put(skb, count), sl->rbuff, count);
>  	skb_reset_mac_header(skb);
>  	skb->protocol =3D htons(ETH_P_IP);
>  	netif_rx(skb);
> -	sl->rx_packets++;
> +	dev->stats.rx_packets++;
>  }
> =20
>  /* Encapsulate one IP datagram and stuff into a TTY queue. */
> @@ -379,7 +380,7 @@ static void sl_encaps(struct slip *sl, unsigned c=
har *icp, int len)
> =20
>  	if (len > sl->mtu) {		/* Sigh, shouldn't occur BUT ... */
>  		printk(KERN_WARNING "%s: truncating oversized transmit packet!\n",=
 sl->dev->name);
> -		sl->tx_dropped++;
> +		sl->dev->stats.tx_dropped++;
>  		sl_unlock(sl);
>  		return;
>  	}
> @@ -433,7 +434,7 @@ static void slip_write_wakeup(struct tty_struct *=
tty)
>  	if (sl->xleft <=3D 0)  {
>  		/* Now serial buffer is almost free & we can start
>  		 * transmission of another packet */
> -		sl->tx_packets++;
> +		sl->dev->stats.tx_packets++;
>  		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
>  		sl_unlock(sl);
>  		return;
> @@ -496,7 +497,7 @@ sl_xmit(struct sk_buff *skb, struct net_device *d=
ev)
>  	}
> =20
>  	sl_lock(sl);
> -	sl->tx_bytes +=3D skb->len;
> +	dev->stats.tx_bytes +=3D skb->len;
>  	sl_encaps(sl, skb->data, skb->len);
>  	spin_unlock(&sl->lock);
> =20
> @@ -562,12 +563,12 @@ static struct net_device_stats *
>  sl_get_stats(struct net_device *dev)
>  {
>  	struct net_device_stats *stats =3D &dev->stats;
> -	struct slip *sl =3D netdev_priv(dev);
> -	unsigned long c_rx_dropped =3D 0;
>  #ifdef SL_INCLUDE_CSLIP
> +	unsigned long c_rx_dropped =3D 0;
>  	unsigned long c_rx_fifo_errors =3D 0;
>  	unsigned long c_tx_fifo_errors =3D 0;
>  	unsigned long c_collisions =3D 0;
> +	struct slip *sl =3D netdev_priv(dev);
>  	struct slcompress *comp =3D sl->slcomp;
> =20
>  	if (comp) {
> @@ -579,17 +580,9 @@ sl_get_stats(struct net_device *dev)
>  	stats->rx_fifo_errors =3D sl->rx_compressed + c_rx_fifo_errors;
>  	stats->tx_fifo_errors =3D sl->tx_compressed + c_tx_fifo_errors;
>  	stats->collisions     =3D sl->tx_misses + c_collisions;
> +	stats->rx_dropped    +=3D c_rx_dropped;

Sorry this bit is wrong.

You cannot do "stats->somefield +=3D somevalue", since its cumulative f=
or
each call to "cat /proc/net/dev"


>  #endif
> =20
> -	stats->rx_packets     =3D sl->rx_packets;
> -	stats->tx_packets     =3D sl->tx_packets;
> -	stats->rx_bytes	      =3D sl->rx_bytes;
> -	stats->tx_bytes	      =3D sl->tx_bytes;
> -	stats->rx_dropped     =3D sl->rx_dropped + c_rx_dropped;
> -	stats->tx_dropped     =3D sl->tx_dropped;
> -	stats->tx_errors      =3D sl->tx_errors;
> -	stats->rx_errors      =3D sl->rx_errors;
> -	stats->rx_over_errors =3D sl->rx_over_errors;
>  	return stats;
>  }
> =20
> @@ -681,7 +674,7 @@ static void slip_receive_buf(struct tty_struct *t=
ty, const unsigned char *cp,
>  	while (count--) {
>  		if (fp && *fp++) {
>  			if (!test_and_set_bit(SLF_ERROR, &sl->flags))
> -				sl->rx_errors++;
> +				sl->dev->stats.rx_errors++;
>  			cp++;
>  			continue;
>  		}
> @@ -981,7 +974,7 @@ static void slip_unesc(struct slip *sl, unsigned =
char s)
>  			sl->rbuff[sl->rcount++] =3D s;
>  			return;
>  		}
> -		sl->rx_over_errors++;
> +		sl->dev->stats.rx_over_errors++;
>  		set_bit(SLF_ERROR, &sl->flags);
>  	}
>  }
> @@ -1057,7 +1050,7 @@ static void slip_unesc6(struct slip *sl, unsign=
ed char s)
>  					sl->rbuff[sl->rcount++] =3D c;
>  					return;
>  				}
> -				sl->rx_over_errors++;
> +				sl->dev->stats.rx_over_errors++;
>  				set_bit(SLF_ERROR, &sl->flags);
>  			}
>  		}
> diff --git a/drivers/net/slip.h b/drivers/net/slip.h
> index 9ea5c11..914e958 100644
> --- a/drivers/net/slip.h
> +++ b/drivers/net/slip.h
> @@ -67,15 +67,6 @@ struct slip {
>    int                   xleft;          /* bytes left in XMIT queue =
    */
> =20
>    /* SLIP interface statistics. */
> -  unsigned long		rx_packets;	/* inbound frames counter	*/
> -  unsigned long         tx_packets;     /* outbound frames counter  =
    */
> -  unsigned long		rx_bytes;	/* inbound byte counte		*/
> -  unsigned long         tx_bytes;       /* outbound byte counter	*/
> -  unsigned long         rx_errors;      /* Parity, etc. errors      =
    */
> -  unsigned long         tx_errors;      /* Planned stuff            =
    */
> -  unsigned long         rx_dropped;     /* No memory for skb        =
    */
> -  unsigned long         tx_dropped;     /* When MTU change          =
    */
> -  unsigned long         rx_over_errors; /* Frame bigger than SLIP bu=
f.  */
>  #ifdef SL_INCLUDE_CSLIP
>    unsigned long		tx_compressed;
>    unsigned long		rx_compressed;


