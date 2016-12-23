From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Fri, 23 Dec 2016 10:30:27 +0100
Message-ID: <5CB44DFD-2807-4FD8-B409-FD28A53DE8B6@gmail.com>
References: <20161213150948.GD20323@lunn.ch>
 <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com>
 <20161214104614.GD27370@lunn.ch>
 <CABHmqqDpiN2kwkTgrM8Qu8EEx3Sjk2yVBy8QQAJppGfJ6-MV5Q@mail.gmail.com>
 <87eg19hzw1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <be3b69b7-b6a3-a939-cf77-c62e5a1fe719@gmail.com>
 <87bmwdcc96.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CABHmqqCOYMPA-Py7Uu4gsQ=s8CrQd-tT4-Db+j8eJH9=2s4L2g@mail.gmail.com>
 <20161216100802.GA20359@lunn.ch>
 <CABHmqqAQddcQZqVBi7gTjR40cHx6+aQebmsY3BwJgeEbLsX5Yw@mail.gmail.com>
 <20161216110115.GC20359@lunn.ch>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: multipart/mixed;
 boundary="Apple-Mail=_40527692-0A96-4890-9FB0-DCD1AB9078DD"
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36563 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935284AbcLWJab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 04:30:31 -0500
Received: by mail-lf0-f67.google.com with SMTP id t196so2288354lff.3
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 01:30:31 -0800 (PST)
In-Reply-To: <20161216110115.GC20359@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_40527692-0A96-4890-9FB0-DCD1AB9078DD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

Hi Andrew,
Here is the program I promised you.
There is a .c and Makefile attached to this mail. Simply type =E2=80=9Dmak=
e=E2=80=9D to build it.
There is a dependency on libnl3, which needs to be installed. If you =
don=E2=80=99t have it
Just install it: "apt-get install libnl-3-dev libnl-route-3-dev=E2=80=9D =
if you use ubuntu based
Linux.

What the program does is it creates a libnl cache, inserts into it some =
hardcoded
Multicast entries, and then adds entries to the kernel (to the bridge =
and to hardware).
By default the program looks for interfaces that have =E2=80=9Deth=E2=80=9D=
 in their names. If your interfaces
Have different names, just correct that line in the code. Otherwise it =
should just run straight away.
When entries are added the timing is presented. By default the program =
uses vlan id 1. If you need
To override it, just pass "-v 2=E2=80=9D or whatever vlan id you wish.
Please try running the program with hash table patch and without. You =
should see a significant difference.

Let me know if there is something you need help with.

Thanks,
Volodymyr

--Apple-Mail=_40527692-0A96-4890-9FB0-DCD1AB9078DD
Content-Disposition: attachment;
	filename=Makefile
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="Makefile"
Content-Transfer-Encoding: 7bit


EXEC      = fdbtest
OBJS      = fdbtest.o 
SRCS      = $(OBJS:.o=.c)
DEPS      = $(SRCS:.c=.d)
CFLAGS   += `pkg-config --cflags libnl-route-3.0`
DEPLIBS   = `pkg-config --libs libnl-route-3.0`
LDLIBS   += $(DEPLIBS)

all: Makefile $(EXEC)

$(EXEC): $(OBJS)

clean:
	-@$(RM) $(OBJS) $(EXEC)

distclean: clean
	-@$(RM) $(DEPS)

--Apple-Mail=_40527692-0A96-4890-9FB0-DCD1AB9078DD
Content-Disposition: attachment;
	filename=fdbtest.c
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="fdbtest.c"
Content-Transfer-Encoding: 7bit

/* 
 * FDB test - insert preprogrammed fdb entries
 * into HW database and measure the time it takes
 * to do the job.
 *
 * Author: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
 */

#include <net/if.h>
#include <netinet/ether.h>
#include <unistd.h>
#include <time.h>

#define _LINUX_IF_H
#include <linux/if_link.h>
#include <netlink/netlink.h>
#include <netlink/route/link.h>
#include <netlink/route/neighbour.h>
#include <netlink/route/link/bridge.h>

struct cb_data {
	int err;
	int vid;
	struct nl_sock *sk;
	void *arg;
};

static void __add(struct nl_object *obj, void *data)
{
	struct cb_data *cbd = data;
	struct nl_sock *sk;
	struct rtnl_neigh *neigh = (struct rtnl_neigh *)obj;

	sk = cbd->sk;
	if (cbd->err)
		return;

        cbd->err = rtnl_neigh_add(sk, neigh, NLM_F_CREATE);
}

static int __insert(struct nl_cache *cache, int ifindex, unsigned char *mac, int vlan)
{
	struct rtnl_neigh *neigh;
	struct nl_addr *addr;
	int err = 0;

        neigh = rtnl_neigh_alloc();
        if (!neigh) {
                printf("Could not allocate netlink neighbour\n");
                return -NLE_NOMEM;
        }

        addr = nl_addr_alloc(ETH_ALEN);
        if (!addr) {
		printf("Could not allocate netlink address\n");
		err = -NLE_NOMEM;
		goto err_put_neigh;
        }

	nl_addr_set_family(addr, AF_LLC);
	nl_addr_set_prefixlen(addr, 48);
        if (nl_addr_set_binary_addr(addr, mac, ETH_ALEN) < 0) {
		printf("Could not set netlink address\n");
		err = -NLE_FAILURE;
		goto err_put_addr;
	}

	rtnl_neigh_set_family(neigh, PF_BRIDGE);
	rtnl_neigh_set_lladdr(neigh, addr);
	rtnl_neigh_set_flags(neigh, NTF_SELF);
	rtnl_neigh_set_state(neigh, NUD_NOARP);
	rtnl_neigh_set_ifindex(neigh, ifindex);
	rtnl_neigh_set_vlan(neigh, vlan);

	err = nl_cache_add(cache, (struct nl_object*)neigh);
	if (err)
		printf("Could not add object to cache, err -> %d", err);

err_put_addr:
	nl_addr_put(addr);
err_put_neigh:
	rtnl_neigh_put(neigh);

	return err;
}

