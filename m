From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: panic at sock_zerocopy_put when I ssh into a VM
Date: Tue, 8 Aug 2017 21:48:24 -0700
Message-ID: <CAF=yD-J8JMyVq3Qt2n+L-EmpxacJ=mD7-KdsjgO3YB3LAzbKMQ@mail.gmail.com>
References: <9ea97b60-7416-bdb2-e167-8fcc8c11b1cc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemb@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35627 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752127AbdHIEtF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 00:49:05 -0400
Received: by mail-oi0-f68.google.com with SMTP id q70so4764020oic.2
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 21:49:05 -0700 (PDT)
In-Reply-To: <9ea97b60-7416-bdb2-e167-8fcc8c11b1cc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the report, David, and sorry for the breakage.

I am not able to reproduce the issue with my qemu setup with vhost-net
with experimental_zcopytx so far.

But looking at the code from that codepath point of view, I do see
that there are incorrect assumptions on ubuf_info fields being
initialized anytime skb_zcopy(skb) is true, that are not true for the
legacy zerocopy case.

Specifically, uarg->mmp and uarg->zerocopy are only valid for
msg_zerocopy. The first can conceivably result in dereferencing
a garbage pointer if an ubuf_info from vhost is passed that does
not have this field properly initialized.

I will take a deeper look. As a first attempt, the following may fix
the issue for this vhost case (only):

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index ba08b78ed630..e1e96d97de71 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -253,7 +253,7 @@ static int vhost_net_set_ubuf_info(struct vhost_net *n)
                zcopy = vhost_net_zcopy_mask & (0x1 << i);
                if (!zcopy)
                        continue;
-               n->vqs[i].ubuf_info = kmalloc(sizeof(*n->vqs[i].ubuf_info) *
+               n->vqs[i].ubuf_info = kzalloc(sizeof(*n->vqs[i].ubuf_info) *
                                              UIO_MAXIOV, GFP_KERNEL);
                if  (!n->vqs[i].ubuf_info)
                        goto err;

Less critical is correctly returning whether the operation completed
without resorting to copying. Boolean uarg->zerocopy is undefined.
This should not cause a kernel panic, as the vhost driver must handle
both cases safely.

Only msg_zerocopy sets bot SKBTX_ZEROCOPY_FRAG and
SKBTX_DEV_ZEROCOPY, which is one way to identify this
special case.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8c0708d2e5e6..7fb8b11ba8f6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1273,7 +1273,10 @@ static inline void skb_zcopy_clear(struct
sk_buff *skb, bool zerocopy)
        struct ubuf_info *uarg = skb_zcopy(skb);

        if (uarg) {
-               uarg->zerocopy = uarg->zerocopy && zerocopy;
+               if (skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG)
+                       uarg->zerocopy = uarg->zerocopy && zerocopy;
+               else
+                       uarg->zerocopy = zerocopy;
                sock_zerocopy_put(uarg);
                skb_shinfo(skb)->tx_flags &= ~SKBTX_ZEROCOPY_FRAG;
        }




On Tue, Aug 8, 2017 at 6:14 PM, David Ahern <dsahern@gmail.com> wrote:
> Willem:
>
> I updated my host server this morning to top of net-next -- commit
> 53b948356554. I am not doing anything fancy or intentionally using the
> zerocopy code. I launch a VM with vhost and attempt to login via ssh.
> Doing that triggers a panic in the host at sock_zerocopy_put. The
> attached is a snapshot of the console -- best I can get for the stack trace.
>
> David
