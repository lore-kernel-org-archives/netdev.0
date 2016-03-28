From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 10:00:34 -0700
Message-ID: <1459184434.6473.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
	 <1458944964-12890-3-git-send-email-edumazet@google.com>
	 <56F95884.8010901@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35874 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbcC1RAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 13:00:36 -0400
Received: by mail-pa0-f51.google.com with SMTP id tt10so102705958pab.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 10:00:36 -0700 (PDT)
In-Reply-To: <56F95884.8010901@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 09:15 -0700, Rick Jones wrote:
> On 03/25/2016 03:29 PM, Eric Dumazet wrote:
> > UDP sockets are not short lived in the high usage case, so the added
> > cost of call_rcu() should not be a concern.
> 
> Even a busy DNS resolver?

If you mean that a busy DNS resolver spends _most_ of its time doing :

fd = socket()
bind(fd  port=0)
  < send and receive one frame >
close(fd)

(If this is the case, may I suggest doing something different, and use
some kind of caches ? It will be way faster.)

Then the result for 10,000,000 loops of <socket()+bind()+close()> are

Before patch : 

real	0m13.665s
user	0m0.548s
sys	0m12.372s

After patch :

real	0m20.599s
user	0m0.465s
sys	0m17.965s

So the worst overhead is 700 ns

This is roughly the cost for bringing 960 bytes from memory, or 15 cache
lines (on x86_64)

# grep UDP /proc/slabinfo 
UDPLITEv6              0      0   1088    7    2 : tunables   24   12    8 : slabdata      0      0      0
UDPv6                 24     49   1088    7    2 : tunables   24   12    8 : slabdata      7      7      0
UDP-Lite               0      0    960    4    1 : tunables   54   27    8 : slabdata      0      0      0
UDP                   30     36    960    4    1 : tunables   54   27    8 : slabdata      9      9      2

In reality, chances that UDP sockets are re-opened right after being
freed and their 15 cache lines are very hot in cpu caches is quite
small, so I would not worry at all about this rather stupid benchmark.

int main(int argc, char *argv[]) {
	struct sockaddr_in addr;
	int i, fd, loops = 10000000;

	for (i = 0; i < loops; i++) {
		fd = socket(AF_INET, SOCK_DGRAM, 0);
		if (fd == -1) {
			perror("socket");
			break;
		}
		memset(&addr, 0, sizeof(addr));
		addr.sin_family = AF_INET;
		if (bind(fd, (const struct sockaddr *)&addr, sizeof(addr)) == -1) {
			perror("bind");
			break;
		}
		close(fd);
	}
	return 0;
}
