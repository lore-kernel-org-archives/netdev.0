From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: x25: possible skb leak on bad facilities
Date: Tue, 1 Feb 2011 22:55:13 +1100
Message-ID: <AANLkTik-ywwtNg2AxAXtsKYJviDp=1zCZ-43JXp9i3g6@mail.gmail.com>
References: <20110131130826.GC16804@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	John Hughes <john@calva.com>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tim Gardner <tim.gardner@canonical.com>
To: Andy Whitcroft <apw@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60084 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab1BALzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 06:55:15 -0500
In-Reply-To: <20110131130826.GC16804@shadowen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two callers, when I was crashing it I don't remember it
using the backlog path.
x25_process_rx_frame is called from both x25_backlog_rcv and also
x25_receive_data (via x25_lapb_receive_frame)

But reviewing that second path now it looks like it will also leak, -1
would make it skip the kfree_skb there as well.
So patch looks good to me, when I have some time I'll run it through
the environment I had setup originally to confirm.

On Tue, Feb 1, 2011 at 12:08 AM, Andy Whitcroft <apw@canonical.com> wro=
te:
> Looking at the changes introduced in the commit below, we seem to
> introduce an skb leak when a packet with bad facilities are present:
>
> =A0 =A0commit a6331d6f9a4298173b413cf99a40cc86a9d92c37
> =A0 =A0Author: andrew hendry <andrew.hendry@gmail.com>
> =A0 =A0Date: =A0 Wed Nov 3 12:54:53 2010 +0000
>
> =A0 =A0 =A0 =A0memory corruption in X.25 facilities parsing
>
> If I am understanding things correctly then we trigger a -1 return to
> the main packet dispatch loop, this being non-zero implies that we ha=
ve
> requeued the skb and it should not be freed. =A0As it was not requeue=
d,
> I believe the skb is no longer referenced and then is leaked.
>
> Perhaps someone better aquainted with this code could review my analy=
sis
> in the patch leader below. =A0If accurate I believe we need the patch=
 below
> to resolve this. =A0If it is not then I suspect a comment is required=
 on
> the -1 return.
>
> Thoughts?
>
> -apw
>
> From 5728c05fb669e8ee1e6d20fb7a71916362039411 Mon Sep 17 00:00:00 200=
1
> From: Andy Whitcroft <apw@canonical.com>
> Date: Mon, 31 Jan 2011 10:37:36 +0000
> Subject: [PATCH] x25: drop packet on invalid facility headers
>
> The commit below introduced additional checks for invalid facilities,
> and a new return path when these were detected:
>
> =A0 =A0commit a6331d6f9a4298173b413cf99a40cc86a9d92c37
> =A0 =A0Author: andrew hendry <andrew.hendry@gmail.com>
> =A0 =A0Date: =A0 Wed Nov 3 12:54:53 2010 +0000
>
> =A0 =A0 =A0 =A0memory corruption in X.25 facilities parsing
>
> This new return path short circuits packet handling, the new return -=
1
> below:
>
> =A0 =A0static int x25_state1_machine(struct sock *sk, struct sk_buff =
*skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int frametype)
> =A0 =A0{
> =A0 =A0[...]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D x25_parse_faci=
lities(skb, &x25->facilities,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0&x25->dte_facilities,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0&x25->vc_facil_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (len > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pu=
ll(skb, len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -1;
> =A0 =A0[...]
>
> This return code is passed back up the chain (via x25_process_rx_fram=
e)
> and is interpreted as below by the caller:
>
> =A0 =A0int x25_backlog_rcv(struct sock *sk, struct sk_buff *skb)
> =A0 =A0{
> =A0 =A0 =A0 =A0int queued =3D x25_process_rx_frame(sk, skb);
>
> =A0 =A0 =A0 =A0if (!queued)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
>
> =A0 =A0 =A0 =A0return 0;
> =A0 =A0}
>
> Here we interpret the non-zero status as indicating the skb has been
> requeued and should be preserved. =A0As we have not actually done so =
it
> will be leaked.
>
> Fix this up by indicating that the packet should be dropped.
>
> Signed-off-by: Andy Whitcroft <apw@canonical.com>
> ---
> =A0net/x25/x25_in.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
> index f729f02..213b93a 100644
> --- a/net/x25/x25_in.c
> +++ b/net/x25/x25_in.c
> @@ -120,7 +120,7 @@ static int x25_state1_machine(struct sock *sk, st=
ruct sk_buff *skb, int frametyp
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (len > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pu=
ll(skb, len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0 =A0 =A0Copy any=
 Call User Data.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> --
> 1.7.1
>
>
