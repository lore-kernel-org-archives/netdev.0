From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH]  hso.c against 2.6.27-rc5 throttle/unthrottle to prevent
 loss of serial data
Date: Fri, 05 Sep 2008 15:30:00 +0200
Message-ID: <48C13458.50803@option.com>
References: <48C0FD6A.10706@option.com> <20080905140919.05f9edd8@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080905140919.05f9edd8-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,
You are very close to understanding me.
If my understanding of the n_tty.c code is correct it will
only start throttling when there is TTY_THRESHOLD_THROTTLE
i.e. 128 bytes left in the n_tty ring buffer this is a very low limit
for my driver. This means
that if I try to do a tty_flip_buffer_push of
of a tty buffer larger than 128 bytes when the threshold
is reached I will lose data. My urb buffers are 4k in
size 2 buffers of this size up to the tty layer in a row 
quickly I believe I'll lose data in the n_tty layer.

Alan Cox wrote:
> O> Alan you'll notice I'm calling tty_flip_buffer_push(tty)
>> i.e. flush_to_ldisc every 32 bytes as
>> TTY_THRESHOLD_THROTTLE in /drivers/char/n_tty.c is
>> only 128 bytes & I need to get unthrottled before
>> I lose characters it would be nice if the tty layer
>> could set the size of the throttle/unthrottle parameters
>> & the size of the n_tty ring buffer.
> 
> I don't really follow what you are trying to do here. You have two layers
> of buffering to consider
> 
>    Driver -> | tty buffer queue (64k) | n_tty - internal queue | user
> 
> 
> And it is when the internal queue gets full that we call throttle not
> when the 64K of tty buffering is full.
> 
> So you really shouldn't see a problem unless you have many Kbytes of USB
> requests floating around to consume all the buffering even after the tty
> is throttled.
> 
> As to the robustness - the USB tty code is generally pretty bad in this
> area so hso won't be any worse. Probably it is sufficient to keep an eye
> on what is in flight and when an URB completes don't just reissue it but
> reissue any others that didn't get posted due to errors.
> 
> The only other case you then have to trap is the nothing could be queued
> case which should never happen and I guess if you are passionate about
> robustness would need a timer.
> 
> Alan


-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
