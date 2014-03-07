From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to
 userspace via Netlink to avoid guest stall
Date: Fri, 7 Mar 2014 09:28:50 -0800
Message-ID: <CALnjE+q=fejHPsjVj9+jnypJCUHfCDFc553U48WR48Tjcf3FZw@mail.gmail.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
 <5319F272.1070101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <5319F272.1070101-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Fri, Mar 7, 2014 at 8:23 AM, Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 02/28/2014 08:16 PM, Zoltan Kiss wrote:
>>
>> The kernel datapath now switched to zerocopy Netlink messages, but that
>> also
>> means that the pages on frags array are sent straight to userspace. If
>> those
>> pages came outside the kernel, we have to swap them out with local copies.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
>> ---
>>   net/openvswitch/datapath.c |    6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
>> index 36f8872..ffb563c 100644
>> --- a/net/openvswitch/datapath.c
>> +++ b/net/openvswitch/datapath.c
>> @@ -464,6 +464,12 @@ static int queue_userspace_packet(struct datapath
>> *dp, struct sk_buff *skb,
>>         }
>>         nla->nla_len = nla_attr_size(skb->len);
>>
>> +       if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC))) {
>> +               err = -ENOMEM;
>> +               skb_tx_error(skb);
>> +               goto out;
>> +       }
>> +
>>         skb_zerocopy(user_skb, skb, skb->len, hlen);
>>
>>         /* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
>
>
> How about we move the call to skb_orphan_frags() into skb_zerocopy()
> itself and call it before we actually reference the frags?
>

Problem is mapping SKBTX_DEV_ZEROCOPY pages to userspace. skb_zerocopy
is not doing that.

Unless I missing something, Current netlink code can not handle
skb-frags with zero copy. So we have to copy skb anyways and no need
to orphan-frags here.
If you are planning on handling skb-frags without copying then
skb_orphan_frags should be done in netlink.
