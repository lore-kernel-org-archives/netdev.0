From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Fri, 25 Mar 2016 09:32:23 -0700
Message-ID: <CAM_iQpXpqVgweZFw438v_b7No8U8YtqHSt0x0+HZ+oSimdCyfg@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com>
	<CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
	<56F4810A.9060904@candelatech.com>
	<56F49036.8050902@candelatech.com>
	<56F490B2.3090603@candelatech.com>
	<CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
	<56F4BFF1.8010806@candelatech.com>
	<CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
	<56F4C8FD.7030907@candelatech.com>
	<CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
	<56F56312.4080408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>,
	Tom Herbert <tom@herbertland.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34251 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbcCYQcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 12:32:24 -0400
Received: by mail-qk0-f178.google.com with SMTP id p130so32792165qke.1
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 09:32:24 -0700 (PDT)
In-Reply-To: <56F56312.4080408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 9:10 AM, Ben Greear <greearb@candelatech.com> wrote:
> I am suspicious that this will break at least some drivers.  I grepped
> around
> for ip_summed, and found this, for instance:
>
> davicom/dm9000.c
>
>         /* The DM9000 is not smart enough to leave fragmented packets alone.
> */
>         if (dm->ip_summed != ip_summed) {
>                 if (ip_summed == CHECKSUM_NONE)
>                         iow(dm, DM9000_TCCR, 0);
>                 else
>                         iow(dm, DM9000_TCCR, TCCR_IP | TCCR_UDP | TCCR_TCP);
>                 dm->ip_summed = ip_summed;
>         }
>
>
> It is taking action based on ip_summed == CHECKSUM_NONE, and your change
> will probably break that.
>
> I would suggest that we try to make any fix specific only to veth,
> at least for now.  A tree-wide audit of drivers is probably required
> to safely make the kind of change you propose above.
>
> So, unless you can explain why your change is safe, then I do not plan
> to test it.

I just blindly trust the comments there:

 * CHECKSUM_UNNECESSARY:
 *
 *   This has the same meaning on as CHECKSUM_NONE for checksum offload on
 *   output.

Let's Cc Tom who wrote this comment.

On the other hand, hyperv got this correctly:

        if ((skb->ip_summed == CHECKSUM_NONE) ||
            (skb->ip_summed == CHECKSUM_UNNECESSARY))
                goto do_send;

So I believe dm9000 needs to fix.

Thanks.
