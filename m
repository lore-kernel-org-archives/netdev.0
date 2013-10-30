From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Wed, 30 Oct 2013 09:22:13 -0400
Message-ID: <52710805.10209@redhat.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com> <20131030110214.GA10220@localhost.localdomain> <AE90C24D6B3A694183C094C60CF0A2F6026B73C5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73C5@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2013 08:18 AM, David Laight wrote:
>> /me wonders if rearranging the instructions into this order:
>> adcq 0*8(src), res1
>> adcq 1*8(src), res2
>> adcq 2*8(src), res1
>
> Those have to be sequenced.
>
> Using a 64bit lea to add 32bit quantities should avoid the
> dependencies on the flags register.
> However you'd need to get 3 of those active to beat a 64bit adc.
>
> 	David
>
>
>

Already done (well, something similar to what you mention above anyway), 
doesn't help (although doesn't hurt either, even though it doubles the 
number of adds needed to complete the same work).  This is the code I 
tested:

#define ADDL_64                                         \
         asm("xorq  %%r8,%%r8\n\t"                       \
             "xorq  %%r9,%%r9\n\t"                       \
             "xorq  %%r10,%%r10\n\t"                     \
             "xorq  %%r11,%%r11\n\t"                     \
             "movl  0*4(%[src]),%%r8d\n\t"               \
             "movl  1*4(%[src]),%%r9d\n\t"               \
             "movl  2*4(%[src]),%%r10d\n\t"              \
             "movl  3*4(%[src]),%%r11d\n\t"              \
             "addq  %%r8,%[res1]\n\t"                    \
             "addq  %%r9,%[res2]\n\t"                    \
             "addq  %%r10,%[res3]\n\t"                   \
             "addq  %%r11,%[res4]\n\t"                   \
             "movl  4*4(%[src]),%%r8d\n\t"               \
             "movl  5*4(%[src]),%%r9d\n\t"               \
             "movl  6*4(%[src]),%%r10d\n\t"              \
             "movl  7*4(%[src]),%%r11d\n\t"              \
             "addq  %%r8,%[res1]\n\t"                    \
             "addq  %%r9,%[res2]\n\t"                    \
             "addq  %%r10,%[res3]\n\t"                   \
             "addq  %%r11,%[res4]\n\t"                   \
             "movl  8*4(%[src]),%%r8d\n\t"               \
             "movl  9*4(%[src]),%%r9d\n\t"               \
             "movl  10*4(%[src]),%%r10d\n\t"             \
             "movl  11*4(%[src]),%%r11d\n\t"             \
             "addq  %%r8,%[res1]\n\t"                    \
             "addq  %%r9,%[res2]\n\t"                    \
             "addq  %%r10,%[res3]\n\t"                   \
             "addq  %%r11,%[res4]\n\t"                   \
             "movl  12*4(%[src]),%%r8d\n\t"              \
             "movl  13*4(%[src]),%%r9d\n\t"              \
             "movl  14*4(%[src]),%%r10d\n\t"             \
             "movl  15*4(%[src]),%%r11d\n\t"             \
             "addq  %%r8,%[res1]\n\t"                    \
             "addq  %%r9,%[res2]\n\t"                    \
             "addq  %%r10,%[res3]\n\t"                   \
             "addq  %%r11,%[res4]"                       \
             : [res1] "=r" (result1),                    \
               [res2] "=r" (result2),                    \
               [res3] "=r" (result3),                    \
               [res4] "=r" (result4)                     \
             : [src] "r" (buff),                         \
               "[res1]" (result1), "[res2]" (result2),   \
               "[res3]" (result3), "[res4]" (result4)    \
             : "r8", "r9", "r10", "r11" )
