From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and clip_start_xmit()
Date: Mon, 15 Sep 2003 17:59:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309152159.h8FLx1Sa005910@ginger.cmf.nrl.navy.mil>
References: <romieu@fr.zoreil.com>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: Message from Francois Romieu <romieu@fr.zoreil.com>
   of "Mon, 15 Sep 2003 22:59:01 +0200." <20030915225901.A22239@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030915225901.A22239@electric-eye.fr.zoreil.com>,Francois Romieu w
rites:
>Afaik unlink_clip_vcc() can be called from a clip_push() issued in IRQ
>context through vcc->push() in a device driver as well as from user-space
>through vcc_ioctl()/ATMARP_SETENTRY. If the lock is taken by user-space
>first, what avoids that unlink_clip_vcc(IRQ) deadlocks on it ?

i believe you are talking about:

        if (!skb) {
                DPRINTK("removing VCC %p\n",clip_vcc);
                if (clip_vcc->entry) unlink_clip_vcc(clip_vcc);
                clip_vcc->old_push(vcc,NULL); /* pass on the bad news */
                kfree(clip_vcc);
                return;
        }

this is triggered by vcc_destroy_sock(), which is part of vcc_release()
which is always going to be in user context.  its a bit subtle but
there is no path to unlink_clip_vcc() that isnt in user context.

>No comment for the clip_start_xmit() part btw.

actually, you dont need to modify that part.
