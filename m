From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH net-next v3 1/2] macb: Add 1588 support in Cadence GEM.
Date: Fri, 9 Dec 2016 11:07:23 +0530
Message-ID: <CAFcVECJutEu2=POtAU=jX6E3-ZHsLXpOMMw+UJ0hcQgZ0n4ZVA@mail.gmail.com>
References: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
 <20161207193908.GA13062@netboy> <20161207210416.GA27622@netboy> <07C910AB6AC6C345A093D5A08F5AF568CB74AF28@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        David Miller <davem@davemloft.net>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        Rafal Ozieblo <rafalo@cadence.com>
To: Andrei Pistirica <Andrei.Pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <07C910AB6AC6C345A093D5A08F5AF568CB74AF28@CHN-SV-EXMX03.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Dec 8, 2016 at 8:11 PM,  <Andrei.Pistirica@microchip.com> wrote:
>
>
>> -----Original Message-----
>> From: Richard Cochran [mailto:richardcochran@gmail.com]
>> Sent: Wednesday, December 07, 2016 11:04 PM
>> To: Andrei Pistirica - M16132
>> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linux-arm-
>> kernel@lists.infradead.org; davem@davemloft.net;
>> nicolas.ferre@atmel.com; harinikatakamlinux@gmail.com;
>> harini.katakam@xilinx.com; punnaia@xilinx.com; michals@xilinx.com;
>> anirudh@xilinx.com; boris.brezillon@free-electrons.com;
>> alexandre.belloni@free-electrons.com; tbultel@pixelsurmer.com;
>> rafalo@cadence.com
>> Subject: Re: [RFC PATCH net-next v3 1/2] macb: Add 1588 support in
>> Cadence GEM.
>>
>> On Wed, Dec 07, 2016 at 08:39:09PM +0100, Richard Cochran wrote:
>> > > +static s32 gem_ptp_max_adj(unsigned int f_nom) {
>> > > + u64 adj;
>> > > +
>> > > + /* The 48 bits of seconds for the GEM overflows every:
>> > > +  * 2^48/(365.25 * 24 * 60 *60) =3D~ 8 925 512 years (~=3D 9 mil ye=
ars),
>> > > +  * thus the maximum adjust frequency must not overflow CNS
>> register:
>> > > +  *
>> > > +  * addend  =3D 10^9/nominal_freq
>> > > +  * adj_max =3D +/- addend*ppb_max/10^9
>> > > +  * max_ppb =3D (2^8-1)*nominal_freq-10^9
>> > > +  */
>> > > + adj =3D f_nom;
>> > > + adj *=3D 0xffff;
>> > > + adj -=3D 1000000000ULL;
>> >
>> > What is this computation, and how does it relate to the comment?
>
> I considered the following simple equation: increment value at nominal fr=
equency (which is 10^9/nominal frequency nsecs) + the maximum drift value (=
nsecs) <=3D maximum increment value at nominal frequency (which is 8bit:0xf=
fff).
> If maximum drift is written as function of nominal frequency and maximum =
ppb, then the equation above yields that the maximum ppb is: (2^8 - 1) *nom=
inal_frequency - 10^9. The equation is also simplified by the fact that the=
 drift is written as ppm + 16bit_fractions and the increment value is writt=
en as nsec + 16bit_fractions.
>
> Rafal said that this value is hardcoded: 0x64E6, while Harini said: 25000=
0000.

@ Andrei, I may have equated max ppb to max tsu frequency allowed on
the system and set that.
That will be wrong.

>
> I need to dig into this...
>
>>
>> I am not sure what you meant, but it sounds like you are on the wrong tr=
ack.
>> Let me explain...
>
> Thanks.
>
>>
>> The max_adj has nothing at all to do with the width of the time register=
.
>> Rather, it should reflect the maximum possible change in the tuning word=
.
>>
>> For example, with a nominal 8 ns period, the tuning word is 0x80000.
>> Looking at running the clock more slowly, the slowest possible word is
>> 0x00001, meaning a difference of 0x7FFFF.  This implies an adjustment of
>> 0x7FFFF/0x80000 or 999998092 ppb.  Running more quickly, we can already
>> have 0x100000, twice as fast, or just under 2 billion ppb.
>>
>> You should consider the extreme cases to determine the most limited
>> (smallest) max_adj value:
>>
>> Case 1 - high frequency
>> ~~~~~~~~~~~~~~~~~~~~~~~
>>
>> With a nominal 1 ns period, we have the nominal tuning word 0x10000.
>> The smallest is 0x1 for a difference of 0xFFFF.  This corresponds to an
>> adjustment of 0xFFFF/0x10000 =3D .9999847412109375 or 999984741 ppb.
>>
>> Case 2 - low frequency
>> ~~~~~~~~~~~~~~~~~~~~~~
>>
>> With a nominal 255 ns period, the nominal word is 0xFF0000, the largest
>> 0xFFFFFF, and the difference is 0xFFFF.  This corresponds to and adjustm=
ent
>> of 0xFFFF/0xFF0000 =3D .0039215087890625 or 3921508 ppb.
>>
>> Since 3921508 ppb is a huge adjustment, you can simply use that as a saf=
e
>> maximum, ignoring the actual input clock.
>>

Thanks Richard.
So, if I understand right, this is theoretically limited by the
maximum input clock:
So if the highest frequency allowed (also commonly sourced in my case)
is 200MHz,
then with a 5ns time period, considering the adjustment to slowest
possible word,
0x4FFFF/0x50000 will be 999996948 ppb.
Shouldn't this be the max_adj?
I'm afraid I don't get why we are choosing the most limited max adj..
Sorry if I'm missing something - could you please help me understand?

Regards,
Harini
