From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Tue, 20 May 2014 09:34:03 +0300
Message-ID: <20140520063403.GB6653@redhat.com>
References: <537AF036.7010005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Xi Wang <xii@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbaETGfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:35:18 -0400
Content-Disposition: inline
In-Reply-To: <537AF036.7010005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 02:03:34PM +0800, Jason Wang wrote:
> On 05/20/2014 01:11 PM, Eric Dumazet wrote:
> > On Tue, 2014-05-20 at 12:44 +0800, Jason Wang wrote:
> >> On 05/19/2014 10:09 PM, Eric Dumazet wrote:
> >>> About the sk_data_ready() and wake_up_all(), you missed the whole part
> >>> of the patch I think.
> >>>
> >>> Check how sock_def_readable() does everything properly and efficiently,
> >>> including the async part.
> >> But this changes (sk_data_ready()) has nothing related to switching to
> >> use __skb_recv_datagram()
> >>
> > This is totally related.
> >
> > I think you did not yet understood this patch
> 
> Sorry for being unclear, but I think you misunderstand my meaning.
> >
> > Compare wake_up_all() and sk_data_ready() speeds, you'll be surprised.
> >
> > You should ask to yourself : Why do we use wq_has_sleeper() in
> > networking stacks ?
> 
> See my first reply, I don't have objection that uses sk_data_ready() in
> tun_net_xmit(). My only concern is using sk_data_ready() in
> tun_detach_all():
> 
> - It was only called during tun destroying, so I believe we don't care
> about the performance in this condition.
> - sk_data_ready() was usually called when there's something new to be
> processed which is not case in tun_detach_all()

OK so what does userspace do to notice change in behaviour?
I don't ask that you write a test but can you show us in
pseudo-code?


> - Not sure it was a problem but sock_def_readable() will not wake up
> uninterruptible task during tun destroying.

But task_uninterruptible here would really mean some in-kernel caller
hooking into this function? is there a way to create this from
userspace? If not we don't care.

> - If we make sock_fasync() works for tun in the future, it may send
> SIGIO to user process during tun destroying which is not expected.
> 
> Thanks

I don't get this last comment. The patch does not touch fasync paths
at all. How can it break them?
