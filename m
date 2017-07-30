From: "K. Den" <den@klaipeden.com>
Subject: Re: [PATCH net] Revert "vhost: cache used event for better
 performance"
Date: Sun, 30 Jul 2017 15:26:51 +0900
Message-ID: <1501396011.21001.11.camel@klaipeden.com>
References: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
         <20170726155435-mutt-send-email-mst@kernel.org>
         <117542fc-eef9-c043-7c9e-daafceb7db4e@redhat.com>
         <6b3a9a98-c095-1729-3528-dd521f136797@redhat.com>
         <20170726190745-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726190745-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-07-26 at 19:08 +0300, Michael S. Tsirkin wrote:
> On Wed, Jul 26, 2017 at 09:37:15PM +0800, Jason Wang wrote:
> > 
> > 
> > On 2017年07月26日 21:18, Jason Wang wrote:
> > > 
> > > 
> > > On 2017年07月26日 20:57, Michael S. Tsirkin wrote:
> > > > On Wed, Jul 26, 2017 at 04:03:17PM +0800, Jason Wang wrote:
> > > > > This reverts commit 809ecb9bca6a9424ccd392d67e368160f8b76c92. Since it
> > > > > was reported to break vhost_net. We want to cache used event and use
> > > > > it to check for notification. We try to valid cached used event by
> > > > > checking whether or not it was ahead of new, but this is not correct
> > > > > all the time, it could be stale and there's no way to know about this.
> > > > > 
> > > > > Signed-off-by: Jason Wang<jasowang@redhat.com>
> > > > 
> > > > Could you supply a bit more data here please?  How does it get stale?
> > > > What does guest need to do to make it stale?  This will be helpful if
> > > > anyone wants to bring it back, or if we want to extend the protocol.
> > > > 
> > > 
> > > The problem we don't know whether or not guest has published a new used
> > > event. The check vring_need_event(vq->last_used_event, new + vq->num,
> > > new) is not sufficient to check for this.
> > > 
> > > Thanks
> > 
> > More notes, the previous assumption is that we don't move used event back,
> > but this could happen in fact if idx is wrapper around.
> 
> You mean if the 16 bit index wraps around after 64K entries.
> Makes sense.
> 
> > Will repost and add
> > this into commit log.
> > 
> > Thanks

Hi,

I am just curious but I have got a question:
AFAIU, if you wanted to keep the caching mechanism alive in the code base,
the following two changes could clear off the issue, or not?:
(1) Always fetch the latest event value from guest when signalled_used event is
invalid, which includes last_used_idx wraps-around case. Otherwise we might need
changes which would complicate too much the logic to properly decide whether or
not to skip signalling in the next vhost_notify round.
(2) On top of that, split the signal-postponing logic to three cases like:
* if the interval of vq.num is [2^16, UINT_MAX]:
any cached event is in should-postpone-signalling interval, so paradoxically
must always do signalling.
* else if the interval of vq.num is [2^15, 2^16):
the logic in the original patch (809ecb9bca6a9) suffices
* else (= less than 2^15) (optional):
checking only (vring_need_event(vq->last_used_event, new + vq->num, new)
would suffice.

Am I missing something, or is this irrelevant?
I would appreciate if you could elaborate a bit more how the situation where
event idx wraps around and moves back would make trouble.

Thanks.
