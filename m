From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: [net] e1000: Small packets may get corrupted during padding by
 HW
Date: Sun, 16 Sep 2012 01:25:45 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89130DC20AA@ORSMSX102.amr.corp.intel.com>
References: <1347740217-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAHXqBFJZnGUSUutN=L-_LpCN7dXLPFY0ndJnQJ10NCcbzPVLww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Michal Miroslaw <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2668 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740Ab2IPBZr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 21:25:47 -0400
In-Reply-To: <CAHXqBFJZnGUSUutN=L-_LpCN7dXLPFY0ndJnQJ10NCcbzPVLww@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Micha=B3 Miros=B3aw [mailto:mirqus@gmail.com]
>Sent: Saturday, September 15, 2012 1:45 PM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Dave, Tushar N; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com
>Subject: Re: [net] e1000: Small packets may get corrupted during paddi=
ng
>by HW
>
>2012/9/15 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
>> From: Tushar Dave <tushar.n.dave@intel.com>
>>
>> On PCI/PCI-X HW, if packet size is less than ETH_ZLEN, packets may g=
et
>> corrupted during padding by HW.
>> To WA this issue, pad all small packets manually.
>>
>> Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++++++++
>>  1 file changed, 11 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> index 3bfbb8d..bde337e 100644
>> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> @@ -3149,6 +3149,17 @@ static netdev_tx_t e1000_xmit_frame(struct
>sk_buff *skb,
>>                 return NETDEV_TX_OK;
>>         }
>>
>> +       /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
>> +        * packets may get corrupted during padding by HW.
>> +        * To WA this issue, pad all small packets manually.
>> +        */
>> +       if (skb->len < ETH_ZLEN) {
>> +               if (skb_pad(skb, ETH_ZLEN - skb->len))
>> +                       return NETDEV_TX_OK;
>> +               skb->len =3D ETH_ZLEN;
>> +               skb_set_tail_pointer(skb, ETH_ZLEN);
>> +       }
>> +
>
>Isn't there a skb_padto() that does just this?

Skb_padto calls skb_pad(). Calling skb_pad directly saves some cycles.
