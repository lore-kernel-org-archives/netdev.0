From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: the side effect of using copy skb instead of skb_clone in cdc ncm/mbim driver
Date: Tue, 08 Jul 2014 09:03:30 +0200
Message-ID: <87y4w4jprx.fsf@nemi.mork.no>
References: <CAOa2BBy4t_17J7G5bBpAZZpBWZYh+Cpc6Fn4u+9cV98M8CZ5gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jim_baxter@mentor.com, alexey.orishko@stericsson.com,
	netdev@vger.kernel.org, zhao.ming9@zte.com.cn
To: joey ming <joey.zming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35103 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610AbaGHHDt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 03:03:49 -0400
In-Reply-To: <CAOa2BBy4t_17J7G5bBpAZZpBWZYh+Cpc6Fn4u+9cV98M8CZ5gw@mail.gmail.com>
	(joey ming's message of "Mon, 7 Jul 2014 21:57:37 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

joey ming <joey.zming@gmail.com> writes:

> Hi, I was hoping you can help me with some questions.
>
> some qualcomm LTE modem has two mode: ECM and QC_NCM.

Yes, and worse than that: You can even mix and match these on UL and DL=
=2E

> QC_NCM is the
> protocol which qualcomm defined,the  difference between qc-ncm and cd=
c-mbim
> are:
> data pipe:     NDP sig vary
>                    qc-ncm  packets are composed of  NTH+datagram+NTB =
 but
> mbim/ncm are NTH+NTB+datagram

Both these schemes are allowed in NCM (and therefore MBIM). There is no
required datagram nd NTB order. Proper alignment is the only requiremen=
t.
So the only real difference is the signature, which AFAIK is
configurable on the QC_NCM devices.

> control pipe: the biggest difference is control pipe. QC-NCM uses QMI=
 cmd
> to control device but mbim/ncm uses CDC cmd .

Yes, but this usage is actually also within the NCM spec.  The only
issues making a typical QC_NCM capable device fail as a CDC NCM class
device are
 - the default signature
 - the USB descriptors

Both are of course configurable by the modem vendors using these
chips/firmware toolkits, so it's possible to create standard CDC NCM
class devices out of these.  But you probably don't want to do that,
because there aren't any NCM class drivers which will let you access th=
e
QMI control channel (except the one you have made :-), and you need QMI
for modem management.

> so for a QC-NCM driver, we can borrow the code of data pipe from
> cdc-mbim/ncm. for a real LTE modem(DL speed:150Mbps) the qc-ncm drive=
r
> speed which used skb_clone in qc_ncm_rxfixup  can reach 126Mbps,but a=
t the
> same time and same envirmont ecm driver can reach 144Mbps for the sam=
e
> modem.
> Thanks for google, I found  Bjorn Mork's discussion about buffering
> restrictions of cdc-ncm host driver.
>  the qc-ncm driver speed can reach 145Mbps  if  I used copy skb inste=
ad of
> skb_clone.
> as we know, the aggregation protocol(such as cdc-ncm,cdc-mbim,qc-ncm =
)
> major purpose are improving performance of CPU by reducing interrupts=
=2E
> Compared ecm and qc-ncm test result, I thought we didn't reach the go=
al.
> the interrupts decreased 20% BUT the driver load was no change.
> I used Intel Core Duo laptop and oprofiled in 3.12 kernel:
>   QC-NCM           0.3146%(CPU0)    0.2899%(CPU1)  vmlinux
>  vmlinux                  memcpy
>                           0.2198%(CPU0)    0.1864%(CPU1)  usbnet
>         usbnet                   usbnet
>                           0.0423 %(CPU0)   0.0385%(CPU1)  qmi_wwan
>      qmi_wwan              /qmi_wwan
>
>   CDC-ECM         0.2470%(CPU0)     0.1735%(CPU1)  usbnet
> usbnet                   /usbnet
>                           0.1341%(CPU0)     0.0132%(CPU1)  vmlinux
>          vmlinux                  memcpy
>                           0.0335%(CPU0)      0.0387%(CPU1)  qc_ncm
>         qc_ncm                  /qc_ncm
>
> for a high speed modem(DL >100Mbps), Is it a appropriate solution use=
 copy
> skb? as above test result, memcpy load was higher than usbnet.

copy is the only solution.  With aggregation on the USB link we can
choose either
 - USB buffers which are much bigger than one IP packet, or
 - splitting some IP packets over two USB buffers

Either way we'll have to copy the IP packets before handing them over t=
o
the upper layers.   Cloning oversized skbs is not a good idea.

The problem you found is that there is no real value in this USB layer
aggregation on Linux.  It's just pointless complexity. A plain ECM
driver transmitting ethernet frames back to back will achieve the exact
same utilisation of the USB link, without all the aggregation complexit=
y
and overhead.

I don't know why the USB-IF found it necessary to create these
aggregation protocols, but I assume there are other OS's than Linux out
there (running on either hosts or devices) which are unable to use the
full USB bandwith with ECM.

But the results you show above is the primary reason why I chose to
completely ignore the QC_NCM bastard protocol.  AFAIK all devices
capable of using this protocol can also do the plain ECM, and will do s=
o
by default.  So they are supported by the qmi_wwan driver with no more
fuzz, doing the maximum speed the devices are capable of.

Thanks a lot for testing this and providing the results!


Bj=C3=B8rn
