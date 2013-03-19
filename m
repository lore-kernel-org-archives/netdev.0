From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Tue, 19 Mar 2013 02:18:06 -0700
Message-ID: <CANP3RGehbKbh1ambT-RQQqfOkovzySB4_CWg+LPdJV7yDkYBCg@mail.gmail.com>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	<1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	<1363651672.21184.17.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:63813 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755410Ab3CSJSH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 05:18:07 -0400
Received: by mail-oa0-f50.google.com with SMTP id l20so206860oag.23
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 02:18:06 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can the HW calculate and return a 1s complement sum of the entire
packet (or a large portion there-of)?
=46ixing that up to be only of the outer IPv4, inner IPv4 and inner TCP
relevant portions should still be simpler (well faster) than
calculating the TCP checksum.
I'm pretty sure that some relationship between 1s complement sum of
all bytes, outer IPv4 checksum, inner IPv4 checksum and TCP checksum
could be pulled out of a hat with some deeper thought.  (similarly for
IPv4/GRE/IPv6/TCP and other combinations)

What portions of the packet can the HW/FW [partially] checksum - and
return the value to the driver for further processing?
Can it return 1s complement sum of data portion of outer IPv4 (ie. in
IPv4/GRE/IPv4/TCP return a 1s complement sum of GRE/IPv4/TCP bytes)

Maciej =C5=BBenczykowski, Kernel Networking Developer @ Google

On Mon, Mar 18, 2013 at 11:30 PM, Dmitry Kravkov <dmitry@broadcom.com> =
wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org] On Behalf Of Eric Dumazet
>> Sent: Tuesday, March 19, 2013 2:08 AM
>> To: Dmitry Kravkov
>> Cc: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein; T=
om Herbert; Maciej =C5=BBenczykowski
>> Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE =
traffic
>>
>> On Mon, 2013-03-18 at 18:51 +0200, Dmitry Kravkov wrote:
>> > The patch drives FW to perform RSS for GRE traffic,
>> > based on inner headers.
>> >
>> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>> > ---
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +++
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c  |   23 ++++++++++=
++-----------
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h  |    9 +++++++++
>> >  3 files changed, 24 insertions(+), 11 deletions(-)
>>
>> This works very well.
>>
>> Problem is we skb_set_queue_mapping(skb, 0); in __skb_tunnel_rx()
>>
>> (this was a patch from Tom Herbert, commit
>> 693019e90ca45d881109d32c0c6d29adf03f6447 (net: reset skb queue mappi=
ng
>> when rx'ing over tunnel )
>>
>> Meaning we hit a single cpu for the GRO stuff in ip_gre.
>>
>> I have to think about it.
>>
>>
>> Another question is :
>>
>> Can bnx2x check the tcp checksum if GRE encapsulated ?
>>
> Current HW can't provide this. Probably, it's possible to separate CS=
UM from GRO/TPA then stack will have to handle CSUM validation for huge=
 packets. Is it worth?
>
