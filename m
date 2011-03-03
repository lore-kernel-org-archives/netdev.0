From: Jesse Gross <jesse@nicira.com>
Subject: Re: skb->frag_list != NULL in start_xmit for device without NETIF_F_FRAGLIST
Date: Thu, 3 Mar 2011 15:31:41 -0800
Message-ID: <AANLkTikk+3A_3K=PbfJjVYomM-n+TTVO+gRP+YND2By+@mail.gmail.com>
References: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
	<AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
	<1299071546.17907.1755.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37953 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758989Ab1CCXbm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 18:31:42 -0500
Received: by vxi39 with SMTP id 39so1540413vxi.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 15:31:42 -0800 (PST)
In-Reply-To: <1299071546.17907.1755.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2011 at 5:12 AM, Ian Campbell <Ian.Campbell@eu.citrix.co=
m> wrote:
>> > In particular I'm not sure where the frag_list is supposed to get
>> > resolved in the case where dev_hard_start_xmit takes the netif_nee=
ds_gso
>> > =3D=3D true path and calls dev_gso_segment rather than taking the
>> > __skb_linearize path (the issue appears to occur only when the net=
back
>> > device has NETIF_F_GSO but not NETIF_F_TSO). AFAICT dev_gso_segmen=
t goes
>> > to tcp_tso_segment and then to skb_segment which does appear to cr=
eate
>> > skbs with a frag_list (although it's not outside the realms of
>> > possibility that I'm reading it wrong).
>>
>> I'm fairly certain that the problem is in skb_segment(). =A0It's not=
 the
>> most tolerant of skbs with frag_lists that do not line up with the
>> requested mss. =A0Depending on how the original skb is laid out,
>> sometimes this will trigger a BUG_ON and sometimes it creates new
>> frag_lists. =A0Since there are no further checks after GSO, the skb =
with
>> a frag_list will get passed to the driver, even if it is not
>> supported.
>
> I wondered if that was the case, but skb_segment made my head spin a
> bit ;-)
>
> Do you think there might be a case for adding a some skb_needs_linear=
ize
> and __skb_linearize calls on the netif_needs_gso paths too, perhaps w=
ith
> some WARN_ON's?

Definitely something needs to be done here, as drivers clearly should
not be handed skbs with features that they don't support.  I'm not
sure what the best way to do that is though.  I would like it if
skb_segment() could be made more tolerant of frag_lists in general,
including the cases that currently have BUG_ON.

Currently the function tries to generate packets that are exactly MSS
size (except for the last one).  If the frag_lists don't align with
this we either get BUG or a new skb with a frag_list.  However, the
MSS is simply a maximum - it's also valid to generate packets smaller
than it.  If we did that we would probably be able to handle all of
these cases without doing any linearization.  It's possible that in
some cases it would be faster to do the linearization instead of
generating additional packets but on the other hand the situations
that this affects aren't handled correctly at all right now, so they
probably don't come up too often.

>
> The first check in skb_needs_linearize looks at skb->data_len, I thou=
ght
> skb->data_len only covered the paged fragments but the conditions in
> skb_needs_linearize seem to imply that it covers the frag_list length
> too? Was I simply mistaken?

skb->data_len includes both the paged fragments and frag_list.
