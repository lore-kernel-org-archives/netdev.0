From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Wed, 20 May 2009 20:46:34 -0400
Message-ID: <20090521004634.GB29869@localhost.localdomain>
References: <20090520230652.GB5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57256 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbZEUAqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:46:42 -0400
Content-Disposition: inline
In-Reply-To: <20090520230652.GB5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 08:06:52PM -0300, Arnaldo Carvalho de Melo wrote:
> Meaning receive multiple messages, reducing the number of syscalls and
> net stack entry/exit operations.
> 
> Next patches will introduce mechanisms where protocols that want to
> optimize this operation will provide an unlocked_recvmsg operation.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Its a neat idea, I like the possibility on saving lots of syscalls for
busy sockets, but I imagine the addition of a new syscall gives people pause.  I
wonder if simply augmenting the existing recvmsg syscall with a message flag to
indicate that multiple messages can be received on that call.

What I would propose looks something like:

1) define a new flag in the msghdr pointer for msg_flags, MSG_COMPOUND.  Setting
this on the call lets the protocol we can store multiple messages

2) if this flag is set the msg_control pointer should contain a cmsghdr with a
new type MSG_COMPOUND_NEXT, in which the size is sizeof(void *) and the data
contains a pointer to the next msghdr pointer.

3) The kernel can iteratively fill out buffers passed in through the chain,
setting the MSG_COMPOUND flag on each msghdr that contains valid data.  The
first msghdr to not have the MSG_COMPOUND flag set denotes the last buffer that
the kernel put valid data in.  This way the buffer chain pointer is kept
unchanged, and userspace can follow it to free the data if need be.

Thoughts?

Neil

> 
