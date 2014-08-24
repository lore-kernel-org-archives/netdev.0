From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sat, 23 Aug 2014 20:39:05 -0700
Message-ID: <CA+mtBx_FH07PTRS8Bbuh9QoWRNgiEFd2CjEtKa2XJwh1rb5CuQ@mail.gmail.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36106 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbaHXDjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 23:39:07 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so8022651ier.6
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2014 20:39:06 -0700 (PDT)
In-Reply-To: <20140823.132811.751469424156827125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2014 at 1:28 PM, David Miller <davem@davemloft.net> wrote:
>
>
> Over time, and specifically and more recently at the Networking
> Workshop during Kernel SUmmit in Chicago, we have discussed the idea
> of having some way to optimize transmits of multiple TX packets at
> a time.
>
> There are several areas of overhead that could be amortized with such
> schemes.  One has to do with locking and transactional overhead, the
> other has to do with device specific costs.
>
> This patch set here is more aimed at device specific costs.
>
> Typically a device queues up a packet in the TX queue and then has to
> do something to have the device start processing that new entry.
> Sometimes this is composed of doing an MMIO write to a "tail"
> register, and in other cases it can involve something as expensive as
> a hypervisor call.
>
> The basic setup defined here is that when the driver supports deferred
> TX queue flushing, ndo_start_xmit should no longer perform that
> operation.  Instead a new operation, ndo_xmit_flush, should do it.
>
Interesting, but I'm still wondering about MSG_MORE idea. If that is
passed with ndo_start_xmit than maybe a new ndo function might not be
needed. Also, since it's advisory, we could pass it to existing
drivers and let them decide how rather to do anything with it.

> I have converted IGB and virtio_net as example initial users.  The IGB
> conversion is tested, virtio_net is not but it does compile :-)
>
> All ndo_start_xmit call sites have been abstracted behind a new helper
> called netdev_start_xmit().
>
> This just adds the infrastructure, it does not actually add any
> instances of actually doing multiple ndo_start_xmit calls per
> ndo_xmit_flush invocation.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
