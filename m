From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix the error processing in netvsc_send()
Date: Wed, 4 Feb 2015 22:26:51 +0000
Message-ID: <BN1PR0301MB0770914291EB27A38F9C69EFCA3A0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1422563689-31036-1-git-send-email-haiyangz@microsoft.com>
 <1422613519.8840.0@smtp.corp.redhat.com>
 <BN1PR0301MB0770FCDA58F3BC9E25382D95CA310@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <1422859762.7028.2@smtp.corp.redhat.com>
 <BN1PR0301MB077018D4A512E3AA9B8583E0CA3D0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <1423034952.10558.3@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1423034952.10558.3@smtp.corp.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Wednesday, February 4, 2015 2:29 AM
> > The EAGAIN error doesn't normally happen, because we set the hi water
> > mark
> > to stop send queue.
> 
> This is not true since only txq was stopped which means only network
> stack stop sending packets but not for control path e.g
> rndis_filter_send_request() or other callers who call
> vmbus_sendpacket() directly (e.g recv completion).
> 
> For control path, user may meet several errors when they want to change
> mac address under heavy load.
> 
> What's more serious is netvsc_send_recv_completion(), it can not even
> recover from more than 3 times of EAGAIN.
> 
> I must say mixing data packets with control packets with the same
> channel sounds really scary. Since control packets could be blocked or
> even dropped because of data packets already queued during heavy load,
> and you need to synchronize two paths carefully (e.g I didn't see any
> tx lock were held if rndis_filter_send_request() call netsc_send()
> which may stop or start a queue).

The RING_AVAIL_PERCENT_HIWATER is defined to be 20, so the data traffic
can only occupy 20% of the ring buffer before stopping the txq. So, this
mechanism ensures the control messages are not blocked by data traffic.

> >  If in really rare case, the ring buffer is full and there
> > is no outstanding sends, we can't stop queue here because there will
> > be no
> > send-completion msg to wake it up.
> 
> Confused, I believe only txq is stopped but we may still get completion
> interrupt in this case.

If there is no outstanding sends in this queue (queue_sends[q_idx]), we 
won't receive any more send-completion msg.

> 
> > And, the ring buffer is likely to be
> > occupied by other special msg, e.g. receive-completion msg (not a
> > normal case),
> > so we can't assume there are available slots.
> 
> Then why not checking hv_ringbuf_avail_percent() instead? And there's
> no need to check queue_sends since it does not count recv completion.

When ret == -EAGAIN, which means the ring is full, we don't need to check
hv_ringbuf_avail_percent().

> > We don't request retry from
> > the upper layer in this case to avoid possible busy retry.
> 
> Can't we just do this by stopping txq and depending on tx interrupt to
> wake it?

There is no tx interrupt. Do you mean rx interrupt for the send-completion?

In usual cases, when we hit the high water mark, the stopped queue depends on
the send-completion msg to wake up. But, not in some special cases.
As said above, we won't receive any more send-completion msg when there is 
no outstanding sends in this queue.

Thanks,
- Haiyang
