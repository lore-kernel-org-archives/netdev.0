From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Tue, 30 Oct 2012 19:20:01 +0100
Message-ID: <20121030182001.GA30373@shrek.podlesie.net>
References: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
 <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 10:26:46AM -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>,Krzysztof Mazur writes:
> 
> as i recall from way back, this shouldnt be necessary.  closing a vcc
> for an attached protocol isnt supposed to require addtional locking
> or synchronization.

Such locking is already used by vcc_sendmsg() and I think we should do here
exacly what vcc_sendmsg() does.

> 
> vcc_release() locks the socket and vcc_destroy_socket() calls the device's
> vcc close routine and pushes a NULL skb to the attached protocol.
> this NULL push is supposed to let the attached protocol that no more
> sends and recvs can be handled. 
> 
> that said, the order for the device vcc close and push does seem
> reversed.  since i imagine there could be a pending pppoatm_send()
> during this interval.  the push of the NULL skb is allowed to wait for
> the subprotocol to finish its cleanup/shutdown.

Yes, this problem can be probably fixed by reversing close and push
and adding some synchronization to pppoatm_unassign_vcc(), but I think
we need that locking anyway, for instance for synchronization for
checking and incrementing sk->sk_wmem_alloc, between pppoatm_send()
and vcc_sendmsg().

Thanks.

Krzysiek
