From: Rick Jones <rick.jones2@hp.com>
Subject: data vs overhead bytes, netperf aggregate RR and retransmissions
Date: Tue, 02 Aug 2011 14:39:36 -0700
Message-ID: <4E386E98.1090606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:48993 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab1HBVjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 17:39:37 -0400
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 7FBF438497
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2011 21:39:37 +0000 (UTC)
Received: from [16.89.244.213] (tardy.cup.hp.com [16.89.244.213])
	by g1t0038.austin.hp.com (Postfix) with ESMTP id 37E51300BB
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2011 21:39:36 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks -

Those who have looked at the "runemomniagg2.sh" script I have up on 
netperf.org will know that one of the tests I often run is an aggregate, 
burst-mode, single-byte TCP_RR test.  I ramp-up how many transactions 
any one instance of netperf will have in-flight at any one time (eg 1, 
4, 16, 64, 256), and also the number of concurrent netperf processes 
going (eg 1, 2, 4, 8, 12, 24).  I do this with TCP_NODELAY set to try to 
guesstimate the maximum PPS

Rather than simply dump burst-size transactions into the connection at 
once, netperf will walk it up - first two transactions in flight, then 
after they complete, three, then four, all in a somewhat slow-start-ish 
way. I usually run this sort of test with TCP_NODELAY set to try to 
guesstimate the maximum PPS. (With the occasional sanity check against 
ethtool stats)

I did some of that testing just recently, from one system to two others 
via a 1 GbE link, all three systems running a 2.6.38 derived kernel 
(Ubuntu 11.04), and Intel 82576 chips running:

$ ethtool -i eth0
driver: igb
version: 2.1.0-k2
firmware-version: 1.8-2
bus-info: 0000:05:00.0

One of the things fixed recently in netperf (top-of-trunk, beyond 2.5.0) 
is I actually have reporting of per-connection TCP retransmissions 
working.  I was looking at that, and noticed a bunch of retransmissions 
at the 256 burst level with 24 concurrent netperfs.  I figured it was 
simple overload of say the switch or the one port active on the SUT (I 
do have one system talking to two, so perhaps some incast).  Burst 64 
had retrans as well.  Burst 16 and below did not.  That pattern repeated 
at 12 concurrent netperfs, and 8, and 4 and 2 and even 1 - yes, a single 
netperf aggregate TCP_RR test with a burst of 64 was reporting TCP 
retransmissions.  No incasting issues there.  The network was otherwise 
clean.

I went to try to narrow it down further:

# for b in 32 40 48 56 64 256; do ./netperf -t TCP_RR -l 30 -H 
mumble.181 -P 0 -- -r 1 -b $b -D -o 
throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,lsr_size_end,rss_size_end,rsr_size_end; 
done
206950.58,32,0,0,129280,87380,137360,87380
247000.30,40,0,0,121200,87380,137360,87380
254820.14,48,1,14,129280,88320,137360,87380
248496.06,56,33,35,125240,101200,121200,101200
278683.05,64,42,10,161600,114080,145440,117760
259422.46,256,2157,2027,133320,469200,137360,471040

and noticed the seeming correlation between the appearance of the 
retransmissions (columns 3 and 4) and the growth of the receive buffers 
(columns 6 and 8).  Certainly, there was never anywhere near 86K of 
*actual* data outstanding, but if the inbound DMA buffers were 2048 
bytes in size, 48 (49 actually, the "burst" is added to the one done by 
default) of them would fill 86KB - so would 40, but there is a race 
between netperf/netserver emptying the socket and packets arriving.

on a lark I set an explicit and larger socket buffer size:
# for b in 32 40 48 56 64 256; do ./netperf -t TCP_RR -l 30 -H 
mumble.181 -P 0 -- -s 128K -S 128K -r 1 -b $b -D -o 
throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,lsr_size_end,rss_size_end,rsr_size_end; 
done
201903.06,32,0,0,262144,262144,262144,262144
266204.05,40,0,0,262144,262144,262144,262144
253596.15,48,0,0,262144,262144,262144,262144
264811.65,56,0,0,262144,262144,262144,262144
254421.20,64,0,0,262144,262144,262144,262144
252563.16,256,4172,9677,262144,262144,262144,262144

poof, the retransmissions up through burst 64 are gone - though at 256 
they are quite high indeed.  Giving more space takes care of that:

# for b in 256; do ./netperf -t TCP_RR -l 30 -H 15.184.83.181 -P 0 -- -s 
1M -S 1M -r 1 -b $b -D -o 
throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,lsr_size_end,rss_size_end,rsr_size_end; 
done
248218.69,256,0,0,2097152,2097152,2097152,2097152

Is this simply a case of "Doctor! Doctor! It hurts when I do *this*!" 
"Well, don't do that!"  or does this suggest that perhaps the receive 
socket buffers aren't growing quite fast enough on inbound, and/or 
collapsing buffers isn't sufficiently effective?  It does seem rather 
strange that one could overfill the socket buffer with just that few 
data bytes.

happy benchmarking,

rick jones

BTW, if I make the MTU 9000 bytes on both sides, and go back to 
auto-tuning, only the burst 256 retransmissions remain, and the receive 
socket buffers don't grow until then either:

# for b in 32 40 48 56 64 256; do ./netperf -t TCP_RR -l 30 -H 
15.184.83.181 -P 0 -- -r 1 -b $b -D -o 
throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,lsr_size_end,rss_size_end,rsr_size_end; 
done
198724.66,32,0,0,28560,87380,28560,87380
242936.45,40,0,0,28560,87380,28560,87380
272157.95,48,0,0,28560,87380,28560,87380
283002.29,56,0,0,1009120,87380,1047200,87380
272489.02,64,0,0,971040,87380,971040,87380
277626.55,256,72,1285,971040,106704,971040,87696

And it would seem a great deal of the send socket buffer size growth 
goes away too.
