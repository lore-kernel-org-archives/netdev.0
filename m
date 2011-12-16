From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Fri, 16 Dec 2011 10:28:16 -0800
Message-ID: <CAEuXFEy02BAL4+=RNOi7u=-4WBvwPpvTOJKPcwND2yxW+hw9FA@mail.gmail.com>
References: <4EE8F884.1010304@hp.com>
	<CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	<1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4EEA3D58.5010101@hp.com>
	<20111215104440.1eef9e47@s6510.linuxnetplumber.net>
	<1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4EEA730E.5010405@hp.com>
	<1324009676.2562.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53843 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760264Ab1LPS2S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:28:18 -0500
Received: by eaaj10 with SMTP id j10so3166785eaa.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:28:16 -0800 (PST)
In-Reply-To: <1324009676.2562.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2011 at 8:27 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 15 d=E9cembre 2011 =E0 14:22 -0800, Rick Jones a =E9crit :
>> On 12/15/2011 11:00 AM, Eric Dumazet wrote:
>> >> Device's work better if the driver proactively manages stop_queue=
/wake_queue.
>> >> Old devices used TX_BUSY, but newer devices tend to manage the qu=
eue
>> >> themselves.
>> >>
>> >
>> > Some 'new' drivers like igb can be fooled in case skb is gso segme=
nted ?
>> >
>> > Because igb_xmit_frame_ring() needs skb_shinfo(skb)->nr_frags + 4
>> > descriptors, igb should stop its queue not at MAX_SKB_FRAGS + 4, b=
ut
>> > MAX_SKB_FRAGS*4

can you please help me understand the need for MAX_SKB_FRAGS * 4 as
the requirement?  Currently driver uses logic like

in hard_start_tx: hey I just finished a tx, I should stop the qdisc if
I don't have room (in tx descriptors) for a worst case transmit skb
(MAX_SKB_FRAGS + 4) the next time I'm called.
when cleaning from interrupt: My cleanup is done, do I have enough
free tx descriptors (should be MAX_SKB_FRAGS + 4) for a worst case
transmit?  If yes, restart qdisc.

I'm missing the jump from the above logic to using MAX_SKB_FRAGS * 4
(=3D=3D (18 * 4) =3D=3D 72) as the minimum number of descriptors I need=
 for a
worst case TSO.  Each descriptor can point to up to 16kB of contiguous
memory, typically we use 1 for offload context setup, 1 for skb->data,
and 1 for each page.  I think we may be overestimating with
MAX_SKB_FRAGS + 4, but that should be no big deal.
