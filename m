From: John Morrissey <jwm@horde.net>
Subject: 'ip tunnel add' uses the wrong interface name on error
Date: Mon, 7 Mar 2016 21:39:01 -0500
Message-ID: <20160308023901.GA4322@boost.horde.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from boost.horde.net ([69.55.65.181]:41909 "EHLO boost.horde.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071AbcCHCry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 21:47:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'ip tunnel add' uses the wrong interface name in its error output.
For example, if the requested interface already exists:

--
[jwm@boost:pts/8 ~> sudo ip tunnel add sit1 mode sit remote 10.10.10.11 local 10.10.10.10
add tunnel "sit0" failed: No buffer space available
--

ip/tunnel.c:tnl_add_ioctl() only uses the passed interface name on
SIOCCHGTUNNEL, not SIOCADDTUNNEL. Shouldn't it always use the passed
interface name, if present?

--
int tnl_add_ioctl(int cmd, const char *basedev, const char *name, void *p)
{
    struct ifreq ifr;
    int fd;
    int err;

    if (cmd == SIOCCHGTUNNEL && name[0])
        strncpy(ifr.ifr_name, name, IFNAMSIZ);
    else
        strncpy(ifr.ifr_name, basedev, IFNAMSIZ);
[...]
    err = ioctl(fd, cmd, &ifr);
    if (err)
        fprintf(stderr, "add tunnel \"%s\" failed: %s\n", ifr.ifr_name,
            strerror(errno));
