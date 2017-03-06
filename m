From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 3/4] vhost: interrupt coalescing support
Date: Mon, 6 Mar 2017 12:31:38 -0500
Message-ID: <CAF=yD-+n_qJP+VK6BqH6dDkBDFaza3X=RJffdCi3cL8aCnUMSw@mail.gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-4-willemdebruijn.kernel@gmail.com> <51a3fba2-a789-7bcf-946d-577220865709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35799 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752685AbdCFRcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 12:32:20 -0500
Received: by mail-wm0-f66.google.com with SMTP id z63so12720599wmg.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 09:32:19 -0800 (PST)
In-Reply-To: <51a3fba2-a789-7bcf-946d-577220865709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 6, 2017 at 4:28 AM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B403=E6=9C=8803=E6=97=A5 22:39, Willem de Bruijn wrote:
>>
>> +void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq);
>> +static enum hrtimer_restart vhost_coalesce_timer(struct hrtimer *timer)
>> +{
>> +       struct vhost_virtqueue *vq =3D
>> +               container_of(timer, struct vhost_virtqueue, ctimer);
>> +
>> +       if (mutex_trylock(&vq->mutex)) {
>> +               vq->coalesce_frames =3D vq->max_coalesce_frames;
>> +               vhost_signal(vq->dev, vq);
>> +               mutex_unlock(&vq->mutex);
>> +       }
>> +
>> +       /* TODO: restart if lock failed and not held by handle_tx */
>> +       return HRTIMER_NORESTART;
>> +}
>> +
>
>
> Then we may lose an interrupt forever if no new tx request? I believe we
> need e.g vhost_poll_queue() here.

Absolutely, I need to fix this. The common case for failing to grab
the lock is competition with handle_tx. With careful coding we can
probably avoid scheduling another run with vhost_poll_queue in
the common case.

Your patch v7 cancels the pending hrtimer at the start of handle_tx.
I need to reintroduce that, and also only schedule a timer at the end
of handle_tx, not immediately when vq->coalesce_frames becomes
non-zero.
