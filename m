From: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/8] net: extend ethtool link mode bitmaps
 to 48 bits
Date: Thu, 8 Jan 2015 10:40:34 +0200
Message-ID: <54AE4282.20009@mellanox.com>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
 <54ABE991.3040107@mellanox.com>
 <CAG88wWYPDpwkWkL+Pj2VKrX5WVp=at8v0=gcFAVAA8nntv+-nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"Masatake YAMATO" <yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Xi Wang <xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>,
	Govindarajulu Varadarajan <_govind
To: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAG88wWYPDpwkWkL+Pj2VKrX5WVp=at8v0=gcFAVAA8nntv+-nw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 1/6/2015 7:36 PM, David Decotigny wrote:
> Interesting. It seems that the band-aid I was proposing is already
> obsolete. We could still use the remaining reserved 16 bits to encode
> 5 more bits per mask (that is: 53 bits / mask total). But if I
> understand you, it would allow us to survive only a few months longer,
> as opposed to a few weeks.
> 
> One short-term alternative solution I can imagine is the following:
> /* For example bitmap-based for variable length: */
> struct ethtool_link_mode {
>   __u32 cmd;
>   __u8 autoneg :1;
>   __u8 duplex :2;
>  __u16 supported_nbits;
>   __u16 advertising_nbits;
>   __u16 lp_advertising_nbits;
>   __u32 reserved[4];
>   __u8 masks[0];
> };
> /* Or simpler, statically limited to 64b / mask, but easier to migrate
> to for driver authors: */
I think the first options is better. A driver will have to do changes in
order to support >32 link modes, so better change it once now, without
having to change it again for >64 link modes.

> struct ethtool_link_mode {
>   __u32 cmd;
>   __u8 autoneg :1;
>   __u8 duplex :2;
>    __u64 supported;
>   __u64 advertising;
>   __u64 lp_advertising;
>   __u32 reserved[4];
> };
> #define ETHTOOL_GLINK_MODE 0x0000004a
> #define ETHTOOL_SLINK_MODE 0x0000004b
> struct ethtool_ops {
> ...
>    int (*get_link_mode)(struct net_device *, struct ethtool_link_mode *);
>    int (*set_link_mode)(struct net_device *, struct ethtool_link_mode *);
> };
> 
> The same thing required for EEE.
Yeh :(

> 
> I am not sure about moving the autoneg and duplex fields into the new
> struct. Especially the "duplex" field.
I think so too. ethtool user space will call ETHTOOL_[GS]SET and after
that ETHTOOL_[GS]LINK_MODE (if supported). No need to get the
duplex/autoneg fields again.

> 
> Then the idea would be to update the ethtool user-space tool to try
> get/set_link mode when reporting/changing the autoneg/advertising
> settings.
> 
> Both will require significant effort from the driver authors.
> Especially if the variable-length bitmap approach is preferred:
>  - most drivers currently use simple bitwise arithmetic in their code,
> and that goes far beyond get/set_settings, it is sometimes part of the
> core driver logic. They will have to migrate to the bitmap API if they
> want to use the larger bitmaps (note: no change needed if they are
> happy with <= 32b / mask)
As I said above, it will save as doing this work again in the future,
and more problematic, save another version to backport in the future. In
addition, not all drivers will have to do it, only if >32 link speeds is
needed - this work will be required.

>  - we would have to progressively deprecate the use of #define
> ADVERTISED_1000baseT_Full in favor of an enum of the bit indices.
Maybe we could use some macro juggling to define the legacy macro's
using enum for the first 32 bits, and fail the compilation if used on
>32. For example, calling this:
DEFINE_LINK_MODE(ADVERTISED_1000baseT_Full, 5)

Will add the following:
ADVERTISED_1000baseT_Full_SHIFT = 5
ADVERTISED_1000baseT_Full = (1<<5)

DEFINE_LINK_MODE(ADVERTISED_100000baseKR5_Full, 50) will add:
ADVERTISED_100000baseKR5_Full_SHIFT = 50
ADVERTISED_100000baseKR5_Full = #error new link speeds must be defined
using [gs]et_link_speed

This will break compilation if ADVERTISED_100000baseKR5_Full is used in
[gs]et_settings (I know the '#error' will not print something very
pretty - I used it only to explain what I meant)

> 
> Any feedback welcome. In the meantime, I am going to propose a v3 of
> current option with 53 bits / mask. I can also propose a prototype of
> the scheme described above, please let me know.
I think that it is better to do it once, and skip the 53 bits / mask
version.
I'll be happy to assist.

Amir
