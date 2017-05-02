From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 3/7] net: add function to retrieve original
 skb device using NAPI ID
Date: Tue, 2 May 2017 12:16:13 -0400
Message-ID: <CAF=yD-+n-KF3r1zDiKEQCQsPMkF_DxGZG3AEpzbX4jXFUXcW-Q@mail.gmail.com>
References: <20170502101103.30444-1-mlichvar@redhat.com> <20170502101103.30444-4-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34112 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdEBQQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:16:54 -0400
Received: by mail-io0-f193.google.com with SMTP id h41so31326955ioi.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 09:16:54 -0700 (PDT)
In-Reply-To: <20170502101103.30444-4-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 6:10 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Since commit b68581778cd0 ("net: Make skb->skb_iif always track
> skb->dev") skbs don't have the original index of the interface which
> received the packet. This information is now needed for a new control
> message related to hardware timestamping.
>
> Instead of adding a new field to skb, we can find the device by the NAPI
> ID if it is available, i.e. CONFIG_NET_RX_BUSY_POLL is enabled and the
> driver is using NAPI. Add dev_get_by_napi_id() and also skb_napi_id() to
> hide the CONFIG_NET_RX_BUSY_POLL ifdef.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Suggested-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

>  /**
> + *     dev_get_by_napi_id - find a device by napi_id
> + *     @napi_id: ID of the NAPI struct
> + *
> + *     Search for an interface by NAPI ID. Returns %NULL if the device
> + *     is not found or a pointer to the device. The device has not had
> + *     its reference counter increased so the caller must be careful
> + *     about locking. The caller must hold RCU lock.

Instead of a comment, can check with

  WARN_ON_ONCE(!rcu_read_lock_held());

> + */
> +
> +struct net_device *dev_get_by_napi_id(unsigned int napi_id)
> +{
> +       struct napi_struct *napi;
> +
> +       if (napi_id < MIN_NAPI_ID)
> +               return NULL;
> +
> +       napi = napi_by_id(napi_id);
> +       if (napi)
> +               return napi->dev;
> +
> +       return NULL;

make return NULL the branch expected not taken.

  return napi ? napi->dev : NULL;
