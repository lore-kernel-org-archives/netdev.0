From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 29/29] fm10k: Add support for PTP
Date: Sat, 20 Sep 2014 16:36:45 -0700
Message-ID: <541E0F8D.3040900@gmail.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com> <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com> <20140919173504.GA4136@localhost.localdomain> <541C76B8.6040708@intel.com> <20140920211647.GB5258@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:56470 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaITXgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 19:36:47 -0400
Received: by mail-pa0-f43.google.com with SMTP id kx10so2299772pab.30
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 16:36:47 -0700 (PDT)
In-Reply-To: <20140920211647.GB5258@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2014 02:16 PM, Richard Cochran wrote:
> On Fri, Sep 19, 2014 at 11:32:24AM -0700, Alexander Duyck wrote:
>> Because the value cannot be adjusted directly.  The timesource for the
>> switch is shared by all ports and host interfaces.  As such we have to
>> maintain a software offset per host to avoid corrupting the other clocks.
> So any host can set the time, but only one may adjust the frequency?

Yes.  Essentially the one who should be adjusting the frequency should
be the host interface that is providing traffic for the control plane
processor.  That way the control plane processor can act as a boundary
clock and can adjust the frequency to match the port it has decided to
be a slave on.

In the case of the ordinary clock host interfaces they will be slaves to
the boundary clock and since they share the same clock source anyway
they shouldn't need any frequency adjustments, or at least that is how
it is supposed to work.  The other reason for using the software offset
is that it can be very time intensive as you have to stop the clock,
update the staring value for each host interface and the Ethernet ports,
and then you can resume the clock.  It can be a rather time consuming
process doing it that way versus just maintaining an offset in software.

Tx timestamps from the host interface are actually identical to the Rx
timestamps on the receiving host interface in the case of traffic going
between two fm10k host interfaces on the same switch.  So what you end
up with is that any two hosts should be able to perfectly synchronize
their clocks with just the follow-up to the first sync message.  I've
done some testing for this with an FPGA and actually it has proven out
as ptp4l did one offset adjustment on the follow-up and then indicated 0
adjustments from there forward.  It is one of the reasons why I believe
we should be able to disable the frequency adjustment for interfaces
configured as ordinary clocks.

> Regarding the overflow, probably you can remove the daily check, since
> you only need a single clock read every 300 years, and that is
> reasonable to expect in any case.

Yeah, I figured that out after I recalled that the overflow check is
only really necessary if the mask is less than 64 bits.

Thanks,

Alex
