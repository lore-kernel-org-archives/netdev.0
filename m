From: Avi Kivity <avi@redhat.com>
Subject: Re: copyless virtio net thoughts?
Date: Fri, 06 Feb 2009 10:46:37 +0200
Message-ID: <498BF8ED.8090208@redhat.com>
References: <20090205020732.GA27684@sequoia.sous-sol.org> <498ADD73.3060906@redhat.com> <20090206054054.GA4824@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>, Arnd Bergmann <arnd@arndb.de>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40178 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbZBFIqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 03:46:32 -0500
In-Reply-To: <20090206054054.GA4824@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Feb 05, 2009 at 02:37:07PM +0200, Avi Kivity wrote:
>   
>> I believe that copyless networking is absolutely essential.
>>     
>
> I used to think it was important, but I'm now of the opinion
> that it's quite useless for virtualisation as it stands.
>
>   
>> For transmit, copyless is needed to properly support sendfile() type  
>> workloads - http/ftp/nfs serving.  These are usually high-bandwidth,  
>> cache-cold workloads where a copy is most expensive.
>>     
>
> This is totally true for baremetal, but useless for virtualisation
> right now because the block layer is not zero-copy.  That is, the
> data is going to be cache hot anyway so zero-copy networking doesn't
> buy you much at all.
>   

The guest's block layer is copyless.  The host block layer is -><- this 
far from being copyless -- all we need is preadv()/pwritev() or to 
replace our thread pool implementation in qemu with linux-aio.  
Everything else is copyless.

Since we are actively working on this, expect this limitation to 
disappear soon.

(even if it doesn't, the effect of block layer copies is multiplied by 
the cache miss percentage which can be quite low for many workloads; but 
again, we're not bulding on that)
> Please also recall that for the time being, block speeds are
> way slower than network speeds.  So the really interesting case
> is actually network-to-network transfers.  Again due to the
> RX copy this is going to be cache hot.
>   

Block speeds are not way slower.  We're at 4Gb/sec for Fibre and 10Gb/s 
for networking.  With dual channels or a decent cache hit rate they're 
evenly matched.

>> For receive, the guest will almost always do an additional copy, but it  
>> will most likely do the copy from another cpu.  Xen netchannel2  
>>     
>
> That's what we should strive to avoid.  The best scenario with
> modern 10GbE NICs is to stay on one CPU if at all possible.  The
> NIC will pick a CPU when it delivers the packet into one of the
> RX queues and we should stick with it for as long as possible.
>
> So what I'd like to see next in virtualised networking is virtual
> multiqueue support in guest drivers.  No I'm not talking about
> making one or more of the physical RX/TX queues available to the
> guest (aka passthrough), but actually turning something like the
> virtio-net interface into a multiqueue interface.
>   

I support this, but it should be in addition to copylessness, not on its 
own.

- many guests will not support multiqueue
- for some threaded workloads, you cannot predict where the final read() 
will come from; this renders multiqueue ineffective for keeping cache 
locality
- usually you want virtio to transfer large amounts of data; but if you 
want your copies to be cache-hot, you need to limit transfers to half 
the cache size (a quarter if hyperthreading); this limits virtio 
effectiveness


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

