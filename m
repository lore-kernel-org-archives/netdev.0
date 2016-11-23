From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH] can: bcm: fix support for CAN FD frames
Date: Wed, 23 Nov 2016 15:15:03 +0100
Message-ID: <CAAeHK+yesHz-JYriBQs5TH5_ZNxGK=n7JrDc1+N4WH6Ju+sNtA@mail.gmail.com>
References: <20161123133325.1812-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-can@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35400 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934159AbcKWOPG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:15:06 -0500
Received: by mail-lf0-f42.google.com with SMTP id b14so4880037lfg.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:15:05 -0800 (PST)
In-Reply-To: <20161123133325.1812-1-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 2:33 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> Since commit 6f3b911d5f29b98 ("can: bcm: add support for CAN FD frames") the
> CAN broadcast manager supports CAN and CAN FD data frames.
>
> As these data frames are embedded in struct can[fd]_frames which have a
> different length the access to the provided array of CAN frames became
> dependend of op->cfsiz. By using a struct canfd_frame pointer for the array of
> CAN frames the new offset calculation based on op->cfsiz was accidently applied
> to CAN FD frame element lengths.
>
> This fix makes the pointer to the arrays of the different CAN frame types a
> void pointer so that the offset calculation in bytes accesses the correct CAN
> frame elements.
>
> Reference: http://marc.info/?l=linux-netdev&m=147980658909653
>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>  net/can/bcm.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 8af9d25..436a753 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -77,7 +77,7 @@
>                      (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG) : \
>                      (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
>
> -#define CAN_BCM_VERSION "20160617"
> +#define CAN_BCM_VERSION "20161123"
>
>  MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
>  MODULE_LICENSE("Dual BSD/GPL");
> @@ -109,8 +109,9 @@ struct bcm_op {
>         u32 count;
>         u32 nframes;
>         u32 currframe;
> -       struct canfd_frame *frames;
> -       struct canfd_frame *last_frames;
> +       /* void pointers to arrays of struct can[fd]_frame */
> +       void *frames;
> +       void *last_frames;
>         struct canfd_frame sframe;
>         struct canfd_frame last_sframe;
>         struct sock *sk;
> @@ -681,7 +682,7 @@ static void bcm_rx_handler(struct sk_buff *skb, void *data)
>
>         if (op->flags & RX_FILTER_ID) {
>                 /* the easiest case */
> -               bcm_rx_update_and_send(op, &op->last_frames[0], rxframe);
> +               bcm_rx_update_and_send(op, op->last_frames, rxframe);
>                 goto rx_starttimer;
>         }
>
> @@ -1068,7 +1069,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>
>                 if (msg_head->nframes) {
>                         /* update CAN frames content */
> -                       err = memcpy_from_msg((u8 *)op->frames, msg,
> +                       err = memcpy_from_msg(op->frames, msg,
>                                               msg_head->nframes * op->cfsiz);
>                         if (err < 0)
>                                 return err;
> @@ -1118,7 +1119,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>                 }
>
>                 if (msg_head->nframes) {
> -                       err = memcpy_from_msg((u8 *)op->frames, msg,
> +                       err = memcpy_from_msg(op->frames, msg,
>                                               msg_head->nframes * op->cfsiz);
>                         if (err < 0) {
>                                 if (op->frames != &op->sframe)
> @@ -1163,6 +1164,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>         /* check flags */
>
>         if (op->flags & RX_RTR_FRAME) {
> +               struct canfd_frame *frame0 = op->frames;
>
>                 /* no timers in RTR-mode */
>                 hrtimer_cancel(&op->thrtimer);
> @@ -1174,8 +1176,8 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>                  * prevent a full-load-loopback-test ... ;-]
>                  */
>                 if ((op->flags & TX_CP_CAN_ID) ||
> -                   (op->frames[0].can_id == op->can_id))
> -                       op->frames[0].can_id = op->can_id & ~CAN_RTR_FLAG;
> +                   (frame0->can_id == op->can_id))
> +                       frame0->can_id = op->can_id & ~CAN_RTR_FLAG;
>
>         } else {
>                 if (op->flags & SETTIMER) {
> --
> 2.10.2
>

Tested-by: Andrey Konovalov <andreyknvl@google.com>
