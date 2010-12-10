From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 09:27:49 +0100
Message-ID: <AANLkTi=vB-9bo09AhE7GTEJ1iPQd+nE=tfcFY+GmKUt-@mail.gmail.com>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	<1291906948.19763.16.camel@localhost>
	<AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
	<1291921115.2647.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:55117 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab0LJI1u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 03:27:50 -0500
Received: by qwa26 with SMTP id 26so3581667qwa.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 00:27:49 -0800 (PST)
In-Reply-To: <1291921115.2647.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 9 grudnia 2010 19:58 u=BFytkownik Ben Hutchings
<bhutchings@solarflare.com> napisa=B3:
> On Thu, 2010-12-09 at 19:47 +0100, Micha=B3 Miros=B3aw wrote:
>> 2010/12/9 Ben Hutchings <bhutchings@solarflare.com>:
>> > On Thu, 2010-12-09 at 16:03 +0530, Govindarajan, Sriramakrishnan w=
rote:
>> >> Hi
>> >> We have a NAPI compliant driver(net/drivers/davinci_emac.c), that=
 does
>> >> well at 10/100Mbps loads. Now the same controller/driver is used =
for
>> >> 1000Mbps
>> >> mode as well, where the CPU gets saturated easily
>> >>
>> >> Internally the module supports scatter gather DMA(which is curren=
tly not
>> >> exercised) but there is no HW checksum support.
>> >>
>> >> To specifically implement GRO, GSO support would it be sufficient=
 to add
>> >> SG support to the driver? Are there other means of increasing the=
 throughput
>> >> and decreasing the CPU loading?
>> [...]
>> > On the TX side, NETIF_F_SG means that the stack may include data i=
n the
>> > skb by reference to arbitrary pages *even if their contents are st=
ill
>> > being changed* (think sendfile()), which means it depends on hardw=
are
>> > checksum generation.
>>
>> Isn't that condition too broad? If the data could change after packe=
t
>> is submitted to the driver then results would be unpredictable and
>> allow sending wrong data with correct (because hw-calculated)
>> checksum.
> This is not done for a regular send(), only for functions such as
> sendfile() which are specified to read the data asynchronously.
>
>> Right now NETIF_F_SG is removed from dev->features by
>> netdev_fix_features() if no checksum offloads are enabled.
>>
>> Just an idea: would driver with NETIF_F_SG|NETIF_F_HW_CSUM using
>> skb_checksum_help() in xmit path work? This would allow to use DMA
>> scatter-gather without hardware checksumming (and avoid copying the
>> packet's data before sending).
> No, you cannot calculate a checksum for the fragments without also
> copying them to ensure the data doesn't change afterward and invalida=
te
> the checksum. =A0You could in theory make a copy into multiple fragme=
nts,
> but there's no point in doing that unless the frame size is larger th=
an
> a page.

Then at least couple of drivers are broken in this way (ibmveth,
chelsio for UDP, there are other hits on skb_checksum_help).

I'm not familiar with splice/sendfile code, but I would expect, that
pages transferred with it have to be submitted after "data ready"
notification and pinned in memory by DMA mapping (with hardware
checksumming, CPU does not need to see the data, but still it has to
be there already) until the frame is transferred to the network
device. So, even if the contents of the page changes (because further
data is transferred), the part that is submitted to be sent should
not.

If that's really not the case, then splice/sendfile to network is
useless as it means random data corruption. Googling around shows
reports about sendfile() correllated corruption - could this the
cause?

Best Regards,
Micha=B3 Miros=B3aw
