From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Wed, 15 Jun 2016 10:06:02 +0200
Message-ID: <20160615080602.GA13555@localhost.localdomain>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>, alsa-devel@vger.kernel.org,
	linux-media@vger.kernel.org
To: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5760C84C.40408@sakamocchi.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 12:15:24PM +0900, Takashi Sakamoto wrote:
> > On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
> >> I have seen audio PLL/multiplier chips that will take, for example, a
> >> 10 kHz input and produce your 48 kHz media clock.  With the right HW
> >> design, you can tell your PTP Hardware Clock to produce a 10000 PPS,
> >> and you will have a synchronized AVB endpoint.  The software is all
> >> there already.  Somebody should tell the ALSA guys about it.
> 
> Just from my curiosity, could I ask you more explanation for it in ALSA
> side?

(Disclaimer: I really don't know too much about ALSA, expect that is
fairly big and complex ;)

Here is what I think ALSA should provide:

- The DA and AD clocks should appear as attributes of the HW device.

- There should be a method for measuring the DA/AD clock rate with
  respect to both the system time and the PTP Hardware Clock (PHC)
  time.

- There should be a method for adjusting the DA/AD clock rate if
  possible.  If not, then ALSA should fall back to sample rate
  conversion.

- There should be a method to determine the time delay from the point
  when the audio data are enqueued into ALSA until they pass through
  the D/A converter.  If this cannot be known precisely, then the
  library should provide an estimate with an error bound.

- I think some AVB use cases will need to know the time delay from A/D
  until the data are available to the local application.  (Distributed
  microphones?  I'm not too sure about that.)

- If the DA/AD clocks are connected to other clock devices in HW,
  there should be a way to find this out in SW.  For example, if SW
  can see the PTP-PHC-PLL-DA relationship from the above example, then
  it knows how to synchronize the DA clock using the network.

  [ Implementing this point involves other subsystems beyond ALSA.  It
    isn't really necessary for people designing AVB systems, since
    they know their designs, but it would be nice to have for writing
    generic applications that can deal with any kind of HW setup. ]

> In ALSA, sampling rate conversion should be in userspace, not in kernel
> land. In alsa-lib, sampling rate conversion is implemented in shared object.
> When userspace applications start playbacking/capturing, depending on PCM
> node to access, these applications load the shared object and convert PCM
> frames from buffer in userspace to mmapped DMA-buffer, then commit them.

The AVB use case places an additional requirement on the rate
conversion.  You will need to adjust the frequency on the fly, as the
stream is playing.  I would guess that ALSA doesn't have that option?

Thanks,
Richard
