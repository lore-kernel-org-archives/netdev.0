From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Mon, 04 Aug 2014 11:48:33 +0200
Message-ID: <53DF56F1.4020701@redhat.com>
References: <1406837476-13776-1-git-send-email-dborkman@redhat.com> <20140731.222804.1403723639172562683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	akinobu.mita@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbaHDJsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2014 05:48:46 -0400
In-Reply-To: <20140731.222804.1403723639172562683.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Cc'ing Akinobu, 6582c665d6b882 ("prandom: introduce prandom_bytes()
   and prandom_bytes_state()") ]

On 08/01/2014 07:28 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 31 Jul 2014 22:11:16 +0200
>
>> -		for (j = 0; j < sizeof(u32); j++) {
>> -			p[i + j] = random;
>> -			random >>= BITS_PER_BYTE;
>> -		}
>> +	while (bytes > sizeof(u32)) {

[ Should have been >= here, missed that earlier. ]

>> +		put_unaligned(prandom_u32_state(state), (u32 *) ptr);
>> +		ptr += sizeof(u32);
>> +		bytes -= sizeof(u32);
>>   	}
>> -	if (i < bytes) {
>> -		u32 random = prandom_u32_state(state);
>>
>> -		for (; i < bytes; i++) {
>> -			p[i] = random;
>> -			random >>= BITS_PER_BYTE;
>> -		}
>> +	if (bytes > 0) {
>> +		u32 rem = prandom_u32_state(state);
>> +		do {
>> +			*ptr++ = (u8) rem;
>> +			bytes--;
>> +			rem >>= BITS_PER_BYTE;
>> +		} while (bytes > 0);
>>   	}
>
> This conversion to put_unaligned() is not an equivalent depending
> upon the endianness of the cpu.
>
> And this means the random value gets distributed differently into
> full words than it will into trailing bytes.
>
> Let's just not mess around with this, ok?

Sorry for the late answer, Dave.

So for the case of callers of prandom_bytes() which internally
invoke prandom_bytes_state(), it doesn't matter at all since, well,
they expect the array to be filled randomly and don't have any
control of the internal state anyway (that's also why we have
periodic reseeding there, etc), so they really don't care.

Now for the direct callers of prandom_bytes_state(), which are
solely located in drivers/mtd/tests/{oobtest.c, pagetest.c,
subpagetest.c}:

These tests basically fill a test write-vector through prandom_bytes_state()
with an a-priori defined seed each time and write that to a MTD
device.

Later on, they set up a read-vector and read back that blocks from
the device. So in the verification phase, the write-vector is being
re-setup [ so same seed and prandom_bytes_state() called ], and then
memcmp()'ed against the read-vector to check if the data is the same.

Akinobu and I also tested this patch with the above fix included,
and it runs through the 3 relevant test cases _without_ any errors
on the nandsim device (simulator for MTD devs):

# modprobe nandsim first_id_byte=0x20 second_id_byte=0xac \
                    third_id_byte=0x00 fourth_id_byte=0x15
# modprobe mtd_oobtest dev=0
# modprobe mtd_pagetest dev=0
# modprobe mtd_subpagetest dev=0

[ ... 'finished with 0 errors' each in klog ]

We also don't have any users depending directly on a particular
result of the PRNG (except the PRNG self-test itself), and that's
just fine as it e.g. allowed us easily to do things like upgrading
from taus88 to taus113.

Thanks,

Daniel
