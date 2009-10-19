From: Xiaotian Feng <xtfeng@gmail.com>
Subject: Re: possible circular locking dependency in ISDN PPP
Date: Mon, 19 Oct 2009 13:27:24 +0800
Message-ID: <7b6bb4a50910182227y1281b40bj3fcc082d32cf4496@mail.gmail.com>
References: <4ADB93C4.4090607@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	Netdev <netdev@vger.kernel.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752724AbZJSF1X@vger.kernel.org>
In-Reply-To: <4ADB93C4.4090607@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---> isdn_net_get_locked_lp
     --->lock &nd->queue_lock
     --->lock &nd->queue->xmit_lock
     .....................
     ---->unlock &nd->queue_lock

---> isdn_net_writebuf_skb (called with &nd->queue->xmit_lock locked)
     ---->isdn_net_inc_frame_cnt
          ---->isdn_net_device_busy
               ----> lock &nd->queue_lock

So there's a circular locking dependency.. Looking into isdn_net_get_lo=
cked_lp()

static __inline__ isdn_net_local * isdn_net_get_locked_lp(isdn_net_dev =
*nd)
{
        unsigned long flags;
        isdn_net_local *lp;

        spin_lock_irqsave(&nd->queue_lock, flags);
        lp =3D nd->queue;         /* get lp on top of queue */
        spin_lock(&nd->queue->xmit_lock);
        while (isdn_net_lp_busy(nd->queue)) {
                spin_unlock(&nd->queue->xmit_lock);
                nd->queue =3D nd->queue->next;
                if (nd->queue =3D=3D lp) { /* not found -- should never=
 happen */
                        lp =3D NULL;
                        goto errout;
                }
                spin_lock(&nd->queue->xmit_lock);
        }
        lp =3D nd->queue;
        nd->queue =3D nd->queue->next;
        local_bh_disable();
errout:
        spin_unlock_irqrestore(&nd->queue_lock, flags);
        return lp;
}

Why do we need to hold xmit_lock while using
isdn_net_lp_busy(nd->queue) ? Can following patch fix this bug?

---
diff --git a/drivers/isdn/i4l/isdn_net.h b/drivers/isdn/i4l/isdn_net.h
index 74032d0..7511f08 100644
--- a/drivers/isdn/i4l/isdn_net.h
+++ b/drivers/isdn/i4l/isdn_net.h
@@ -83,19 +83,19 @@ static __inline__ isdn_net_local *
isdn_net_get_locked_lp(isdn_net_dev *nd)

        spin_lock_irqsave(&nd->queue_lock, flags);
        lp =3D nd->queue;         /* get lp on top of queue */
-       spin_lock(&nd->queue->xmit_lock);
        while (isdn_net_lp_busy(nd->queue)) {
-               spin_unlock(&nd->queue->xmit_lock);
                nd->queue =3D nd->queue->next;
                if (nd->queue =3D=3D lp) { /* not found -- should never=
 happen */
                        lp =3D NULL;
                        goto errout;
                }
-               spin_lock(&nd->queue->xmit_lock);
        }
        lp =3D nd->queue;
        nd->queue =3D nd->queue->next;
+       spin_unlock_irqrestore(&nd->queue_lock, flags);
+       spin_lock(&lp->xmit_lock);
        local_bh_disable();
+       return lp;
 errout:
        spin_unlock_irqrestore(&nd->queue_lock, flags);
        return lp;

