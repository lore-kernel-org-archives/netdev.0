From: "Noah J. Misch" <noah@caltech.edu>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Mon, 13 Oct 2003 22:52:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.58.0310132128450.8530@blinky>
References: <Pine.GSO.4.58.0310101519330.9806@inky> <20031012201316.7ecf73c8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>, Elmer.Joandi@ut.ee, elmer@ylenurme.ee
In-Reply-To: <20031012201316.7ecf73c8.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy,

I poked around the driver a bit and uncovered a few points that suggest to me a
different approach to the problem.

The file arlan-proc.c contains a number of functions supporting the driver's
sysctl interface.  Nothing in that file appears procfs-specific.

I would change the Makefile to compile arlan-proc.c depending on CONFIG_SYSCTL
and remove the #ifdef CONFIG_PROC_FS guarding much of that file.  I would then
make arlan.h define macro or static inline stubs for init_arlan_proc and
cleanup_arlan_proc much like the current arlan.h does.

For the matter, perhaps one could add an extra config option, ARLAN_SYSCTL, that
depends on ARLAN and SYSCTL, and conditional-compile arlan-proc.c on that
instead of CONFIG_SYSCTL itself.  That way, users could leave it out to save
space without zapping all sysctls.  I would go for this approach myself.

The configuration help text for the arlan driver claims that it builds a module
for the driver and another for its sysctl interface.  It doesn't do that at the
moment, but that is another option (though not one I like as much).

What do you think?

On Sun, 12 Oct 2003, Randy.Dunlap wrote:

> On Fri, 10 Oct 2003 16:06:29 -0700 (PDT) "Noah J. Misch" <noah@caltech.edu> wrote:
>
> | > There are several other drivers/protocols that don't build
> | > with PROC_FS=n, like arlan, siimage, ipx, llc, and bluetooth.
>
>
> Here's a patch for the wireless/arlan driver for PROC_FS=n.
> Currently it defines both a function and a macro for
> init_arlan_proc() if PROC_FS=n.  This causes a bunch of
> compile-time errors.
>
> It looks to me like it should always call the init_arlan_proc()
> (and cleanup_arlan_proc()) functions since it inits some sysctl tables.
> Or am I misunderstanding it?
>
> Thanks,
> --
> ~Randy
>
>
> patch_name:	arlan_noprocfs.patch
> patch_version:	2003-10-12.19:46:24
> author:		Randy.Dunlap <rddunlap@osdl.org>
> description:	use init_arlan_proc() for sysctl inits
> product:	Linux
> product_versions: 2.6.0-test7
> diffstat:	=
>  drivers/net/wireless/arlan.h |    5 -----
>  1 files changed, 5 deletions(-)
>
>
> diff -Naur ./drivers/net/wireless/arlan.h~arlanprocfs ./drivers/net/wireless/arlan.h
> --- ./drivers/net/wireless/arlan.h~arlanprocfs	2003-10-08 12:24:08.000000000 -0700
> +++ ./drivers/net/wireless/arlan.h	2003-10-12 19:45:46.000000000 -0700
> @@ -39,13 +39,8 @@
>  #define ARLAN_RCV_PROMISC 1
>  #define ARLAN_RCV_CONTROL 2
>
> -#ifdef CONFIG_PROC_FS
>  extern int init_arlan_proc(void);
>  extern void cleanup_arlan_proc(void);
> -#else
> -#define init_arlan_proc()	(0)
> -#define cleanup_arlan_proc()	do { } while (0);
> -#endif
>
>  extern struct net_device *arlan_device[MAX_ARLANS];
>  extern int	arlan_debug;
>
>
