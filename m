From: Mat Martineau <mathewm-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: Possible regression with skb_clone() in 2.6.36
Date: Fri, 10 Sep 2010 09:53:31 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1009100920270.14322@linux-sea-02>
References: <1283988727-1456-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1283988727-1456-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Gustavo -

I'm not sure why the streaming code used to work, but this does not 
look like an skb_clone() problem.  Your patch to remove the 
skb_clone() call in l2cap_streaming_send() addresses the root cause of 
this crash.

On Wed, 8 Sep 2010, Gustavo F. Padovan wrote:

> I've been experiencing some problems when running the L2CAP Streaming mode in
> 2.6.36. The system quickly runs in an Out Of Memory condition and crash. That
> wasn't happening before, so I think we may have a regression here (I didn't
> find where yet). The crash log is below.
>
> The following patch does not fix the regression, but shows that removing the
> skb_clone() call from l2cap_streaming_send() we workaround the problem. The
> patch is good anyway because it saves memory and time.
>
> By now I have no idea on how to fix this.
>
> <snip>

This has to do with the sk->sk_wmem_alloc accounting that controls the 
amount of write buffer space used on the socket.

When the L2CAP streaming mode socket segments its data, it allocates 
memory using sock_alloc_send_skb() (via bt_skb_send_alloc()).  Before 
that allocation call returns, skb_set_owner_w() is called on the new 
skb.  This adds to sk->sk_wmem_alloc and sets skb->destructor so that 
sk->sk_wmem_alloc is correctly updated when the skb is freed.

When that skb is cloned, the clone is not "owned" by the write buffer. 
The clone's destructor is set to NULL in __skb_clone().  The version 
of l2cap_streaming_send() that runs out of memory is passing the 
non-owned skb clone down to the HCI layer.  The original skb (the one 
that's "owned by w") is immediately freed, which adjusts 
sk->sk_wmem_alloc back down - the socket thinks it has unlimited write 
buffer space.  As a result, bt_skb_send_alloc() never blocks waiting 
for buffer space (or returns EAGAIN for nonblocking writes) and the 
HCI send queue keeps growing.

This isn't a problem for the ERTM sends, because the original skbs are 
kept in the ERTM tx queue until they are acked.  Once they're acked, 
the write buffer space is freed and additional skbs can be allocated.

Regards,

--
Mat Martineau
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum
