From: Dan Williams <dcbw@redhat.com>
Subject: Re: commit : ppp: add rtnetlink device creation support - breaks
 netcf on my machine.
Date: Tue, 06 Dec 2016 17:12:46 -0600
Message-ID: <1481065966.11028.3.camel@redhat.com>
References: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
         <20161205175320.mbtswpmdjumfgh7y@alphalink.fr>
         <5d537b7e-97e9-709c-7b3e-61280cc264f8@fnarfbargle.com>
         <20161206230853.ukyg75cyxugdwg4a@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
        David Miller <davem@davemloft.net>, thaller@redhat.com
To: Guillaume Nault <g.nault@alphalink.fr>,
        Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33016 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751134AbcLFXMt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 18:12:49 -0500
In-Reply-To: <20161206230853.ukyg75cyxugdwg4a@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 00:08 +0100, Guillaume Nault wrote:
> (Cc Thomas and David)

CC Thomas Haller who is the current libnl maintainer...

Dan

> On Tue, Dec 06, 2016 at 03:47:20PM +0800, Brad Campbell wrote:
> > 
> > On 06/12/16 01:53, Guillaume Nault wrote:
> > > 
> > > > 
> > > > 
> > > Probably not a mistake on your side. I've started looking at
> > > netcf'
> > > source code, but haven't found anything that could explain your
> > > issue.
> > > It'd really help if you could provide steps to reproduce the bug.
> > 
> > Further to my message this morning, I started with a clean
> > linux.git
> > 4.9.0-rc7-00198-g0cb65c8 and did two runs. One untouched and one
> > with the
> > identified patch reverted. I logged both of these with NLCB=debug,
> > then
> > split out the ppp section and diffed them.
> > 
> > It appears the only difference of note is the new ATTR 18. I did a
> > diff of
> > the entire dump for both and nothing else popped out.
> > 
> Thanks for the detailed report. Things are getting clear now.
> 
> > 
> > 
> > brad@test:~$ diff -u ppp-ok ppp-fail
> > --- ppp-ok	2016-12-06 13:32:04.358393578 +0800
> > +++ ppp-fail	2016-12-06 13:32:18.577864406 +0800
> > @@ -1,10 +1,10 @@
> >  --------------------------   BEGIN NETLINK MESSAGE
> > ---------------------------
> >    [HEADER] 16 octets
> > -    .nlmsg_len = 628
> > +    .nlmsg_len = 644
> >      .nlmsg_type = 16 <route/link::new>
> >      .nlmsg_flags = 2 <MULTI>
> > -    .nlmsg_seq = 1481001940
> > -    .nlmsg_pid = 7462
> > +    .nlmsg_seq = 1481002252
> > +    .nlmsg_pid = 7376
> >    [PAYLOAD] 16 octets
> >      00 00 00 02 0a 00 00 00 d1 10 01 00 00 00 00
> > 00       ................
> >    [ATTR 03] 5 octets
> > @@ -71,6 +71,8 @@
> >      00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > ..................
> >      00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > ..................
> >      00 00 00 00 00 00                                     ......
> > +  [ATTR 18] 12 octets
> > +    08 00 01 00 70 70 70 00 04 00 02
> > 00                   ....ppp.....
> >    [ATTR 26] 132 octets
> >      84 00 02 00 80 00 01 00 01 00 00 00 00 00 00 00 00 00
> > ..................
> >      00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
> > ..................
> > @@ -81,3 +83,4 @@
> >      00 00 00 00 10 27 00 00 e8 03 00 00 00 00 00 00 00 00
> > .....'............
> >      00 00 00 00 00 00                                     ......
> >  ---------------------------  END NETLINK MESSAGE
> > ---------------------------
> > 
> 'ATTR 18' is the IFLA_LINKINFO attribute. It contains two sub-
> attributes:
>   * IFLA_INFO_KIND ('08 00 01 00 70 70 70 00'), containing the "ppp"
>     string,
>   * and IFLA_INFO_DATA ('04 00 02 00') which has no payload because,
>     currently, ppp has no device specific data to return.
> 
> > 
> > Running with NLDBG=4 seems to generate this :
> > DBG<2>: While picking up for 0x26d2e00 <route/link>, recvmsgs()
> > returned
> > -34:  (errno = Numerical result out of range)DBG<1>: Clearing cache
> > 0x26d2e00 <route/link>...
> > 
> libnl1 rejects the IFLA_INFO_DATA attribute because it expects it to
> contain a sub-attribute. Since the payload size is zero it doesn't
> match the policy and parsing fails.
> 
> There's no problem with libnl3 because its policy accepts empty
> payloads for NLA_NESTED attributes (see libnl3 commit 4be02ace4826
> "Be
> liberal when receiving an empty nested attribute").
> 
> I think empty nested attributes make perfect sense. At least we
> accept
> them from user space since commit ea5693ccc553 ("netlink: allow empty
> nested attributes"), so it should be fine to generate some from the
> kernel.
> OTOH, since some user space programs broke because of this, it might
> be
> better to always add attributes in the .fill_info() callbacks, to
> work
> around libnl1's policy. David, Thomas, do you have any opinion on
> this?
