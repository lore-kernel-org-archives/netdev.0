From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v3 net-next 0/1] net: lls select poll support
Date: Wed, 19 Jun 2013 13:04:21 +0300
Message-ID: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Here is a rework of the select/poll patch.

One question: do we need in sock_poll() to test that sock->sk is not null?
(Thanks to Willem de Bruijn for pointing this out.) 

When select or poll are used on a lot of sockets the sysctl value
needs to be set higher than 50. For 300 sockets a setting of 100 works
for me. For 1000 sockets a setting of 200 works well but the gain is
very small, probably not worth it.

I should mention that unlike the version we had in v9, with this version
of the patch, LLS always performs better than no LLS. 

In this version I split the sysctl entries into two.
sysctl.net.core.low_latency_read for blocking socket reads.
sysctl.net.core.low_latency_poll for select/poll.

The main reason we need two sysctl entries is that the values are different.
For socket reads 50us is plenty of time but when polling on 300 sockets
we need about 100us.

This also allows poll to busy poll only on some sockets.
You set sysctl.net.core.low_latency_poll, but leave the read value 0.
Then you use the socket option to enable SO_LL only on the sockets
you would like to buys poll on.

Maybe what we really want is a cgroup that would allow settings
per-process group.

-Eliezer

Change log:
v3
- split sysctl value into two separate ones, one for read and one for poll.
- updated Documentation/sysctl/net.txt
- fixed possible overflow (again) reported by Eric Dumazet.
- poll/select loop optimizations by Eric Dumazet and Willem de Bruijn.

v2
- added POLL_LL flag, used to signal between the syscalls and sock_poll().
- add a separate ll_end_time() function to be used from poll.
- slight reorder of sk_poll_ll so the timing primitives are not used
  when called from sock_poll().
- select/poll stop busy polling as soon as there is something to return
  to the user.

Change log from the original LLS patch series:
v9
- better mask testing in sock_poll(), reported by Eric Dumazet.

v8
- split out udp and select/poll into separate patches.
  what used to be patch 2/5 is now three patches.

v5
- added simple poll/select support
