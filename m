From: Jesse Gross <jesse@nicira.com>
Subject: Re: skb->frag_list != NULL in start_xmit for device without NETIF_F_FRAGLIST
Date: Thu, 3 Mar 2011 18:12:31 -0800
Message-ID: <AANLkTim89suf7iyMOygG-=r37y+LO7dTrVdeM2AaXGSW@mail.gmail.com>
References: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
	<AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
	<1299071546.17907.1755.camel@zakaz.uk.xensource.com>
	<1299071683.17907.1764.camel@zakaz.uk.xensource.com>
	<1299087749.17907.1792.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>, dev@openvswitch.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37521 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759108Ab1CDCMc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 21:12:32 -0500
Received: by vxi39 with SMTP id 39so1648710vxi.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 18:12:31 -0800 (PST)
In-Reply-To: <1299087749.17907.1792.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2011 at 9:42 AM, Ian Campbell <Ian.Campbell@citrix.com> =
wrote:
> On Wed, 2011-03-02 at 13:14 +0000, Ian Campbell wrote:
>> On Wed, 2011-03-02 at 13:12 +0000, Ian Campbell wrote:
>> >
>> > > I believe that not much has changed in this regard between 2.6.3=
2
>> > and net-next.
>> >
>> > It turns out I cannot reproduce with either 2.6.32 (pvops xen.git)=
 or
>> > a more recent ((26.38-rc) kernel. The kernel where we see this is =
the
>> > XCP kernel which is a 2.6.32 based thing derived from SLES11SP1 + =
XCP
>> > specific updates.
>>
>> Paul reminded me that his XCP system where we see this is running
>> openvswitch not bridging (all my own tests were with bridging), is t=
his
>> something which could be caused by vswitch at all? I don't see any
>> interesting ->frag_list usage in openvswitch.git.
>>
>> Anyway I'm going to see if I can repro with vswitch.
>
> It seems that was the key.
>
> Using openvswitch.git aae3743bf24cd0e14be726c774a0be49ff0459d7 on top=
 of
> 2.6.38-rc7 (+ some Xen stuff from linux-next and my netback branch). =
I
> added:
> =A0 =A0 =A0 =A0WARN_ONCE(skb_shinfo(skb)->frag_list, "skb %p has a fr=
ag list\n", skb)
> to netback's start_xmit and saw it trigger (full trace below).

Open vSwitch shouldn't create or use frag_lists in the normal packet
processing path.  However, it does pull more data into the linear data
area compared to the Linux bridge, which affects the skb geometry.  In
fact, looking at the lengths that you previously sent, the linear data
area contains 64 bytes, which is the default amount that we pull in.
It sounds like the original packet that was received was small, GRO
attached a larger one to it with a frag_list, and Open vSwitch pulled
data across, screwing up the layout.  It's a little surprising that
the first packet would be so small but it's possible.

Regardless, it seems like this is a valid operation and something that
skb_segment() should be able to handle.
