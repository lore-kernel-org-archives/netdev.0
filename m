From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 2/5] virtio-net: transmit napi
Date: Mon, 24 Apr 2017 20:14:12 +0300
Message-ID: <20170424201346-mutt-send-email-mst@kernel.org>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
	<20170418202108.61920-3-willemdebruijn.kernel@gmail.com>
	<2ae5889b-69d4-3041-d7fd-a7ea38e8c4e2@redhat.com>
	<CAF=yD-K0Cwwcob+0nWXWTY_07_zwcae1GRHwdagF2pGrv8HwtA@mail.gmail.com>
	<118c5f96-6151-c012-7a31-16d24a835878@redhat.com>
	<CAF=yD-KdtvXV+=ZROcLPHJxB55wbnJOmV0MJn2AJPHugoofR0g@mail.gmail.com>
	<20170424194015-mutt-send-email-mst@kernel.org>
	<CAF=yD-Lv8BptfhV+Many0iaG1Dz+LmkT2VVv5Kgo=TU31PJPHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAF=yD-Lv8BptfhV+Many0iaG1Dz+LmkT2VVv5Kgo=TU31PJPHQ@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 24, 2017 at 01:05:45PM -0400, Willem de Bruijn wrote:
> On Mon, Apr 24, 2017 at 12:40 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Fri, Apr 21, 2017 at 10:50:12AM -0400, Willem de Bruijn wrote:
> >> >>> Maybe I was wrong, but according to Michael's comment it looks like he
> >> >>> want
> >> >>> check affinity_hint_set just for speculative tx polling on rx napi
> >> >>> instead
> >> >>> of disabling it at all.
> >> >>>
> >> >>> And I'm not convinced this is really needed, driver only provide affinity
> >> >>> hint instead of affinity, so it's not guaranteed that tx and rx interrupt
> >> >>> are in the same vcpus.
> >> >>
> >> >> You're right. I made the restriction broader than the request, to really
> >> >> err
> >> >> on the side of caution for the initial merge of napi tx. And enabling
> >> >> the optimization is always a win over keeping it off, even without irq
> >> >> affinity.
> >> >>
> >> >> The cycle cost is significant without affinity regardless of whether the
> >> >> optimization is used.
> >> >
> >> >
> >> > Yes, I noticed this in the past too.
> >> >
> >> >> Though this is not limited to napi-tx, it is more
> >> >> pronounced in that mode than without napi.
> >> >>
> >> >> 1x TCP_RR for affinity configuration {process, rx_irq, tx_irq}:
> >> >>
> >> >> upstream:
> >> >>
> >> >> 1,1,1: 28985 Mbps, 278 Gcyc
> >> >> 1,0,2: 30067 Mbps, 402 Gcyc
> >> >>
> >> >> napi tx:
> >> >>
> >> >> 1,1,1: 34492 Mbps, 269 Gcyc
> >> >> 1,0,2: 36527 Mbps, 537 Gcyc (!)
> >> >> 1,0,1: 36269 Mbps, 394 Gcyc
> >> >> 1,0,0: 34674 Mbps, 402 Gcyc
> >> >>
> >> >> This is a particularly strong example. It is also representative
> >> >> of most RR tests. It is less pronounced in other streaming tests.
> >> >> 10x TCP_RR, for instance:
> >> >>
> >> >> upstream:
> >> >>
> >> >> 1,1,1: 42267 Mbps, 301 Gcyc
> >> >> 1,0,2: 40663 Mbps, 445 Gcyc
> >> >>
> >> >> napi tx:
> >> >>
> >> >> 1,1,1: 42420 Mbps, 303 Gcyc
> >> >> 1,0,2:  42267 Mbps, 431 Gcyc
> >> >>
> >> >> These numbers were obtained with the virtqueue_enable_cb_delayed
> >> >> optimization after xmit_skb, btw. It turns out that moving that before
> >> >> increases 1x TCP_RR further to ~39 Gbps, at the cost of reducing
> >> >> 100x TCP_RR a bit.
> >> >
> >> >
> >> > I see, so I think we can leave the affinity hint optimization/check for
> >> > future investigation:
> >> >
> >> > - to avoid endless optimization (e.g we may want to share a single
> >> > vector/napi for tx/rx queue pairs in the future) for this series.
> >> > - tx napi is disabled by default which means we can do optimization on top.
> >>
> >> Okay. I'll drop the vi->affinity_hint_set from the patch set for now.
> >
> > I kind of like it, let's be conservative. But I'd prefer a comment
> > near it explaining why it's there.
> 
> I don't feel strongly. Was minutes away from sending a v3 with this
> code reverted, but I'll reinstate it and add a comment. Other planned
> changes based on Jason's feedback to v2:
> 
>   v2 -> v3:
>     - convert __netif_tx_trylock to __netif_tx_lock on tx napi poll
>           ensure that the handler always cleans, to avoid deadlock
>     - unconditionally clean in start_xmit
>           avoid adding an unnecessary "if (use_napi)" branch
>     - remove virtqueue_disable_cb in patch 5/5
>           a noop in the common event_idx based loop

Makes sense, thanks!

-- 
MST
