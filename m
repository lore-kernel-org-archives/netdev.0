From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Thu, 8 Jan 2009 00:59:36 +0300
Message-ID: <20090107215935.GB4610@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <20090107210758.GH3164@didacte.laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:50092 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762065AbZAGV7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 16:59:38 -0500
Content-Disposition: inline
In-Reply-To: <20090107210758.GH3164@didacte.laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 04:07:58PM -0500, Michael Stone (michael@laptop.org) wrote:
> First, thanks very much for all your comments and questions.

you are welcome :)

> >It isn't, since it can not set rlimit, and if it can, it still can drop
> >it.
> 
> Some sample code will probably clarify the use of my patch: 
> 
>   http://dev.laptop.org/git?p=users/mstone/test-rlimit-network;a=blob;f=disable_network.c;hb=HEAD
> 
> This C code describes a 'disable_network' exec-chain script which, when run 
> as
> any user, irrevocably disables network access as described in my previous
> emails. 
> 
> As you can see, processes start with full access to the 'network' resource 
> and
> may, at any time, irrevocably (modulo CAP_SYS_RESOURCE) limit their and 
> their
> future children's access to this resource by lowering both their soft and 
> hard
> limits to 0.

Argh, I see. That clarifies most questions indeed.

> >Your code does not cover sendpage() interface (aka splice() and
> >sendfile()) 
> 
> Nor should it. Applications should continue to be able to send data on any
> sockets where were already connected and should be able to accept new
> connections on sockets which were already bound.
> 
> I have done some primitive testing to ensure that the patch implements this
> functionality by means of the test utilities provided here:
> 
>  http://dev.laptop.org/git?p=users/mstone/test-rlimit-network;a=tree
> 
> Can you confirm my results?

Your patch adds a rlimit check into __sock_sendmsg() call, which is
invoked via usual send() path, but sendfile() and splice() are still
exectuted without this check and thus will be able to send data after
rlimit applied.

> >and with your approach application will suddenly stops sending data even 
> >into
> >old sockets, but will be able to receive it from anywhere. Is it 
> >intentional?
> 
> Why do you think this would happen? 
> 
> (My test results, e.g. via
>    http://dev.laptop.org/git?p=users/mstone/test-rlimit-network;a=blob;f=positive_localhost_tcp;hb=HEAD
>  show otherwise.)

I meant that connected or accepted socket will not be able to send data
via send() call, but will be able to receive data using recv().

-- 
	Evgeniy Polyakov
