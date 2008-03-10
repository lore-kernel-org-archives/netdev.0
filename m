From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Mon, 10 Mar 2008 18:57:55 +0100
Message-ID: <47D576A3.1080503@trash.net>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI> <47CFF9B7.5060803@trash.net> <Pine.LNX.4.64.0803061612290.4202@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0803061618090.4378@sbz-30.cs.Helsinki.FI> <47D0014D.1060901@trash.net> <Pine.LNX.4.64.0803061640380.4820@sbz-30.cs.Helsinki.FI> <47D004DB.4010105@trash.net> <47D01277.9060807@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, clameter@sgi.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep25-int.chello.at ([62.179.121.45]:29796 "EHLO
	viefep25-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196AbYCJR6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 13:58:23 -0400
In-Reply-To: <47D01277.9060807@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka Enberg wrote:
> Hi Patrick,
> 
> Patrick McHardy wrote:
>> > I think you are misunderstanding ksize() (see mm/slub.c::ksize() for 
>> > example).
>>
>> The ksize() description in mm/slab.c matches exactly what netfilter
>> wants to do:
> 
> Agreed.
> 
> Patrick McHardy wrote:
>> The initial allocation size is calculated as max(size, min slab size)
>> and is stored as ext->alloc_size. When adding the first extension,
> 
> Yes, this part is correct, however...
> 
>> it allocates ext->alloc_size of memory and stores both the real amount
>> of space used (ext->len) and the actual size (ext->real_len).
>> When adding further extensions, it calculates the new total amount of
>> space needed (newlen). If that is larger than the real amount of
>> memory allocated (real_len), it reallocates.
> 
> ...looking at nf_ct_ext_create() you do:
> 
>         *ext = kzalloc(real_len, gfp);
>                        ^^^^^^^^
>         if (!*ext)
>                 return NULL;
> 
>         (*ext)->offset[id] = off;
>         (*ext)->len = len;
>         (*ext)->real_len = real_len;
>                            ^^^^^^^^
> 
> You are storing the _object size_ (total amount of memory requested) and 
> not the _buffer size_ (total amount of memory allocated). Keep in mind 
> that object size < buffer size and that ksize() returns the latter.


For all length <= minimum slab size alloc_size (and thus
real_len) is equal to the buffer size. You are correct
however that your patch is fine, I somehow misread the

+       if (newlen >= ksize(ct->ext)) {

part and thought you would always compare against the
minimum slab size.

I've queued your patch and will pass it upstream after
some testing, thanks.
