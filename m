From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: some failures with vxlan offloads..
Date: Tue, 28 Oct 2014 17:27:06 +0200
Message-ID: <544FB5CA.2060003@mellanox.com>
References: <544CF8E3.8070207@mellanox.com>	<CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>	<CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com> <CA+mtBx9g6MYpFv83av1YdRpZRBcBKvsqzSnhs5C7iV+kP8cWDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:42918 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751378AbaJ1P1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 11:27:12 -0400
In-Reply-To: <CA+mtBx9g6MYpFv83av1YdRpZRBcBKvsqzSnhs5C7iV+kP8cWDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2014 3:23 AM, Tom Herbert wrote:
> On Sun, Oct 26, 2014 at 3:23 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sun, Oct 26, 2014 at 5:29 PM, Tom Herbert <therbert@google.com> wrote:
>>> Can you determine what the TSO HW engine is setting in UDP checksum
>>> field? tcpdump -vv might be able to show this. The symptoms seem to
>>> indicate that it may not be zero.
>> Thanks for the quick response. I'll check what is placed in the UDP
>> checksum field for packets that went through the offloading HW and let
>> you know.
>>
>> BTW, if following the direction you proposed, I wonder why this works
>> (e.g the kernel doesn't drops the encapsulated TCP packets) when both
>> sides are offloaded?
>>
> I'm just speculating, but the device may be returning checksum unnecessary for the UDP checksum without actually checking it. Technically, VXLAN RFC7348 allows an implementation to ignore the UDP checksum, although this clearly violates RFC1122 UDP checksum
> requirements. In the stack we now checksum all non-zero checksums including UDP checksum in VXLAN if it's not marked checksum-unnecessary.

OK, I found something (it's always bad habit to try and potentially 
blame someone else for your bugs...) -- as I wrote here earlier, the 
current HW doesn't support checksum generation for both the inner (say 
TCP) and outer (UDP) packet (and indeed we don't advertize 
SKB_GSO_UDP_TUNNEL_CSUM).

So if we tell them to offload the inner TCP checksum we must **not** 
tell them to attempt and offload the outer checksum too, and I wrongly 
did that... once I stopped doing so, I get mixed configurations (one 
side offloaded the peer not offloaded) to work. I will submit mlx4 fix 
for that.

I wonder if we have another bug somewhere... when both sides were 
offloaded, it works even with the mlx4 bug, canyou explain that?is it 
possible that the GRO stack somehow covers on the bug when both sides 
are offloaded and GRO/VXLAN comes into play?

Or.

after the fix, packets sent by the offloaded side (192.168.31.17) carry 
zero udpchecksum

17:20:44.445866 IP (tos 0x0, ttl 64, id 61275, offset 0, flags [DF], 
proto UDP (17), length 1500)
     192.168.31.17.45387 > 192.168.31.18.4789: [no cksum] UDP, length 1472
         0x0000:  f452 1401 da82 0002 c9e9 bf32 0800 4500
         0x0010:  05dc ef5b 4000 4011 8641 c0a8 1f11 c0a8
         0x0020:  1f12 b14b 12b5 05c8 0000 0800 0000 0000
         0x0030:  6300 b2c7 81db e850 7a83 2ecb 8c68 0800
         0x0040:  4500 05aa bb84 4000 4006 9055 c0a8 3411
         0x0050:  c0a8 3412 e479 9116 553a e008 f28e 6268
         0x0060:  5010 0038 88e3 0000 6600 6e65 7470 6572
         0x0070:  6600 6e65 7470 6572 6600
17:20:44.445871 IP (tos 0x0, ttl 64, id 61276, offset 0, flags [DF], 
proto UDP (17), length 1500)
     192.168.31.17.45387 > 192.168.31.18.4789: [no cksum] UDP, length 1472
         0x0000:  f452 1401 da82 0002 c9e9 bf32 0800 4500
         0x0010:  05dc ef5c 4000 4011 8640 c0a8 1f11 c0a8
         0x0020:  1f12 b14b 12b5 05c8 0000 0800 0000 0000
         0x0030:  6300 b2c7 81db e850 7a83 2ecb 8c68 0800
         0x0040:  4500 05aa bb85 4000 4006 9054 c0a8 3411
         0x0050:  c0a8 3412 e479 9116 553a e58a f28e 6268
         0x0060:  5010 0038 7afc 0000 6e65 7470 6572 6600
         0x0070:  6e65 7470 6572 6600 6e65


