From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Wed, 3 Jul 2013 12:26:33 -0700
Message-ID: <CAL1RGDU0JiGPFEAu87JbxxbHWbgZVsRz1qbz4BvqbCJU9RtRAA@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
 <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com> <51D45449.5010604@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51D45449.5010604-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 3, 2013 at 9:41 AM, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> Jack looked on this comment/code and he says that the active flag is used
> to prevent re-scheduling the timer from inside the timer handling routine.
>
> In the kernel, the comment header in the source file for del_timer_sync
> explicitly states that re-scheduling the timer must be prevented,
> or the sync is useless:Callers must prevent restarting of the timer,
> otherwise
> this function is meaningless
>
> So we believe that code should remain.

Look at the actual timer code.  del_timer_sync() won't work if
something unrelated re-adds the timer, but it will work if the timer
itself is what re-adds itself.

Documentation/DocBook/kernel-locking.tmpl says:

      Another common problem is deleting timers which restart
      themselves (by calling <function>add_timer()</function> at the end
      of their timer function).  Because this is a fairly common case
      which is prone to races, you should use
<function>del_timer_sync()</function>
      (<filename class="headerfile">include/linux/timer.h</filename>)
      to handle this case.  It returns the number of times the timer
      had to be deleted before we finally stopped it from adding itself back
      in.

which pretty clearly says that del_timer_sync() will work in this case.

Or look at the code using it in arch/sparc/kernel/led.c for example
(just one of the first hits in my grep, there are many other
examples).

Not a big deal but I'm pretty sure the flag isn't needed.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
