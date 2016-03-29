From: Alex Duyck <aduyck@mirantis.com>
Subject: Re: [net PATCH] gro: Allow tunnel stacking in the case of FOU/GUE
Date: Mon, 28 Mar 2016 21:15:42 -0700
Message-ID: <CAMt9YRo07TD0kxkdKve2kD_E=xt89Cf=08=ZzZ_j+k1=6R5R-g@mail.gmail.com>
References: <20160328235613.26269.26291.stgit@localhost.localdomain>
	<CALx6S3624MH3cKF1zPUvvr1saGAwhTUb6DC6tZcrFYKqRMCozA@mail.gmail.com>
	<CAEh+42g2AudOVigy9udEsDz-K1RrG_0GJyYYrMoN5xNUHdJyfg@mail.gmail.com>
	<CALx6S34PLWEMVM3t8jEnj5S4GH+XbCuOdm0aJD_ijPVqoy9ueQ@mail.gmail.com>
	<CAKgT0UeszLNiv=hjeD50pHRB7rgT7qWzbvVAj690jkepVQC7Xg@mail.gmail.com>
	<CALx6S37xUjQpxYdskm0Lt33MQr6Jwwg1eGjZYnadX8762EuxBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:36036 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcC2EPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 00:15:45 -0400
Received: by mail-lf0-f53.google.com with SMTP id e133so2684692lfe.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 21:15:44 -0700 (PDT)
In-Reply-To: <CALx6S37xUjQpxYdskm0Lt33MQr6Jwwg1eGjZYnadX8762EuxBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 9:01 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Mar 28, 2016 at 8:27 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Mon, Mar 28, 2016 at 8:17 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Mon, Mar 28, 2016 at 6:54 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>> On Mon, Mar 28, 2016 at 6:24 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>>> On Mon, Mar 28, 2016 at 4:58 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>>>> This patch should fix the issues seen with a recent fix to prevent
>>>>>> tunnel-in-tunnel frames from being generated with GRO.  The fix itself is
>>>>>> correct for now as long as we do not add any devices that support
>>>>>> NETIF_F_GSO_GRE_CSUM.  When such a device is added it could have the
>>>>>> potential to mess things up due to the fact that the outer transport header
>>>>>> points to the outer UDP header and not the GRE header as would be expected.
>>>>>>
>>>>>> Fixes: fac8e0f579695 ("tunnels: Don't apply GRO to multiple layers of encapsulation.")
>>>>>
>>>>> This could only fix FOU/GUE. It is very possible someone else could
>>>>> happily be doing some other layered encapsulation and never had a
>>>>> problem before, so the decision to start enforcing only a single layer
>>>>> of encapsulation for GRO would still break them. I still think we
>>>>> should revert the patch, and for next version fixes things to that any
>>>>> combination/nesting of encapsulation is supported, and if there are
>>>>> exceptions to that support they need be clearly documented.
>>>>
>>>> It was pointed out to me that prior to my patch, it was also possible
>>>> to remotely cause a stack overflow by filling up a packet with tunnel
>>>> headers and letting GRO descend through them over and over again.
>>>>
>>> Then the fix would be set set a reasonable limit on the number of
>>> encapsulation levels.
>>>
>>>> Tom, I'm sorry that you don't like how I fixed this issue but there
>>>> really, truly is a bug here. I gave you a specific example to be clear
>>>> but that doesn't mean that is the only case. I am aware that the bug
>>>> is not encountered in all situations and that the fix removes an
>>>> optimization in some of those but I think that ensuring correct
>>>> behavior must come first.
>>>
>>> The example you gave results in packet loss, this is not
>>> incorrectness. Actually reproduce a real issue that leads to
>>> incorrectness and then we can talk about a solution.
>>
>> Tom,
>>
>> Just take a look in the __skb_udp_tunnel_segment or gre_gso_segment
>> code.  Then tell me how we are supposed to deal with the fact that the
>> GSO code expects skb_inner_network_offset() to be valid.  If you have
>> more than an inner and an outer network header we cannot.  So we
>> cannot put GRE in UDP, or UDP in GRE if there is a network header
>> between them.  The FOU/GUE code gets around this because in the IPIP
>> and SIT cases you are adding an L4 header between two L3 headers.  The
>> GRE case works because you essentially convert the GRE header into a
>> tunnel header like VXLAN or GENEVE and we just overwrite the outer
>> transport header offset.
>>
>> What it comes down to is that we can only support 2 network headers
>> per frame.  One for the inner and one for the outer.  That is why we
>> can have an exception for GUE as it only has 2 network headers.  If we
>> had multiple levels of UDP, or GRE, or 2 levels of network headers
>> either before or after either UDP or GRE we cannot support
>> segmentation because the code will blow up and generate a malformed
>> frame.
>>
> If you apply Edward's jumbo L2 header concept then
> Eth|IP|UDP|VXLAN|Eth|IP|UDP|GUE|GRE|IPIP|IPv6|TCP|payload becomes
> Eth|IP|UDP|encapsulation-hdrs|IPv6|TCP|Payload. One set of outer
> headers, one set of inner headers. The rules that encapsulation_hdrs
> don't contain fields that need to be modified for every segment need
> to be supported in GRO and the stack when it generates such a
> configuration.

Thats all well and good but nothing like that exists now.  So you
cannot expect us to fix the kernel to support code that isn't there.
In addition there were a number of issues with the jumbo L2 header
approach.  That was one of the reasons why I went with the jumbo L3
header approach as it is much easier to be compliant with all the
RFCs.

We might be able to get some of that supported for net-next but things
are going to be limited.  We need to have the UDP tunnels actually
setting the DF bit which as far as I know none of them do now.  In
addition we will have to add rules for all the encapsulated types so
that we can enforce the outer IP header incrementing in the event that
DF is not set.  Then we will also have to go through and make certain
that we have the DF bit set in all headers between the transport and
the outer network header in order to allow support for GSO partial.

What you are describing is no small task.  There are bugs that need to
be fixed now in net.  We can try to get the features you want pushed
for net-next but they don't exist now so locking down GRO so that it
matches the feature set provided by GSO is not a regression.

- Alex
