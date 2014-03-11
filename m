From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to
 userspace via Netlink to avoid guest stall
Date: Tue, 11 Mar 2014 19:41:04 +0000
Message-ID: <531F66D0.1050000@citrix.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>	<5319F272.1070101@redhat.com>
 <CALnjE+q=fejHPsjVj9+jnypJCUHfCDFc553U48WR48Tjcf3FZw@mail.gmail.com>
 <531A0911.4040304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <531A0911.4040304-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 07/03/14 17:59, Thomas Graf wrote:
> On 03/07/2014 06:28 PM, Pravin Shelar wrote:
>> Problem is mapping SKBTX_DEV_ZEROCOPY pages to userspace. skb_zerocopy
>> is not doing that.
>>
>> Unless I missing something, Current netlink code can not handle
>> skb-frags with zero copy. So we have to copy skb anyways and no need
>> to orphan-frags here.
>> If you are planning on handling skb-frags without copying then
>> skb_orphan_frags should be done in netlink.
>
> If you look at the second part of skb_zerocopy() this is exactly what
> it is doing unless the target skb has sufficient linear space
> preallocated. At least unless mmap is enabled in which case we would
> have to copy again until we have implemented a way to pass page refs
> via the nl ring buffer.
>
> So I think Zoltan is correct in orphaning frags that come from f.e.
> a tun device via zerocopy_sg_from_iovec().

Now as I'm checking how Netlink works, I might be wrong at some parts :) 
skb_zerocopy correctly add the frags to the user_skb we are sending 
upwards, however when the userspace receive it in netlink_recvmsg(), it 
gets copied to the supplied buffer anyway. Is that correct? In which 
case we don't need to worry that userspace will sit on that page 
indefinitely. However we have to worry about userspace not calling recv 
on that Netlink socket, so in the end we still need skb_orphan_frags, 
just for a different reason :)
We can put skb_orphan_frags into skb_zerocopy, skb_clone also do that.

However with Netlink mmapped IO, we should take a different approach, 
and instead of calling skb_orphan_frags we should make sure user_skb can 
hold any skb we get from the kernel, and copy the frags there. Even if 
we would be able to pass page refs to userspace through the ring buffer 
(AFAIK currently we can't), it would be fragile to just pass kernel 
pages directly to userspace, even if they came without the 
SKBTX_DEV_ZEROCOPY flag. And I think it would be quite rare that we need 
that copy anyway, because the flow setup usually happens with small 
packets without frags.
If we choose the above approach with Netlink mmap, we don't need 
skb_orphan_frags, in fact

Regards,

Zoli
