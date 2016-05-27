From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Fri, 27 May 2016 19:14:42 +0200
Message-ID: <4ef3d8a6-2340-60fc-0dfd-f69f5c869270@stressinduktion.org>
References: <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
 <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
 <20160521174438.GA27990@oracle.com>
 <82086299-ddb2-8acc-1286-5a1a7b2bf311@stressinduktion.org>
 <20160522115605.GA30516@oracle.com>
 <CALx6S358LkPTz9kzWDuveZgDFjaL7AbgwgcVLP4iyC6Bvd3yBg@mail.gmail.com>
 <CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
 <614c9a42-02c1-052a-52b6-289818bf757b@stressinduktion.org>
 <20160527150318.GA25040@oracle.com>
 <CALx6S35G2CWexCn=1o4YwbELF=_ic+e_qmgqh5q4EJQYtoV0mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Tom Herbert <tom@herbertland.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45925 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932496AbcE0ROr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 13:14:47 -0400
In-Reply-To: <CALx6S35G2CWexCn=1o4YwbELF=_ic+e_qmgqh5q4EJQYtoV0mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 27.05.2016 18:59, Tom Herbert wrote:
> On Fri, May 27, 2016 at 8:03 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
>> On (05/27/16 11:53), Hannes Frederic Sowa wrote:
>>>> Thinking about this some more, the per option white list is a better
>>>> approach. If we allow an open ended mechanism for applications to
>>>> signal the network with arbitrary data (like user specified hbp
>>>> options would be), then use of that mechanism will inevitably
>>>> exploited by some authorities to force user to hand over private data
>>>> about their communications. It's better to not build in back doors to
>>>> security...
>>>
>>> Sorry, Tom, can you try to explain again, I think I might not have
>>> understood you correctly.
>>
> Option whitelists are the right approach, applications should not be
> able to set random options in IP extension headers.
> 
>> yes, me too. Might help to discuss this by looking at an instance
>> of the type of option we are talking about.
>>
>> Usually hbh options are handled in the forwarding path (and thus
>> as unpopular as ip options, since they derail the packet to the
>> slow path). Are you suggesting some type of AAA to vet the hbh
>> option itself?
>>
> The issue that came up in IETF is that network operators (particularly
> radio networks) are concerned about the loss of visibility into the
> content since TLS became widely deployed. Unfortunately from the
> operators point of view at least, we are likely to see transport layer
> headers also being encrypted in the Internet (like Transports over
> UDP) which means they will have even less information. There is
> discussion now about rather applications can "give back" information
> that network operators previously deduced from inspecting clear text
> transport headers and payload. This would be accomplished with some
> sort of signaling to the network from applications. IP ext. headers
> are the standard mechanism for such signaling, although are a lot of
> people don't want to use them because they need to go through the
> kernel to set them-- because kernel takes too long deploy, bad
> interfaces, has too much control, etc.

I also wonder how helpful TCP middleboxes are nowadays. I haven't done
any kind of tests for example over satellite connections with TCP. A TCP
frame cache probably helps a lot getting a faster connection but at the
same time messes with the RTT. I could imagine network operators wanting
control over the data stream.

Your proposal with DTLS also leaks a lot of information. E.g. I remember
that certificates are always send in clear text and I currently don't
know if TLS 1.3 solves this (DTLS is basically TLS split on record
boundaries to UDP frames). Sequence numbers ensure that e.g. no reply
attack can happen. The DTLS "connection establishment" and "teardown"
also provides the necessary information to handle the UDP flow stateful,
thus connection tracking is not completely circumvented. (D)TLS also
provides extensions which could be used for signaling and keeping state
in the network.

Otherwise my problem with DTLS is that it is much less deployed. E.g. I
remember from the mosh paper [1] that no current implementation of DTLS
actually supports roaming of "DTLS connections".

[1] https://mosh.mit.edu/mosh-paper-draft.pdf

> Hop by hop are open ended options defined as "The Hop-by-Hop Options
> header is used to carry optional information that must be examined by
> every node along a packet's delivery path.". If we allow applications
> to set arbitrary hbh options then the danger is that their network
> operator or local authority may require their own defined options.
> There's no reason to believe that this would be benevolent, such a
> mechanism could be used to force applications to leak private
> information about encrypted content which would diminish security or
> net neutrality. For instance a network provider could require its
> users to mark packets that are for cat videos, or want the URLs being
> accessed in http requests (described in a accord BOF @IETF), and there
> are even going to be authorities that demand they have access to
> crypto keys. Obviously there are always going to be attempts to force
> users to give up private information, but I don't think we (neither
> Linux nor IETF) should be building mechanisms that make it easy to do
> that.

Sounds like solving social problems with technology. :)

In general I agree, but it seems to me that the provider edges are
already capable of doing so, adding headers at the edge and transporting
them over the backbone and removing them add the edge again. They could
as well also be tunneled in geneve completely to provide arbitrary TLV
options.

Another questions about your approach:

Do you expect e.g. Facebook deploying TLS inside DTLS or is the DTLS
connection in the long run a way to defeat end-to-end crypto, as only
the tunnel themselves will be encrypted? Adding encryption in encryption
might be a huge performance loss?

And another addendum: did you look into using ALPN (RFC 7301) instead of
using payload transformers in GUE?

All in all, I agree, maybe not because of the same reasons but it would
be hard to come up with a blacklist of possible options.

Bye,
Hannes
