From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Tue, 14 Feb 2017 22:08:10 +0000
Message-ID: <6d605909-b049-9a8d-05a9-32b715c30527@solarflare.com>
References: <20170208234127.3041579-1-tom@herbertland.com>
 <20170208234127.3041579-2-tom@herbertland.com>
 <20170214213157.32e37148@redhat.com>
 <CALx6S34mpo+Q_gsP37ENDqC8yEhk9s=in9v0S_c26z0JTM=adQ@mail.gmail.com>
 <CALx6S35C3SYvaBT93VsDJW4gej30MXD1PqjN53cfqG00L=NM3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:1827 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751366AbdBNWIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 17:08:45 -0500
In-Reply-To: <CALx6S35C3SYvaBT93VsDJW4gej30MXD1PqjN53cfqG00L=NM3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/17 21:07, Tom Herbert wrote:
> Off the top of my head... I'd say may we might be able to have a
> minimally invasive interface with something like:
> 
> XDP_RUN(hook, xdp, drv_xdp_handle_action)
> 
> This replaces xdp_run and return codes are processed in the called
> functions. Its a macro so that xdp_handle_action can be inlined.
I don't see why callbacks are needed, since XDP programs (I assume)
 aren't supposed to block.  This XDP_RUN ends up looking a lot like
 NF_HOOK, for no good reason that I can see (unlike NF hooks, we never
 do things like NF_QUEUE).
> Batching could then be done in the backend XDP so that it would be
> transparent to the driver.
I also don't see how you can transparently batch and still allow the
 handler to be inlined - you'd have to stash a function pointer that
 you could call later when you decide to dispatch a batch of packets.

To me, the sensible interface (which makes the batching explicit to
 the driver, which I think is necessary) is to have an int (or maybe
 unsigned int, which is the return type of xdp_hookfn, I'm not sure
 which is intended) member in struct xdp_buff.
Then the driver can call something like
	XDP_RUN_ARRAY(napi, xdp_array, array_len);
which is semantically equivalent to
	unsigned int i;
	for (i = 0; i < array_len; i++)
		xdp_array[i].ret = xdp_hook_run(napi, xdp_array + i);
except that it may run the hooks in 'row-major order'.
No callbacks needed, the driver can just loop over xdp_array reading
 the .ret and applying the relevant action to each packet.

This also has the advantage that the driver knows how many packets it
 might have to process in a single batch (i.e. NAPI_POLL_WEIGHT) and
 can allocate the array statically, whereas an XDP hook that tried to
 transparently be 'helpful' would have to guess and/or use kmalloc.

-Ed
