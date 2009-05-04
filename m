From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2 patch]: Add 'ip tuntap' facility for managing tun/tap
 devices
Date: Mon, 4 May 2009 07:38:13 -0700
Message-ID: <20090504073813.19d0d624@nehalam>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	<1241433778.6126.90.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53396 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724AbZEDOiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 10:38:19 -0400
In-Reply-To: <1241433778.6126.90.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 May 2009 11:42:58 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> This patch provides support for 'ip tuntap', allowing creation and
> deletion of persistent tun/tap devices.
> 
> The support for _listing_ devices relies on the patch I just sent to
> netdev (<1241433136.6126.70.camel@macbook.infradead.org>), although
> creation and deletion work without that patch.
> 
> diff --git a/ip/Makefile b/ip/Makefile
> index 98ba876..e868f3e 100644
> --- a/ip/Makefile
> +++ b/ip/Makefile
> @@ -1,6 +1,6 @@
>  IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
>      rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
> -    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
> +    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
>      ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
>      iplink_vlan.o link_veth.o link_gre.o
>  
> diff --git a/ip/ip.c b/ip/ip.c
> index 2bd54b2..d846a76 100644
> --- a/ip/ip.c
> +++ b/ip/ip.c
> @@ -47,7 +47,7 @@ static void usage(void)
>  "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
>  "       ip [ -force ] -batch filename\n"
>  "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
> -"                   tunnel | maddr | mroute | monitor | xfrm }\n"
> +"                   tunnel | tuntap | maddr | mroute | monitor | xfrm }\n"
>  "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
>  "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
>  "                    -o[neline] | -t[imestamp] | -b[atch] [filename] }\n");
> @@ -75,6 +75,8 @@ static const struct cmd {
>  	{ "link",	do_iplink },
>  	{ "tunnel",	do_iptunnel },
>  	{ "tunl",	do_iptunnel },
> +	{ "tuntap",	do_iptuntap },
> +	{ "tap",	do_iptuntap },
>  	{ "monitor",	do_ipmonitor },
>  	{ "xfrm",	do_xfrm },
>  	{ "mroute",	do_multiroute },
> diff --git a/ip/ip_common.h b/ip/ip_common.h
> index 273065f..c857667 100644
> --- a/ip/ip_common.h
> +++ b/ip/ip_common.h
> @@ -32,6 +32,7 @@ extern int do_ipneigh(int argc, char **argv);
>  extern int do_ipntable(int argc, char **argv);
>  extern int do_iptunnel(int argc, char **argv);
>  extern int do_ip6tunnel(int argc, char **argv);
> +extern int do_iptuntap(int argc, char **argv);
>  extern int do_iplink(int argc, char **argv);
>  extern int do_ipmonitor(int argc, char **argv);
>  extern int do_multiaddr(int argc, char **argv);
> diff --git a/ip/iptuntap.c b/ip/iptuntap.c
> new file mode 100644
> index 0000000..b480296
> --- /dev/null
> +++ b/ip/iptuntap.c
> @@ -0,0 +1,322 @@
> +/*
> + * iptunnel.c	       "ip tuntap"
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * Authors:	David Woodhouse <David.Woodhouse@intel.com>
> + *
> + */
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <unistd.h>
> +#include <sys/types.h>
> +#include <sys/socket.h>
> +#include <arpa/inet.h>
> +#include <sys/ioctl.h>
> +#include <linux/if.h>
> +#include <linux/if_tun.h>
> +#include <pwd.h>
> +#include <grp.h>
> +#include <fcntl.h>
> +#include <dirent.h>
> +#include <errno.h>
> +
> +#include "rt_names.h"
> +#include "utils.h"
> +#include "ip_common.h"
> +
> +#define TUNDEV "/dev/net/tun"
> +
> +static void usage(void) __attribute__((noreturn));
> +
> +static void usage(void)
> +{
> +	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
> +	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
> +	fprintf(stderr, "          [ one_queue ] [ no_pi ] [ vnet_hdr ]\n");
> +	fprintf(stderr, "\n");
> +	fprintf(stderr, "Where: USER  := { STRING | NUMBER }\n");
> +	fprintf(stderr, "       GROUP := { STRING | NUMBER }\n");
> +	exit(-1);
> +}
> +
> +static int tap_add_ioctl(struct ifreq *ifr, uid_t uid, gid_t gid)
> +{
> +	int fd = open(TUNDEV, O_RDWR);
> +	int ret = -1;
> +
> +#ifndef IFF_TUN_EXCL
> +#define IFF_TUN_EXCL	0x8000
> +#endif
> +	ifr->ifr_flags |= IFF_TUN_EXCL;
> +
> +	if (fd < 0) {
> +		perror("open");
> +		return -1;
> +	}
> +	if (ioctl(fd, TUNSETIFF, ifr)) {
> +		perror("ioctl(TUNSETIFF)");
> +		goto out;
> +	}
> +	if (uid != -1 && ioctl(fd, TUNSETOWNER, uid)) {
> +		perror("ioctl(TUNSETOWNER)");
> +		goto out;
> +	}
> +	if (gid != -1 && ioctl(fd, TUNSETGROUP, gid)) {
> +		perror("ioctl(TUNSETGROUP)");
> +		goto out;
> +	}
> +	if (ioctl(fd, TUNSETPERSIST, 1)) {
> +		perror("ioctl(TUNSETPERSIST)");
> +		goto out;
> +	}
> +	ret = 0;
> + out:
> +	close(fd);
> +	return ret;
> +}
> +
I would rather provide a netlink for managing TUNTAP interfaces and reorganize
under ip link??
