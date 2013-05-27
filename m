From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v5 net-next 0/5] net: low latency Ethernet device polling
Date: Mon, 27 May 2013 10:43:51 +0300
Message-ID: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Dave Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

There are many small changes from the last time.
The two big changes are:
* Skb and sk now store a napi_id instead of a pointer.
* Very naive poll/select support. There is a dramatic improvement in both
  latencey and jitter, but clearly more work needs to be done here.

Please consider applying.

some rough poll/select results:
Using the optimized kernel from v2
testing with the sysctl value set to 50 and 0
sockperf using poll   on 10 udp sockets 7.0us vs. 51.9us
sockperf using select on 10 udp sockets 7.2us vs. 51.8us
sockperf using poll   on 10 tcp sockets 7.1us vs. 53.2us
sockperf using selct  on 10 tcp sockets 7.4us vs. 52.8us

Note to anyone doing testing: the sysctl value has moved to net.core 

change log
v5
- corrections suggested by Ben Hutchings:
  fixed typos, moved the config option and sysctl value from IPv4 to net
- moved sk_mark_ll() to the protocol handlers
- removed global id mechanism, replaced with a hashed napi_id.
  based on code sample from Eric Dumazet
  Note that ixgbe_free_q_vector() already waits an rcu grace period
  before freeing the q_vector, so nothing additional needs to be done
  when adding a call to napi_hash_del().
- simple poll/select support

v4
- removed separate config option for TCP as suggested Eric Dumazet.
- added linux mib counter for packets received through the low latency path,
  as suggested by Andi Kleen.
- re-allow module unloading, remove module param, use a global generation id
  instead to prevent the use of a stale napi pointer, as suggested
  by Eric Dumazet
- updated Documentation/networking/ip-sysctl.txt text

v3
- coding style changes suggested by Dave Miller

v2
- the sysctl knob is now in microseconds. The default value is now 0 (off).
- for now the code depends at configure time on CONFIG_I86_TSC 
- the napi reference in struct skb is now a union with the dma cookie
  since the former is only used on RX and the latter on TX,
  as suggested by Eric Dumazet.
- we do a better job at honoring non-blocking operations.
- removed busy-polling support for tcp_read_sock()
- remove dynamic disabling of GRO
- coding style fixes
- disallow unloading the device module after the feature has been used

Credit:
Jesse Brandeburg, Arun Chekhov Ilango, Julie Cummings,
Alexander Duyck, Eric Geisler, Jason Neighbors, Yadong Li,
Mike Polehn, Anil Vasudevan, Don Wood
Special thanks for finding bugs in earlier versions:
Willem de Bruijn and Andi Kleen

Thanks,
Eliezer
