From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 0/5] tun/macvtap: TUNSETIFF fixes
Date: Wed, 17 Dec 2014 03:19:52 +0008
Message-ID: <1418785912.6058.0@smtp.corp.redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, Dec 16, 2014 at 9:04 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> Dan Carpenter reported the following:
> 	static checker warning:
> 
> 		drivers/net/tun.c:1694 tun_set_iff()
> 		warn: 0x17100 is larger than 16 bits
> 
> 	drivers/net/tun.c
> 	  1692
> 	  1693          tun->flags = (tun->flags & ~TUN_FEATURES) |
> 	  1694                  (ifr->ifr_flags & TUN_FEATURES);
> 	  1695
> 
> 	It's complaining because the "ifr->ifr_flags" variable is a short
> 	(should it be unsigned?).  The new define:
> 
> 	#define IFF_VNET_LE    0x10000
> 
> 	doesn't fit in two bytes.  Other suspect looking code could be:
> 
> 		return __virtio16_to_cpu(q->flags & IFF_VNET_LE, val);
> 
> And that's true: we have run out of IFF flags in tun.

I don't have objections on this series.
Just note that we still have several bits available.
> 
> So let's not try to add more: add simple GET/SET ioctls
> instead. Easy to test, leads to clear semantics.
> 
> Alternatively we'll have to revert the whole thing for 3.19,
> but that seems more work as this has dependencies
> in other places.
> 
> While here, I noticed that macvtap was actually reading
> ifreq flags as a 32 bit field.
> Fix that up as well.
> 
> Michael S. Tsirkin (5):
>   macvtap: fix uninitialized access on TUNSETIFF
>   if_tun: add TUNSETVNETLE/TUNGETVNETLE
>   tun: drop broken IFF_VNET_LE
>   macvtap: drop broken IFF_VNET_LE
>   if_tun: drop broken IFF_VNET_LE
> 
>  include/uapi/linux/if_tun.h |  3 ++-
>  drivers/net/macvtap.c       | 30 ++++++++++++++++++++++++------
>  drivers/net/tun.c           | 26 +++++++++++++++++++++++---
>  3 files changed, 49 insertions(+), 10 deletions(-)
> 
> -- 
> MST
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
