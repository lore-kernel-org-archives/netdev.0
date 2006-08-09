From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Tue, 08 Aug 2006 17:09:41 -0700 (PDT)
Message-ID: <20060808.170941.71164303.davem@davemloft.net>
References: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
	<20060807.205910.68157131.davem@davemloft.net>
	<1155057591.26188.5.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29649
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030332AbWHIAJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:09:38 -0400
To: sri@us.ibm.com
In-Reply-To: <1155057591.26188.5.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 08 Aug 2006 10:19:51 -0700

> We cannot do this as xs_sendpages() doesn't like to use sendpage()
> with highmem pages and has the following check before making the
> actual call.
>                 /* Hmm... We might be dealing with highmem pages */
>                 if (PageHighMem(*ppage))
>                         sendpage = sock_no_sendpage;
>                 err = sendpage(sock, *ppage, base, len, flags);

The question is why doesn't it "like" highmem pages?

The kernel socket operation will handle highmem pages just fine and in
fact this sock_no_sendpage bit in xs_sendpages() has a negative
performance impact when it does trigger.

What's more this code is even worse than it appears at first, because
it will use sock_no_sendpage for _every_ page after the first highmem
one it sees.

I tried to figure out the origin of this highmem test.  It comes from
before all this code was moved from net/sunrpc/xdr.c into
net/sunrpc/xprtsock.c

Looking further in history, it even predates GIT :)

So I went through the pre-GIT history and it shows that this test was
there from the very beginning when xdr_sendpage and zerocopy sunrpc
support was added.

Trond, I think the highmem check in xs_sendpages() is completely
bogus, do you mind if we remove it? :-)

The socket layer will properly check the device to make sure it
can handle highmem pages, and if not it will copy the data into
a low-mem page as-needed.
