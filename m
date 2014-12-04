From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Use rtnl_dump_filter in handle_netlink_request
Date: Thu, 4 Dec 2014 02:00:08 +0200
Message-ID: <CAMw6YJLu=7NMRUZVBBvff8f4U3CyDRXPkH3BJOwFbZKWSdzi2Q@mail.gmail.com>
References: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
	<20141203092129.49f16769@urahara>
	<20141203172010.GA8639@angus-think.wlc.globallogic.com>
	<20141203095123.40429f4c@urahara>
	<20141203174506.GA12511@angus-think.wlc.globallogic.com>
	<CAMw6YJ+W0KCvGrfij990+BU2EsW6E4SEWJRsrRgk=vnq-okjzQ@mail.gmail.com>
	<20141203150748.001d481e@urahara>
	<20141203232819.GA12656@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38556 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbaLDAAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 19:00:10 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so33033018wib.16
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 16:00:08 -0800 (PST)
In-Reply-To: <20141203232819.GA12656@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ofcourse I think it is possible to add checking if protocol ==
NETLINK_INET_DIAG protocol
and dont print the error message in lib/netlink.c  if errno == ENOENT,
but I am not sure if you will like such approach ...

On Thu, Dec 4, 2014 at 1:28 AM,  <vadim4j@gmail.com> wrote:
> On Wed, Dec 03, 2014 at 03:07:48PM -0800, Stephen Hemminger wrote:
>> On Thu, 4 Dec 2014 00:15:54 +0200
>> Vadim Kochan <vadim4j@gmail.com> wrote:
>>
>> > I established some simple OpenVPN connection (at least by the logs and
>> > ss I see that peer is connected), but
>> > I dont get any errors with ss.
>> >
>> > So can you please provide some more info how did you tested this patch
>> > ? I am surprised that this is caused only
>> > by these changes ...
>> >
>> > On Wed, Dec 3, 2014 at 7:45 PM,  <vadim4j@gmail.com> wrote:
>> > > On Wed, Dec 03, 2014 at 09:51:23AM -0800, Stephen Hemminger wrote:
>> > >> On Wed, 3 Dec 2014 19:20:10 +0200
>> > >> vadim4j@gmail.com wrote:
>> > >>
>> > >> > On Wed, Dec 03, 2014 at 09:21:29AM -0800, Stephen Hemminger wrote:
>> > >> > > On Tue,  2 Dec 2014 16:53:04 +0200
>> > >> > > Vadim Kochan <vadim4j@gmail.com> wrote:
>> > >> > >
>> > >> > > > Replaced handling netlink messages by rtnl_dump_filter
>> > >> > > > from lib/libnetlink.c, also:
>> > >> > > >
>> > >> > > >     - removed unused dump_fp arg;
>> > >> > > >     - added MAGIC_SEQ #define for 123456 seq id
>> > >> > > >
>> > >> > > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>> > >> > >
>> > >> > > This doesn't work correctly.
>> > >> > >
>> > >> > > Simple test
>> > >> > >   $ misc/ss >/dev/null
>> > >> > > RTNETLINK answers: No such file or directory
>> > >> > > RTNETLINK answers: No such file or directory
>> > >> > > RTNETLINK answers: No such file or directory
>> > >> >
>> > >> > Just tried, I did not get such errors.
>> > >>
>> > >> I have OpenVPN running.
>> > >
>> > > Hm, it is reproduced only with this patch ?
>> > > If so I will try to setup OpenVPN ... can't imagine how it can be
>> > > related ...
>>
>> I am running on 3.17.4 kernel if that helps.
>
> OK, thank you!
>
> I see a reason why it was caused by this patch. So the difference is in
> the way how the libnetlink/rtnl_* and original ss.c handles the
> NLMSG_ERROR, ss.c netlink handler checks errno ENOENT (No such file or directory)
> and silently closes file end returns -1, but rtnl_* prints the error message.
>
> Meanwhile I dont know the real reason why ENOENT error is happaned, may
> be it is OK in context of diagnostic messages. But I grepped over the
> commits and found that this ENOENT checking was added by Eric in:
>
>     commit a3fd8e58c1787af186f5c4b234ff974544f840b6
>     Author: Eric Dumazet <eric.dumazet@gmail.com>
>     Date:   Mon Jan 30 17:05:45 2012 +0100
>
>     ss: should support CONFIG_INET_UDP_DIAG=n kernels
>
>     ss -x currently fails if CONFIG_INET_UDP_DIAG=n or old kernels
>
>     Also close file descriptors while we are at it.
>
>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Cc: Pavel Emelyanov <xemul@parallels.com>
