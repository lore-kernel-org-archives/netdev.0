From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH v2 05/11] mtd: cfi: reduce stack size with KASAN
Date: Fri, 4 Aug 2017 09:42:54 +0200
Message-ID: <20170804094254.369140c0@bbrezillon>
References: <20170614211556.2062728-1-arnd@arndb.de>
        <20170614211556.2062728-6-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        linux-mtd@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-6-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 23:15:40 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> When CONFIG_KASAN is used, we consume a lot of extra stack space:
> 
> drivers/mtd/chips/cfi_cmdset_0020.c: In function 'do_write_buffer':
> drivers/mtd/chips/cfi_cmdset_0020.c:603:1: error: the frame size of 2184 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> drivers/mtd/chips/cfi_cmdset_0020.c: In function 'cfi_staa_erase_varsize':
> drivers/mtd/chips/cfi_cmdset_0020.c:972:1: error: the frame size of 1936 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> drivers/mtd/chips/cfi_cmdset_0001.c: In function 'do_write_buffer':
> drivers/mtd/chips/cfi_cmdset_0001.c:1841:1: error: the frame size of 1776 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> 
> This marks some functions as noinline_if_stackbloat to keep reduce the
> overall stack size.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/mtd/chips/cfi_cmdset_0020.c | 8 ++++----
>  include/linux/mtd/map.h             | 8 ++++----
>  2 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/mtd/chips/cfi_cmdset_0020.c b/drivers/mtd/chips/cfi_cmdset_0020.c
> index 7d342965f392..5eee5e883f55 100644
> --- a/drivers/mtd/chips/cfi_cmdset_0020.c
> +++ b/drivers/mtd/chips/cfi_cmdset_0020.c
> @@ -244,7 +244,7 @@ static struct mtd_info *cfi_staa_setup(struct map_info *map)
>  }
>  
>  
> -static inline int do_read_onechip(struct map_info *map, struct flchip *chip, loff_t adr, size_t len, u_char *buf)
> +static noinline_if_stackbloat int do_read_onechip(struct map_info *map, struct flchip *chip, loff_t adr, size_t len, u_char *buf)

Why do we even need to mark those functions inline in the first place?
Isn't the compiler smart enough to decide when it should inline things?

>  {
>  	map_word status, status_OK;
>  	unsigned long timeo;
> @@ -728,7 +728,7 @@ cfi_staa_writev(struct mtd_info *mtd, const struct kvec *vecs,
>  }
>  
>  
> -static inline int do_erase_oneblock(struct map_info *map, struct flchip *chip, unsigned long adr)
> +static noinline_if_stackbloat int do_erase_oneblock(struct map_info *map, struct flchip *chip, unsigned long adr)
>  {
>  	struct cfi_private *cfi = map->fldrv_priv;
>  	map_word status, status_OK;
> @@ -1029,7 +1029,7 @@ static void cfi_staa_sync (struct mtd_info *mtd)
>  	}
>  }
>  
> -static inline int do_lock_oneblock(struct map_info *map, struct flchip *chip, unsigned long adr)
> +static noinline_if_stackbloat int do_lock_oneblock(struct map_info *map, struct flchip *chip, unsigned long adr)
>  {
>  	struct cfi_private *cfi = map->fldrv_priv;
>  	map_word status, status_OK;
> @@ -1175,7 +1175,7 @@ static int cfi_staa_lock(struct mtd_info *mtd, loff_t ofs, uint64_t len)
>  	}
>  	return 0;
>  }
> -static inline int do_unlock_oneblock(struct map_info *map, struct flchip *chip, unsigned long adr)
> +static noinline_if_stackbloat int do_unlock_oneblock(struct map_info *map, struct flchip *chip, unsigned long adr)
>  {
>  	struct cfi_private *cfi = map->fldrv_priv;
>  	map_word status, status_OK;
> diff --git a/include/linux/mtd/map.h b/include/linux/mtd/map.h
> index 3aa56e3104bb..29db74314db8 100644
> --- a/include/linux/mtd/map.h
> +++ b/include/linux/mtd/map.h
> @@ -316,7 +316,7 @@ static inline map_word map_word_or(struct map_info *map, map_word val1, map_word
>  	return r;
>  }
>  
> -static inline int map_word_andequal(struct map_info *map, map_word val1, map_word val2, map_word val3)
> +static noinline_if_stackbloat int map_word_andequal(struct map_info *map, map_word val1, map_word val2, map_word val3)

It's indeed needed for those defined in a header.

>  {
>  	int i;
>  
> @@ -328,7 +328,7 @@ static inline int map_word_andequal(struct map_info *map, map_word val1, map_wor
>  	return 1;
>  }
>  
> -static inline int map_word_bitsset(struct map_info *map, map_word val1, map_word val2)
> +static noinline_if_stackbloat int map_word_bitsset(struct map_info *map, map_word val1, map_word val2)
>  {
>  	int i;
>  
> @@ -362,7 +362,7 @@ static inline map_word map_word_load(struct map_info *map, const void *ptr)
>  	return r;
>  }
>  
> -static inline map_word map_word_load_partial(struct map_info *map, map_word orig, const unsigned char *buf, int start, int len)
> +static noinline_if_stackbloat map_word map_word_load_partial(struct map_info *map, map_word orig, const unsigned char *buf, int start, int len)
>  {
>  	int i;
>  
> @@ -392,7 +392,7 @@ static inline map_word map_word_load_partial(struct map_info *map, map_word orig
>  #define MAP_FF_LIMIT 8
>  #endif
>  
> -static inline map_word map_word_ff(struct map_info *map)
> +static noinline_if_stackbloat map_word map_word_ff(struct map_info *map)
>  {
>  	map_word r;
>  	int i;
