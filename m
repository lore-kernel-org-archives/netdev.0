From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH 2/2] mlx5: fix 64-bit division on times
Date: Fri, 17 Jun 2016 18:09:00 +0300
Message-ID: <CALzJLG9S_Q37ErepBm-7rm7vVdEZH-1gXbay+zpveHSYhpPi5A@mail.gmail.com>
References: <20160615152816.2800830-1-arnd@arndb.de> <20160615152816.2800830-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Achiad Shochat <achiad@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615152816.2800830-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 6:27 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> The mlx5 driver fails to build on 32-bit architectures after some
> references to 64-bit divisions got added:
>
> drivers/net/built-in.o: In function `mlx5e_rx_am':
> :(.text+0xf88ac): undefined reference to `__aeabi_ldivmod'
>
> The driver even performs three division here, and it uses the
> obsolete 'struct timespec' that we want to get rid of.
>
> Using ktime_t and ktime_us_delta() replaces one of the divisions
> and is mildly more efficient, aside from working across 'settimeofday'
> calls and being the right type for the y2038 conversion.
>
> Using a u32 instead of s64 to store the number of microseconds
> limits the maximum time to about 71 minutes, but if we exceed that
> time, we probably don't care about the result any more for the
> purpose of rx coalescing.
>
> For the number of packets, we are taking the difference between
> two 'unsigned int', so the result won't ever be greater than that
> either.
>
> After those changes, the other two divisions are done as 32-bit
> arithmetic operations, which are much faster.

Nice catch Arnd,  we originally fixed this with div_u64, but your
solution looks wiser.
does ktime_t gives time in a resolution same as timespec ?

As discussed before this patch can't be applied on net-next as
the original patch which it meant to fix is yet to be submitted,
I will CC you once we submit the fixed patch.
