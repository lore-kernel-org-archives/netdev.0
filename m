From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Thu, 06 Mar 2008 15:51:07 +0100
Message-ID: <47D004DB.4010105@trash.net>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI> <47CFF9B7.5060803@trash.net> <Pine.LNX.4.64.0803061612290.4202@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0803061618090.4378@sbz-30.cs.Helsinki.FI> <47D0014D.1060901@trash.net> <Pine.LNX.4.64.0803061640380.4820@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, clameter@sgi.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0803061640380.4820@sbz-30.cs.Helsinki.FI>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka J Enberg wrote:
> On Thu, 6 Mar 2008, Patrick McHardy wrote:
>> It decides to reallocate when the remaining space isn't enough
>> to hold the new data. NF_CT_EXT_MIN_SIZE is used to make sure it
>> doesn't allocate anything smaller than the minimum slab size and
>> hopefully avoid reallocations in the future. Unless I'm
>> misunderstanding what ksize() does, the easiest way to get
>> rid of this would be to replace NF_CT_EXT_MIN_SIZE by ksize(0).
> 
> I think you are misunderstanding ksize() (see mm/slub.c::ksize() for 
> example).

The ksize() description in mm/slab.c matches exactly what netfilter
wants to do:

  * kmalloc may internally round up allocations and return more memory
  * than requested. ksize() can be used to determine the actual amount 
of
  * memory allocated. The caller may use this additional memory, even though
  * a smaller amount of memory was initially specified with the kmalloc 
call.

> Furthermore, I think your current reallocation code is broken 
> too as explained in a previous mail and my patch fixes that to behave as 
> krealloc() does.

I don't think there is anything broken with that code.

The initial allocation size is calculated as max(size, min slab size)
and is stored as ext->alloc_size. When adding the first extension,
it allocates ext->alloc_size of memory and stores both the real amount
of space used (ext->len) and the actual size (ext->real_len).
When adding further extensions, it calculates the new total amount of
space needed (newlen). If that is larger than the real amount of
memory allocated (real_len), it reallocates.

What am I missing here?

