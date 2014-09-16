From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Tue, 16 Sep 2014 13:31:00 -0700
Message-ID: <CA+mtBx-dwzZaRO=YmyCFVvz_T0ZsC_+EdPDmbW0GQ2hLxFrNJQ@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
	<CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
	<CAEP_g=_bnr94YHKd40qipmniYs80CH4g3iFiHOgZHOnDQ82Epw@mail.gmail.com>
	<CAJ3xEMgEUsBic5N_eXm=OYx94FL7ERkz5CUNCo4OBhqCVwC42g@mail.gmail.com>
	<CA+mtBx-B-25-nS1pVgeCiuykdFydCiay0QCwiE75P37Q3ODRCQ@mail.gmail.com>
	<CAJ3xEMghyiuo3TOdsiSBOBBOk21zSfso6fdt-jEqY5ifA2Q1vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:60230 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbaIPUbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:31:02 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar1so412308iec.35
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 13:31:00 -0700 (PDT)
In-Reply-To: <CAJ3xEMghyiuo3TOdsiSBOBBOk21zSfso6fdt-jEqY5ifA2Q1vg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 12:14 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Sep 16, 2014 at 9:34 PM, Tom Herbert <therbert@google.com> wrote:
>> On Tue, Sep 16, 2014 at 5:44 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Tue, Sep 16, 2014 at 1:44 AM, Jesse Gross <jesse@nicira.com> wrote:
>>>> On Mon, Sep 15, 2014 at 12:15 PM, Tom Herbert <therbert@google.com> wrote:
>>>
>>>>> My interpretation is that NETIF_F_GSO_UDP_TUNNEL means L3/L4
>>>>> encapsulation over UDP, not VXLAN.
>>>>> If the NIC implements things properly following the generic interface then I believe it should work
>>>>> with various flavors of UDP encapsulation (FOU, GUE, VXLAN, VXLAN-gpe,
>>>>> geneve, LISP, L2TP, nvgre, or whatever else people might dream up).
>>>>> This presumes that any encapsulation headers doesn't require any per
>>>>> segment update (so no GRE csum for instance). The stack will set up
>>>>> inner headers as needed, which should enough to provide to devices the
>>>>> offsets inner IP and TCP header which are needed for the the TSO
>>>>> operation (outer IP and UDP can be deduced also).
>>>
>>>
>>>
>>>> From the NICs that I am familiar with this is mostly true. The main
>>>> part that is missing from the current implementation is a length
>>>> limit: just because the hardware can skip over headers to an offset
>>>> doesn't mean that it can do so to an arbitrary depth. For example, in
>>>> the NICs that are exposing VXLAN as NETIF_F_GSO_UDP_TUNNEL we can
>>>> probably assume that this is limited to 8 bytes. With the Intel NICs
>>>> that were just announced with Geneve support, this limit has been
>>>> increased to 64. If we add a parameter to the driver interface to
>>>> expose this then it should be generic across tunnels.
>>>
>>> I'm not sure to see why the length limit became our primary concern here...
>
>> Like Jesse mentioned above, looks like some NICs may have assumed all
>> encapsulation headers are eight bytes (which allows HW to implement
>> everything in fixed offsets). But this length is not a universal
>> constant: FOU is zero length encapsulation headers, GUE or geneve is
>> variable. The driver should really be checking if NIC can handle the
>> length and if it can't perform GSO in software-- I don't think we'll
>> need to expose this in the features.
>
> I understand that for some NICs there's a claim saying the essence of
> the limitation lies in an assumption on fixed length of the
> encapsulation headers  -- and BTW for VXLAN it's 50 (= 14 + 20 + 8 +
> 8) bytes, not eight. So newer NICs  or new brands of existing NICs
> should be more flexible.
>
> If I correctly read your comment "The driver should really be checking
> if NIC can handle the length and if it can't perform GSO in software"
> as saying that a SW GSO call should be made from within the driver
> when they can't serve GSO under some encap scheme -- I don't think
> this is the correct track, the driver should advertize up what they
> can do in HW so the stack does in SW what's not supported.
>
The problem is that it is likely impractical for drivers to advertise
all possible constraints of their HW. Right now we have the features
flags, but that is very limited and we really can't afford to add a
new value for every permutation.  There are just to many dimensions.
Some devices might expect fixed length headers, some might not but
might have other length constraints. Some may perfectly happy with
v4/v4 but maybe choke on combinations with IPv6. Others may not mind
IP options or extension headers, some might be okay. Some devices
might not like certain packet layouts, etc.

There is precedent for the driver punting to software mechanisms when
it can't handle something. For instance, cxgb veth call
skb_checksum_help for resolving UDP checksums, myri10ge and marvell
controller call it for headers that are too large. gianfar calls it
per some errata condition...

If we can't do GSO from within the drivers, then another alternative
would be to add an ndo_gso_check function to call when stack is
deciding whether to do SW GSO.

> Another clarification - so FOU doesn't supersedes GUE? what's their
> difference...?
>
FOU is direct encapsulation of IP protocol packets in UDP payload. GUE
is an encapsulation header between UDP and the encapsulated IP
protocol packet. http://tools.ietf.org/html/draft-herbert-gue-01


Tom

> Or.
