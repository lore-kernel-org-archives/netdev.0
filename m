From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] ezchip: nps_enet: check if napi has been completed
Date: Thu, 30 Mar 2017 06:25:47 -0700
Message-ID: <CANn89iJysKbV92XW8UKb-YOmOqC=SSbz_urGDB4YubpdDYwYdA@mail.gmail.com>
References: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
 <20170329.143014.2001816338079751776.davem@davemloft.net> <CANn89iJ1+7CrF=hJj-_pLWV+EDXxhUZGOL+3je6zjE8dJDcr=A@mail.gmail.com>
 <1490865403.32756.21.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "eladkan@mellanox.com" <eladkan@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "noamca@mellanox.com" <noamca@mellanox.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vlad Zakharov <Vladislav.Zakharov@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490865403.32756.21.camel@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2017 at 2:16 AM, Vlad Zakharov
<Vladislav.Zakharov@synopsys.com> wrote:

> I am not sure what is happening with other drivers, but in case of ezchip nps_enet driver after the following commit:
> 39e6c8208d7b6fb9d2047850fb3327db567b564b
>
> if we got into NAPI_STATE_MISSED state the following happened:
> in nps_enet_poll func we were calling napi_complete_done() (which reset MISSED state but left SCHED state) and after
> that without any checks were enabling interrupts.
>
> Then we obviously were getting into nps_enet_irq_hanlder() if irq was pending (it is very possbile state). If we look
> inside this function we will see that it disables interrupts only in case napi_sched_prep() returns true. In its turn
> napi_sched_prep() returns true only in case it changes state from non-SCHED to SCHED. But in our case as SCHED had been
> already set it set MISSED state and then returned false. So at that point we had already been trapped: after exiting irq
> hanlder we were getting into nps_enet_irq_hanlder() again and again as we couldn't rescind pending irq signal and
> disable corresponding irq.

Hi Vlad

Considering the use of  napi_schedule_prep() in
nps_enet_irq_handler(), it is strange that nps_enet_poll() uses :

if (nps_enet_is_tx_pending(priv)) {
     nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
     napi_reschedule(napi); // note the return value is ignored...
}

So nps_enet_poll() was enabling interrupts, then disabling them, which
seems very unusual.

I need to check all drivers using napi_schedule_prep() and/or
napi_reschedule() and make sure they also test napi_comple_done()
return value...

I count 12 drivers using napi_reschedule() without checking its return value.
They either should check its return value, or use conventional napi_schedule()

Thanks !
