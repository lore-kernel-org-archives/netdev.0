From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Sat, 18 Jun 2016 14:22:13 +0900
Message-ID: <5764DA85.3050801@sakamocchi.jp>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain> <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk> <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Henrik Austad <henrik@austad.us>,
 linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
 Arnd Bergmann <arnd@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>, alsa-devel@alsa-project.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20160615080602.GA13555@localhost.localdomain>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry to be late. In this weekday, I have little time for this thread
because working for alsa-lib[1]. Besides, I'm not full-time developer
for this kind of work. In short, I use my limited private time for this
discussion.

On Jun 15 2016 17:06, Richard Cochran wrote:
> On Wed, Jun 15, 2016 at 12:15:24PM +0900, Takashi Sakamoto wrote:
>>> On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
>>>> I have seen audio PLL/multiplier chips that will take, for example, a
>>>> 10 kHz input and produce your 48 kHz media clock.  With the right HW
>>>> design, you can tell your PTP Hardware Clock to produce a 10000 PPS,
>>>> and you will have a synchronized AVB endpoint.  The software is all
>>>> there already.  Somebody should tell the ALSA guys about it.
>>
>> Just from my curiosity, could I ask you more explanation for it in ALSA
>> side?
> 
> (Disclaimer: I really don't know too much about ALSA, expect that is
> fairly big and complex ;)

In this morning, I read IEEE 1722:2011 and realized that it quite
roughly refers to IEC 61883-1/6 and includes much ambiguities to end
applications.

(In my opinion, the author just focuses on packet with timestamps,
without enough considering about how to implement endpoint applications
which perform semi-real sampling, fetching and queueing and so on, so as
you. They're satisfied just by handling packet with timestamp, without
enough consideration about actual hardware/software applications.)

> Here is what I think ALSA should provide:
> 
> - The DA and AD clocks should appear as attributes of the HW device.
> 
> - There should be a method for measuring the DA/AD clock rate with
>   respect to both the system time and the PTP Hardware Clock (PHC)
>   time.
> 
> - There should be a method for adjusting the DA/AD clock rate if
>   possible.  If not, then ALSA should fall back to sample rate
>   conversion.
> 
> - There should be a method to determine the time delay from the point
>   when the audio data are enqueued into ALSA until they pass through
>   the D/A converter.  If this cannot be known precisely, then the
>   library should provide an estimate with an error bound.
> 
> - I think some AVB use cases will need to know the time delay from A/D
>   until the data are available to the local application.  (Distributed
>   microphones?  I'm not too sure about that.)
> 
> - If the DA/AD clocks are connected to other clock devices in HW,
>   there should be a way to find this out in SW.  For example, if SW
>   can see the PTP-PHC-PLL-DA relationship from the above example, then
>   it knows how to synchronize the DA clock using the network.
> 
>   [ Implementing this point involves other subsystems beyond ALSA.  It
>     isn't really necessary for people designing AVB systems, since
>     they know their designs, but it would be nice to have for writing
>     generic applications that can deal with any kind of HW setup. ]

Depends on which subsystem decides "AVTP presentation time"[3]. This
value is dominant to the number of events included in an IEC 61883-1
packet. If this TSN subsystem decides it, most of these items don't need
to be in ALSA.

As long as I know, the number of AVTPDU per second seems not to be
fixed. So each application is not allowed to calculate the timestamp by
its own way unless TSN implementation gives the information to each
applications.

For your information, in current ALSA implementation of IEC 61883-1/6 on
IEEE 1394 bus, the presentation timestamp is decided in ALSA side. The
number of isochronous packet transmitted per second is fixed by 8,000 in
IEEE 1394, and the number of data blocks in an IEC 61883-1 packet is
deterministic according to 'sampling transfer frequency' in IEC 61883-6
and isochronous cycle count passed from Linux FireWire subsystem.

In the TSN subsystem, like FireWire subsystem, callback for filling
payload should have information of 'when the packet is scheduled to be
transmitted'. With the information, each application can calculate the
number of event in the packet and presentation timestamp. Of cource,
this timestamp should be handled as 'avtp_timestamp' in packet queueing.

>> In ALSA, sampling rate conversion should be in userspace, not in kernel
>> land. In alsa-lib, sampling rate conversion is implemented in shared object.
>> When userspace applications start playbacking/capturing, depending on PCM
>> node to access, these applications load the shared object and convert PCM
>> frames from buffer in userspace to mmapped DMA-buffer, then commit them.
> 
> The AVB use case places an additional requirement on the rate
> conversion.  You will need to adjust the frequency on the fly, as the
> stream is playing.  I would guess that ALSA doesn't have that option?

In ALSA kernel/userspace interfaces , the specification cannot be
supported, at all.

Please explain about this requirement, where it comes from, which
specification and clause describe it (802.1AS or 802.1Q?). As long as I
read IEEE 1722, I cannot find such a requirement.

(When considering about actual hardware codecs, on-board serial bus such
as Inter-IC Sound, corresponding controller, immediate change of
sampling rate is something imaginary for semi-realtime applications. And
the idea has no meaning for typical playback/capture softwares.)


[1] [alsa-lib][PATCH 0/9 v3] ctl: add APIs for control element set
http://mailman.alsa-project.org/pipermail/alsa-devel/2016-June/109274.html
[2] IEEE 1722-2011
http://ieeexplore.ieee.org/servlet/opac?punumber=5764873
[3] 5.5 Timing and Synchronization
op. cit.
[4] 1394 Open Host Controller Interface Specification
http://download.microsoft.com/download/1/6/1/161ba512-40e2-4cc9-843a-923143f3456c/ohci_11.pdf


Regards

Takashi Sakamoto
