From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Fri, 6 Oct 2017 05:09:13 +0000
Message-ID: <CY1PR0701MB20123E0FC36400232910B65888710@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <CY1PR0701MB2012A2F8E3E923D98B1E1A6488700@CY1PR0701MB2012.namprd07.prod.outlook.com>
        <20171005.120629.2161199733119811102.davem@davemloft.net>
        <CY1PR0701MB201241C43A192735A0F1EEDD88700@CY1PR0701MB2012.namprd07.prod.outlook.com>,<20171005.172013.746380495399822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171005.172013.746380495399822.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> o=
n behalf of David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

>From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>Date: Thu, 5 Oct 2017 20:27:22 +0000
>
>> The spinlock is required for the case that rx buffers are posted
>> from a different thread, where it could be run simultaneously to the
>> rxq_completion.
>
>This only brings us back to my original argument, if the lock is
>necessary in order to synchronize with those paths, how can you
>possible drop the lock safely here?
>
>Is it because you re-read the head and tail pointers of the queue each
>time around the loop?

It's safe to drop the lock here because the implementation of the queue (qe=
d_chain)
maintains both a consumer pointer (tail) indices and producer pointer(head)=
.
The main loop reads  the FWs value and stores it as the "new cons"
and traverses the queue only until it reaches the FWs consumer value.=20
The post function adds more buffers to the end of the queue and updates the=
=20
producer. They will not affect the consumer pointers. So posting of buffers
doesn't affect the main loop.

The resources that are protected by the lock and accessed inside the loop
and from post-buffers are three linked-lists, free-descq, posting_descq and
active_descq, their head and tail are  read on every access
(elements are removed and moved between the lists).

Following this discussion, it looks like there was no need to take the lock=
 in the
outer function, but only around the places that access these lists, this is=
 a delicate
change which affects the ll2 clients (iscsi,fcoe,roce,iwarp). As this serie=
s is rather
large as it is and is intended for iWARP, please consider taking this one a=
s it is.=20
Since it doesn't change existing functionality and doesn't introduce risk t=
o other
components.=20

thanks,
Michal


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
