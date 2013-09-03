From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ppc: bpf_jit: support MOD operation
Date: Tue, 03 Sep 2013 22:52:29 +0200
Message-ID: <52264C0D.3000409@redhat.com>
References: <1377643792-10327-1-git-send-email-murzin.v@gmail.com> <20130902174842.GA1866@hp530> <1378154750.3978.43.camel@pasglop> <20130903195819.GA1971@hp530>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, paulus@samba.org,
	davem@davemloft.net, Matt Evans <matt@ozlabs.org>,
	netdev <netdev@vger.kernel.org>
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760506Ab3ICUwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 16:52:45 -0400
In-Reply-To: <20130903195819.GA1971@hp530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 09:58 PM, Vladimir Murzin wrote:
> On Tue, Sep 03, 2013 at 06:45:50AM +1000, Benjamin Herrenschmidt wrote:
>> On Mon, 2013-09-02 at 19:48 +0200, Vladimir Murzin wrote:
>>> Ping
>>>
>>> On Wed, Aug 28, 2013 at 02:49:52AM +0400, Vladimir Murzin wrote:
>>>> commit b6069a9570 (filter: add MOD operation) added generic
>>>> support for modulus operation in BPF.
>>>>
>> Sorry, nobody got a chance to review that yet. Unfortunately Matt
>> doesn't work for us anymore and none of us has experience with the
>> BPF code, so somebody (possibly me) will need to spend a bit of time
>> figuring it out before verifying that is correct.
>>
>> Do you have a test case/suite by any chance ?
>>
>> Ben.
>>
>
> Hi Ben!
>
> Thanks for your feedback.
>
> This patch is only compile tested. I have no real hardware, but I'll
> probably bring up qemu ppc64 till end of the week...
> Meanwhile, I've made simple how-to for testing. You can use it if you wish.
> It is mainly based on the [1] and rechecked on x86-64.

Please also cc netdev on BPF related changes.

Actually, your test plan can be further simplified ...

For retrieving and disassembling the JIT image, we have bpf_jit_disasm [1].

  1) echo 2 > /proc/sys/net/core/bpf_jit_enable
  2) ... attach filter ...
  3) bpf_jit_disasm -o

For generating a simple stupid test filter, you can use bpfc [2] (also
see its man page). E.g. ...

   # cat blub
   ldi #10
   mod #8
   ret a
   # bpfc blub
   { 0x0, 0, 0, 0x0000000a },
   { 0x94, 0, 0, 0x00000008 },
   { 0x16, 0, 0, 0x00000000 },

And load this array e.g. either into a small C program that attaches this
as BPF filter, or simply do bpfc blub > blub2 and run netsniff-ng -f blub2\
-s -i eth0, that should also do it.

Then, when attached, the kernel should truncate incoming frames for pf_packet
into max length of 2, just as an example.

   [1] kernel tree, tools/net/bpf_jit_disasm.c
   [2] git clone git://github.com/borkmann/netsniff-ng.git

> 1. get the tcpdump utility (git clone git://bpf.tcpdump.org/tcpdump)
> 2. get the libcap library (git clone git://bpf.tcpdump.org/libpcap)
> 2.1. apply patch for libcap [2] (against libcap-1.3 branch)
> 2.2. build libcap (./configure && make && ln -s libcap.so.1.3.0 libcap.so)
> 3. build tcpdump (LDFLAGS="-L/path/to/libcap" ./configure && make)
> 4. run
>
> # ./tcpdump -d "(ip[2:2] - 20) % 5 != 0 && ip[6] & 0x20 = 0x20"
> (000) ldh [14]
> (001) jeq #0x800 jt 2 jf 10
> (002) ldh [18]
> (003) sub #20
> (004) mod #5
> (005) jeq #0x0 jt 10 jf 6
> (006) ldb [22]
> (007) and #0x20
> (008) jeq #0x20 jt 9 jf 10
> (009) ret #65535
> (010) ret #0
>
> to get pseudo code (we are interested the most into line #4)
>
> 5. enable bpf jit compiler
>
> # echo 2 > /proc/sys/net/core/bpf_jit_enable
>
> 6. run
>
> ./tcpdump -nv "(ip[2:2] - 20) % 5 != 0 && ip[6] & 0x20 = 0x20"
>
> 7. check dmesg for lines starting with (output for x86-64 is provided as an example)
>
> [ 3768.329253] flen=11 proglen=99 pass=3 image=ffffffffa003c000
> [ 3768.329254] JIT code: ffffffffa003c000: 55 48 89 e5 48 83 ec 60 48 89 5d f8 44 8b 4f 60
> [ 3768.329255] JIT code: ffffffffa003c010: 44 2b 4f 64 4c 8b 87 c0 00 00 00 0f b7 47 76 86
> [ 3768.329256] JIT code: ffffffffa003c020: c4 3d 00 08 00 00 75 37 be 02 00 00 00 e8 9f 3e
> [ 3768.329257] JIT code: ffffffffa003c030: 02 e1 83 e8 14 31 d2 b9 05 00 00 00 f7 f1 89 d0
> [ 3768.329258] JIT code: ffffffffa003c040: 85 c0 74 1b be 06 00 00 00 e8 9f 3e 02 e1 25 20
> [ 3768.329259] JIT code: ffffffffa003c050: 00 00 00 83 f8 20 75 07 b8 ff ff 00 00 eb 02 31
> [ 3768.329259] JIT code: ffffffffa003c060: c0 c9 c3
>
> 8. make sure generated opcodes (JIT code) implement pseudo code form step 4.
>
> Reference
> [1] http://comments.gmane.org/gmane.linux.network/242456
> [2] http://permalink.gmane.org/gmane.network.tcpdump.devel/5973
>
> P.S.
> I hope net people will corect me if I'm wrong there
>
> Cheers
> Vladimir Murzin
>
>>>> This patch brings JIT support for PPC64
>>>>
>>>> Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
