From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 2/3] pppoatm: fix race condition with destroying of vcc
Date: Tue, 30 Oct 2012 10:26:46 -0400
Message-ID: <201210301426.q9UEQkI7007209@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <1350926091-12642-2-git-send-email-krzysiek@podlesie.net>,Krzysztof Mazur writes:
>The pppoatm_send() calls vcc->send() and now also checks for
>some vcc flags that indicate destroyed vcc without proper locking.
...
>The vcc_sendmsg() uses lock_sock(sk). This lock is used by
>vcc_release(), so vcc_destroy_socket() will not be called between
>check and during ->send(). The vcc_release_async() sets ATM_VF_CLOSE,
>but it should be safe to call ->send() after it, because
>vcc->dev->ops->close() is not called.

as i recall from way back, this shouldnt be necessary.  closing a vcc
for an attached protocol isnt supposed to require addtional locking
or synchronization.

vcc_release() locks the socket and vcc_destroy_socket() calls the device's
vcc close routine and pushes a NULL skb to the attached protocol.
this NULL push is supposed to let the attached protocol that no more
sends and recvs can be handled. 

that said, the order for the device vcc close and push does seem
reversed.  since i imagine there could be a pending pppoatm_send()
during this interval.  the push of the NULL skb is allowed to wait for
the subprotocol to finish its cleanup/shutdown.
