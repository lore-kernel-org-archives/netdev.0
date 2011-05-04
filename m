From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Tue, 3 May 2011 20:10:14 -0700
Message-ID: <BANLkTinkFzF5a42c+_7CvHsBwuyZADQt0A@mail.gmail.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
	<20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
	<4DC08E7B.7070906@chelsio.com>
	<1304465684.2873.26.camel@bwh-desktop>
	<4DC09DE0.8070102@intel.com>
	<4DC0AD7B.7070009@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f170.google.com ([209.85.212.170]:62080 "EHLO
	mail-px0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360Ab1EDDKO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 23:10:14 -0400
Received: by pxi19 with SMTP id 19so521522pxi.1
        for <netdev@vger.kernel.org>; Tue, 03 May 2011 20:10:14 -0700 (PDT)
In-Reply-To: <4DC0AD7B.7070009@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 3, 2011 at 6:35 PM, Dimitris Michailidis <dm@chelsio.com> w=
rote:
> On 05/03/2011 05:29 PM, Alexander Duyck wrote:
>> The thing to keep in mind is that the index doesn't have to be a har=
dware
>> index. =A0In ixgbe we have a field in the hardware which is meant to=
 just be a
>> unique software index and that is what I am using as the location fi=
eld for
>> our filters. =A0All the location information in the rules really pro=
vides is a
>> logical way of tracking rules. =A0It doesn't necessarily have to rep=
resent the
>> physical location of the rule in hardware.
>
> I appreciate the intent but there are couple problems.
> a) ethtool.h documents location as
>
> =A0* @location: Index of filter in hardware table
>
> i.e., physical location. =A0But we could change that.

I will probably want to change that.  The fact is as I recall even niu
was using a hash in addition to the location index.  As such it isn't
really the true location in the hardware since there is a second piece
to determining the actual location in hardware.

> b) for TCAMs physical location is important and if ethtool offers to =
provide
> only a logical index and massages the original user input to do so wh=
ere
> will a driver get the physical location it ultimately needs? =A0For a=
 device
> with physical indices a multiple of 4 the logical index ethtool picks=
 will
> very frequently be illegal as physical location. =A0E.g., if location=
 1 is
> available ethtool will keep selecting it and the driver will need to =
deal
> with these requests without the benefit of knowing what the user real=
ly
> asked for.
>
> Another problem with ethtool selecting locations is it assumes it's t=
he sole
> allocator (I think there's a comment in the code pointing this out). =
=A0But
> this isn't a valid assumption, e.g., HW RFS comes to mind as another
> allocator.

The other thing to keep in mind is that this doesn't preclude the
option of adding an ethtool command at some point in the future for
handling the determination of filter location.  The fact is all that
would need to be done is to add an extra ioctl call to determine the
location based on the filter and if that returns op not supported we
fall back to the current rule manager.

The way I have things setup now provides a good foundation in
user-space for managing the rules.  I fully admit it doesn't fit all
solutions, and I welcome follow-on patches to add extra functionality,
but at this time I really would prefer avoiding adding extra
functionality for yet to be implemented features in device drivers.
The ntuple display functionality provides a good example of why I
would prefer to avoid it.  Everything looked like it should have
worked when get_rx_ntuple was implemented in the device drivers, but
as soon as I implemented a get_rx_ntuple for ixgbe I quickly
discovered it didn't work and as such I am now stuck moving everything
over to network flow classifier for ixgbe.

Thanks,

Alex
