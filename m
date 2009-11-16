From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Mon, 16 Nov 2009 19:08:19 +0200
Message-ID: <4B018703.3080507@redhat.com>
References: <4AF98A8C.9040201@novell.com>	<20091114011229.GA18580@gondor.apana.org.au>	<4AFE08EF.2030308@gmail.com> <20091113.190438.78469912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregory.haskins@gmail.com, herbert@gondor.apana.org.au,
	ghaskins@novell.com, mst@redhat.com,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753612AbZKPRIh@vger.kernel.org>
In-Reply-To: <20091113.190438.78469912.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2009 05:04 AM, David Miller wrote:
> From: Gregory Haskins<gregory.haskins@gmail.com>
> Date: Fri, 13 Nov 2009 20:33:35 -0500
>
>    
>> Well, not with respect to the overall protocol, of course not.  But with
>> respect to the buffer in question, it _has_ to be.  Or am I missing
>> something?
>>      
> sendfile() absolutely, and positively, is not.
>
> Any entity can write to the pages being send via sendfile(), at will,
> and those writes will show up in the packet stream if they occur
> before the NIC DMA's the memory backed by those pages into it's
> buffer.
>
> There is zero data synchronization whatsoever, we don't lock the
> pages, we don't block their usage while they are queued up in the
> socket send queue, nothing like that.
>
>    

But it must maintain a reference count on the page being dmaed and drop 
it only after dma is complete.  Otherwise we risk the page being 
recycled and arbitrary memory sent out on the wire; and an application 
can trivially cause this by truncate()ing a sendfile.

> The user returns long before it every hits the wire and there is zero
> "notification" to the user that the pages in question for the
> sendfile() request are no longer in use.
>    

The put_page() is a notification except it doesn't reach the caller.  
Gregory's patch (and previous shared info destructor patches) is an 
attempt to make it reach the caller, IIUC.

-- 
error compiling committee.c: too many arguments to function
