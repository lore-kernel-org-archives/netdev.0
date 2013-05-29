From: Rik van Riel <riel@redhat.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Wed, 29 May 2013 03:36:49 -0400
Message-ID: <51A5B011.7000101@redhat.com>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>  <51A39A3F.8080903@redhat.com> <1369693520.3301.477.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: atomlin@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	edumazet@google.com, pshelar@nicira.com, mst@redhat.com,
	alexander.h.duyck@intel.com, aquini@redhat.com,
	sergei.shtylyov@cogentembedded.com, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369693520.3301.477.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27/2013 06:25 PM, Eric Dumazet wrote:
> On Mon, 2013-05-27 at 13:39 -0400, Rik van Riel wrote:


>> Yes please. Getting memory management bug reports for
>> dropped network packets got old years ago.  Lets get
>> rid of those messages.
>
> I am only wondering why this path has anything needing special
> attention, over thousands of kmalloc() like call sites in the kernel.

There are a few special things about the network code:

1) network packets can arrive extremely fast, in
    large batches
2) the network code cannot wait for the VM to free
    memory (GFP_ATOMIC)

Other allocations tend to be done less at a time, and/or
allow the VM to free up memory before proceeding.

> If mm allocation warnings are useless, just make __GFP_NOWARN the
> default, and save us thousand of patches (adding the __GFP_NOWARN
> everywhere)
>
> Truth is : some network drivers don't deal very well with allocation
> errors. mlx4 for example absolutely wants order-2 pages in RX path, with
> no fallback to order-0 pages.

Network protocols and network applications tend to deal
with packet loss by retransmitting data, though.

Also, once all the data from one of those order-2 page
buffers has been delivered or forwarded, that buffer
becomes available to subsequent network packets.

Other allocations tend not to free & reuse their
memory as quickly as the network stack.

> So I am not against this patch, but I can not really acknowledge it,
> sorry.
>
>
>
