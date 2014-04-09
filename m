From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] openvswitch: supply a dummy err_handler of
 gre_cisco_protocol to prevent kernel crash
Date: Tue, 8 Apr 2014 17:46:00 -0700
Message-ID: <CAEP_g=8VE8KWu8CqTNeub8rTwiVZD-SWGDr9mZzgAZ-0-T2AMQ@mail.gmail.com>
References: <1396398194-4163-1-git-send-email-asuka.com@163.com>
 <CAEP_g=9WRyaSmRKHDZmWXwzjDyex8NheyveGzfH4qmMbhgGHdQ@mail.gmail.com>
 <158dbf4d.1b3c.145301dbf7a.Coremail.asuka.com@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: wei zhang <asuka.com-9Onoh4P/yGk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <158dbf4d.1b3c.145301dbf7a.Coremail.asuka.com-9Onoh4P/yGk@public.gmane.org>
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

On Fri, Apr 4, 2014 at 9:20 PM, wei zhang <asuka.com-9Onoh4P/yGk@public.gmane.org> wrote:
> At 2014-04-05 07:05:59,"Jesse Gross" <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>>On Tue, Apr 1, 2014 at 5:23 PM, Wei Zhang <asuka.com-9Onoh4P/yGk@public.gmane.org> wrote:
>>>
>>> v2 -> v1: use the same logic of the gre_rcv() to distinguish which packet is
>>> intended to us!
>>
>>As a tip on kernel process: if you put the version information after
>>three dashes below the signed-off-by line then git will automatically
>>remove it when the final patch is applied.
>
> Thanks, should I modify it and send a v3 patch?
>
>>
>>> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
>>> index a3d6951..f391df1 100644
>>> --- a/net/openvswitch/vport-gre.c
>>> +++ b/net/openvswitch/vport-gre.c
>>> @@ -110,6 +110,21 @@ static int gre_rcv(struct sk_buff *skb,
>>>         return PACKET_RCVD;
>>>  }
>>>
>>> +/* Called with rcu_read_lock and BH disabled. */
>>> +static int gre_err(struct sk_buff *skb, u32 info,
>>> +                  const struct tnl_ptk_info *tpi)
>>> +{
>>> +       struct ovs_net *ovs_net;
>>> +       struct vport *vport;
>>> +
>>> +       ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
>>> +       vport = rcu_dereference(ovs_net->vport_net.gre_vport);
>>> +       if (unlikely(!vport))
>>> +               return PACKET_REJECT;
>>> +       else
>>> +               return PACKET_RCVD;
>>
>>Sorry, I forgot to say this before - if we receive the packet then we
>>should also call consume_skb() on it.
>
> Maybe there is no need to call consume_skb()? The icmp_rcv() would
> call kfree_skb() for us. I also checked the ipgre_err(), it return
> PACKET_RCVD without call consume_skb() too.

Thanks, you are right. I applied your patch as is.
