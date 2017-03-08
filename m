From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 3/4] vhost: interrupt coalescing support
Date: Wed, 8 Mar 2017 11:25:21 +0800
Message-ID: <bf53ae2d-faca-a454-4df0-48296f8106b2@redhat.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-4-willemdebruijn.kernel@gmail.com>
 <51a3fba2-a789-7bcf-946d-577220865709@redhat.com>
 <CAF=yD-+n_qJP+VK6BqH6dDkBDFaza3X=RJffdCi3cL8aCnUMSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752548AbdCHDZe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 22:25:34 -0500
In-Reply-To: <CAF=yD-+n_qJP+VK6BqH6dDkBDFaza3X=RJffdCi3cL8aCnUMSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月07日 01:31, Willem de Bruijn wrote:
> On Mon, Mar 6, 2017 at 4:28 AM, Jason Wang <jasowang@redhat.com> wrote:
>>
>> On 2017年03月03日 22:39, Willem de Bruijn wrote:
>>> +void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq);
>>> +static enum hrtimer_restart vhost_coalesce_timer(struct hrtimer *timer)
>>> +{
>>> +       struct vhost_virtqueue *vq =
>>> +               container_of(timer, struct vhost_virtqueue, ctimer);
>>> +
>>> +       if (mutex_trylock(&vq->mutex)) {
>>> +               vq->coalesce_frames = vq->max_coalesce_frames;
>>> +               vhost_signal(vq->dev, vq);
>>> +               mutex_unlock(&vq->mutex);
>>> +       }
>>> +
>>> +       /* TODO: restart if lock failed and not held by handle_tx */
>>> +       return HRTIMER_NORESTART;
>>> +}
>>> +
>>
>> Then we may lose an interrupt forever if no new tx request? I believe we
>> need e.g vhost_poll_queue() here.
> Absolutely, I need to fix this. The common case for failing to grab
> the lock is competition with handle_tx. With careful coding we can
> probably avoid scheduling another run with vhost_poll_queue in
> the common case.

Yes, probably add some checking after releasing the mutex_lock in 
handle_tx().

Thans

>
> Your patch v7 cancels the pending hrtimer at the start of handle_tx.
> I need to reintroduce that, and also only schedule a timer at the end
> of handle_tx, not immediately when vq->coalesce_frames becomes
> non-zero.
