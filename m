From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Wed, 6 Mar 2013 18:20:35 +0100
Message-ID: <CALZVapniE32NfuOjmfDd7DmVHxGLmMTunJu2CxBHRsyoE1Kqaw@mail.gmail.com>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
 <20130208.145728.1110053781319882182.davem@davemloft.net> <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
 <20130208.151523.798634382725569230.davem@davemloft.net> <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
 <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
 <1360458962.6696.38.camel@edumazet-glaptop> <CALZVap=_x_nvnH55n7SGMxFGCR9XPKkNzSrt0J1dp41g-HUAqQ@mail.gmail.com>
 <1360484188.20362.11.camel@edumazet-glaptop> <CALZVapm1evE6rOgNkJapu9VboA6OojKGJ-UhRhZ26J0A+k4nmw@mail.gmail.com>
 <CALZVapmKbqcamTYTEhoerRUPpjsaLJqoTo84Fqmz+aUWWTmh2g@mail.gmail.com> <1361542281.3683.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:46402 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab3CFRU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 12:20:58 -0500
Received: by mail-vc0-f180.google.com with SMTP id fo13so4887922vcb.25
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 09:20:56 -0800 (PST)
In-Reply-To: <1361542281.3683.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> To free memory, so that rx handler gets more chance to be able to
> allocate memory, and reuse memory already hot in cpu caches.

I have been thinking about the tx completion thread, and what happens
if for example in e1000_clean:

tx_clean_complete = e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);

adapter->clean_rx(adapter, &adapter->rx_ring[0], &work_done, budget);

if (!tx_clean_complete)
work_done = budget;

the tx_clean_complete is false (count of the cleaned tx packets is
less than the needed ones), that would then make the polling function
return that the budget was fully filled. If this happens with the
first poll, it will make net_rx_action believe that those packets have
been captured, so it will have to exit after that loop.

Thus that interface, will be checked in net_rx_action, as the work
equals the weight of the function:

if (unlikely(work == weight)) {
if (unlikely(napi_disable_pending(n))) {
local_irq_enable();
napi_complete(n);
local_irq_disable();
} else {
list_move_tail(&n->poll_list, &sd->poll_list);
}
}

, it will be rescheduled for the next net_rx_action, but the rest of
the poll-able cards would then have to move to the next net_rx_action
softirq. Would it be alright to make e1000/e1000e drivers just return
the budget they used?

Another question, that is a little related, in tg3, it deactivates
napi, when it has a TX_RECOVERY_PENDING, what does that flag mean?

Thank you for your attention,

Javier Domingo