before the fix, packets sent by the offloaded side (192.168.31.17) carry 
junkudpchecksum

Also note that on one of the packets sent by the offloaded part, we 
don't see the "bad udp cksum" scream from tcpdump, which is weird...

17:03:08.765845 IP (tos 0x0, ttl 64, id 52396, offset 0, flags [DF], 
proto UDP (17), length 746)
     192.168.31.17.56686 > 192.168.31.18.4789: UDP, length 718
         0x0000:  f452 1401 da82 0002 c9e9 bf32 0800 4500
         0x0010:  02ea ccac 4000 4011 abe2 c0a8 1f11 c0a8
         0x0020:  1f12 dd6e 12b5 02d6 0c1b 0800 0000 0000
         0x0030:  6300 b2c7 81db e850 7a83 2ecb 8c68 0800
         0x0040:  4500 02b8 6357 4000 4006 eb74 c0a8 3411
         0x0050:  c0a8 3412 86f2 3241 d67e f47d e5a9 d041
         0x0060:  5018 0038 871c 0000 0000 0258 ffff ffff
         0x0070:  0000 0000 0000 0000 0000
17:03:09.336285 IP (tos 0x0, ttl 64, id 52536, offset 0, flags [DF], 
proto UDP (17), length 90)
     192.168.31.17.56686 > 192.168.31.18.4789: [bad udp cksum 1360!] 
UDP, length 62
         0x0000:  f452 1401 da82 0002 c9e9 bf32 0800 4500
         0x0010:  005a cd38 4000 4011 ade6 c0a8 1f11 c0a8
         0x0020:  1f12 dd6e 12b5 0046 139a 0800 0000 0000
         0x0030:  6300 b2c7 81db e850 7a83 2ecb 8c68 0800
         0x0040:  4500 0028 6358 4000 4006 ee03 c0a8 3411
         0x0050:  c0a8 3412 86f2 3241 d67e f70d e5a9 d041
         0x0060:  5011 0038 897b 0000
17:03:10.335074 IP (tos 0x0, ttl 64, id 40045, offset 0, flags [DF], 
proto UDP (17), length 98)
     192.168.31.18.48861 > 192.168.31.17.4789: [no cksum] UDP, length 70
         0x0000:  0002 c9e9 bf32 f452 1401 da82 0800 4500
         0x0010:  0062 9c6d 4000 4011 dea9 c0a8 1f12 c0a8
         0x0020:  1f11 bedd 12b5 004e 0000 0800 0000 0000
         0x0030:  6300 7a83 2ecb 8c68 b2c7 81db e850 0800
         0x0040:  4500 0030 0000 4000 4006 5154 c0a8 3412
         0x0050:  c0a8 3411 3241 86f2 e5a9 d040 d67e f47d
         0x0060:  7012 6e28 f282 0000 0204 0582 0103 0307
17:03:10.335110 IP (tos 0x0, ttl 64, id 52764, offset 0, flags [DF], 
proto UDP (17), length 90)
     192.168.31.17.56686 > 192.168.31.18.4789: [bad udp cksum 1360!] 
UDP, length 62
         0x0000:  f452 1401 da82 0002 c9e9 bf32 0800 4500
         0x0010:  005a ce1c 4000 4011 ad02 c0a8 1f11 c0a8
         0x0020:  1f12 dd6e 12b5 0046 139a 0800 0000 0000
         0x0030:  6300 b2c7 81db e850 7a83 2ecb 8c68 0800
         0x0040:  4500 0028 6359 4000 4006 ee02 c0a8 3411
         0x0050:  c0a8 3412 86f2 3241 d67e f70e e5a9 d041
         0x0060:  5010 0038 897b 0000
