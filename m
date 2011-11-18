From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 11:27:09 -0500
Message-ID: <20111118162709.GA8342@elliptictech.com>
References: <20111117190925.GA23214@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.elliptictech.com ([209.217.122.41]:57539 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758126Ab1KRQ1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 11:27:15 -0500
Content-Disposition: inline
In-Reply-To: <20111117190925.GA23214@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-11-17 14:09 -0500, Nick Bowler wrote:
> One of the tests we do with IPsec involves sending and receiving UDP
> datagrams of all sizes from 1 to N bytes, where N is much larger than
> the MTU.  In this particular instance, the MTU is 1500 bytes and N is
> 10000 bytes.  This test works fine with IPv4, but I'm getting an
> occasional oops on Linus' master with IPv6 (output at end of email).  We
> also run the same test where N is less than the MTU, and it does not
> trigger this issue.  The resulting fallout seems to eventually lock up
> the box (although it continues to work for a little while afterwards).
> 
> The issue appears timing related, and it doesn't always occur.  This
> probably also explains why I've not seen this issue before now, as we
> recently upgraded all our lab systems to machines from this century
> (with newfangled dual core processors).  This also makes it somewhat
> hard to reproduce, but I can trigger it pretty reliably by running 'yes'
> in an ssh session (which doesn't use IPsec) while running the test:
> it'll usually trigger in 2 or 3 runs.  The choice of cipher suite
> appears to be irrelevant.
> 
> I built a relatively old kernel (2.6.34) and could not reproduce the
> issue there, so I ran a git bisect.  It pointed to the following, which
> (unsurprisingly) no longer reverts cleanly.
> 
> Let me know if you need any more info.  I'll see if I can reproduce the
> issue with a smaller test case...

OK, here's a somewhat straigthforward way to reproduce it that I've
found.  It uses a short test program called "udp_burst" which simply
transmits a bunch of UDP datagrams at all sizes between 1 and 10000,
included at the end of this mail.

 * Build the test program

    % gcc -o udp_burst udp_burst.c

 * Setup transport mode IPv6 SAs between two hosts so that they can
   communicate using IPsec.  Choose your favourite cipher suite.
   In this example, my two hosts are "fec0::3/64" and "fec0::2/64": I
   will be crashing the former.

   It can be reproduced with just one host transmitting to the bit
   bucket, but it seems to go much faster with two.

 * Create some constant non-IPsec network traffic on the machine to be
   crashed (for example, log in via SSH and run "yes").
 
 * On the machine to be crashed, run

    % while :; do ./udp_burst remote; done

   where remote is the other host (fec0::2 in my case).
 
 * Wait a few seconds and watch the fireworks.

% cat >udp_burst.c <<'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#define MAX_DGRAM_SIZE 10000

static char buf[MAX_DGRAM_SIZE];

int main(int argc, char **argv)
{
	char *addr = NULL, *port = "9000";
	struct addrinfo *info, hints = {
		.ai_family   = AF_UNSPEC,
		.ai_socktype = SOCK_DGRAM,
		.ai_flags    = AI_PASSIVE,
	};
	int i, rc, sock;

	if (argc > 1)
		addr = argv[1];
	if (argc > 2)
		port = argv[2];
	if (!addr) {
		fprintf(stderr, "usage: %s addr [port]\n", argv[0]);
		return EXIT_FAILURE;
	}

	rc = getaddrinfo(addr, port, &hints, &info);
	if (rc != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rc));
		return EXIT_FAILURE;
	}

	sock = socket(info->ai_family, info->ai_socktype, info->ai_protocol);
	if (sock == -1) {
		perror("socket");
		return EXIT_FAILURE;
	}

	if (connect(sock, info->ai_addr, info->ai_addrlen) == -1) {
		perror("connect");
		return EXIT_FAILURE;
	}

	for (i = 0; i < MAX_DGRAM_SIZE; i++) {
		if (send(sock, buf, i+1, MSG_DONTWAIT) == -1) {
			if (errno != EAGAIN && errno != ECONNREFUSED) {
				perror("send");
			}
		}
	}

	return 0;
}
EOF

Cheers,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
