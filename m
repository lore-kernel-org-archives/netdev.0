From: David Miller <davem@davemloft.net>
Subject: state of rtcache removal...
Date: Wed, 16 Feb 2011 16:08:38 -0800 (PST)
Message-ID: <20110216.160838.39164069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752008Ab1BQAIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 19:08:02 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5687C24C087
	for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 16:08:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So I've been testing out the routing cache removal patch to see
what the impact is on performance.

I'm using a UDP flood to a single IP address over a dummy interface
with hard coded ARP entries, so that pretty much just the main IP
output and routing paths are being exercised.

The UDP flood tool I cooked up based upon a description sent to me by
Eric Dumazet of a similar utility he uses for testing.  I've included
the code to this tool at the end of this email, as well as the dummy
interface setup script.   Basically, you go:

bash# ./udpflood_setup.sh
bash# time ./udpflood -l 10000 10.2.2.11

The IP output path is about twice as slow with the routing cache
removed entirely.  Here are the numbers I have:

net-next-2.6, rt_cache on:

davem@maramba:~$ time udpflood -l 10000000 10.2.2.11
real		 1m47.012s
user		 0m8.670s
sys		 1m38.370s

net-next-2.6, rt_cache turned off via sysctl:

davem@maramba:~$ time udpflood -l 10000000 10.2.2.11
real		 3m12.662s
user		 0m9.490s
sys		 3m3.220s

net-next-2.6 + "BONUS" rt_cache deletion patch:

maramba:/home/davem# time ./bin/udpflood -l 10000000 10.2.2.11
real		     3m9.921s
user		     0m9.520s
sys		     3m0.440s

I then worked on some simplifications of the code in net/ipv4/route.c
that remains after the cache removal.  I'll post those patches after
I've chewed on them some more, but they knock a couple seconds back off
of the benchmark:

The profile output is what you'd expect, with fib_table_lookup() topping
the charts taking ~%10 of the time.

What might not be initially apparent is that each output route lookup
results in two calls to fib_table_lookup() and thus two trie lookups.
Why?  Because we have two routing tables (3 with IP_MULTIPLE_TABLES
enabled) that get searched, first the LOCAL then the MAIN table (then
with mutliple-tables enabled, the DEFAULT).  And most external
outgoing routes sit in the MAIN table.

We do this so we can store all the interface address network,
broadcast, loopback network, et al. routes in the LOCAL table, then all
globally visible routes in the MAIN table.

Anyways, the long and short of this is that route lookups take two
trie lookups instead of just one.  On input there are even more, for
source address validation done by fib_validate_source().  That can be
up to 4 more fib_table_lookup() invocations.

Add in another level of complexity if you have a series of FIB rules
installed.

So, to me, this means that spending time micro-optiming fib_trie is
not going to help much.  Getting rid of that multiplier somehow, on
the other hand, might.

I plan to play with some ideas, such as sticking fib_alias entries into
the flow cache and consulting/populating the flow cache on fib_lookup()
calls.

-------------------- udpflood.c --------------------
/* An adaptation of Eric Dumazet's udpflood tool.  */

#include <stdio.h>
#include <stddef.h>
#include <malloc.h>
#include <string.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define _GNU_SOURCE
#include <getopt.h>

static int usage(void)
{
	printf("usage: udpflood [ -l count ] [ -m message_size ] IP_ADDRESS\n");
	return -1;
}

static int send_packets(in_addr_t addr, int port, int count, int msg_sz)
{
	char *msg = malloc(msg_sz);
	struct sockaddr_in saddr;
	int fd, i, err;

	if (!msg)
		return -ENOMEM;

	memset(msg, 0, msg_sz);

	memset(&saddr, 0, sizeof(saddr));
	saddr.sin_family = AF_INET;
	saddr.sin_port = port;
	saddr.sin_addr.s_addr = addr;

	fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (fd < 0) {
		perror("socket");
		err = fd;
		goto out_nofd;
	}
	err = connect(fd, (struct sockaddr *) &saddr, sizeof(saddr));
	if (err < 0) {
		perror("connect");
		close(fd);
		goto out;
	}
	for (i = 0; i < count; i++) {
		err = sendto(fd, msg, msg_sz, 0,
			     (struct sockaddr *) &saddr, sizeof(saddr));
		if (err < 0) {
			perror("sendto");
			goto out;
		}
	}

	err = 0;
out:
	close(fd);
out_nofd:
	free(msg);
	return err;
}

int main(int argc, char **argv, char **envp)
{
	int port, msg_sz, count, ret;
	in_addr_t addr;

	port = 6000;
	msg_sz = 32;
	count = 10000000;

	while ((ret = getopt(argc, argv, "l:s:p:")) >= 0) {
		switch (ret) {
		case 'l':
			sscanf(optarg, "%d", &count);
			break;
		case 's':
			sscanf(optarg, "%d", &msg_sz);
			break;
		case 'p':
			sscanf(optarg, "%d", &port);
			break;
		case '?':
			return usage();
		}
	}

	if (!argv[optind])
		return usage();

	addr = inet_addr(argv[optind]);
	if (addr == INADDR_NONE)
		return usage();

	return send_packets(addr, port, count, msg_sz);
}

-------------------- udpflood_setup.sh --------------------
#!/bin/sh
modprobe dummy
ifconfig dummy0 10.2.2.254 netmask 255.255.255.0 up

for f in $(seq 11 26)
do
 arp -H ether -i dummy0 -s 10.2.2.$f 00:00:0c:07:ac:$f
done
