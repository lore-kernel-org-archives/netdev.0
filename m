From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 6 Jun 2011 22:19:33 +0200
Message-ID: <201106062219.33432.arnd@arndb.de>
References: <1307389540.2642.3.camel@edumazet-laptop> <201106062206.29134.arnd@arndb.de> <20110606.130958.1488166895702555231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58533 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab1FFUTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:19:39 -0400
In-Reply-To: <20110606.130958.1488166895702555231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 June 2011 22:09:58 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Mon, 6 Jun 2011 22:06:28 +0200
> 
> > On Monday 06 June 2011 21:45:40 Eric Dumazet wrote:
> >> While trying Alexander Holler patch, I found a 32bit brctl program was
> >> not able to work on a 64bit kernel. So I had to switch to another
> >> machine for my tests.
> >> 
> >> brctl addbr mybridge
> >> ->
> >> socket(PF_FILE, SOCK_STREAM, 0)         = 3
> >> ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
> >> 
> >> Should we care or not ?
> >> 
> > 
> > Generally, we try to make all ioctls work in compat mode. For the old
> > bridge ioctls, this is currently impossible because it uses SIOCPRIVATE
> > ioctls, but it would be easy to add an ndo_do_compat_ioctl. 
> 
> Right, we need to funnel compat ioctls down to the device and add a
> ->ndo_compat_ioctl() or similar, if that is indeed feasible.

I think it would be good to first understand why it doesn't work with the
new style ioctls that are in the kernel. The source code of brctl that
I'm looking at here contains:

int br_add_bridge(const char *brname)
{
        int ret;

#ifdef SIOCBRADDBR
        ret = ioctl(br_socket_fd, SIOCBRADDBR, brname);
        if (ret < 0)
#endif
        {
                char _br[IFNAMSIZ];
                unsigned long arg[3]
                        = { BRCTL_ADD_BRIDGE, (unsigned long) _br };

                strncpy(_br, brname, IFNAMSIZ);
                ret = ioctl(br_socket_fd, SIOCSIFBR, arg);
        }

        return ret < 0 ? errno : 0;
}

This means it should first attempt to call SIOCBRADDBR, which has
32 bit compat support in the kernel. The only reasons I can see why
this would not work are:

* the brctl tool in question is built from really old sources that
  don't have the SIOCBRADDBR option.
* it is built against really old kernel headers that do not export
  the SIOCBRADDBR definition.

If neither of the two is true, there is probably a bug somewhere that
wants to get fixed.

	Arnd
