From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next v2 0/8] net: extend ethtool link mode bitmaps to
 48 bits
Date: Sun, 11 Jan 2015 14:49:45 -0800
Message-ID: <CAG88wWYryVb1-fQM5vmqY+-dQ3FhBpbCUrqobzH1A7gTfqW4Bg@mail.gmail.com>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
 <54ABE991.3040107@mellanox.com> <CAG88wWYPDpwkWkL+Pj2VKrX5WVp=at8v0=gcFAVAA8nntv+-nw@mail.gmail.com>
 <54AE4282.20009@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Govindarajulu Varadarajan <_govind@g
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54AE4282.20009@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the input. Please ignore this patch series: I'm preparing a
new version: new commands, bitmap-based that should allow us to live
happily ever after, should take your feedback into account. Will send
an RFC patch series in the next hours/days.

On Thu, Jan 8, 2015 at 12:40 AM, Amir Vadai <amirv@mellanox.com> wrote:
> On 1/6/2015 7:36 PM, David Decotigny wrote:
>> Interesting. It seems that the band-aid I was proposing is already
>> obsolete. We could still use the remaining reserved 16 bits to encode
>> 5 more bits per mask (that is: 53 bits / mask total). But if I
>> understand you, it would allow us to survive only a few months longer,
>> as opposed to a few weeks.
>>
>> One short-term alternative solution I can imagine is the following:
>> /* For example bitmap-based for variable length: */
>> struct ethtool_link_mode {
>>   __u32 cmd;
>>   __u8 autoneg :1;
>>   __u8 duplex :2;
>>  __u16 supported_nbits;
>>   __u16 advertising_nbits;
>>   __u16 lp_advertising_nbits;
>>   __u32 reserved[4];
>>   __u8 masks[0];
>> };
>> /* Or simpler, statically limited to 64b / mask, but easier to migrate
>> to for driver authors: */
> I think the first options is better. A driver will have to do changes in
> order to support >32 link modes, so better change it once now, without
> having to change it again for >64 link modes.
>
>> struct ethtool_link_mode {
>>   __u32 cmd;
>>   __u8 autoneg :1;
>>   __u8 duplex :2;
>>    __u64 supported;
>>   __u64 advertising;
>>   __u64 lp_advertising;
>>   __u32 reserved[4];
>> };
>> #define ETHTOOL_GLINK_MODE 0x0000004a
>> #define ETHTOOL_SLINK_MODE 0x0000004b
>> struct ethtool_ops {
>> ...
>>    int (*get_link_mode)(struct net_device *, struct ethtool_link_mode *);
>>    int (*set_link_mode)(struct net_device *, struct ethtool_link_mode *);
>> };
>>
>> The same thing required for EEE.
> Yeh :(
>
>>
>> I am not sure about moving the autoneg and duplex fields into the new
>> struct. Especially the "duplex" field.
> I think so too. ethtool user space will call ETHTOOL_[GS]SET and after
> that ETHTOOL_[GS]LINK_MODE (if supported). No need to get the
> duplex/autoneg fields again.
>
>>
>> Then the idea would be to update the ethtool user-space tool to try
>> get/set_link mode when reporting/changing the autoneg/advertising
>> settings.
>>
>> Both will require significant effort from the driver authors.
>> Especially if the variable-length bitmap approach is preferred:
>>  - most drivers currently use simple bitwise arithmetic in their code,
>> and that goes far beyond get/set_settings, it is sometimes part of the
>> core driver logic. They will have to migrate to the bitmap API if they
>> want to use the larger bitmaps (note: no change needed if they are
>> happy with <= 32b / mask)
> As I said above, it will save as doing this work again in the future,
> and more problematic, save another version to backport in the future. In
> addition, not all drivers will have to do it, only if >32 link speeds is
> needed - this work will be required.
>
>>  - we would have to progressively deprecate the use of #define
>> ADVERTISED_1000baseT_Full in favor of an enum of the bit indices.
> Maybe we could use some macro juggling to define the legacy macro's
> using enum for the first 32 bits, and fail the compilation if used on
>>32. For example, calling this:
> DEFINE_LINK_MODE(ADVERTISED_1000baseT_Full, 5)
>
> Will add the following:
> ADVERTISED_1000baseT_Full_SHIFT = 5
> ADVERTISED_1000baseT_Full = (1<<5)
>
> DEFINE_LINK_MODE(ADVERTISED_100000baseKR5_Full, 50) will add:
> ADVERTISED_100000baseKR5_Full_SHIFT = 50
> ADVERTISED_100000baseKR5_Full = #error new link speeds must be defined
> using [gs]et_link_speed
>
> This will break compilation if ADVERTISED_100000baseKR5_Full is used in
> [gs]et_settings (I know the '#error' will not print something very
> pretty - I used it only to explain what I meant)
>
>>
>> Any feedback welcome. In the meantime, I am going to propose a v3 of
>> current option with 53 bits / mask. I can also propose a prototype of
>> the scheme described above, please let me know.
> I think that it is better to do it once, and skip the 53 bits / mask
> version.
> I'll be happy to assist.
>
> Amir
