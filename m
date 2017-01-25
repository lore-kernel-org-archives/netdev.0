From: Joel Cunningham <joel.cunningham@me.com>
Subject: Re: sk_buff and reference counting netdev pointers
Date: Wed, 25 Jan 2017 15:31:05 -0600
Message-ID: <7E4178F2-EEC0-4610-B671-3015A3739ED0@me.com>
References: <E593AEBC-5FD1-4CEF-A119-2C032DB574FC@me.com>
 <CAM_iQpXKsFA5ZZmBvqJaTJ8H88GmoTRmU0HT=FHH8hPrDxX_4Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pv38p43im-ztdg05071201.me.com ([17.133.183.8]:46868 "EHLO
        pv38p43im-ztdg05071201.me.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752133AbdAYVbI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 16:31:08 -0500
Received: from process-dkim-sign-daemon.pv38p43im-ztdg05071201.me.com by
 pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OKC00A00UEE3O00@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Wed, 25 Jan 2017 21:31:07 +0000 (GMT)
In-reply-to: <CAM_iQpXKsFA5ZZmBvqJaTJ8H88GmoTRmU0HT=FHH8hPrDxX_4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jan 23, 2017, at 5:45 PM, Cong Wang <xiyou.wangcong@gmail.com> =
wrote:
>=20
> On Mon, Jan 23, 2017 at 2:37 PM, Joel Cunningham =
<joel.cunningham@me.com> wrote:
>> Hi,
>>=20
>> I=E2=80=99m working on a research effort to understand the =
synchronization mechanisms for accessing and modifying a struct =
net_device object.  One area that isn=E2=80=99t clear is the net device =
pointer (dev) stored in a struct sk_buff.  =46rom my investigation, the =
pointer appears to be assigned without increasing the struct =
net_device=E2=80=99s reference count (example __netdev_alloc_skb =
doesn=E2=80=99t call dev_hold) and also when the sk_buff is freed =
(kfree_skb) no call to dev_put() is made.  This seems to leave a =
possibility of an skb referencing a stale net device unless something is =
cleaning up all the skbs during unregister_netdevice() (which waits for =
all outstanding references to be released).  Any insight in =
understanding how this is working would be appreciated!
>>=20
>=20
> This is a very common question.
>=20
> synchronize_net() is supposed to wait for on-flying packets, since
> both for TX and RX paths we acquire RCU read lock.

Thanks for the insight on in-flight packets!  I continued my research =
effort on how queued/outstanding sk_buffs with dev pointer set are =
cleaned up during an unregister.  Do my findings sound correct?

1. RX packets queued in the link-layer backlog are freed via =
flush_backlog (called from netdev_run_todo)
2. RX packets that have been processed and queued in an upper layer =
buffer have already had their sk_buff->dev pointer NULLed out (I saw =
this in tcp_v4_rcv() and sock_queue_rcv_skb() for UDP pathway)
3. TX packets waiting in a queue discipline are freed via =
device_deactive_many()/dev_deactivate_queue()
4. TX packets that have been accepted by the driver in ndo_start_xmit() =
but are queued for asynchronous transmit will be freed during ndo_stop()

Thanks,

Joel=
