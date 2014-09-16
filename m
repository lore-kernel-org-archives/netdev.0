From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Tue, 16 Sep 2014 15:44:20 +0300
Message-ID: <CAJ3xEMgEUsBic5N_eXm=OYx94FL7ERkz5CUNCo4OBhqCVwC42g@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
	<CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
	<CAEP_g=_bnr94YHKd40qipmniYs80CH4g3iFiHOgZHOnDQ82Epw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35144 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbaIPMoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 08:44:20 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo20so3478459obc.26
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 05:44:20 -0700 (PDT)
In-Reply-To: <CAEP_g=_bnr94YHKd40qipmniYs80CH4g3iFiHOgZHOnDQ82Epw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 1:44 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Sep 15, 2014 at 12:15 PM, Tom Herbert <therbert@google.com> wrote:

>> My interpretation is that NETIF_F_GSO_UDP_TUNNEL means L3/L4
>> encapsulation over UDP, not VXLAN.
>> If the NIC implements things properly following the generic interface then I believe it should work
>> with various flavors of UDP encapsulation (FOU, GUE, VXLAN, VXLAN-gpe,
>> geneve, LISP, L2TP, nvgre, or whatever else people might dream up).
>> This presumes that any encapsulation headers doesn't require any per
>> segment update (so no GRE csum for instance). The stack will set up
>> inner headers as needed, which should enough to provide to devices the
>> offsets inner IP and TCP header which are needed for the the TSO
>> operation (outer IP and UDP can be deduced also).



> From the NICs that I am familiar with this is mostly true. The main
> part that is missing from the current implementation is a length
> limit: just because the hardware can skip over headers to an offset
> doesn't mean that it can do so to an arbitrary depth. For example, in
> the NICs that are exposing VXLAN as NETIF_F_GSO_UDP_TUNNEL we can
> probably assume that this is limited to 8 bytes. With the Intel NICs
> that were just announced with Geneve support, this limit has been
> increased to 64. If we add a parameter to the driver interface to
> expose this then it should be generic across tunnels.

I'm not sure to see why the length limit became our primary concern here...

Fact is that we have nice set of NICs drivers in the kernel that do advertize
the GSO_UDP_TUNNEL feature but their HW isn't capable to segment all of:
FOU, GUE, VXLAN, VXLAN-gpe, geneve, LISP, L2TP, nvgre, or whatever
else people might dream up, right?

So we need to fix that and let each NIC properly advertize up to the
stack what they
can segment in HW and what not which means that networking code would have to
do that in SW for (say) 64KB guest TCP segment that just went through
this encapsulation.

As long as Linux didn't support any UDP encapsulation other then VXLAN
it worked,
but soon will too easily broken, and I vote for the fix to be part of
the FOU series, so we have
the kernel functional also once it applied...

Even if the encapsulated headers need no update per segment (and they always
do, e.g the IP ID field of the outer IP header) still a certain HW may
not be able
to do TCP segmentation under any encapsulation scheme.

And in that respect, I am not sure to follow on the " If the NIC
implements things properly
following the generic interface" comment.

Or.
