From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 03/17] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Tue, 1 Dec 2015 22:00:58 -0800
Message-ID: <CAG88wWbW=yxO0mzauJauEd3W-SuPq3eNGRE+Xe6ATcLKhrPq3A@mail.gmail.com>
References: <1448921155-24764-1-git-send-email-ddecotig@gmail.com>
 <1448921155-24764-4-git-send-email-ddecotig@gmail.com> <20151201.221356.2176806670215219133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eyal Perry <eyalpe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151201.221356.2176806670215219133.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

There is a set of conversion routines ulong[]<->u32[] to address this
32/64-bit compat issue. Using a u32-based bitmap would require drivers
to handle the u32 bitmaps themselves, this might be confusing,
considering there is a standard bitmap api; and might be error-prone
as well. Plus there is %*pb[l] format that's very helpful for
debugging. That's why I preferred to handle the relative complexity of
u32 bitmaps with the CPP conditionals in the non-driver code that
handles the user/kernel interactions, and drivers can use the standard
bitmap api transparently.

I was currently moving/rewriting the u32/ulong conversion code to
bitmap.{c,h} as Ben Hutchings was suggesting, which should hopefully
make the code more digestible; and could possibly be used for other
user/kernel interfaces. How about I send an updated version with this
solution, and if it's still not right, I'll revisit with either u32[]
everywhere or fixed-size bitmap instead of variable-size as here? Or
maybe another option would be to implement a new u32[]
bitmap_u32.{c,h} api, possibly using a set of macro tricks to share
code with bitmap.{c,h}?

On Tue, Dec 1, 2015 at 7:13 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 30 Nov 2015 14:05:41 -0800
>
>> This patch defines a new ETHTOOL_GSETTINGS/SSETTINGS API, handled by
>> the new get_ksettings/set_ksettings callbacks. This API provides
>> support for most legacy ethtool_cmd fields, adds support for larger
>> link mode masks (up to 4064 bits, variable length), and removes
>> ethtool_cmd deprecated fields (transceiver/maxrxpkt/maxtxpkt).
>
> Please do not define the mask using a non-fixed type.  I know it makes
> it easier to use the various bitmap helper routines if you use 'long',
> but here it is clearly superior to use "u32" for the bitmap type and
> do the bit operations by hand if necessary.
>
> Otherwise you have to have all of this ulong size CPP conditional code
> which is incredibly ugly.
>
> Furthermore you have to use fixed sized types anyways so that we don't
> need compat code to deal with 32-bit userspace applications making
> these ethtool calls into a 64-bit kernel.
>
> THanks.
