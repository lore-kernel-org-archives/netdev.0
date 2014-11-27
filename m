From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?
Date: Thu, 27 Nov 2014 11:03:24 +0100
Message-ID: <874mtl55ar.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
	<87ppc957h1.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1411271037050.9464@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: youtux@gmail.com, alexxst@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49053 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182AbaK0KDe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:03:34 -0500
In-Reply-To: <alpine.LNX.2.03.1411271037050.9464@gmail.com> (Enrico Mioso's
	message of "Thu, 27 Nov 2014 10:45:59 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Ok - we can arrive to some ocnclusions regarding the E3272.
> First of all - the modem seems buggy enough to not be able to handle =
requests=20
> for different formats. You need to unplug and re-plug it, but this is=
 onlyan=20
> impression and is reasonable.
>
> Then - the modem will accept to ndisdup the connection with
> at^ndisdup=3D1,1,"internet"
> but - if we use huawei_cdc_ncm + cdc_ncm we have no flow handling mes=
sages and=20
> the modem stops here.
> If we use the cdc_ncm 32-bit driver (modified) we get lotfs of
> ^dsflorpt
> that's how it should be.
> So I think we can say that something is changing.
> Then there's the alignment problem you mentioned in your previous rep=
ly. And=20
> this is hard to solve.
> could you try to help me understand where the problem is?
> I feel like we are very close to the solution but something isn't wor=
king.
> Or might be just try to change the 16 bit driver?

If you use a recent version of the driver as a basis, then you get the
CDC NCM NTB parameters in sysfs (if not, then you need to enable
debugging and look in the log for these values).  For example:

bjorn@nemi:~$ grep . /sys/class/net/wwan0/cdc_ncm/*
/sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0001
/sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:15360
/sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:15360
/sys/class/net/wwan0/cdc_ncm/min_tx_pkt:13824
/sys/class/net/wwan0/cdc_ncm/rx_max:15360
/sys/class/net/wwan0/cdc_ncm/tx_max:15360
/sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
/sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
/sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:1
/sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:0
/sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
/sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:32
/sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:0
/sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:32


The possible problem I am thinking of is proper handling of the
wNdp*PayloadRemainder values. See section 3.3.4 "NCM Ethernet Frame
Alignment" in the spec.  Which is confusing as hell, but if I understan=
d
it correctly then we are supposed to align the start of the IP packets
(the "payload", _not_ the ethernet frame) to a whole wNdp*Divisor numbe=
r
as long as the wNdp*PayloadRemainder is 0.


Bj=C3=B8rn
