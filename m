From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Mon, 31 Aug 2015 11:50:31 +0300
Message-ID: <55E41557.1060803@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru>
 <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
 <1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
 <87k2sk9zaf.fsf@nemi.mork.no> <55E01750.4010202@rosalab.ru>
 <87mvxbzta9.fsf@nemi.mork.no> <55E03B28.6050305@rosalab.ru>
 <87io7vzzdl.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87io7vzzdl.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

31.08.2015 10:32, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>> 28.08.2015 11:55, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>
>>> I guess you are right.  At least I cannot prove that you are not :)
>>>
>>> There is a bit too much complexity involved here for me...
>>
>> :-)
>>
>> Yes, it is quite complex.
>>
>> I admit, it was easier for me to find the races in usbnet (the tools
>> like KernelStrider and RaceHound do the dirty work) than to analyze
>> their consequences. The latter often requires some time and effort,
>> and so it did this time.
>>
>> Well, any objections to this patch?
>
> No objections from me.
>
> But I would have liked it much better if the code became simpler inst=
ead
> of more complex.

Me too, but I can see no other way here. The code is simpler without=20
locking, indeed, but locking is needed to prevent the problems describe=
d=20
earlier.

One needs to make sure that checking if txq or rxq is empty in=20
usbnet_terminate_urbs() cannot get inbetween of processing of these=20
queues and dev->done in defer_bh(). So 'list' and 'dev->done' must be=20
updated under a common lock in defer_bh(). list->lock is an obvious=20
candidate for this.

=46or the same reason, skb_queue_empty(q) must be called under q->lock.=
 So=20
the code takes it, calls skb_queue_empty(q) and then releases it to wai=
t=20
a little. Rinse and repeat.

The last complex piece is that spin_lock_nested() in defer_bh. It is=20
safe to take both list->lock and dev->done.lock there (defer_bh can onl=
y=20
be called for list =3D dev->rxq or dev->txq but not for dev->done). For=
=20
lockdep, however, this is suspicious because '*list' and 'dev->done' ar=
e=20
of the same type so the lock class is the same. So it complained.

To tell lockdep it is OK to use such locking scheme in this particular=20
case, the recommended pattern was used: spin_lock_nested with=20
SINGLE_DEPTH_NESTING.

Regards,
Eugene
