From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 07:05:38 -0500
Message-ID: <20151202120538.GJ23178@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <20151202065305.GB14008@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	sowmini.varadhan@oracle.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151202065305.GB14008@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/02/15 07:53), Steffen Klassert wrote:
> 
> I'm currently working on a GRO/GSO codepath for IPsec too. The GRO part
> works already. I decapsulate/decrypt the packets on layer2 with a esp GRO
> callback function and reinject them into napi_gro_receive(). So in case
> the decapsulated packet is TCP, GRO can aggregate big packets.

Would you be able to share your patch with me? I'd like to give that a try
just to get preliminary numbers (and I could massage it as needed
for transport mode too).

> My approach to GSO is a bit different to yours. I focused on tunnel mode,
> but transport mode should work too. I encapsulate the big GSO packets
> but don't do the encryption. Then I've added a esp_gso_segment() function,
> so the (still not encrypted ESP packets) get segmented with GSO. Finally I
> do encryption for all segments. This works well as long as I do sync crypto.
> The hard part is when crypto returns async. This is what I'm working on now.
> I hope to get this ready during the next weeks that I can post a RFC version
> and some numbers.

I see. My thought for attacking tunnel mode would have been to 
callout the esp code at the tail of gre_gso_segment, but I did not
yet consider this carefully - clearly you've spent more time on it,
and know more about all the gotchas there.

> Also I tried to consider the IPsec GRO/GSO codepath as a software fallback.
> So I added hooks for the encapsulation, encryption etc. If a NIC can do
> IPsec, it can use this hooks to prepare the packets the way it needs it.
> There are NICs that can do IPsec, it's just that our stack does not support
> it.

yes, this is one of the things I wanted to bring up at netdev 1.1.
Evidently many of the 10G NICS (Niantic, Twinville, Sageville) already
support ipsec offload but that feature is not enabled for BSD or linux
because the stack does not support it (though Microsoft does. The intel
folks pointed me at this doc:
https://msdn.microsoft.com/en-us/library/windows/hardware/ff556996%28v=vs.85%29.aspx)

But quite independant of h/w offload, the s/w stack can already do
a very good job for 10G with just GSO and GRO, so being able to extend
that path to do encryption after segmentation should at least bridge
the huge gap between the ipsec and non-ipsec mech.

And that gap should be as small as possible for esp-null, so that
the only big hit we take is for the complexity of encryption itself!

> Another thing, I thought about setting up an IPsec BoF/workshop at
> netdev1.1. My main topic is GRO/GSO for IPsec. I'll send out a mail
> to the list later this week to see if there is enough interest and
> maybe some additional topics.

Sounds like an excellent idea. I'm certainly interested.

--Sowmini
> 
