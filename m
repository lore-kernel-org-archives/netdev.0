From: Kosuke Tatsukawa <tatsu-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier
 in sunrpc
Date: Mon, 12 Oct 2015 10:41:06 +0000
Message-ID: <17EC94B0A072C34B8DCF0D30AD16044A02877311@BPXM09GP.gisp.nec.co.jp>
References: <20151009211819.GE8188@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Neil Brown <nfbrown-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151009211819.GE8188-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Content-Language: ja-JP
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

J. Bruce Fields wrote:
> On Fri, Oct 09, 2015 at 06:29:44AM +0000, Kosuke Tatsukawa wrote:
>> Neil Brown wrote:
>> > Kosuke Tatsukawa <tatsu-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org> writes:
>> > 
>> >> There are several places in net/sunrpc/svcsock.c which calls
>> >> waitqueue_active() without calling a memory barrier.  Add a memory
>> >> barrier just as in wq_has_sleeper().
>> >>
>> >> I found this issue when I was looking through the linux source code
>> >> for places calling waitqueue_active() before wake_up*(), but without
>> >> preceding memory barriers, after sending a patch to fix a similar
>> >> issue in drivers/tty/n_tty.c  (Details about the original issue can be
>> >> found here: https://lkml.org/lkml/2015/9/28/849).
>> > 
>> > hi,
>> > this feels like the wrong approach to the problem.  It requires extra
>> > 'smb_mb's to be spread around which are hard to understand as easy to
>> > forget.
>> > 
>> > A quick look seems to suggest that (nearly) every waitqueue_active()
>> > will need an smb_mb.  Could we just put the smb_mb() inside
>> > waitqueue_active()??
>> <snip>
>> 
>> There are around 200 occurrences of waitqueue_active() in the kernel
>> source, and most of the places which use it before wake_up are either
>> protected by some spin lock, or already has a memory barrier or some
>> kind of atomic operation before it.
>> 
>> Simply adding smp_mb() to waitqueue_active() would incur extra cost in
>> many cases and won't be a good idea.
>> 
>> Another way to solve this problem is to remove the waitqueue_active(),
>> making the code look like this;
>> 	if (wq)
>> 		wake_up_interruptible(wq);
>> This also fixes the problem because the spinlock in the wake_up*() acts
>> as a memory barrier and prevents the code from being reordered by the
>> CPU (and it also makes the resulting code is much simpler).
> 
> I might not care which we did, except I don't have the means to test
> this quickly, and I guess this is some of our most frequently called
> code.
> 
> I suppose your patch is the most conservative approach, as the
> alternative is a spinlock/unlock in wake_up_interruptible, which I
> assume is necessarily more expensive than an smp_mb().
> 
> As far as I can tell it's been this way since forever.  (Well, since a
> 2002 patch "NFSD: TCP: rationalise locking in RPC server routines" which
> removed some spinlocks from the data_ready routines.)
> 
> I don't understand what the actual race is yet (which code exactly is
> missing the wakeup in this case?  nfsd threads seem to instead get
> woken up by the wake_up_process() in svc_xprt_do_enqueue().)

Thank you for the reply.  I tried looking into this.

The callbacks in net/sunrpc/svcsock.c are set up in svc_tcp_init() and
svc_udp_init(), which are both called from svc_setup_socket().
svc_setup_socket() is called (indirectly) from lockd, nfsd, and nfsv4
callback port related code.

Maybe I'm wrong, but there might not be any kernel code that is using
the socket's wait queue in this case.

Best regards.
---
Kosuke TATSUKAWA  | 3rd IT Platform Department
                  | IT Platform Division, NEC Corporation
                  | tatsu-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
