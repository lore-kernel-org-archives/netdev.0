From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Wed, 12 Dec 2012 09:27:00 -0800
Message-ID: <20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
	<20121212081500.24085752@nehalam.linuxnetplumber.net>
	<20121212170520.GA3060@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44639 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601Ab2LLR2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 12:28:18 -0500
In-Reply-To: <20121212170520.GA3060@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 18:05:20 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Wed, Dec 12, 2012 at 05:15:00PM CET, shemminger@vyatta.com wrote:
> >On Wed, 12 Dec 2012 11:58:03 +0100
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> This is basically a repost of my previous patchset:
> >> "[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30
> >> 
> >> The way net-sysfs stores values changed and this patchset reflects it.
> >> Also, I exposed carrier via rtnetlink iface.
> >> 
> >> So far, only dummy driver uses carrier change ndo. In very near future
> >> team driver will use that as well.
> >> 
> >> Jiri Pirko (4):
> >>   net: add change_carrier netdev op
> >>   net: allow to change carrier via sysfs
> >>   rtnl: expose carrier value with possibility to set it
> >>   dummy: implement carrier change
> >> 
> >>  drivers/net/dummy.c          | 10 ++++++++++
> >>  include/linux/netdevice.h    |  7 +++++++
> >>  include/uapi/linux/if_link.h |  1 +
> >>  net/core/dev.c               | 19 +++++++++++++++++++
> >>  net/core/net-sysfs.c         | 15 ++++++++++++++-
> >>  net/core/rtnetlink.c         | 10 ++++++++++
> >>  6 files changed, 61 insertions(+), 1 deletion(-)
> >> 
> >
> >I needed to do the same thing for a project we are working on and discovered
> >that there already is a working documented interface for doing that via
> >operstate mode. Therefore I can't recommend that the additional complexity
> >of a new API for this is required.
> 
> I might be missing something, but I'm unable to find how operstate set
> can affect value returned by netif_carrier_ok()
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Here is an example using dummy device using libmnl. It is also possible
with ip commands.

# modprobe dummy
# ip li show dev dummy0
12: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT 
    link/ether ce:90:46:83:6e:f8 brd ff:ff:ff:ff:ff:ff
# ./dummy dummy0 init
# ip li show dev dummy0
12: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DORMANT 
    link/ether ce:90:46:83:6e:f8 brd ff:ff:ff:ff:ff:ff
# ip li set dummy0 up
# ip li show dev dummy0
12: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DORMANT 
    link/ether ce:90:46:83:6e:f8 brd ff:ff:ff:ff:ff:ff
# ./dummy dummy0 down
# ip li show dev dummy0
12: dummy0: <NO-CARRIER,BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state DORMANT mode DORMANT 
    link/ether ce:90:46:83:6e:f8 brd ff:ff:ff:ff:ff:ff
# ./dummy dummy0 up
# ip li show dev dummy0
12: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT 
    link/ether ce:90:46:83:6e:f8 brd ff:ff:ff:ff:ff:ff


/* Sample program to control link mode and link state */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <libmnl/libmnl.h>

#include <linux/if.h>
#include <linux/if_tun.h>
#include <linux/rtnetlink.h>

static void panic(const char *str)
{
	perror(str);
	exit(1);
}

static void usage(const char *cmd)
{
	fprintf(stderr, "Usage: %s dummyX [up|down|init]\n", cmd);
	exit(1);
}

/* Send request and parse response */
static void mnl_talk(struct mnl_socket *nl, struct nlmsghdr *nlh)
{
	unsigned portid = mnl_socket_get_portid(nl);
	uint32_t seq = time(NULL);
	char buf[MNL_SOCKET_BUFFER_SIZE];

	nlh->nlmsg_flags |= NLM_F_ACK;
	nlh->nlmsg_seq = seq;

	if (mnl_socket_sendto(nl, nlh, nlh->nlmsg_len) < 0)
		panic("mnl_socket_sendto failed");

	int ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
	if (ret < 0)
		panic("mnl_socket_recvfrom");

	if ( mnl_cb_run(buf, ret, seq, portid, NULL, NULL) < 0)
		panic("mnl_cb_run");
}

static void linkstate(struct mnl_socket *nl,
		      const char *ifname, unsigned int state)
{
	char buf[MNL_SOCKET_BUFFER_SIZE];
	struct nlmsghdr *nlh = mnl_nlmsg_put_header(buf);
	nlh->nlmsg_type = RTM_NEWLINK;
	nlh->nlmsg_flags = NLM_F_REQUEST;

	struct ifinfomsg *ifi;
	ifi = mnl_nlmsg_put_extra_header(nlh, sizeof(struct ifinfomsg));
	ifi->ifi_family = AF_UNSPEC;

	mnl_attr_put_strz(nlh, IFLA_IFNAME, ifname);
	mnl_attr_put_u8(nlh, IFLA_OPERSTATE, state);

	mnl_talk(nl, nlh);
}

/* Set device link mode */
static void init(struct mnl_socket *nl, const char *ifname)
{
	char buf[MNL_SOCKET_BUFFER_SIZE];
	struct nlmsghdr *nlh = mnl_nlmsg_put_header(buf);
	nlh->nlmsg_type = RTM_NEWLINK;
	nlh->nlmsg_flags = NLM_F_REQUEST;

	struct ifinfomsg *ifi;
	ifi = mnl_nlmsg_put_extra_header(nlh, sizeof(struct ifinfomsg));
	ifi->ifi_family = AF_UNSPEC;
	
	mnl_attr_put_strz(nlh, IFLA_IFNAME, ifname);
	mnl_attr_put_u8(nlh, IFLA_LINKMODE, IF_LINK_MODE_DORMANT);
	mnl_talk(nl, nlh);
}

int main(int argc, char **argv)
{
	if (argc != 3)
		usage(argv[0]);

	struct mnl_socket *nl = mnl_socket_open(NETLINK_ROUTE);
	if (!nl)
		panic("mnl_socket_open");

	if (mnl_socket_bind(nl, 0, MNL_SOCKET_AUTOPID) < 0)
		panic("mnl_socket_bind");
	

	if (strcmp(argv[2], "init") == 0)
		init(nl, argv[1]);
	else if (strcmp(argv[2], "up") == 0)
		linkstate(nl, argv[1], IF_OPER_UP);
	else if (strcmp(argv[2], "down") == 0)
		linkstate(nl, argv[1], IF_OPER_DORMANT);
	else
		usage(argv[0]);

	return 0;
}
