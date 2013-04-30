From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Apr 30 (netdev: mellanox/mlx4)
Date: Tue, 30 Apr 2013 13:39:05 -0700
Message-ID: <51802BE9.7020805@infradead.org>
References: <20130430165730.7779d7e5d8fdca911213cce7@canb.auug.org.au>  <51801449.7080600@infradead.org> <1367350578.11020.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40392 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933613Ab3D3Ujf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 16:39:35 -0400
In-Reply-To: <1367350578.11020.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/13 12:36, Eric Dumazet wrote:
> On Tue, 2013-04-30 at 11:58 -0700, Randy Dunlap wrote:
>> On 04/29/13 23:57, Stephen Rothwell wrote:
>>> Hi all,
>>>
>>> Please do not add any v3.11 destined work to your linux-next included
>>> branches until after v3.10-rc1 is released.
>>>
>>> Changes since 20130429:
>>>
>>
>> on i386:
>>
>> ERROR: "__udivdi3" [drivers/net/ethernet/mellanox/mlx4/mlx4_en.ko] undefined!
>>
>>
> 
> Could you try the following patch/fix ?

Yes, that fixes it.  Thanks.

Acked-by: Randy Dunlap <rdunlap@infradead.org>


> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> index 2f18121..fd64410 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> @@ -114,6 +114,7 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
>  void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>  {
>  	struct mlx4_dev *dev = mdev->dev;
> +	u64 ns;
>  
>  	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
>  	mdev->cycles.read = mlx4_en_read_clock;
> @@ -133,10 +134,9 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>  	/* Calculate period in seconds to call the overflow watchdog - to make
>  	 * sure counter is checked at least once every wrap around.
>  	 */
> -	mdev->overflow_period =
> -		(cyclecounter_cyc2ns(&mdev->cycles,
> -				    mdev->cycles.mask) / NSEC_PER_SEC / 2)
> -		* HZ;
> +	ns = cyclecounter_cyc2ns(&mdev->cycles, mdev->cycles.mask);
> +	do_div(ns, NSEC_PER_SEC / 2 / HZ);
> +	mdev->overflow_period = ns;
>  }
>  
>  void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
> 
> 
> --


-- 
~Randy
