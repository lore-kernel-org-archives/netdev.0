From: Jinpu Wang <jinpu.wang@profitbricks.com>
Subject: Re: [PATCH]mlx4-core: fix possible use after free in cq_completion
Date: Mon, 27 Jul 2015 10:41:11 +0200
Message-ID: <CAMGffEk+CKhHka+5ZmYAU8--7QmX9vCWn0enAGzmHhAvmEF-_A@mail.gmail.com>
References: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
 <20150726175748.78091e75@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Yun Wang <yun.wang@profitbricks.com>
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35914 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbG0Ilc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:41:32 -0400
Received: by wicgb10 with SMTP id gb10so101449875wic.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 01:41:30 -0700 (PDT)
In-Reply-To: <20150726175748.78091e75@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jack,

Thanks for your reply, could you send me your PATCH, I can test it in
our environment.
please see comments inline.

>
> We have seen this problem, and have developed a fix for it.  We will
> be submitting the fix within the next few days (after final testing).
> The fix utilizes rcu locking in the interrupt handlers (to avoid
> deadlocks).
>
> The fix you propose below has the potential to cause a deadlock.
> (We originally tried irq spinlocks here, because this lock is also
> grabbed in the process context in mlx4_cq_alloc/free).
>
> The problem is that under VPI, the ETH interface uses multiple msix i=
rq's,
> which can result in one cq completion event interrupting another,
> in-progress cq completion event. A deadlock results when the handler
> for the first cq completion grabs the spinlock, and is interrupted by
> the second completion before it has a chance to release the spinlock.
> The handler for the second completion will deadlock waiting for the
> spinlock to be released.
>
> -Jack
>
So spin_lock_irqsave is more appropriate for this fix, but will
introduce more performance lose I guess.
In OFED, rcu lock is used,  but synchronize_rcu() is missing, may also
need combine cq->refcount, I guess?


--=20
Mit freundlichen Gr=C3=BC=C3=9Fen,
Best Regards,

Jack Wang

Linux Kernel Developer Storage
ProfitBricks GmbH  The IaaS-Company.

ProfitBricks GmbH
Greifswalder Str. 207
D - 10405 Berlin
Tel: +49 30 5770083-42
=46ax: +49 30 5770085-98
Email: jinpu.wang@profitbricks.com
URL: http://www.profitbricks.de

Sitz der Gesellschaft: Berlin.
Registergericht: Amtsgericht Charlottenburg, HRB 125506 B.
Gesch=C3=A4ftsf=C3=BChrer: Andreas Gauger, Achim Weiss.
