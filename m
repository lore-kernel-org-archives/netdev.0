From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ipv4: Constrain UFO fragment sizes to multiples of 8 bytes
Date: Wed, 8 Jun 2016 21:59:23 -0700
Message-ID: <CAM_iQpUmts3gXa3cNSVxt=gVr-Erx5iAwoVhbEVgQqpGK6xLeA@mail.gmail.com>
References: <6A051441C8B95A448E49718A747690B901CA76BE7B@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Steven Caron <steven.caron@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35927 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932812AbcFIE7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:59:43 -0400
In-Reply-To: <6A051441C8B95A448E49718A747690B901CA76BE7B@gbplmail03.genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing netdev...)

On Mon, Jun 6, 2016 at 1:24 PM, Steven Caron <steven.caron@genband.com> wrote:
> Back in 2011, Bill Sommerfeld submitted an update to prevent ip_append_data to create malformed packets:
>  Commit: d9be4f7a6f5a8da3133b832eca41c3591420b1ca
>
> Now we're finding that we need to apply the same logic to ip_append_page  to get nfs to work with udp when UFO is enabled:
>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 124bf0a..21ec54e 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1239,7 +1239,7 @@ ssize_t   ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
>                 if (skb->ip_summed != CHECKSUM_PARTIAL)
>                         return -EOPNOTSUPP;
>
> -               skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
> +               skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
>                 skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>         }
>         cork->length += size;
>
> We're wondering if this is something that was missed by that initial update of if there is a reason for ip_append_page to behave differently.
>
> We realize that there might not be a lot of people who care about running NFS over UDP, but the issue is still reproducible in the latest kernel.
>
> I include some additional info in case anyone is interested in reproducing with their own setup.
>
> Using two VMs connected with a bridge, one using e1000, the other virtio.
> Test done using FInnix 111 (kernel 4.0) as the guest.
>
> # On each VM export which allows NFSv3
> mount -t tmpfs tmps /export
> vi /etc/exports
> /export *(rw,no_subtree_check,fsid=0,insecure) # insecure to allow NFSv3
> /etc/init.d/rpcbind start
> /etc/init.d/nfs-kernel-server start
>
> # On each VM mount each other exported as UDP
> mkdir /mnt/import
> mount 169.254.208.5:/export /mnt/import -o vers=3,udp,rsize=16394,wsize=16384,soft,nolock # soft to avoid permanent hang
>
> # Using common MTU of 1500 on both VMs
> ifconfig eth0 mtu 1500
>
> # On the one with UFO=on (virtio):
> dd if=/dev/zero count=1 bs=16384 of=/mnt/import/test
> # Work as expected
>
> # On the one with UFO=on (virtio)
> dd if=/dev/zero count=1 bs=16384 of=/export/test
> # On the one with UFO=off (e1000)
> dd if=/mnt/import/test count=1 bs=16384 of=/dev/null
> # Work as expected
>
>
> # Using non-standard MTU of 1496 of both VMs
> ifconfig eth0 mtu 1496
>
> # On the one with UFO=on (virtio)
> dd if=/dev/zero count=1 bs=16384 of=/mnt/import/test
> # get Input/output error
>
> # On the one with UFO=on (virtio)
> dd if=/dev/zero count=1 bs=16384 of=/export/test
> # On the one with UFO=off (e1000)
> dd if=/mnt/import/test count=1 bs=1496 of=/dev/null
> # get Input/output error
>
> Regards,
>
> Steven Caron
> Designer, GENWare
> 500 Palladium Dr. Suite 2100| Ottawa ON, K2V 1C2
> office: +1.343.883.2345  |  steven.caron.genband.com
>
>
>
