From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Wed, 26 Nov 2014 16:03:16 -0500
Message-ID: <CA+FuTScmwYyrU-LOK5dvbdcp4n=wig7GTdV1gmViS-2gJ4Q9ZA@mail.gmail.com>
References: <1416938286-14147-2-git-send-email-willemb@google.com>
 <20141125.134240.861582393401487675.davem@davemloft.net> <CA+FuTSdT9=Hi7K3OnMxVRiK8PmS4=DvVqLumWx74OEz3okx23A@mail.gmail.com>
 <20141125.145434.1790615963499624322.davem@davemloft.net> <CALCETrXHdSVC-YLsdjHxAp3rU2gGFZaz8NNgaTKYgjM-ah3z+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:47459 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaKZVDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 16:03:47 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so2751924qcx.30
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 13:03:47 -0800 (PST)
In-Reply-To: <CALCETrXHdSVC-YLsdjHxAp3rU2gGFZaz8NNgaTKYgjM-ah3z+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 4:39 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Tue, Nov 25, 2014 at 11:54 AM, David Miller <davem@davemloft.net> wrote:
>> From: Willem de Bruijn <willemb@google.com>
>> Date: Tue, 25 Nov 2014 14:52:00 -0500
>>
>>> On Tue, Nov 25, 2014 at 1:42 PM, David Miller <davem@davemloft.net> wrote:
>>>> From: Willem de Bruijn <willemb@google.com>
>>>> Date: Tue, 25 Nov 2014 12:58:03 -0500
>>>>
>>>> What's the harm in exposing the headers?  Either it's harmful, and
>>>> therefore doing so for UDP is bad too, or it's harmless and
>>>
>>> Headers may expose information not available otherwise. I don't
>>> immediately see critical problems, but that does not mean that they
>>> might not lurk there.
>>>
>>> We so far avoid exposing the sequence number, though keeping it hidden
>>> is more about third parties. More in general, unprivileged processes
>>> may start requesting timestamps only to learn tcp state that they
>>> should either get from tcpinfo or cannot currently get at all, likely
>>> for good reason. A far-fetched example is identifying admin iptables
>>> tos mangling rules by reading the tos bits at the driver layer. At least
>>> on my machine, iptables -L is privileged.
>>>
>>>> we should probably leave it alone to not risk breaking anyone.
>>>
>>> That's fair. I sent it for rfc first for that reason. I won't resubmit
>>> unless more serious concerns are raised.
>>
>> I just worry about the potential breakage.
>>
>> Your concerns are valid... I honestly don't know what we should do here.
>> Both choices have merit.
>
> Here's a scenario in which giving the headers might be dangerous:
>
> Suppose I create a network namespace that's designed to contain
> something, e.g. a Tor or Tor-like client, that shouldn't know any of
> its public addressing information.  I might assign something like a
> tunnel interface to the namespace, but, if the contained code can get
> lower-level headers, it might learn something that would identify the
> *other* end of the tunnel, which wouldn't be so good.  Admittedly,
> this would be just one of several things that would require care to
> get this right.

network namespaces are an interesting case, indeed.

>
> Also, what happens if the output is transformed by ipsec?  Does the
> timestamp message show the ciphertext?
>
> TBH, I'd rather send no payload at all and have an scm message that
> the sender provides that specifies a cookie identifying the particular
> sent data.  But that ship mostly sailed awhile ago.
>
> For bytestreams, though, isn't this all new in 3.18?  Or am I off by a release.

It was added in 3.17. That is still very recent.

One third option, though hardly pretty, is to put display of headers
under administrator control. An application cannot easily infer whether
headers are stripped, and legacy applications do not even know to try.
So, this is a bit too crude:

+    if (sk->sk_protocol == IPPROTO_TCP && sysctl_net_blind_errqueue)
+        skb_pull(skb, skb_transport_offset(skb) + tcp_hdrlen(skb));
+    else if (sk->sk_protocol == IPPROTO_UDP && sysctl_net_blind_errqueue >= 2)
+        skb_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr));

An alternative is to add a timestamping option to skip headers (or
even full payload, basically
http://patchwork.ozlabs.org/patch/366967/) and give the administrator
a sysctl to drop all requests that do not pass this flag. The intent
is that future proof applications will start requesting the flag, and
relying on the ts counter. Hardened installations can set the sysctl
from the start, accepting possible breakage.
