From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv4 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook in xfrm_input()
Date: Wed, 06 Oct 2010 23:42:40 +0200
Message-ID: <87sk0jknfz.fsf@small.ssi.corp>
References: <cover.1286139128.git.arno@natisbad.org>
	<db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org>
	<20101004084041.GB17939@gondor.apana.org.au>
	<87vd5h7kbh.fsf@small.ssi.corp>
	<20101005062732.GA27337@gondor.apana.org.au>
	<878w2cfcd1.fsf@small.ssi.corp>
	<20101006012509.GA3540@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:36637 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933169Ab0JFVlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 17:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Wed, Oct 06, 2010 at 01:28:42AM +0200, Arnaud Ebalard wrote:
>>
>>  1) First, current net-next-2.6 (no patches applied)
>>  2) then, with my patches applied and CONFIG_XFRM_SUB_POLICY enabled
>>  3) then, with my patches applied and CONFIG_XFRM_SUB_POLICY disabled
>
> To measure the effect of this properly you should use null
> encryption/hashing and look at the CPU utilisation with minimum
> packet sizes.

I did that w/ the following kernels on the receiver (same as before):

 - kernel 1: w/o patches (net-next-2.6)
 - kernel 2: patches applied w/ CONFIG_XFRM_SUB_POLICY
 - kernel 3: patches applied w/o CONFIG_XFRM_SUB_POLICY

5 runs of sending 1073741824 bytes over TCP protected using ESP (null
enc and null auth) in transport mode, forcing small packets:

dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x <v4orv6dst> 1234 

5 runs for each kernel for IPv4 and IPv6. I keep only the 3 central
values provided by dd indicating the completion of the emission (remove
highest and smallest) and do an average w/ those 3 values: 

              IPv4          IPv6
kernel 1    70.0815s      72.4843s
kernel 2    69.8335s      72.3462s
kernel 3    69.9758s      72.3588s

I used the exact same method for the tests for the 3 cases (reboot,
started the test, nothing else running). I am unable to explain why it's
longer for the test to complete with an unpatched kernel but this is
what I get. Maybe it is just an artefact and the impact is just simply
too small to be mesured. Anyway, the whole set of results are at the end
of the email. 


>> > With your remapping, would it be possible to add dummy xfrm_state
>> > objects with the remapped destination address that could then call
>> > xfrm6_input_addr?
>> >
>> > That way normal IPsec users would not be affected at all while
>> > preserving your new functionality.
>> 
>> I don't think I can do that easily (at all?) with what XFRM provides,
>> can I? Or at least I don't see how it is possible because I would need
>> some kind of policy for the state to be applied and the only trigger I
>> see is the src/dst address mismatch when processing the IPsec packet.
>
> So do you know the remapped destination addresses a priori?

I have both the HoA and the CoA (this is x->coaddr in my state. '::' is
allowed if I want to allow anything), but the appplication of the state
needs to be done for traffic meant for the HoA and not blindly for all
the IPsec traffic received with the CoA (as source or destination).

it's not possible to just blindly remap things based on the on-wire
address and the fact it is IPsec traffic. For instance, if some tunnel
mode IPsec traffic between a MN and its HA is used in parallel, I cannot
remap the CoA from received packets on the MN to the HoA.

That's the reason why the lookup is done via something stable (i.e. the
HoA) which is derived from the SPI during SA lookup. 


> If not then then other possibility would be to add the code hook
> in case of xfrm_state_lookup failure.

This would work for destination address. But it has the drawback of
requiring a first lookup (guaranteed to fail if destination remapping
for the feature) and then a second (somehow w/o using the destination
address). Source check would still be done in all cases.


> But more importantly you need to solve the hash collission issue
> that I mentioned earlier.  Without that it won't work at all.

You are correct. The fact that the byspi hash table contains all states
(for in and out traffic) and that the state lookup does not involve the
direction but only the destination address (damn, the one I remove ;-))
is a real issue. It just makes the state lookup unreliable when I pass
NULL as daddr for incoming traffic. Thanks for pointing that.

I don't see any good solution yet (state have no direction) but I will
definitely focus on that issue and spend some time on it tomorrow.

Cheers,

a+

The full set of results for the tests:

* kernel 1

$ dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x 192.168.0.14 1234
1073741824 bytes (1.1 GB) copied, 70.0393 s, 15.3 MB/s
1073741824 bytes (1.1 GB) copied, 70.2442 s, 15.3 MB/s
1073741824 bytes (1.1 GB) copied, 70.1995 s, 15.3 MB/s
1073741824 bytes (1.1 GB) copied, 70.0057 s, 15.3 MB/s
1073741824 bytes (1.1 GB) copied, 69.9887 s, 15.3 MB/s

$ dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x fdff::1 1234 
1073741824 bytes (1.1 GB) copied, 72.5605 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 72.9725 s, 14.7 MB/s
1073741824 bytes (1.1 GB) copied, 72.3099 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 72.435 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 72.4573 s, 14.8 MB/s

* kernel 2

$ dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x 192.168.0.14 1234
1073741824 bytes (1.1 GB) copied, 69.6845 s, 15.4 MB/s
1073741824 bytes (1.1 GB) copied, 69.9419 s, 15.4 MB/s
1073741824 bytes (1.1 GB) copied, 69.8615 s, 15.4 MB/s
1073741824 bytes (1.1 GB) copied, 70.0142 s, 15.3 MB/s
1073741824 bytes (1.1 GB) copied, 69.6970 s, 15.4 MB/s

$ dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x fdff::1 1234 
1073741824 bytes (1.1 GB) copied, 72.4252 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 71.5411 s, 15.0 MB/s
1073741824 bytes (1.1 GB) copied, 72.2388 s, 14.9 MB/s
1073741824 bytes (1.1 GB) copied, 72.3745 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 72.6553 s, 14.8 MB/s

* kernel 3

$ dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x 192.168.0.14 1234
1073741824 bytes (1.1 GB) copied, 69.8569 s, 15.4 MB/s
1073741824 bytes (1.1 GB) copied, 70.4445 s, 15.2 MB/s
1073741824 bytes (1.1 GB) copied, 69.8989 s, 15.4 MB/s
1073741824 bytes (1.1 GB) copied, 70.0238 s, 15.3 MB/s
1073741824 bytes (1.1 GB) copied, 70.0047 s, 15.3 MB/s

$ dd if=/dev/zero bs=1024 count=1048576 | nc --mtu=100 -x fdff::1 1234 
1073741824 bytes (1.1 GB) copied, 72.4677 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 72.2757 s, 14.9 MB/s
1073741824 bytes (1.1 GB) copied, 72.2261 s, 14.9 MB/s
1073741824 bytes (1.1 GB) copied, 72.3331 s, 14.8 MB/s
1073741824 bytes (1.1 GB) copied, 72.8262 s, 14.7 MB/s

