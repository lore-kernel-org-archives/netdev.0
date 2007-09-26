From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on	connected
 socket
Date: Wed, 26 Sep 2007 10:17:19 -0700
Message-ID: <46FA941F.2030804@hp.com>
References: <E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:50956 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753724AbXIZRRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 13:17:39 -0400
In-Reply-To: <E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
>>The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
>>describes an issue where write() can't be used to generate a zero-length
>>datagram (but send, and sendto do work).
>>
>>I think the following is needed:
>>
>>--- a/net/socket.c      2007-08-20 09:54:28.000000000 -0700
>>+++ b/net/socket.c      2007-09-24 15:31:25.000000000 -0700
>>@@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
>>       if (pos != 0)
>>               return -ESPIPE;
>>
>>-       if (iocb->ki_left == 0) /* Match SYS5 behaviour */
>>-               return 0;
>>+       if (unlikely(iocb->ki_left == 0)) {
>>+               struct socket *sock = iocb->ki_filp->private_data;
>>+               if (sock->type == SOCK_STREAM)
>>+                       return 0;
>>+       }
> 
> 
> I'm not sure whether all STREAM protocols treat zero-length
> sends as no-ops.  What about SCTP?

I asked Vlad that very question, since SCTP can preserve message 
boundaries. He tells me that a zero-length message is not part of SCTP.

rick jones
