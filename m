From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 8 Nov 2013 18:39:40 +0100
Message-ID: <20131108173940.GA30013@order.stressinduktion.org>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com> <20131108130244.GE5876@order.stressinduktion.org> <1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com> <20131108142856.GA28330@order.stressinduktion.org> <1383923478.9412.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, tytso@mit.edu,
	linux-wireless@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58585 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757577Ab3KHRjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 12:39:42 -0500
Content-Disposition: inline
In-Reply-To: <1383923478.9412.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 08, 2013 at 07:11:18AM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 15:28 +0100, Hannes Frederic Sowa wrote:
> 
> > What do you think about using a timer to keep the reseed out of fast-path
> > and switch to the non-arch get_random_bytes instead?
> 
> Well, the initial seed value is get_random_bytes(). I felt that using a
> xor with the _arch() version would be safe enough.

Ted Ts'o talked about how we seed the prng on another mailing list. I
used his patch
<https://git.kernel.org/cgit/linux/kernel/git/tytso/random.git/patch/?id=392a546dc8368d1745f9891ef3f8f7c380de8650>
to demonstrate why I don't think get_random_bytes provides enough entropy
at that point so we can use it for port randomization.

He also raised the point that maybe the minstrel algorithm does slurp the
entropy too early and also too much, becasue it calls get_random_once
repeatedly [so I also added wireless to Cc]. It seems fine, but maybe
it could be changed to net_get_random_once, too. I have not found an
easy way to do that, yet. I just leave it here for discussion.

Using this patch my box starts up with this trace:

# dmesg | grep -i random:
[    0.000000] random: start_kernel+0x2c/0x44e get_random_bytes called with 0 bits of entropy available
[    0.078516] random: start_secondary+0x1e4/0x2e0 get_random_bytes called with 3 bits of entropy available
[    0.078516] random: cpu_startup_entry+0x24/0x410 get_random_bytes called with 3 bits of entropy available
[    0.096357] random: cpu_startup_entry+0x24/0x410 get_random_bytes called with 3 bits of entropy available
[    1.003745] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    1.010271] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    1.029952] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    1.034723] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    1.041257] random: rt_genid_init+0x2b/0x30 get_random_bytes called with 3 bits of entropy available
[    3.134969] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    3.147144] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    3.154366] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    3.159000] random: neigh_hash_alloc+0x8c/0xd0 get_random_bytes called with 3 bits of entropy available
[    3.173849] random: init_oops_id+0x35/0x40 get_random_bytes called with 3 bits of entropy available
[    3.185702] random: prandom_reseed+0x5a/0x9e get_random_bytes called with 3 bits of entropy available
[    3.191982] random: prandom_reseed+0x5a/0x9e get_random_bytes called with 3 bits of entropy available

I don't think this does look too good for initializing a PRNG. We
consider the entropy pool initialized when entropy_total reaches 128
bits of entropy (this is a not so large kernel config running in kvm).

IMHO we should be more conservative here.

Further output just FYI:

[    3.213113] random: random_int_secret_init+0x1a/0x20 get_random_bytes called with 3 bits of entropy available
[    3.342258] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 3 bits of entropy available
[    3.476120] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 4 bits of entropy available
[    3.611206] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 5 bits of entropy available
[    3.667358] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 5 bits of entropy available
[    3.734871] random: generate_random_uuid+0x17/0x40 get_random_bytes called with 5 bits of entropy available
[    3.757351] random: nl_portid_hash_rehash+0xa9/0x1c3 get_random_bytes called with 5 bits of entropy available
[    3.785217] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 5 bits of entropy available
[    3.831928] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 5 bits of entropy available
[    3.954606] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.021579] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.184380] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.212022] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.266360] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.349230] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.360435] random: nl_portid_hash_rehash+0xa9/0x1c3 get_random_bytes called with 6 bits of entropy available
[    4.503675] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.521476] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 6 bits of entropy available
[    4.730249] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    4.793874] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    4.853621] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    4.929740] random: nl_portid_hash_rehash+0xa9/0x1c3 get_random_bytes called with 7 bits of entropy available
[    5.004383] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    5.034793] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    5.268004] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    5.551956] random: __ipv6_regen_rndid+0x2d/0xc0 get_random_bytes called with 7 bits of entropy available

I put this on my todo list, too.

[    5.644543] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 7 bits of entropy available
[    5.676996] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 8 bits of entropy available
[    5.960995] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    5.974738] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    6.001795] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    6.018472] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    6.044597] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    6.091984] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    6.119498] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 13 bits of entropy available
[    6.212952] random: ext4_fill_super+0x1681/0x2f80 get_random_bytes called with 14 bits of entropy available
[    6.273980] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.274730] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.340308] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.420832] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.431657] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.440941] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.480322] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.494260] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.525949] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.582898] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.638663] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.675789] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 14 bits of entropy available
[    6.796919] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    6.816349] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    6.901432] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    6.969880] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    6.987195] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    7.030526] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    7.056945] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    7.060785] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[    7.227736] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 15 bits of entropy available
[   17.086529] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 122 bits of entropy available
[   17.105672] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 122 bits of entropy available
[   17.148562] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 122 bits of entropy available
[   17.152420] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 122 bits of entropy available
[   17.193339] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 122 bits of entropy available
[   17.193456] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 122 bits of entropy available
[   17.793175] random: load_elf_binary+0xad3/0x1890 get_random_bytes called with 126 bits of entropy available

> 
> For the timer, I do not think its worth the pain : Do you want a per cpu
> timer, or a global one ?

I would use a global one and just do the same thing as prandom_reseed. I
am not sure if we should discard the previous prng state.

IMHO reseeding must not take place very often.

> The unlikely() clause makes the test very small and test is well
> predicted.

I agree, this should not really hurt. I think your patch is fine and
added a fine safety net when we also reseed the prng after the
nonblocking_pool is fully available.

Greetings,

  Hannes
