From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 10:27:17 +0200
Message-ID: <1274257637.2766.11.camel@edumazet-laptop>
References: <20100519075721.GA23926@gondor.apana.org.au>
	 <1274256582.2766.5.camel@edumazet-laptop>
	 <20100519082047.GA24331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63298 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab0ESI1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 04:27:21 -0400
Received: by fxm10 with SMTP id 10so2021190fxm.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 01:27:20 -0700 (PDT)
In-Reply-To: <20100519082047.GA24331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 mai 2010 =C3=A0 18:20 +1000, Herbert Xu a =C3=A9crit :
> On Wed, May 19, 2010 at 10:09:42AM +0200, Eric Dumazet wrote:
> >=20
> > 6) netif_rx() pro is that packet processing is done while stack usa=
ge is
> > guaranteed to be low (from process_backlog, using a special softirq
> > stack, instead of current stack)
> >=20
> > After your patch, tun will use more stack. Is it safe on all contex=
ts ?
>=20
> Dave also raised this but I believe nothing changes with regards
> to the stack.  We currently call do_softirq which does not switch
> stacks.
>=20
> Only a real interrupt would switch stacks.

This is a bit wrong, at least here (CONFIG_4KSTACKS=3Dy)

Some people still use 32bits these days ;)

Please check arch/x86/kernel/irq_32.c

asmlinkage void do_softirq(void)
{
        unsigned long flags;
        struct thread_info *curctx;
        union irq_ctx *irqctx;
        u32 *isp;

        if (in_interrupt())
                return;

        local_irq_save(flags);

        if (local_softirq_pending()) {
                curctx =3D current_thread_info();
                irqctx =3D __get_cpu_var(softirq_ctx);
                irqctx->tinfo.task =3D curctx->task;
                irqctx->tinfo.previous_esp =3D current_stack_pointer;

                /* build the stack frame on the softirq stack */
                isp =3D (u32 *) ((char *)irqctx + sizeof(*irqctx));

                call_on_stack(__do_softirq, isp);
                /*
                 * Shouldnt happen, we returned above if in_interrupt()=
:
                 */
                WARN_ON_ONCE(softirq_count());
        }

        local_irq_restore(flags);
}



