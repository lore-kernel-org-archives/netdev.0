From: Paul Stewart <pstew@chromium.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Fri, 22 Apr 2011 07:59:18 -0700
Message-ID: <BANLkTikjRzBjQ7uar+GDSGsPvK8snY84rQ@mail.gmail.com>
References: <BANLkTinhmAfe1V2SvoY+J6Tu_DdnZMoYgw@mail.gmail.com>
	<Pine.LNX.4.44L0.1104211436540.1939-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, USB list <linux-usb@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:25063 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275Ab1DVO7U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 10:59:20 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p3MExJKp009506
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 07:59:20 -0700
Received: from gwj21 (gwj21.prod.google.com [10.200.10.21])
	by kpbe12.cbf.corp.google.com with ESMTP id p3MEwY6v025978
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 07:59:18 -0700
Received: by gwj21 with SMTP id 21so215747gwj.2
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 07:59:18 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.44L0.1104211436540.1939-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2011 at 11:48 AM, Alan Stern <stern@rowland.harvard.edu=
> wrote:
> On Thu, 21 Apr 2011, Paul Stewart wrote:
>
>> > The driver needs better coordination between open/stop and
>> > resume/suspend. =EF=BF=BDThe interrupt and receive URBs are suppos=
ed to be
>> > active whenever the interface is up and not suspended, right? =EF=BF=
=BDWhich
>> > means that usbnet_resume() shouldn't submit anything if the interf=
ace
>> > isn't up.
>>
>> How do we define "up" here (from a network perspective there are man=
y
>> ways to interpret that)? =C2=A0How does this concept compare to the =
user's
>> "ifconfig up/down" state?
>
> I don't know the details of how network drivers are supposed to work.
> But it doesn't matter -- for your purposes you should define "up" to
> mean "whenever the URBs are supposed to be active (unless the interfa=
ce
> is suspended)".
>
>> =C2=A0What call do I use in usbnet_resume() to
>> tell that the interface isn't up? =C2=A0Currently I'm using netif_ru=
nning()
>> which responds true in this condition, which is why I'm resorting to
>> the flag.
>
> Again, I don't know. =C2=A0However, the URBs get submitted from withi=
n
> usbnet_open() and killed within usbnet_stop(), right? =C2=A0Therefore=
 you
> can use any condition which gets set to True in usbnet_open() and set
> to False in usbnet_stop(). =C2=A0(If nothing else is suitable, use a =
flag of
> your own.)

This is exactly the situation I'm in.  I couldn't find any other
driver or network state that cleanly represented the stop/start state
of the driver.  I'll post a new patch that uses an OPEN flag instead
of an interrupt halted flag, a GFP_NOIO flag, and kills and frees the
interrupt URB on usb_disconnect().

> =C2=A0And be careful of the edge case: Since usbnet_open() itself
> performs a resume operation, you need to make sure the resume takes
> place before the condition becomes True -- otherwise the URBs will ge=
t
> submitted twice.
>
> One more thing to keep in mind: If the kernel is built without PM
> support, the resume and suspend routines will never get called.
> Therefore they must not be the only places where URBs are submitted a=
nd
> killed.
>
> Alan Stern
>
>
