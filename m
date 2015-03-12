From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/2] rhashtable: Arbitrary rehashing
Date: Thu, 12 Mar 2015 16:46:35 +0000
Message-ID: <20150312164635.GA11089@casper.infradead.org>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
 <20150309095833.GA4028@gondor.apana.org.au>
 <20150309222631.GA12221@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51179 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbCLQqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:46:37 -0400
Content-Disposition: inline
In-Reply-To: <20150309222631.GA12221@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 03/10/15 at 09:26am, Herbert Xu wrote:
> I have tested it using netlink but obviously more testing especially
> using netfilter would be welcome.

I ran the attached bind_netlink test written by Ying Xue and it
currently crashes with:

[  108.693908] BUG: unable to handle kernel paging request at fffffffffffffe68

I'm running bind_netlink like this:

while true; do
    ./bind_netlink 9000 324234324&
    ./bind_netlink 9000 888448422&
    ./bind_netlink 9000 324
done

I tested with the synchronize_rcu() fix on top as well and that
didn't help so it must be something else.

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bind_netlink.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <netinet/in.h>
#include <linux/netlink.h>

void diep(char *err)
{
	perror(err);
	exit(1);
}

int main(int argc, char *argv[])
{
	int i;
	int *fds;
	int num_ports;
	struct sockaddr_nl local;

	srand(strtoul(argv[2], NULL, 0));

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <PORTS>\n", argv[0]);
		exit(1);
	}

	num_ports = atoi(argv[optind]);

	printf("Create %u ports\n", num_ports);

	fds = malloc(sizeof(int) * num_ports);
	for (i = 1; i <= num_ports; i++) {
		if (!(fds[i] = socket(PF_NETLINK, SOCK_RAW, 0)))
			diep("socket");

		memset(&local, 0, sizeof(local));
		local.nl_family = AF_NETLINK;
		local.nl_pid = rand();
		local.nl_groups = 0;
		if(bind(fds[i], (struct sockaddr *)&local, sizeof(local)) != 0){
			diep("socket");
		}
		
		if (!(i % 1000))
			printf("Created %u ports\n", i);

	}
	printf("Ports successfully created, terminating\n");

	return 0;
}

--YZ5djTAD1cGYuMQK--
