From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Tue, 27 Sep 2016 10:44:04 +0200
Message-ID: <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
References: <20160922152831.24165-1-vbabka@suse.cz>
 <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
 <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com> <57E55CBB.5060309@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Alexander Viro' <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, 'Michal Hocko' <mhocko@kernel.org>,
        netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jason Baron <jbaron@akamai.com>,
        Nicholas Piggin <npiggin@gmail.com>,
        Hillf Danton <hillf.zj@alibaba-inc.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57E55CBB.5060309@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2016 06:47 PM, Jason Baron wrote:
> Hi,
>
> On 09/23/2016 03:24 AM, Nicholas Piggin wrote:
>> On Fri, 23 Sep 2016 14:42:53 +0800
>> "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:
>>
>>>>
>>>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>>>> with the number of fds passed. We had a customer report page allocation
>>>> failures of order-4 for this allocation. This is a costly order, so it might
>>>> easily fail, as the VM expects such allocation to have a lower-order fallback.
>>>>
>>>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>>>> physically contiguous. Also the allocation is temporary for the duration of the
>>>> syscall, so it's unlikely to stress vmalloc too much.
>>>>
>>>> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
>>>> it doesn't need this kind of fallback.
>>
>> How about something like this? (untested)

This pushes the limit further, but might just delay the problem. Could be an 
optimization on top if there's enough interest, though.

[...]

>> +
>> +		if (!(fds.in && fds.out && fds.ex &&
>> +				fds.res_in && fds.res_out && fds.res_ex))
>> +			goto out;
>> +	} else {
>> +		if (nr_bytes > sizeof(stack_fds)) {
>> +			/* Not enough space in on-stack array */
>> +			if (nr_bytes > PAGE_SIZE * 2)
>
> The 'if' looks extraneous?
>
> Also, I wonder if we can just avoid some allocations altogether by
> checking by if the user fd_set pointers are NULL? That can avoid failures :)

That would be a more major rewrite, as the core algorithm doesn't expect NULLs.

> Thanks,
>
> -Jason
>
