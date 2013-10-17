From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: transmit lockup using smsc95xx ethernet on usb3
Date: Wed, 16 Oct 2013 17:07:58 -0700
Message-ID: <20131017000758.GL7082@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B738B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Xenia Ragiadakou <burzalodowa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B738B-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2013 at 10:59:18AM +0100, David Laight wrote:
> We are seeing complete lockups of the transmit side when using
> the smsc95xx driver connected to a USB3 port on an i7 (Ivybridge) cpu.
> These errors are very intermittent - less than once a day, and
> it isn't actually clear that they are related to traffic load.
> 
> Most of the systems are running the 3.2 kernel from Ubuntu 12.04
> but I've seen the same problem when running a 3.4 kernel.

Have you tried the latest stable kernel or the latest -rc kernel?

> Looking at the changelog for xhci-ring.c I can see that some
> 'nasty' bugs were fixed between 3.2 and 3.4 (and possibly since)
> but the usbmon trace I've now got doesn't seem to match any
> of the changelog entries.
> 
> We are also seeing similar problems if we connect to a USB2
> header.

Do you mean a USB 2.0 port under the xHCI host controller?  What does
`lsusb -t` show as the parent host controller in that case?

> Since we can't reproduce the problem quickly it is difficult to
> do any analysis. Any suggestions for increasing the error rate
> would be welcome.
> 
> Below is an annotated extract from a usbmon trace while running
> a netperf test that was sending 8192 byte TCP packets (nagle off).
> I've deleted the Bi entries (packets are received throughout)
> and numbered all the others (modulo 10000) so it is easier to
> see when the requests complete, I've also calculated the elapsed
> time and the number of Setup entries between the S and C traces.
> 
> The USB ring seems to have 60 outstanding transmits in it,
> each time one completes another is sent. There are a few 10000
> traces of that then:
> 
>   start:9870         ffff88020ea16000 293811125 S Bo:3:003:2 -115 1514 =
>                         e2350000 e2450000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 05d0ff11
>    done:9811:6969:60 ffff88020c7c8000 293811236 C Bo:3:003:2 0 1090 >
>   start:9871         ffff88020ea16a80 293811242 S Bo:3:003:2 -115 1090 =
>                         3a340000 3a440000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 0428ff12
> ...
>   start:9929         ffff88020ea16780 293817964 S Bo:3:003:2 -115 1514 =
>                         e2350000 e2450000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 05d0ff4c
> Last successful completion.
>    done:9870:6968:60 ffff88020ea16000 293818093 C Bo:3:003:2 0 1514 >
>   start:9930         ffff88020ea16000 293818099 S Bo:3:003:2 -115 1514 =
>                         e2350000 e2450000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 05d0ff4d
> 
> At this point something (untraced) seems to have gone horribly
> wrong in the transmit ring. dmesg shows nothing.
> Two Bo 'fail -71', 6 succeed, one fails -32 the rest fail -104.
>    done:9871:6913:60 ffff88020ea16a80 293818155 C Bo:3:003:2 -71 512 >
>    done:9872:6927:59 ffff88020ea16f00 293818235 C Bo:3:003:2 -71 0
>    done:9873:6875:58 ffff88020ea16480 293818313 C Bo:3:003:2 0 1514 >
>    done:9874:6786:57 ffff88020c7c83c0 293818353 C Bo:3:003:2 0 1514 >
>    done:9875:6794:56 ffff88020c7c80c0 293818470 C Bo:3:003:2 0 1514 >
>    done:9876:6789:55 ffff88020c7c8e40 293818589 C Bo:3:003:2 0 1514 >
>    done:9877:6775:54 ffff88020c7c8240 293818702 C Bo:3:003:2 0 1090 >
>    done:9878:6751:53 ffff88020c7c8180 293818803 C Bo:3:003:2 0 1514 >
>    done:9879:6735:52 ffff88020c7c89c0 293818885 C Bo:3:003:2 -32 0
>    done:9880:6671:51 ffff88020c7c8900 293818925 C Bo:3:003:2 -104 0
> ...
>     done:9927:1292:4 ffff88020cf0c480 293819015 C Bo:3:003:2 -104 0
>     done:9928:1170:3 ffff88020ea160c0 293819016 C Bo:3:003:2 -104 0
> Something is known to be wrong...
>   start:9931         ffff88020ea160c0 293819037 S Co:3:003:0
>                          s 02 01 0000 0002 0000 0
>     done:9929:1080:3 ffff88020ea16780 293819044 C Bo:3:003:2 -104 0
>      done:9930:945:2 ffff88020ea16000 293819044 C Bo:3:003:2 -104 0
>       done:9931:48:1 ffff88020ea160c0 293819085 C Co:3:003:0 0 0
> 
> These 10 transmits never finish:
>   start:9932         ffff88020ea160c0 293819098 S Bo:3:003:2 -115 1090 =
>                         3a340000 3a440000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 0428ff4e
> ... 9933 to 9940 deleted
>   start:9941         ffff88020ea16b40 293819111 S Bo:3:003:2 -115 1514 =
>                         e2350000 e2450000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 05d0ff57
> 
> All further transmits fail immediately E -12 and generate the
>     'xhci_hcd 0000:00:14.0: ERROR no room on ep ring' message.
> (There are 1070 'E' traces and 1070 'no room' messages.)
> Receives are still working.
>   start:9942         ffff88020ea16240 293819113 S Bo:3:003:2 -115 1514 =
>                         e2350000 e2450000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 05d0ff58
>     done:9942:1550:1 ffff88020ea16240 293820663 E Bo:3:003:2 -12 0
>   start:9943         ffff88020ea16240 293820675 S Bo:3:003:2 -115 1514 =
>                         e2350000 e2450000 22003200 00224d98
>                         d8460002 1f0057d7 08004500 05d0ff59
>     done:9943:1507:1 ffff88020ea16240 293822182 E Bo:3:003:2 -12 0
> 
> Eventually something causes a device remove and insert - everything re-initialises.
> This is over 12 hours later.
>       done:unknown   ffff88020c8570c0 3637139297 C Ii:3:001:1 0:2048 1 = 02
>   start:1015         ffff88020c8570c0 3637139302 S Ii:3:001:1 -115:2048 4 <
>   start:1016         ffff88020cbeb300 3637139323 S Ci:3:001:0
>                          s a3 00 0000 0001 0004 4 <
>                      ffff88020ea16240 3637139331 C Bi:3:003:1 -71 0
>        done:1016:9:1 ffff88020cbeb300 3637139332 C Ci:3:001:0 0 4 = 00010100
>   start:1017         ffff88020cbeb300 3637139334 S Co:3:001:0
>                          s 23 01 0010 0001 0000 0
>        done:1017:4:1 ffff88020cbeb300 3637139338 C Co:3:001:0 0 0
>       done:unknown   ffff88020ca9ae40 3637139423 C Ii:3:003:3 -71:1 0
>                      ffff88020c9db540 3637139428 C Bi:3:003:1 -108 0
>                      ffff88020c9db780 3637139430 C Bi:3:003:1 -108 0
>                      ffff88020d8bb540 3637139431 C Bi:3:003:1 -108 0
> 
> The last 10 transmits then terminate with error -108:
>  done:9932:xxxx      ffff88020ea160c0 3637139462 C Bo:3:003:2 -108 0
> ... 9933 to 9940 deleted
>  done:9941:xxxx      ffff88020ea16b40 3637139482 C Bo:3:003:2 -108 0
>    done:1015:21090:3 ffff88020c8570c0 3637160392 C Ii:3:001:1 0:2048 1 = 02
>   start:1018         ffff88020c8570c0 3637160396 S Ii:3:001:1 -115:2048 4 <
>       done:unknown   ffff88020cbf26c0 3637176790 C Ii:3:005:1 -108:8 0
>       done:unknown   ffff88020c68aa80 3637622497 C Ii:3:002:1 -108:2048 0
> 
> Followed by lots of Ci/Co and eventually it all starts working again.
> 
> I've not yet tried to look up the control transfers.
> 
> These aren't the only errors we are seeing, we also see (separately):
> [21549.917529] hub 3-2:1.0: port 1 disabled by hub (EMI?), re-enabling...
> [ 5822.629579] NETDEV WATCHDOG: eth0 (smsc95xx): transmit queue 0 timed out
> [ 7263.834404] hid-generic 0003:413C:2005.0002: can't reset device, 0000:00:1a.0-1.4.3/input0, status -71 (connected to a USB2 header).
> These all cause a USB bus reset and everything recovers within a couple of seconds.

I would suggest you try with the latest stable kernel, with
CONFIG_USB_DEBUG and CONFIG_USB_XHCI_HCD_DEBUGGING enabled.  If you try
the latest 3.12-rc, you will only need the CONFIG_USB_DEBUG.  Or, if
that output is too much (it will spew on short packets, which may be an
issue with your ethernet adapter), with the 3.12-rc kernel, you can turn
off CONFIG_USB_DEBUG and capture command trace events through the xHCI
trace infrastructure.  Xenia can help you with that if necessary (I'm
going to be at a conference starting Friday).

Without that dmesg, I really can't tell what's happening at an xHCI
level.

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
