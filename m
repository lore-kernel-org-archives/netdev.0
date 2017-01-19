From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: ethtool: avoid allocation failure for dump_regs
Date: Thu, 19 Jan 2017 14:22:30 -0500 (EST)
Message-ID: <20170119.142230.1012416564568457058.davem@davemloft.net>
References: <20170119141508.GA6245@tuxdriver.com>
        <20170119155620.GD6245@tuxdriver.com>
        <87h94uorc1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, darcari-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87h94uorc1.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Thu, 19 Jan 2017 20:08:30 +0200

> "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> writes:
> 
>> I forgot to Cc Johannes and Kalle...
> 
> Also adding linux-wireless.
> 
>> On Thu, Jan 19, 2017 at 09:15:09AM -0500, John W. Linville wrote:
>>> On Thu, Jan 19, 2017 at 07:35:22AM -0500, David Arcari wrote:
>>> > On 01/18/2017 11:45 AM, David Miller wrote:
>>> > > From: David Arcari <darcari-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> > > Date: Wed, 18 Jan 2017 08:34:05 -0500
>>> > >
>>> > >> If the user executes 'ethtool -d' for an interface and the associated
>>> > >> get_regs_len() function returns 0, the user will see a call trace from
>>> > >> the vmalloc() call in ethtool_get_regs().  This patch modifies
>>> > >> ethtool_get_regs() to avoid the call to vmalloc when the size is zero.
>>> > >>
>>> > >> Signed-off-by: David Arcari <darcari-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> > > I think when the driver indicates this, it is equivalent to saying that
>>> > > the operation isn't supported.
>>> > >
>>> > > Also, this guards us against ->get_regs() methods that don't handle
>>> > > zero length requests properly.  I see many which are going to do
>>> > > really terrible things in that situation.
>>> > >
>>> > > Therefore, if get_regs_len() returns zero, treat it the safe as if the
>>> > > ethtool operations were NULL.
>>> > >
>>> > > Thanks.
>>> > 
>>> > That was actually the fix that I was originally considering, but it
>>> > turns out
>>> > there is a problem with it.
>>> > 
>>> > I found that the vmalloc error was occurring because
>>> > ieee80211_get_regs_len() in
>>> > net/mac80211/ethtool.c was returning zero.  The ieee80211_get_regs in
>>> > the same
>>> > file returns the hw version. It turns out that this information is used
>>> > by the
>>> > at76c50x-usb driver in the user space ethtool to report which HW variant
>>> > is in
>>> > use.  Returning an error when regs_len() returns zero would break this
>>> > functionality.
>>> > 
>>> > -Dave
>>> 
>>> I'm responsible for this mess. The original idea was for various
>>> mac80211-based drivers to override the ethtool operation and provide
>>> their own dump operation, but the mac80211 crowd never embraced
>>> the idea.
>>> 
>>> In the meantime, I added the default implementation which just
>>> passed-up wdev->wiphy->hw_version as the version info for a 0-length
>>> register dump. I then implemented a driver-specific regiser dump
>>> handler for userland ethtool that would interpret the hardware version
>>> information for the at76c50x-usb driver.
>>> 
>>> So the net of it is, if we treat a return of 0 from get_regs_len()
>>> as "not supported", we break this one driver-specific feature for
>>> userland ethtool. Realistically, there are probably very few users
>>> to care. But I can't guarantee that the number is zero.
> 
> I know the number is not zero, because I remember using it years back
> with something else than at76c50x-usb. But is the number more than one,
> I don't know :)

I'm trying to dig down and figure out why this problem is showing up now.
ethtool_get_regs() has been using vzalloc() since 2011, and before that it
used plain vmalloc().

This code has therefore been using v{m,z}alloc() forever.  What changed?

The zero size check has been in the vmalloc implementation since at least
2009.

I don't understand why this is all triggering and being noticed now.  The
whole ieee80211 "return zero length regs and return hw version in get_regs"
thing should have been failing for at least 7 years now.
