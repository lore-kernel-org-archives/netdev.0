From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 6/6] vhost_net: don't poll on -EFAULT
Date: Mon, 16 Apr 2012 16:39:00 +0300
Message-ID: <20120416133859.GB13190@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416060833.14140.28139.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416071646.GB25396@redhat.com>
 <4F8BD81A.7010507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F8BD81A.7010507@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2012 at 04:28:10PM +0800, Jason Wang wrote:
> On 04/16/2012 03:16 PM, Michael S. Tsirkin wrote:
> >On Mon, Apr 16, 2012 at 02:08:33PM +0800, Jason Wang wrote:
> >>Currently, we restart tx polling unconditionally when sendmsg()
> >>fails. This would cause unnecessary wakeups of vhost wokers as it's
> >>only needed when the socket send buffer were exceeded.
> >Why is this a problem?
> 
> This issue is when guest driver is able to hit the -EFAULT, vhost
> discard the the descriptor and restart the polling. This would wake
> vhost thread and repeat the loop again which waste cpu.

Does same thing happen if we get an error from copy from user?

> Another possible solution is don't discard the descriptor.
> >
> >>Fix this by
> >>restart the tx polling only when sendmsg() returns value other than
> >>-EFAULT.
> >>
> >>Signed-off-by: Jason Wang<jasowang@redhat.com>
> >>---
> >>  drivers/vhost/net.c |    3 ++-
> >>  1 files changed, 2 insertions(+), 1 deletions(-)
> >>
> >>diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> >>index 29abd65..035fa95 100644
> >>--- a/drivers/vhost/net.c
> >>+++ b/drivers/vhost/net.c
> >>@@ -262,7 +262,8 @@ static void handle_tx(struct vhost_net *net)
> >>  					UIO_MAXIOV;
> >>  			}
> >>  			vhost_discard_vq_desc(vq, 1);
> >>-			tx_poll_start(net, sock);
> >>+			if (err != -EFAULT)
> >>+				tx_poll_start(net, sock);
> >>  			break;
> >>  		}
> >>  		if (err != len)
> >--
> >To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >Please read the FAQ at  http://www.tux.org/lkml/
