From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on connected
 socket
Date: Wed, 26 Sep 2007 14:47:18 -0400
Message-ID: <46FAA936.6040205@hp.com>
References: <E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:48626 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754797AbXIZSrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 14:47:41 -0400
In-Reply-To: <E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
>> The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
>> describes an issue where write() can't be used to generate a zero-length
>> datagram (but send, and sendto do work).
>>
>> I think the following is needed:
>>
>> --- a/net/socket.c      2007-08-20 09:54:28.000000000 -0700
>> +++ b/net/socket.c      2007-09-24 15:31:25.000000000 -0700
>> @@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
>>        if (pos != 0)
>>                return -ESPIPE;
>>
>> -       if (iocb->ki_left == 0) /* Match SYS5 behaviour */
>> -               return 0;
>> +       if (unlikely(iocb->ki_left == 0)) {
>> +               struct socket *sock = iocb->ki_filp->private_data;
>> +               if (sock->type == SOCK_STREAM)
>> +                       return 0;
>> +       }
> 
> I'm not sure whether all STREAM protocols treat zero-length
> sends as no-ops.  What about SCTP?

0 byte writes are not allowed in SCTP.  A no-op is fine, otherwise
SCTP would return an error.

-vlad

> 
> Put it another way, do we really need to keep the short-circuit
> for SOCK_STREAM?
> 
> Cheers,

