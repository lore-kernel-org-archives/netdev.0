From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v7 net-next 01/16] gso: Remove arbitrary checks for
 unsupported GSO
Date: Fri, 20 May 2016 20:56:34 -0700
Message-ID: <CAKgT0Uc9eqYtXB=HVVitF1BWkoVZv8tqppwbQdnhKbfJ-VA_ew@mail.gmail.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
	<1463587584-2315623-2-git-send-email-tom@herbertland.com>
	<cc2e026a-6ab0-8d52-5c3d-29843c6ddf40@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35287 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbcEUD4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 23:56:36 -0400
Received: by mail-ig0-f173.google.com with SMTP id bi2so4200852igb.0
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 20:56:35 -0700 (PDT)
In-Reply-To: <cc2e026a-6ab0-8d52-5c3d-29843c6ddf40@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 20, 2016 at 6:02 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello,
>
> On 18.05.2016 18:06, Tom Herbert wrote:
>> In several gso_segment functions there are checks of gso_type against
>> a seemingly arbitrary list of SKB_GSO_* flags. This seems like an
>> attempt to identify unsupported GSO types, but since the stack is
>> the one that set these GSO types in the first place this seems
>> unnecessary to do. If a combination isn't valid in the first
>> place that stack should not allow setting it.
>>
>> This is a code simplication especially for add new GSO types.
>
> I couldn't still wrap my head around this.
>
> I wonder if this is safe in case of if the packet is generated from an
> untrusted virtual machine over virtio_net?

The problem is the test is kind of pointless.  I think the original
point of the tests was to prevent the case of IPIP and TSO6 or SIT and
TSO4.  However since we dropped IPIP and SIT and instead replaced them
with the IPXIP6 and IPXIP4 there shouldn't be any combinations that
don't work now other than UDP being combined with TCP segmentation.

If we are wanting to prevent that case we might place something
earlier in the segmentation code that would perform an and with all
the L4 GSO types that should be mutually exclusive, verify that value
is non-zero, and then and that value with itself - 1 to verify that
exactly 1 bit is set in that grouping and no more than that.

- Alex
