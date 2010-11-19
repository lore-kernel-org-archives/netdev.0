From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 14:47:01 -0800
Message-ID: <4CE6FE65.9040302@hp.com>
References: <4CE6ED09.70602@hp.com>	<20101119.135213.15239226.davem@davemloft.net>	<4CE6F2FD.8080301@hp.com> <20101119.140818.242132853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:26210 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755371Ab0KSWrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 17:47:03 -0500
In-Reply-To: <20101119.140818.242132853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 19 Nov 2010 13:58:21 -0800
> 
> 
>>David Miller wrote:
>>
>>>From: Rick Jones <rick.jones2@hp.com>
>>>Date: Fri, 19 Nov 2010 13:32:57 -0800
>>>
>>>
>>>>I suppose then one would be able to track the consumer pointer (on tx)
>>>>to "know" that certain data had been ACKed by the remote?  For TCP
>>>>anyway - and assuming there wouldn't be a case where TCP might copy
>>>>the data out of the ring and assert "completion."
>>>
>>>Yes, that's implicit in his design, the kernel manages the consumer
>>>pointer in the ring and this is how userspace can see when ring
>>>entries
>>>are reusable.
>>
>>But does one really want to lock-in that the update to the consumer
>>pointer means the data has been ACKed by the remote (or I suppose that
>>DMA have completed if it were UDP)?
> 
> 
> I think the ACK (or for UDP, the kfree_skb() after TX completes) should
> move the consumer pointer.  Otherwise you have to copy, and the ACKs
> do not clock the sender process properly.

I'm not worried about the ACK/kfree_skb() moving the pointer.  I'm simply 
worried about what the application should infer from the pointer's movement. 
That is, if the design is documented  "Movement of the consumer pointer implies 
that the corresponding data has been ACKed by the remote TCP" that is locking 
the design into a semantic I don't know that it will always want to maintain, 
because there may end-up being some cases where the stack might indeed want to 
copy and so not maintain that "pointer update means the remote TCP has the data" 
semantic.

> But you do bring up an interesting point about TX buffer space sizing.
> 
> This whole scheme currently seems to completely ignore buffer size
> auto-tuning done by TCP, and that won't fly I think. :-)
> 
> The whole point is to make it so that applications do not need to know
> about that aspect of buffering at all.  With the current mmap design
> we're back to the stone ages where the app essentially has to pick an
> explicit send buffer size.

In some ways, the stone ages were nicer :)

What if... :)  the stack had a way to communicate to the application that it 
wanted to change the effective socket buffer size?  If that is indeed 
sufficiently infrequent, perhaps a "signal the new size and the app does a fresh 
mmap()" mechanism would suffice. The app would, I presume need to first wait for 
the existing ring to drain, which could cause some complications I suppose.  Is 
there a way to flip the sense and have the kernel allocate the ring(s) and 
communicate that to the application?

But doesn't the whole idea of having an explicitly mmap()ed area of memory fly 
in the face of autotuning to begin with?  (Mind you, I've not always been a fan 
of autotuning as some of my previous "Why is it growing the window so large?!?" 
will attest :)  It is suggesting that the application has some "communications 
memory" (that it won't be itself copying to/from) and presumably knows or thinks 
it knows how much of that it needs.  For all we know, Tom is thinking that this 
mmap()ed region of memory will be rather larger than the maximum autotuned 
socket buffer sizes in the first place.  Going back to his initial email I don't 
see anything that explicitly describes the relationship between the size of this 
mmap()'ed region and the socket buffer sizes - I was just ass-u-me-ing it would 
set them.  Sure, it would have to be an effective upper bound for copy-less 
transmit and receive, but there is nothing that says the windows TCP is using 
have to be that large.

rick
