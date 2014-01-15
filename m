From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tun/macvtap: limit the packets queued through
 rcvbuf
Date: Wed, 15 Jan 2014 11:36:01 +0800
Message-ID: <52D60221.1060701@redhat.com>
References: <1389682387-28601-1-git-send-email-jasowang@redhat.com> <20140114082516.GB1101@redhat.com> <52D4F924.2040502@redhat.com> <20140114095219.GB2846@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbaAODg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 22:36:28 -0500
In-Reply-To: <20140114095219.GB2846@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2014 05:52 PM, Michael S. Tsirkin wrote:
> On Tue, Jan 14, 2014 at 04:45:24PM +0800, Jason Wang wrote:
>> > On 01/14/2014 04:25 PM, Michael S. Tsirkin wrote:
>>> > > On Tue, Jan 14, 2014 at 02:53:07PM +0800, Jason Wang wrote:
>>>> > >> We used to limit the number of packets queued through tx_queue_length. This
>>>> > >> has several issues:
>>>> > >>
>>>> > >> - tx_queue_length is the control of qdisc queue length, simply reusing it
>>>> > >>   to control the packets queued by device may cause confusion.
>>>> > >> - After commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 ("macvtap: Add
>>>> > >>   support of packet capture on macvtap device."), an unexpected qdisc
>>>> > >>   caused by non-zero tx_queue_length will lead qdisc lock contention for
>>>> > >>   multiqueue deivce.
>>>> > >> - What we really want is to limit the total amount of memory occupied not
>>>> > >>   the number of packets.
>>>> > >>
>>>> > >> So this patch tries to solve the above issues by using socket rcvbuf to
>>>> > >> limit the packets could be queued for tun/macvtap. This was done by using
>>>> > >> sock_queue_rcv_skb() instead of a direct call to skb_queue_tail(). Also two
>>>> > >> new ioctl() were introduced for userspace to change the rcvbuf like what we
>>>> > >> have done for sndbuf.
>>>> > >>
>>>> > >> With this fix, we can safely change the tx_queue_len of macvtap to
>>>> > >> zero. This will make multiqueue works without extra lock contention.
>>>> > >>
>>>> > >> Cc: Vlad Yasevich <vyasevic@redhat.com>
>>>> > >> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>> > >> Cc: John Fastabend <john.r.fastabend@intel.com>
>>>> > >> Cc: Stephen Hemminger <stephen@networkplumber.org>
>>>> > >> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>>>> > >> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> > > No, I don't think we can change userspace-visible behaviour like that.
>>> > >
>>> > > This will break any existing user that tries to control
>>> > > queue length through sysfs,netlink or device ioctl.
>> > 
>> > But it looks like a buggy API, since tx_queue_len should be for qdisc
>> > queue length instead of device itself.
> Probably, but it's been like this since 2.6.x time.
> Also, qdisc queue is unused for tun so it seemed kind of
> reasonable to override tx_queue_len.
>
>> > If we really want to preserve the
>> > behaviour, how about using a new feature flag and change the behaviour
>> > only when the device is created (TUNSETIFF) with the new flag?
> OK this addresses the issue partially, but there's also an issue
> of permissions: tx_queue_len can only be changed if
> capable(CAP_NET_ADMIN). OTOH in your patch a regular user
> can change the amount of memory consumed per queue
> by calling TUNSETRCVBUF.

Yes, but we have the same issue for TUNSETSNDBUF.
>
>>> > >
>>> > > Take a look at my patch in msg ID 20140109071721.GD19559@redhat.com
>>> > > which gives one way to set tx_queue_len to zero without
>>> > > breaking userspace.
>> > 
>> > If I read the patch correctly, it will make no way for the user who
>> > really want to change the qdisc queue length for tun.
> Why would this matter?  As far as I can see qdisc queue is currently unused.
>

User may use qdisc to do port mirroring, bandwidth limitation, traffic
prioritization or more for a VM. So we do have users and maybe more
consider the case of vpn.
