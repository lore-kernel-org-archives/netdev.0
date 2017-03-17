From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Ignore BUSY packets on old calls
Date: Thu, 16 Mar 2017 21:28:11 -0700 (PDT)
Message-ID: <20170316.212811.922027663786917489.davem@davemloft.net>
References: <148968163004.20909.2389917167977671935.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148968163004.20909.2389917167977671935.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 16 Mar 2017 16:27:10 +0000

> If we receive a BUSY packet for a call we think we've just completed, the
> packet is handed off to the connection processor to deal with - but the
> connection processor doesn't expect a BUSY packet and so flags a protocol
> error.
> 
> Fix this by simply ignoring the BUSY packet for the moment.
> 
> The symptom of this may appear as a system call failing with EPROTO.  This
> may be triggered by pressing ctrl-C under some circumstances.
> 
> This comes about we abort calls due to interruption by a signal (which we
> shouldn't do, but that's going to be a large fix and mostly in fs/afs/).
> What happens is that we abort the call and may also abort follow up calls
> too (this needs offloading somehoe).  So we see a transmission of something
> like the following sequence of packets:
> 
> 	DATA for call N
> 	ABORT call N
> 	DATA for call N+1
> 	ABORT call N+1
> 
> in very quick succession on the same channel.  However, the peer may have
> deferred the processing of the ABORT from the call N to a background thread
> and thus sees the DATA message from the call N+1 coming in before it has
> cleared the channel.  Thus it sends a BUSY packet[*].
> 
> [*] Note that some implementations (OpenAFS, for example) mark the BUSY
>     packet with one plus the callNumber of the call prior to call N.
>     Ordinarily, this would be call N, but there's no requirement for the
>     calls on a channel to be numbered strictly sequentially (the number is
>     required to increase).
> 
>     This is wrong and means that the callNumber in the BUSY packet should
>     be ignored (it really ought to be N+1 since that's what it's in
>     response to).
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
