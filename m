From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test_bpf: fix sparse warnings
Date: Thu, 14 May 2015 10:18:28 -0700
Message-ID: <5554D8E4.50500@plumgrid.com>
References: <1431574839-7099-1-git-send-email-ast@plumgrid.com> <5554C8F7.5080002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36783 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030206AbbENRSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 13:18:30 -0400
Received: by igbpi8 with SMTP id pi8so172922918igb.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 10:18:30 -0700 (PDT)
In-Reply-To: <5554C8F7.5080002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/15 9:10 AM, Daniel Borkmann wrote:
> On 05/14/2015 05:40 AM, Alexei Starovoitov wrote:
>> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>>
>> Fix several sparse warnings like:
>> lib/test_bpf.c:1824:25: sparse: constant 4294967295 is so big it is long
>> lib/test_bpf.c:1878:25: sparse: constant 0x0000ffffffff0000 is so big
>> it is long
>>
>> Fixes: cffc642d93f9 ("test_bpf: add 173 new testcases for eBPF")
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>>   lib/test_bpf.c |  122
>> ++++++++++++++++++++++++++++----------------------------
>>   1 file changed, 61 insertions(+), 61 deletions(-)
>>
> ...
>>       {
>>           "ALU_MOV_K: 0x0000ffffffff0000 = 0x00000000ffffffff",
>>           .u.insns_int = {
>> -            BPF_LD_IMM64(R2, 0x0000ffffffff0000),
>> -            BPF_LD_IMM64(R3, 0x00000000ffffffff),
>> +            BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
>> +            BPF_LD_IMM64(R3, 0x00000000ffffffffLL),
>
> Should have been ULL, no?

why? The data type is derived from the value.
0xffff0000ffffffffLL is unsigned. GCC does the right thing. Here
we're just shutting up sparse.
I actually most of the time use LL as well since it's one character
shorter.

Ex:
  printf("%llx\n", 0xffff0000ffffffffLL >> 32);
  printf("%llx\n", 0xffff0000ffffffffULL >> 32);
  printf("%llx\n", ((long long)0xffff0000ffffffff) >> 32);
  printf("%llx\n", ((unsigned long long)0xffff0000ffffffff) >> 32);
will print:
  ffff0000
  ffff0000
  ffffffffffff0000
  ffff0000

I also think that sparse shouldn't be complaining about this.
The suffix is redundant.

> Anyway, the BPF_LD_IMM64() macro will cast it
> correctly anyway.

it's correct even without LL.
It's not a bugfix. It's 'mute the sparse' patch :)

> Other than that:
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
