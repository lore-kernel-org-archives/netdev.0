From: Bin Guo <bguo@bluesocket.com>
Subject: Question about connect and ipsec
Date: Tue, 12 Apr 2005 10:09:52 -0400
Message-ID: <1113314992.9028.18.camel@bguo.bluesocket.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm running 2.6.11 IPSec where the esp tunnel endpoint is the default
gateway. During debugging, I found when there is no SA, plain arping
would fail (my policy is require for any<->my-adress):

	setkey -F
	arping -I eth1 9.9.9.1 # default-gateway=9.9.9.1
	connect: Resource temporarily unavailable
        #(racoon is trying to re-establish the tunnel here...)

but if you give arping source address, it's ok:

	setkey -F
	arping -I eth1 -s 9.9.9.238 9.9.9.1 # my-address=9.9.9.238
	ARPING 9.9.9.1 from 9.9.9.238 eth1
	Unicast reply from 9.9.9.1 [00:02:B3:5E:9E:13]  47.350ms

>From the source code of iputils/arping.c (and strace), when no source
address is provided, arping will do something like the following to
find proper local source address:

	int probe_fd = socket(AF_INET, SOCK_DGRAM);
	setsockopt(probe_fd, SOL_SOCKET, SO_BINDTODEVICE, ...);
	setsockopt(probe_fd, SOL_SOCKET, SO_DONTROUTE, &1, ...);
	connect(probe_fd, &dst, ...);
        getsockname(probe_fd, &src, ...);

The connect call seems to map directly to net/ipv4/datagram.c:
ip4_datagram_connect. Is it true that connect call on udp sockets
result in SA creation and temporary failure? Is it by design just
checking route to a destination protected ipsec will trigger SA
creation?

-- 
Bin
