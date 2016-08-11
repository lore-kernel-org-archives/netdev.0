From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Thu, 11 Aug 2016 11:52:02 -0700
Message-ID: <CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
 <1452684335-46107-4-git-send-email-hare@suse.de> <20160209210458.GB32530@localhost>
 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru> <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
 <1470787409.3015.81.camel@kernel.crashing.org> <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
 <1470873296.3015.117.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	santosh@chelsio.com, Netdev <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35272 "EHLO
	mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbcHKSwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 14:52:04 -0400
In-Reply-To: <1470873296.3015.117.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 4:54 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Wed, 2016-08-10 at 08:47 -0700, Alexander Duyck wrote:
>>
>> The problem is if we don't do this it becomes possible for a guest to
>> essentially cripple a device on the host by just accessing VPD
>> regions that aren't actually viable on many devices.
>
> And ? We already can cripple the device in so many different ways
> simpy because we have pretty much full BAR access to it...
>
>>  We are much better off
>> in terms of security and stability if we restrict access to what
>> should be accessible.
>
> Bollox. I've heard that argument over and over again, it never stood
> and still doesn't.
>
> We have full BAR access for god sake. We can already destroy the device
> in many cases (think: reflashing microcode, internal debug bus access
> with a route to the config space, voltage/freq control ....).
>
> We aren't protecting anything more here, we are just adding layers of
> bloat, complication and bugs.

To some extent I can agree with you.  I don't know if we should be
restricting the VFIO based interface the same way we restrict systemd
from accessing this region.  In the case of VFIO maybe we need to look
at a different approach for accessing this.  Perhaps we need a
privileged version of the VPD accessors that could be used by things
like VFIO and the cxgb3 driver since they are assumed to be a bit
smarter than those interfaces that were just trying to slurp up
something like 4K of VPD data.

>>  In this case what has happened is that the
>> vendor threw in an extra out-of-spec block and just expected it to
>> work.
>
> Like vendors do all the time in all sort of places
>
> I still completely fail to see the point in acting as a filtering
> middle man.

The problem is we are having to do some filtering because things like
systemd were using dumb accessors that were trying to suck down 4K of
VPD data instead of trying to parse through and read it a field at a
time.

>> In order to work around it we just need to add a small function
>> to drivers/pci/quirks.c that would update the VPD size reported so
>> that it matches what the hardware is actually providing instead of
>> what we can determine based on the VPD layout.
>>
>> Really working around something like this is not much different than
>> what we would have to do if the vendor had stuffed the data in some
>> reserved section of their PCI configuration space.
>
> It is, in both cases we shouldn't have VFIO or the host involved. We
> should just let the guest config space accesses go through.
>
>>   We end up needing
>> to add special quirks any time a vendor goes out-of-spec for some
>> one-off configuration interface that only they are ever going to use.
>
> Cheers,
> Ben.

If you have a suggestion on how to resolve this patches are always
welcome.  Otherwise I think the simpler approach to fixing this
without re-introducing the existing bugs is to just add the quirk.  I
will try to get to it sometime this weekend if nobody else does.  It
should be pretty straight foward, but I just don't have the time to
pull up a kernel and generate a patch right now.

- Alex
