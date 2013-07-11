From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 45/50] sound: usb: usx2y: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 22:13:35 +0800
Message-ID: <CACVXFVPuv4VD_xCocP2QVOqUqAXm9gjwgwcRn6y=3qXPntOxCQ@mail.gmail.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
	<1373533573-12272-46-git-send-email-ming.lei@canonical.com>
	<51DEAE4E.90204@cogentembedded.com>
	<s5hip0hb3y6.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Jaroslav Kysela <perex@perex.cz>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <s5hip0hb3y6.wl%tiwai@suse.de>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 11, 2013 at 9:50 PM, Takashi Iwai <tiwai@suse.de> wrote:
> At Thu, 11 Jul 2013 17:08:30 +0400,
> Sergei Shtylyov wrote:
>>
>> On 11-07-2013 13:06, Ming Lei wrote:
>>
>> > Complete() will be run with interrupt enabled, so change to
>> > spin_lock_irqsave().
>>
>>     Changelog doesn't match the patch.
>
> Yep, but moreover...
>
>> > Cc: Jaroslav Kysela <perex@perex.cz>
>> > Cc: Takashi Iwai <tiwai@suse.de>
>> > Cc: alsa-devel@alsa-project.org
>> > Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> > ---
>> >   sound/usb/usx2y/usbusx2yaudio.c |    4 ++++
>> >   1 file changed, 4 insertions(+)
>>
>> > diff --git a/sound/usb/usx2y/usbusx2yaudio.c b/sound/usb/usx2y/usbusx2yaudio.c
>> > index 4967fe9..e2ee893 100644
>> > --- a/sound/usb/usx2y/usbusx2yaudio.c
>> > +++ b/sound/usb/usx2y/usbusx2yaudio.c
>> > @@ -273,7 +273,11 @@ static void usX2Y_clients_stop(struct usX2Ydev *usX2Y)
>> >             struct snd_usX2Y_substream *subs = usX2Y->subs[s];
>> >             if (subs) {
>> >                     if (atomic_read(&subs->state) >= state_PRERUNNING) {
>> > +                           unsigned long flags;
>> > +
>> > +                           local_irq_save(flags);
>> >                             snd_pcm_stop(subs->pcm_substream, SNDRV_PCM_STATE_XRUN);
>> > +                           local_irq_restore(flags);
>> >                     }
>
> ... actually this snd_pcm_stop() call should have been covered by
> snd_pcm_stream_lock().  Maybe it'd be enough to have a single patch
> together with the change, i.e. wrapping with
> snd_pcm_stream_lock_irqsave().

Please use snd_pcm_stream_lock_irqsave() so that I can avoid sending
out similar patch later, :-)

>
> I'll prepare the patch for 3.11 independently from your patch series,
> so please drop this one.

OK, thanks for dealing with that.

>
>
> BTW, the word "cleanup" in the subject is inappropriate.  This is
> rather a fix together with the core change.

It is a cleanup since the patchset only addresses lock problem which
is caused by the tasklet conversion.

>
> And, I wonder whether we can take a safer approach.  When the caller
> condition changed, we often introduced either a different ops
> (e.g. ioctl case) or a flag for the new condition, at least during the
> transition period.

Interrupt is't enabled until all current drivers are cleaned up, so it is really
safe, please see patch [2].

>
> Last but not least, is a conversion to tasklet really preferred?
> tasklet is rather an obsoleted infrastructure nowadays, and people
> don't recommend to use it any longer, AFAIK.

We discussed the problem in the below link previously[1], Steven
and Thomas suggested to use threaded irq handler, but which
may degrade USB mass storage performance, so we have to
take tasklet now until we rewrite transport part of USB mass storage
driver.

Also the conversion[2] has avoided the tasklet spin lock problem
already.


[1], http://marc.info/?t=137079119200001&r=1&w=2
[2], http://marc.info/?l=linux-usb&m=137286326726326&w=2

Thanks,
--
Ming Lei
