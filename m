From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next v5 05/19] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Wed, 16 Dec 2015 16:26:46 -0800
Message-ID: <CAG88wWa85iPJMYQtE4o_Cx3+-A-m_+wqxf2PWYTcpOvB=8_d8Q@mail.gmail.com>
References: <1450127046-4573-1-git-send-email-ddecotig@gmail.com>
 <1450127046-4573-6-git-send-email-ddecotig@gmail.com> <20151216.113814.2025166082777387327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Yuval Mintz <Yuval.Mint
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151216.113814.2025166082777387327.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks David: you are right, we should copy back sizeof(struct
ethtool_settings) in that case and not sizeof(usettings). Sorry about
that, will fix for v6.

a few questions before sending update:
 - is this handshake reasonable? or should we have an ethtool cmd
dedicated to this kind of handshake, or should we hardcode bitmap
length once and for all (ie. 128 instead of 32 today)?
 - is it ok to have the u32[] api part of bitmap.h? I was assuming it
could be used for other ioctl/syscalls outside ethtool... but maybe
this is being too pretentious and we could keep this internal to
net/core?
 - struct inheritance is used to have the link mode bitmaps
piggybacked at end the public struct ethtool_settings. hence this
"parent" field. I'm not super proud of this, but I find relying on the
compiler more comfortable. could revise my position with a
constructor+accessors macros if you think it's preferred.


On Wed, Dec 16, 2015 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
> From: David Decotigny <ddecotig@gmail.com>
> Date: Mon, 14 Dec 2015 13:03:52 -0800
>
>> +static int ethtool_get_ksettings(struct net_device *dev, void __user *useraddr)
>> +{
>  ...
>> +     if (__ETHTOOL_LINK_MODE_MASK_NU32
>> +         != ksettings.parent.link_mode_masks_nwords) {
>> +             /* wrong link mode nbits requested */
>> +             memset(&ksettings, 0, sizeof(ksettings));
>> +             /* keep cmd field reset to 0 */
>> +             /* send back number of words required as negative val */
>> +             compiletime_assert(__ETHTOOL_LINK_MODE_MASK_NU32 <= S8_MAX,
>> +                                "need too many bits for link modes!");
>> +             ksettings.parent.link_mode_masks_nwords
>> +                     = -((s8)__ETHTOOL_LINK_MODE_MASK_NU32);
>
> I'm trying to understand how this can work.
>
> Supposedly, the link_mode_masks_nwords field is there so that we can
> add new link modes yet still work with tools built against any
> particular link mode list in the UAPI header files.
>
> But here you're forcing the value of link_mode_masks_nwords and then
> copying that amount back to userspace.  If the user allocated less
> space than the the link mode list in the kernel supports, we will
> overwrite past the end of the user's usettings object.
>
> You cannot unconditionally copy sizeof(usettings) back to the user,
> as store_ksettings_for_user() will do.
>
> I think you have to truncate here, copying only the array elements the
> user's structure actually has space for.  That's the only way this can
> work.
