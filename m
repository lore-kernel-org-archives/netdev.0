From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 12:50:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910195003.GA13912@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote :
> 
> Allows changing of device name via rtnetlink. Last bit needed to do full
> link configuration via rtnetlink.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

	This does not work, because you don't return the new name to
user space. If the new name is a pattern, such as "eth%d" or "wlan%d",
you absolutely need to return the new instanciated device name to user
space so that userspace doesn't loose track of the device.

	Please look at this snipset from dev.c :

-----------------------------------------------------------------
		/*
		 *	These ioctl calls:
		 *	- require superuser power.
		 *	- require strict serialization.
		 *	- return a value
		 */
		case SIOCGMIIPHY:
		case SIOCGMIIREG:
		case SIOCSIFNAME:
			if (!capable(CAP_NET_ADMIN))
				return -EPERM;
			dev_load(ifr.ifr_name);
			rtnl_lock();
			ret = dev_ifsioc(&ifr, cmd);
			rtnl_unlock();
			if (!ret) {
				if (colon)
					*colon = ':';
				if (copy_to_user(arg, &ifr,
						 sizeof(struct ifreq)))
					ret = -EFAULT;
			}
			return ret;
-----------------------------------------------------------------

	I'm all for converting stuff to RtNetlink, but please don't
criple the functionality...

	Have fun...

	Jean
