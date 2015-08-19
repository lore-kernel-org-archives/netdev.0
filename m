From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vrf: plug skb leaks
Date: Wed, 19 Aug 2015 14:00:09 -0700
Message-ID: <55D4EE59.6030109@cumulusnetworks.com>
References: <1439953949-23736-1-git-send-email-razor@blackwall.org> <55D4B935.5090400@cumulusnetworks.com> <CABQ03vHefGG1yM6CPM2Xosa_MgxfgO0YK9EeqmHAQLZUWsh8Uw@mail.gmail.com> <B23BDD39-42FF-49D6-8515-680F9D5F3970@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shm@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34449 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbbHSVAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 17:00:12 -0400
Received: by pdbfa8 with SMTP id fa8so5525484pdb.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 14:00:11 -0700 (PDT)
In-Reply-To: <B23BDD39-42FF-49D6-8515-680F9D5F3970@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/19/15 1:17 PM, Nikolay Aleksandrov wrote:
>
>> On Aug 19, 2015, at 8:27 PM, Nikolay Aleksandrov <nikolay@cumulusnet=
works.com> wrote:
>>
>>
>> On Aug 19, 2015 20:13, "David Ahern" <dsa@cumulusnetworks.com> wrote=
:
>>>
>>> Hi Nikolay:
>>>
>>>
>>> On 8/18/15 8:12 PM, Nikolay Aleksandrov wrote:
>>>>
>>>> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
>>>> index ed208317cbb5..4aa06450fafa 100644
>>>> --- a/drivers/net/vrf.c
>>>> +++ b/drivers/net/vrf.c
>>>> @@ -97,6 +97,12 @@ static bool is_ip_rx_frame(struct sk_buff *skb)
>>>>          return false;
>>>>    }
>>>>
>>>> +static void vrf_tx_error(struct net_device *vrf_dev, struct sk_bu=
ff *skb)
>>>> +{
>>>> +       vrf_dev->stats.tx_errors++;
>>>> +       kfree_skb(skb);
>>>> +}
>>>> +
>>>>    /* note: already called with rcu_read_lock */
>>>>    static rx_handler_result_t vrf_handle_frame(struct sk_buff **ps=
kb)
>>>>    {
>>>> @@ -149,7 +155,8 @@ static struct rtnl_link_stats64 *vrf_get_stats=
64(struct net_device *dev,
>>>>    static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
>>>>                                             struct net_device *dev=
)
>>>>    {
>>>> -       return 0;
>>>> +       vrf_tx_error(dev, skb);
>>>> +       return NET_XMIT_DROP;
>>>>    }
>>>>
>>>>    static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 =
*fl4,
>>>> @@ -206,8 +213,7 @@ static netdev_tx_t vrf_process_v4_outbound(str=
uct sk_buff *skb,
>>>>    out:
>>>>          return ret;
>>>>    err:
>>>> -       vrf_dev->stats.tx_errors++;
>>>> -       kfree_skb(skb);
>>>> +       vrf_tx_error(vrf_dev, skb);
>>>>          goto out;
>>>>    }
>>>>
>>>> @@ -219,6 +225,7 @@ static netdev_tx_t is_ip_tx_frame(struct sk_bu=
ff *skb, struct net_device *dev)
>>>>          case htons(ETH_P_IPV6):
>>>>                  return vrf_process_v6_outbound(skb, dev);
>>>>          default:
>>>> +               vrf_tx_error(dev, skb);
>>>>                  return NET_XMIT_DROP;
>>>>          }
>>>>    }
>>>>
>>>
>>> Would be simpler to do the vrf_tx_error at the end of is_ip_tx_fram=
e() if ret =3D=3D NET_XMIT_DROP.
>>>
>>> David
>>>
>>
>> Sure, that will work too.
>>
>
> Actually no, this will not work because ip_local_out() can return NET=
_XMIT_DROP and the packet
> can already be dropped. I=E2=80=99d prefer to keep these cases separa=
te and explicit as they are in my patch.
>

ok. Then the patch looks good to me.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
