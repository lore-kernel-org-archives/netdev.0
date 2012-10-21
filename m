From: Daniel Mack <zonque@gmail.com>
Subject: Re: was: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sun, 21 Oct 2012 16:21:41 +0200
Message-ID: <508404F5.2010502@gmail.com>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05> <20121020162759.GA12551@liondog.tnic> <966148591.30347.1350754909449.JavaMail.mail@webmail08> <20121020203227.GC555@elf.ucw.cz> <20121020225849.GA8976@liondog.tnic> <1781795634.31179.1350774917965.JavaMail.mail@webmail04> <20121021002424.GA16247@liondog.tnic> <1798605268.19162.1350784641831.JavaMail.mail@webmail17> <20121021110851.GA6504@liondog.tnic> <121566322.100103.1350820776893.JavaMail.mail@webmail20> <5083E4AA.3060807@gmail.com> <317435358.100327.1350822615555.JavaMail.mail@webmail20>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010407020805040801070700"
Cc: bp@alien8.de, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org, alsa-devel <alsa-devel@alsa-project.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54234 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799Ab2JUOVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 10:21:49 -0400
In-Reply-To: <317435358.100327.1350822615555.JavaMail.mail@webmail20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010407020805040801070700
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

[Cc: alsa-devel]

On 21.10.2012 14:30, Artem S. Tashkinov wrote:
> On Oct 21, 2012, Daniel Mack wrote: 
> 
>> A hint at least. How did you enable the audio record exactly? Can you
>> reproduce this with arecord?
>>
>> What chipset are you on? Please provide both "lspci -v" and "lsusb -v"
>> dumps. As I said, I fail to reproduce that issue on any of my machines.
> 
> All other applications can read from the USB audio without problems, it's
> just something in the way Adobe Flash polls my audio input which causes
> a crash.
> 
> Just video capture (without audio) works just fine in Adobe Flash.

Ok, so that pretty much rules out the host controller. I just wonder why
I still don't see it here, and I haven't heard of any such problem from
anyone else.

Some more questions:

- Which version of Flash are you running?
- Does this also happen with Firefox?
- Does flash access the device directly or via PulseAudio?
- Could you please apply the attached patch and see what it spits out to
dmesg once Flash opens the device? It returns -EINVAL in the hw_params
callback to prevent the actual streaming. On my machine with Flash
11.4.31.110, I get values of 2/44800/1/32768/2048/0, which seems sane.
Or does your machine still crash before anything is written to the logs?

> Only and only when I choose to use 
> 
> USB Device 0x46d:0x81d my system crashes in Adobe Flash.
>
> See the screenshot:
> 
> https://bugzilla.kernel.org/attachment.cgi?id=84151

When exactly does the crash happen? Right after you selected that entry
from the list? There's a little recording level meter in that dialog.
Does that show any input from the microphone?

> My hardware information can be fetched from here:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=49181
> 
> On a second thought that can be even an ALSA crash or pretty much
> anything else.

We'll see. Thanks for your help to sort this out!


Daniel




--------------010407020805040801070700
Content-Type: text/x-patch;
 name="snd-usb-hwparams.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="snd-usb-hwparams.diff"

diff --git a/sound/usb/pcm.c b/sound/usb/pcm.c
index f782ce1..5664b45 100644
--- a/sound/usb/pcm.c
+++ b/sound/usb/pcm.c
@@ -453,6 +453,18 @@ static int snd_usb_hw_params(struct snd_pcm_substream *substream,
 	unsigned int channels, rate, format;
 	int ret, changed;
 
+
+	printk(">>> %s()\n", __func__);
+
+	printk("format: %d\n", params_format(hw_params));
+	printk("rate: %d\n", params_rate(hw_params));
+	printk("channels: %d\n", params_channels(hw_params));
+	printk("buffer bytes: %d\n", params_buffer_bytes(hw_params));
+	printk("period bytes: %d\n", params_period_bytes(hw_params));
+	printk("access: %d\n", params_access(hw_params));
+
+	return -EINVAL;
+
 	ret = snd_pcm_lib_alloc_vmalloc_buffer(substream,
 					       params_buffer_bytes(hw_params));
 	if (ret < 0)

--------------010407020805040801070700--
