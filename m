From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] option for large routing hash
Date: Tue, 9 Dec 2003 23:28:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16342.19599.686693.823755@robur.slu.se>
References: <16341.58771.558850.163216@robur.slu.se>
	<20031209122031.048b406f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031209122031.048b406f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > There is a point at which hash table size exceeds it's usefulness in
 > that the gains you are getting from the O(1) lookup are offset by the
 > fact that the access to the hash table heads are constantly taking cpu
 > cache misses.
 
 Yes.
 
 > You've obtained good results in your tests with a _specific_ hash
 > table size for the routing cache, but the algorithm you are proposing
 > for the kernel computes things relative to the amount of memory in the
 > machine.  It cannot be a function of only this parameter.
 > 
 > Do you see my point?

I do. Lets look at experiment to start with also we seen people trying
to use in real hi-flow environments. pktgen is sending 32 kflows with
flowlen 10 packets (64 byte) at 2 * 300 kpps on into a router. Packet
streams 2 * 1M packets. TX OK gives thoughput.

And cache settings  max_size=262144 gc_thresh=32768 gc_elastity=8 for both
setup.


IP: routing cache hash table of 4096 buckets, 32Kbytes

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 2671635 9583466 9583466 7328370     10      0      0      0 BRU
eth1   1500   0     12      0      0      0 2671640      0      0      0 BRU
eth2   1500   0 2623413 9556039 9556039 7376591      4      0      0      0 BRU
eth3   1500   0      1      0      0      0 2623412      0      0      0 BRU

rtstat sample (truncated)

 size   IN: hit     tot    mc no_rt bcast madst masrc  
35320     62700   88890     0     0     0     0     0 

Look due to the cache size and GC it looks like a route DoS attack. We have
very little use of the hash as tot(long path) > (cache) hit. Lots of linear
seach in hash. And tot+hit gives the pps throughput 152 kpps. It's easy to 
characterize as a DoS attack but flowlen is 10 packets.

----------------------------------------------------------------------------

IP: routing cache hash table of 32768 buckets, 256Kbytes

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4382945 9293599 9293599 5617062     13      0      0      0 BRU
eth1   1500   0     16      0      0      0 4381291      0      0      0 BRU
eth2   1500   0 4290290 9292399 9292399 5709713      3      0      0      0 BRU
eth3   1500   0      1      0      0      0 4288727      0      0      0 BRU

rtstat sample (truncated)

  size   IN: hit     tot    mc no_rt bcast madst masrc  
212976    212665   52703     0     0     0     0     0  

We see cache is now used as hit > tot and we get a performance jump from 
152 to 265 kpps.

Just as you said this was the experiment. I'll stop here for now.

Cheers.
						--ro