On Mon, Oct 19, 2009 at 6:16 AM, Tilman Schmidt <tilman@imap.cc> wrote:
> A test of PPP over ISDN with ipppd, capidrv and the so far unmerged
> CAPI port of the Gigaset driver produced the following lockdep
> message:
>
> =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =C2=A0[ INFO: possible circular locking dependency detected ]
> =C2=A02.6.32-rc4-testing #7
> =C2=A0-------------------------------------------------------
> =C2=A0ipppd/28379 is trying to acquire lock:
> =C2=A0(&netdev->queue_lock){......}, at: [<e62ad0fd>] isdn_net_device=
_busy+0x2c/0x74 [isdn]
>
> =C2=A0but task is already holding lock:
> =C2=A0(&netdev->local->xmit_lock){+.....}, at: [<e62aefc2>] isdn_net_=
write_super+0x3f/0x6e [isdn]
>
> =C2=A0which lock already depends on the new lock.
>
>
> =C2=A0the existing dependency chain (in reverse order) is:
>
> =C2=A0-> #1 (&netdev->local->xmit_lock){+.....}:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0157e9c>] __lock_acquire+0xa12/0xb99
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c01580ac>] lock_acquire+0x89/0xa0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0373249>] _spin_lock+0x1b/0x2a
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62b9d1c>] isdn_ppp_xmit+0xf0/0x5b0 [isd=
n]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62b03f0>] isdn_net_start_xmit+0x4c6/0x6=
6b [isdn]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0307e75>] dev_hard_start_xmit+0x251/0x2=
e4
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0317bcc>] sch_direct_xmit+0x4f/0x122
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c030829c>] dev_queue_xmit+0x2ae/0x412
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c030d748>] neigh_resolve_output+0x1f2/0x=
23c
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0329b9c>] ip_finish_output2+0x1b1/0x1db
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0329c25>] ip_finish_output+0x5f/0x62
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0329cb5>] ip_output+0x8d/0x92
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c03290c0>] ip_local_out+0x18/0x1b
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c032932c>] ip_push_pending_frames+0x269/=
0x2c1
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c033fd78>] raw_sendmsg+0x618/0x6b0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0347ac9>] inet_sendmsg+0x3b/0x48
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c02fa5b5>] __sock_sendmsg+0x45/0x4e
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c02fad4b>] sock_sendmsg+0xb8/0xce
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c02faea0>] sys_sendmsg+0x13f/0x192
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c02fbeb2>] sys_socketcall+0x157/0x18e
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0102974>] sysenter_do_call+0x12/0x32
>
> =C2=A0-> #0 (&netdev->queue_lock){......}:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0157da9>] __lock_acquire+0x91f/0xb99
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c01580ac>] lock_acquire+0x89/0xa0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c03732db>] _spin_lock_irqsave+0x24/0x34
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62ad0fd>] isdn_net_device_busy+0x2c/0x7=
4 [isdn]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62aeee3>] isdn_net_writebuf_skb+0x6e/0x=
c2 [isdn]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62aefd4>] isdn_net_write_super+0x51/0x6=
e [isdn]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62bc26f>] isdn_ppp_write+0x3a8/0x3bc [i=
sdn]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<e62b785a>] isdn_write+0x1d9/0x1f9 [isdn]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c01c42c5>] vfs_write+0x84/0xdf
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c01c43b9>] sys_write+0x3b/0x60
> =C2=A0 =C2=A0 =C2=A0 =C2=A0[<c0102974>] sysenter_do_call+0x12/0x32
>
> =C2=A0other info that might help us debug this:
>
> =C2=A01 lock held by ipppd/28379:
> =C2=A0#0: =C2=A0(&netdev->local->xmit_lock){+.....}, at: [<e62aefc2>]=
 isdn_net_write_super+0x3f/0x6e [isdn]
>
> =C2=A0stack backtrace:
> =C2=A0Pid: 28379, comm: ipppd Not tainted 2.6.32-rc4-testing #7
> =C2=A0Call Trace:
> =C2=A0[<c03710dc>] ? printk+0xf/0x13
> =C2=A0[<c015714d>] print_circular_bug+0x90/0x9c
> =C2=A0[<c0157da9>] __lock_acquire+0x91f/0xb99
> =C2=A0[<c01580ac>] lock_acquire+0x89/0xa0
> =C2=A0[<e62ad0fd>] ? isdn_net_device_busy+0x2c/0x74 [isdn]
> =C2=A0[<c03732db>] _spin_lock_irqsave+0x24/0x34
> =C2=A0[<e62ad0fd>] ? isdn_net_device_busy+0x2c/0x74 [isdn]
> =C2=A0[<e62ad0fd>] isdn_net_device_busy+0x2c/0x74 [isdn]
> =C2=A0[<e62aeee3>] isdn_net_writebuf_skb+0x6e/0xc2 [isdn]
> =C2=A0[<e62aefd4>] isdn_net_write_super+0x51/0x6e [isdn]
> =C2=A0[<e62bc26f>] isdn_ppp_write+0x3a8/0x3bc [isdn]
> =C2=A0[<e62b785a>] isdn_write+0x1d9/0x1f9 [isdn]
> =C2=A0[<c01c3b6c>] ? rw_verify_area+0x8a/0xad
> =C2=A0[<e62b7681>] ? isdn_write+0x0/0x1f9 [isdn]
> =C2=A0[<c01c42c5>] vfs_write+0x84/0xdf
> =C2=A0[<c01c43b9>] sys_write+0x3b/0x60
> =C2=A0[<c0102974>] sysenter_do_call+0x12/0x32
>
> The message appeared shortly after initiating the connection,
> during the PPP negotiation, just when the IP address was assigned.
> The system continued to run normally, and the connection was
> successfully established. Full log showing the entire connection
> (with capidrv and Gigaset driver debugging output enabled, 70 kB),
> available at http://www.phoenixsoftware.de/~ts/ppp-lockprob-full.log
> in case someone's interested. It shows the messages from ipppd
> about the IP address assignment arriving in the middle of the
> lockdep message.
>
> I cannot say whether this is a regression. My previous tests of
> that scenario were done on a machine with an Nvidia graphics card
> where the lockdep machinery would refuse to run because of the
> kernel being tainted by the Nvidia driver, so I wouldn't have seen
> anything one way or another.
>
> Btw, one of those "NOHZ: local_softirq_pending 08" messages is also
> present in the log, but that's 28 seconds later so I'd be surprised
> if the two were related.
>
> Any hints about the possible cause and seriousness of that
> message would be welcome. I'm particularly interested, of course,
> in finding out whether the Gigaset driver might somehow be causing
> it, even though it doesn't appear anywhere in the backtraces.
>
> aTdHvAaNnKcSe
> Tilman
>
> --
> Tilman Schmidt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0E-Mail: tilman@imap.cc
> Bonn, Germany
> Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
> Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
>
>
