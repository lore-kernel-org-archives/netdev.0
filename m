From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Mon, 27 Sep 2010 19:23:15 +0200
Message-ID: <20100927172315.GA8387@redhat.com>
References: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757074Ab0I0R3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 13:29:25 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 02:35:16PM -0700, Tom Herbert wrote:
> In this patch we propose to adds some socket API to retrieve the
>  "transmit completion sequence number", essentially a byte counter
> for the number of bytes that have been transmitted and will not be
> retransmitted.  In the case of TCP, this should correspond to snd_una.
> 
> The purpose of this API is to provide information to userspace about
> which buffers can be reclaimed when sending with vmsplice() on a
> socket.
> 
> There are two methods for retrieving the completed sequence number:
> through a simple getsockopt (implemented here for TCP), as well as
> returning the value in the ancilary data of a recvmsg.
> 
> The expected flow would be something like:
>    - Connect is created
>    - Initial completion seq # is retrieved through the sockopt, and is
>      stored in userspace "compl_seq" variable for the connection.
>    - Whenever a send is done, compl_seq += # bytes sent.
>    - When doing a vmsplice the completion sequence number is saved
>      for each user space buffer, buffer_compl_seq = compl_seq.
>    - When recvmsg returns with a completion sequence number in
>      ancillary data, any buffers cover by that sequence number
>      (where buffer_compl_seq < recvmsg_compl_seq) are reclaimed
>      and can be written to again.
>    - If no data is receieved on a connection (recvmsg does not
>      return), a timeout can be used to call the getsockopt and
>      reclaim buffers as a fallback.
> 
> Using recvmsg data in this manner is sort of a cheap way to get a
> "callback" for when a vmspliced buffer is consumed.  It will work
> well for a client where the response causes recvmsg to return.
> On the server side it works well if there are a sufficient
> number of requests coming on the connection (resorting to the
> timeout if necessary as described above).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> Signed-off-by: Sridhar Raman <sridharr@google.com>

Can not packets referencing this memory
still be outstanding at the NIC device, if retransmit happens
before the ack but after the packet was passed to a device?

It's true that the reftransmit will likely get discarded
by the remote end, but this might be a security issue
if an application puts sensitive data in the buffer
and that gets inadvertently sent on the wire, can it not?

-- 
MST
