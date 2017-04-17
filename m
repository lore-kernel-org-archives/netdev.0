From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC] ptr_ring: add ptr_ring_unconsume
Date: Mon, 17 Apr 2017 12:43:52 +0300
Message-ID: <26e9e780-1fc7-5dc2-613c-ab957441bdd6@cogentembedded.com>
References: <1492384496-22644-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:34693 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753381AbdDQJnz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 05:43:55 -0400
Received: by mail-lf0-f46.google.com with SMTP id t144so63123982lff.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 02:43:54 -0700 (PDT)
In-Reply-To: <1492384496-22644-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 4/17/2017 2:19 AM, Michael S. Tsirkin wrote:

> Applications that consume a batch of entries in one go
> can benefit from ability to return some of them back
> into the ring.
>
> Add an API for that - assuming there's space. If there's no space
> naturally we can't do this and have to drop entries, but this implies
> ring is full so we'd likely drop some anyway.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> Jason, in my mind the biggest issue with your batching patchset is the
> backet drops on disconnect.  This API will help avoid that in the common

    Packet?

[...]
> diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
> index 783e7f5..5fbeab4 100644
> --- a/include/linux/ptr_ring.h
> +++ b/include/linux/ptr_ring.h
> @@ -457,6 +457,63 @@ static inline int ptr_ring_init(struct ptr_ring *r, int size, gfp_t gfp)
>  	return 0;
>  }
>
> +/*
> + * Return entries into ring. Destroy entries that don't fit.
> + *
> + * Note: this is expected to be a rare slow path operation.
> + *
> + * Note: producer lock is nested within consumer lock, so if you
> + * resize you must make sure all uses nest correctly.
> + * In particular if you consume ring in interrupt or BH context, you must
> + * disable interrupts/BH when doing so.
> + */
> +static inline void ptr_ring_unconsume(struct ptr_ring *r, void **batch, int n,
> +				      void (*destroy)(void *))
> +{
> +	unsigned long flags;
> +	int head;
> +
> +	spin_lock_irqsave(&(r)->consumer_lock, flags);
> +	spin_lock(&(r)->producer_lock);

    The innermost parens seem pointless here....

[...]
> +done:
> +	/* Destroy all entries left in the batch. */
> +	while (n--) {
> +		destroy(batch[n]);
> +	}

    Braces not needed here.

> +	spin_unlock(&(r)->producer_lock);
> +	spin_unlock_irqrestore(&(r)->consumer_lock, flags);

    Same comment about the innermost parens...

[...]

MBR, Sergei