static int __insert_in_vlan(struct nl_cache *cache, char* ifname, unsigned char *mac, int vid)
{
       int ifindex;
       int err = 0;

       ifindex = if_nametoindex(ifname);
       err = __insert(cache, ifindex, mac, vid);

       return err;
}

static int __insert_default_mac(struct nl_cache *cache, char* ifname, int vid)
{
	int err = 0;
	size_t i;
        unsigned char mac[][ETH_ALEN] = {
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x01 }, /* 224.0.0.1 */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x02 }, /* 224.0.0.2 */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x04 }, /* 224.0.0.4   - DVMRP */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x05 }, /* 224.0.0.5   - OSPF */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x06 }, /* 224.0.0.6   - OSPF */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x09 }, /* 224.0.0.9   - RIPv2 */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x0a }, /* 224.0.0.10  - IGRP */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x0c }, /* 224.0.0.12  - DHCP Server/Relay */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x0d }, /* 224.0.0.13  - PIM */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x0e }, /* 224.0.0.14  - RSVP */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x12 }, /* 224.0.0.18  - VRRP*/
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x13 }, /* 224.0.0.19 */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x14 }, /* 224.0.0.20 */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x15 }, /* 224.0.0.21 */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x16 }, /* 224.0.0.22  - IGMP */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x18 }, /* 224.0.0.24  - OSPF */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x66 }, /* 224.0.0.102 - HSRP */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x6b }, /* 224.0.0.107 - PTP-pdelay */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0xfb }, /* 224.0.0.251 - mDNS */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0xfc }, /* 224.0.0.252 - Link-local multicast DNS */
                { 0x01, 0x00, 0x5e, 0x00, 0x00, 0xfe }  /* 224.0.0.254 */
        };

	for (i = 0; i < sizeof(mac) / sizeof(mac[0]); i++)
		__insert_in_vlan(cache, ifname, mac[i], vid);

	return err;
}

static void __add_fdb_defaults(struct nl_object *obj, void *data)
{
	struct cb_data *cbd = data;
	struct nl_cache *fdb_cache = cbd->arg;
	struct rtnl_link *link = nl_object_priv(obj);
	char *ifname;

	ifname = rtnl_link_get_name(link);
	if (!strncmp(ifname, "eth", 3)) {
		printf("Using interface -> %s\n", ifname);
		cbd->err = __insert_default_mac(fdb_cache, ifname, cbd->vid);
	}
	else
		printf("Skipping interface -> %s\n", ifname);
}

static int usage(int code)
{
	fprintf(stderr, "\nUsage: fdbtest [-h] [-v vid]\n\n"
		"  -h         Show summary of command line options and exit\n"
		"  -v vid     Set vlan id\n"
		"\n");

	return code;
}

int main(int argc , char *argv[])
{
	struct nl_cache *link_cache, *neigh_cache;
	struct nl_sock *nlsk;
	struct cb_data cbd = {.err = 0, .vid = 1 };
	clock_t start, end;
	double time_used;
	int err = 0;
	int c;

	while ((c = getopt(argc, argv, "hv:")) != EOF) {
		switch (c) {
		case 'h':
			return usage(0);

		case 'v':
			cbd.vid = atoi(optarg);
			break;

		default:
			return usage(1);
		}
	}

	printf("Init\n");
	nlsk = nl_socket_alloc();
	if (!nlsk)
		return -NLE_NOMEM;
	err = nl_connect(nlsk, NETLINK_ROUTE);
	if (err)
		goto free_nlsk;

	err = rtnl_link_alloc_cache(nlsk, AF_UNSPEC, &link_cache);
	if (err)
		goto free_nlsk;

	err = rtnl_neigh_alloc_cache(nlsk, &neigh_cache);
	if (err)
		goto free_lcache;

	printf("Using vlan %d\n\n", cbd.vid);
	cbd.arg = neigh_cache;
	nl_cache_foreach(link_cache, __add_fdb_defaults, &cbd);
	err = cbd.err;

	cbd.sk = nlsk;
	start = clock();
	nl_cache_foreach(neigh_cache, __add, &cbd);
	end = clock();
	err = cbd.err;
	time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	printf("\nTime spent: %f sec\n", time_used);
	
	nl_cache_free(neigh_cache);
	printf("Exit %d\n", err);

 free_lcache:
	nl_cache_free(link_cache);
 free_nlsk:
	nl_socket_free(nlsk);

	return err;
}

--Apple-Mail=_40527692-0A96-4890-9FB0-DCD1AB9078DD
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii


> 16 dec. 2016 kl. 12:01 skrev Andrew Lunn <andrew@lunn.ch>:
> 
> On Fri, Dec 16, 2016 at 11:26:01AM +0100, Volodymyr Bendiuga wrote:
>> Hi Andrew,
>> 
>> I don't have any script right now, the code I have is a part of
>> the OS, but I could write simple C program which represents
>> what we are doing with mc entries and send it to you for profiling.
> 
> It would be nice to have a benchmark test we can use to test out
> ideas.
> 
> Please try to make the code flexible. The slave interface names on my
> boards are probably not the same as on your. Also, the number of ports
> may differ.
> 
>    Thanks
> 	Andrew


--Apple-Mail=_40527692-0A96-4890-9FB0-DCD1AB9078DD--
