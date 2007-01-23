From: Rick Jones <rick.jones2@hp.com>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 10:22:41 -0800
Message-ID: <45B65271.1040709@hp.com>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dean gaudet <dean@arctic.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:42842 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932939AbXAWSYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 13:24:08 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> dean gaudet <dean@arctic.org> wrote:
> 
>>in the test program below the getsockname result on a TCP socket changes 
>>across a write which produces EPIPE... here's a fragment of the strace:
>>
>>getsockname(3, {sa_family=AF_INET, sin_port=htons(37636), sin_addr=inet_addr("127.0.0.1")}, [17863593746633850896]) = 0
>>...
>>write(3, "hi!\n", 4)                    = 4
>>write(3, "hi!\n", 4)                    = -1 EPIPE (Broken pipe)
>>--- SIGPIPE (Broken pipe) @ 0 (0) ---
>>getsockname(3, {sa_family=AF_INET, sin_port=htons(59882), sin_addr=inet_addr("127.0.0.1")}, [16927060683038654480]) = 0
>>
>>why does the port# change?  this is on 2.6.19.1.
> 
> 
> Prior to the last write, the socket entered the CLOSED state meaning
> that the old port is no longer allocated to it.  As a result, the
> last write operates on an unconnected socket which causes a new local
> port to be allocated as an autobind.  It then fails because the socket
> is still not connected.
> 
> So any attempt to run getsockname after an error on the socket is
> simply buggy.

But falls within the principle of least surprise doesn't it?  Unless the 
application has called close() or bind(), it does seem like a reasonable 
expectation that the port assignments are not changed.

> (fwiw this is one of two reasons i've found for libnss-ldap to leak 
> sockets... causing nscd to crash.)

Of course, that seems rather odd too - why does libnss-ldap check the 
socket name on a socket after an EPIPE anyway?

rick jones
