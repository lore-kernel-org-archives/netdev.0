From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Sat, 15 Sep 2012 18:48:33 -0700
Message-ID: <50552FF1.5030708@intel.com>
References: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com> <CAHXqBFJZnGUSUutN=L-_LpCN7dXLPFY0ndJnQJ10NCcbzPVLww@mail.gmail.com> <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Miroslaw <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37340 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932Ab2IPBsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2012 21:48:35 -0400
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/2012 6:25 PM, Dave, Tushar N wrote:
>> -----Original Message-----
>> From: Micha=B3 Miros=B3aw [mailto:mirqus@gmail.com]
>> Sent: Saturday, September 15, 2012 1:45 PM
>> To: Kirsher, Jeffrey T
>> Cc: davem@davemloft.net; Dave, Tushar N; netdev@vger.kernel.org;
>> gospo@redhat.com; sassmann@redhat.com
>> Subject: Re: [net] e1000: Small packets may get corrupted during pad=
ding
>> by HW
>>
>> 2012/9/15 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
>>> From: Tushar Dave <tushar.n.dave@intel.com>
>>>
>>> On PCI/PCI-X HW, if packet size is less than ETH_ZLEN, packets may =
get
>>> corrupted during padding by HW.
>>> To WA this issue, pad all small packets manually.
>>>
>>> Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
>>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>   drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++++++++
>>>   1 file changed, 11 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
>>> b/drivers/net/ethernet/intel/e1000/e1000_main.c
>>> index 3bfbb8d..bde337e 100644
>>> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>>> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>>> @@ -3149,6 +3149,17 @@ static netdev_tx_t e1000_xmit_frame(struct
>> sk_buff *skb,
>>>                  return NETDEV_TX_OK;
>>>          }
>>>
>>> +       /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
>>> +        * packets may get corrupted during padding by HW.
>>> +        * To WA this issue, pad all small packets manually.
>>> +        */
>>> +       if (skb->len < ETH_ZLEN) {
>>> +               if (skb_pad(skb, ETH_ZLEN - skb->len))
>>> +                       return NETDEV_TX_OK;
>>> +               skb->len =3D ETH_ZLEN;
>>> +               skb_set_tail_pointer(skb, ETH_ZLEN);
>>> +       }
>>> +
>>
>> Isn't there a skb_padto() that does just this?
>
> Skb_padto calls skb_pad(). Calling skb_pad directly saves some cycles=
=2E
>

How/where?

static inline int skb_padto(struct sk_buff *skb, unsigned int len)
{
         unsigned int size =3D skb->len;
         if (likely(size >=3D len))
                 return 0;
         return skb_pad(skb, len - size);
}


Also wouldn't you want an unlikely() in your patch?

=2EJohn
