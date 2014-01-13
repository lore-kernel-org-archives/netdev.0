From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending refcount
Date: Sun, 12 Jan 2014 21:51:48 -0800
Message-ID: <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
	<1389543768-20234-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47183 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaAMFvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 00:51:48 -0500
Received: by mail-pa0-f49.google.com with SMTP id bj1so3383343pad.36
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 21:51:48 -0800 (PST)
In-Reply-To: <1389543768-20234-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 8:22 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> +static void packet_inc_pending(struct packet_ring_buffer *rb)
> +{
> +       this_cpu_inc(*rb->pending_refcnt);
> +}
> +
> +static void packet_dec_pending(struct packet_ring_buffer *rb)
> +{
> +       this_cpu_dec(*rb->pending_refcnt);
> +}
> +
> +static int packet_read_pending(const struct packet_ring_buffer *rb)
> +{
> +       int i, refcnt = 0;
> +
> +       /* We don't use pending refcount in rx_ring. */
> +       if (rb->pending_refcnt == NULL)
> +               return 0;
> +
> +       for_each_possible_cpu(i)
> +               refcnt += *per_cpu_ptr(rb->pending_refcnt, i);
> +
> +       return refcnt;
> +}

How is this supposed to work? Since there is no lock,
you can't read accurate refcnt. Take a look at lib/percpu_counter.c.

I guess for some reason you don't care the accuracy?
Then at least you need to comment in the code.

Thanks.
