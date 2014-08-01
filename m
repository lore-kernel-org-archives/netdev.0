From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Fri, 01 Aug 2014 14:16:55 +0200
Message-ID: <87y4v876bs.fsf@synack.fr>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, brandon.carpenter@pnnl.gov,
	casey@schaufler-ca.com, netdev@vger.kernel.org
To: Peter Moody <pmoody@google.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1406856100-21674-1-git-send-email-pmoody@google.com> (Peter
	Moody's message of "Thu, 31 Jul 2014 18:21:38 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Moody <pmoody@google.com> writes:

> I'm interested in having a host-based monitoring mechanism in
> place in the linux kernel. At this point I'm specifically looking
> to tie any given packet seen on the network back to the process
> that sent or received it. This is the sort of information our
> incident responders are constantly asking for.
>
> This is round 2 of the patchset. It's essentially taking HONE [1],
> a kernel module originally written by Brandon Carpenter and switches
> the hooks to use the standard (plus a new one, task_post_create) LSM
> hooks + a run through cleanfile/checkpatch.
>
> At a high level, Hone hooks process/socket creations/terminations
> and inet/inet6 packets that are sent or received. A userspace
> application can then correlate packet to process by reading the
> events from the kernel.
>
> (Note, there doesn't appear to be outbound version of the callback
> socket_sock_rcv_skb and the socket_sendmsg/socket_recvmsg
> are called too early in the process to be used so this uses netfilter
> hooks.)
>
> This patchset makes the events available as text via securityfs
> in /sys/kernel/security/hone/text and /sys/kernel/security/hone/pcapng.
> The text output looks like
>
> 3.350826817 EXEC 718 1 0 0 "/usr/sbin/cupsd" /usr/sbin/cupsd -f
> 3.350826817 SOCK O 718 1 0 0 b14e0000
> ...
> 5301.871561546 EXEC 2652 2586 1000 1000 "/bin/less" less
> 5303.104510870 EXEC 2653 2651 0 0 "/bin/cat" cat /sys/kernel/security/hone/text
> 5303.110322648 PAKT O 382d0700 2524 TCPv4 169.254.0.11:22 -> 169.254.0.2:49387 120
>
> and the pcapng format is described in hone_pcapng.h.
>
> There are some drawbacks with this method. Notably, it doesn't
> accurately track the owning pid of sockets passed via dup(), dup2()
> etc.
>
> This particular approach is all very experimental. We had a need
> for this level of monitoring on some of our machines (did I mention
> the incident responders?) and HONE had the best features/efficiency.
>
> I've CC'd the netdev folks at James' suggestion. I CC'd you, Casey
> as you were the one who suggested this be a proper LSM.
>
> So I'm humbly requesting comments.
>
>  * Is there a better (more efficient/extensible) way to do this?
>  * Is there already an existing mechanism to do this?

Hi Peter,
I have built a such subsystem, for years now.
Please, you can access latest public patchset here :

https://lkml.org/lkml/2011/5/5/132

monitoring events is possible with snet.

thanks,

(resending, first mail didn't hit lists)

>  * Is there any interest in something like this living in the
>    kernel? Or is the dkms distributed path the way to go?
>
> And if this is all reasonable, is it possible to add a
> socket_sock_send_skb callback and where might that go?
>
> Finally, the linux-sensor project was released under the GPL but
> I'm not sure if there are any copyright issues ... ? I've just
> kept the copyright comments in any event.
>
> This has been tested against security-next
>
> [1] https://github.com/HoneProject/Linux-Sensor
>
> Peter Moody (2):
>   security: create task_post_create callback.
>   security: Hone LSM
>
>  include/linux/hone.h               |  50 +++
>  include/linux/security.h           |   8 +
>  kernel/fork.c                      |   1 +
>  security/Kconfig                   |   1 +
>  security/Makefile                  |   2 +
>  security/capability.c              |   5 +
>  security/hone/Kconfig              |   8 +
>  security/hone/Makefile             |   3 +
>  security/hone/hone.h               | 164 ++++++++++
>  security/hone/hone_event.c         | 625 +++++++++++++++++++++++++++++++++++++
>  security/hone/hone_lsm.c           | 183 +++++++++++
>  security/hone/hone_mmutil.c        | 106 +++++++
>  security/hone/hone_mmutil.h        |  20 ++
>  security/hone/hone_notify.c        | 450 ++++++++++++++++++++++++++
>  security/hone/hone_pcapng.c        | 596 +++++++++++++++++++++++++++++++++++
>  security/hone/hone_pcapng.h        |  30 ++
>  security/hone/hone_ringbuf.c       |  51 +++
>  security/hone/hone_ringbuf.h       |  34 ++
>  security/hone/hone_socket_lookup.c | 264 ++++++++++++++++
>  security/security.c                |   5 +
>  20 files changed, 2606 insertions(+)
>  create mode 100644 include/linux/hone.h
>  create mode 100644 security/hone/Kconfig
>  create mode 100644 security/hone/Makefile
>  create mode 100644 security/hone/hone.h
>  create mode 100644 security/hone/hone_event.c
>  create mode 100644 security/hone/hone_lsm.c
>  create mode 100644 security/hone/hone_mmutil.c
>  create mode 100644 security/hone/hone_mmutil.h
>  create mode 100644 security/hone/hone_notify.c
>  create mode 100644 security/hone/hone_pcapng.c
>  create mode 100644 security/hone/hone_pcapng.h
>  create mode 100644 security/hone/hone_ringbuf.c
>  create mode 100644 security/hone/hone_ringbuf.h
>  create mode 100644 security/hone/hone_socket_lookup.c
>
> -- 
> 2.0.0.526.g5318336
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

