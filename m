From: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Wed, 15 Jun 2016 12:15:24 +0900
Message-ID: <5760C84C.40408@sakamocchi.jp>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain> <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Henrik Austad <henrik@austad.us>,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@linaro.org>,
	alsa-devel@vger.kernel.org, linux-media@vger.kernel.org
To: alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-proxy002.phy.lolipop.jp ([157.7.104.43]:56446 "EHLO
	smtp-proxy002.phy.lolipop.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932364AbcFODP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 23:15:28 -0400
In-Reply-To: <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

 > On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
 >> 3. ALSA support for tunable AD/DA clocks.  The rate of the Listener's
 >>    DA clock must match that of the Talker and the other Listeners.
 >>    Either you adjust it in HW using a VCO or similar, or you do
 >>    adaptive sample rate conversion in the application. (And that is
 >>    another reason for *not* having a shared kernel buffer.)  For the
 >>    Talker, either you adjust the AD clock to match the PTP time, or
 >>    you measure the frequency offset.
 >>
 >> I have seen audio PLL/multiplier chips that will take, for example, a
 >> 10 kHz input and produce your 48 kHz media clock.  With the right HW
 >> design, you can tell your PTP Hardware Clock to produce a 10000 PPS,
 >> and you will have a synchronized AVB endpoint.  The software is all
 >> there already.  Somebody should tell the ALSA guys about it.

Just from my curiosity, could I ask you more explanation for it in ALSA 
side?

The similar mechanism to synchronize endpoints was also applied to audio 
and music unit on IEEE 1394 bus. According to IEC 61883-1/6, some of 
these actual units can generate presentation-timestamp from header 
information of 8,000 packet per sec, and utilize the signal as sampling 
clock[1].

There's much differences between IEC 61883-1/6 on IEEE 1394 bus and 
Audio and Video Bridge on Ethernet[2], especially for synchronization, 
but in this point of transferring synchnization signal and time-based 
data, we have the similar requirements of software implementations, I think.

My motivation to join in this discussion is to consider about to make it 
clear to implement packet-oriented drivers in ALSA kernel-land, and 
enhance my work for drivers to handle IEC 61883-1/6 on IEEE 1394 bus.

 >> I don't know if ALSA has anything for sample rate conversion or not,
 >> but haven't seen anything that addresses distributed synchronized
 >> audio applications.

In ALSA, sampling rate conversion should be in userspace, not in kernel 
land. In alsa-lib, sampling rate conversion is implemented in shared 
object. When userspace applications start playbacking/capturing, 
depending on PCM node to access, these applications load the shared 
object and convert PCM frames from buffer in userspace to mmapped 
DMA-buffer, then commit them.

Before establishing a PCM substream, userspace applications and 
in-kernel drivers communicate to decide sampling rate, PCM frame format, 
the size of PCM buffer, and so on. (see snd_pcm_hw_params() and 
ioctl(SNDRV_PCM_IOCTL_HW_PARAMS)). Thus, as long as in-kernel drivers 
know specifications of endpoints, userspace applications can start PCM 
substreams correctly.


[1] In detail, please refer to specification of 1394TA I introduced:
http://www.spinics.net/lists/netdev/msg381259.html
[2] I guess that IEC 61883-1/6 packet for Ethernet-AVB is a mutant from 
original specifications.


Regards

Takashi Sakamoto
