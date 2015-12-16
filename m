From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 05/19] net: ethtool: add new
 ETHTOOL_GSETTINGS/SSETTINGS API
Date: Wed, 16 Dec 2015 11:38:14 -0500 (EST)
Message-ID: <20151216.113814.2025166082777387327.davem@davemloft.net>
References: <1450127046-4573-1-git-send-email-ddecotig@gmail.com>
	<1450127046-4573-6-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, _govind-KK0ffGbhmjU@public.gmane.org,
	VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org,
	robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org,
	decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org
To: ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450127046-4573-6-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 14 Dec 2015 13:03:52 -0800

> +static int ethtool_get_ksettings(struct net_device *dev, void __user *useraddr)
> +{
 ...
> +	if (__ETHTOOL_LINK_MODE_MASK_NU32
> +	    != ksettings.parent.link_mode_masks_nwords) {
> +		/* wrong link mode nbits requested */
> +		memset(&ksettings, 0, sizeof(ksettings));
> +		/* keep cmd field reset to 0 */
> +		/* send back number of words required as negative val */
> +		compiletime_assert(__ETHTOOL_LINK_MODE_MASK_NU32 <= S8_MAX,
> +				   "need too many bits for link modes!");
> +		ksettings.parent.link_mode_masks_nwords
> +			= -((s8)__ETHTOOL_LINK_MODE_MASK_NU32);

I'm trying to understand how this can work.

Supposedly, the link_mode_masks_nwords field is there so that we can
add new link modes yet still work with tools built against any
particular link mode list in the UAPI header files.

But here you're forcing the value of link_mode_masks_nwords and then
copying that amount back to userspace.  If the user allocated less
space than the the link mode list in the kernel supports, we will
overwrite past the end of the user's usettings object.

You cannot unconditionally copy sizeof(usettings) back to the user,
as store_ksettings_for_user() will do.

I think you have to truncate here, copying only the array elements the
user's structure actually has space for.  That's the only way this can
work.
