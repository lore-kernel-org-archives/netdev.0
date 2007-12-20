From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed correctly
Date: Fri, 21 Dec 2007 01:21:02 +0900
Message-ID: <d72b7ace0712200821k7cde0834rf1187b30c68cd1ce@mail.gmail.com>
References: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
	 <20071220091230.GB1924@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:13393 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756425AbXLTQVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 11:21:05 -0500
Received: by wr-out-0506.google.com with SMTP id c49so2411105wra.1
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 08:21:04 -0800 (PST)
In-Reply-To: <20071220091230.GB1924@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i see. HZ can be < 1000.. i should be wrong.

however, i got the following,

[root iproute2.org]# ./ip/ip route change 192.168.140.0/24 dev eth1 rto_min 4s
[root iproute2.org]# gdb -q ./ip/ip
Using host libthread_db library "/lib/libthread_db.so.1".
(gdb) br iproute.c:512
Breakpoint 1 at 0x804fc8d: file iproute.c, line 512.
(gdb) r route show dev eth1
Starting program: /root/iproute2.org/ip/ip route show dev eth1

Breakpoint 1, print_route (who=0xbfb9854c, n=0xbfb94528, arg=0x6404c0)
at iproute.c:512
512                                     unsigned val =
*(unsigned*)RTA_DATA(mxrta[i]);
(gdb) l 512,522
512                                     unsigned val =
*(unsigned*)RTA_DATA(mxrta[i]);
513
514                                     val *= 1000;
515                                     if (i == RTAX_RTT)
516                                             val /= 8;
517                                     else if (i == RTAX_RTTVAR)
518                                             val /= 4;
519                                     if (val >= hz)
520                                             fprintf(fp, " %ums", val/hz);
521                                     else
522                                             fprintf(fp, " %.2fms",
(float)val/hz);
(gdb) p hz
$1 = 1000000000
(gdb) n
514                                     val *= 1000;
(gdb) p val
$2 = 4000000000
(gdb) p val/ (hz / 1000)
$3 = 4000
(gdb) n
515                                     if (i == RTAX_RTT)
(gdb) p val
$4 = 1385447424
(gdb) c
Continuing.
192.168.140.0/24  scope link  rto_min lock 1ms

Program exited normally.
(gdb)


Thanks,
Satoru SATOH

2007/12/20, Jarek Poplawski <jarkao2@gmail.com>:
> On 20-12-2007 04:31, Satoru SATOH wrote:
> > "ip route show" does not print correct value when larger rto_min is
> > set (e.g. 3sec).
> >
> > This problem is because of overflow in print_route() and
> > the patch below is a workaround fix for that.
> >
> ...
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -510,16 +510,16 @@ int print_route(const struct sockaddr_nl *who,
> > struct nlmsghdr *n, void *arg)
> >                                 fprintf(fp, " %u",
> > *(unsigned*)RTA_DATA(mxrta[i]));
> >                         else {
> >                                 unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
> > +                               unsigned hz1 = hz / 1000;
> ...
> > +                               if (val >= hz1)
> > +                                       fprintf(fp, " %ums", val/hz1);
> ...
>
> Probably I miss something or my iproute sources are too old, but:
> does this work with hz < 1000?
>
> Regards,
> Jarek P.
