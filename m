From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC 2/2] e1000e: Support RXALL feature flag.
Date: Tue, 07 Feb 2012 16:19:01 -0800
Message-ID: <4F31BF75.4090304@candelatech.com>
References: <1328656063-13129-1-git-send-email-greearb@candelatech.com> <1328656063-13129-2-git-send-email-greearb@candelatech.com> <CAHXqBFJ9=fXYuzZd0SM0hGsDxQee5UPzOwThbxNkks03VLFunw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46360 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756144Ab2BHATD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 19:19:03 -0500
In-Reply-To: <CAHXqBFJ9=fXYuzZd0SM0hGsDxQee5UPzOwThbxNkks03VLFunw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2012 04:06 PM, Micha=C5=82 Miros=C5=82aw wrote:
> 2012/2/8<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows the NIC to receive all frames available, including
>> those with bad FCS, un-matched vlans, ethernet control frames,
>> and more.
>>
>> Tested by sending frames with bad FCS.
>
> This should probably mark the bad packets somehow, so they are not
> passed up the stack and mixed with correct traffic.

Anything that does higher-level checksumming should figure out the
problem, if it's real (ie, if not *just* a corrupted FCS).  Anything
that doesn't is open to abuse by something sending corrupted packets
with correct checksums anyway.

But, if you think it's really needed, I could add a flag to the skb and
then free the skb after the ptype_all logic in netif_receive_skb
has been called?

>> @@ -2996,6 +3001,25 @@ static void e1000_setup_rctl(struct e1000_ada=
pter *adapter)
>>                 ew32(PSRCTL, psrctl);
>>         }
>>
>> +       /* This is useful for sniffing bad packets. */
>> +       if (adapter->netdev->features&  NETIF_F_RXALL) {
>> +               rctl |=3D (E1000_RCTL_SBP | /* Receive bad packets *=
/
>> +                        E1000_RCTL_UPE | /* RX all Unicast Pkts */
>> +                        E1000_RCTL_MPE | /* RX all Mcast Pkts */
>> +                        E1000_RCTL_BAM | /* RX All Bcast Pkts Pkts =
*/
>> +                        E1000_RCTL_PMCF); /* RX All MAC Ctrl Pkts *=
/
>> +
>> +               rctl&=3D ~(E1000_RCTL_VFE | /* Disable VLAN filter *=
/
>> +                         E1000_RCTL_DPF | /* Allow filtered pause *=
/
>> +                         E1000_RCTL_CFIEN); /* Dis VLAN CFIEN Filte=
r */
>> +               /* disable VLAN tagging/striping */
>> +               /* SKIP This, it also affects transmit side and
>> +                  screws up VLANs --Ben. */
>> +               /* ctrl =3D er32(CTRL); */
>> +               /* ctrl&=3D ~E1000_CTRL_VME; */
>> +               /* ew32(CTRL, ctrl); */
>> +       }
>> +
> [...]
>
> Looks like it can be enabled independently of promisc mode: rx-all +
> no-promisc would receive only bad packets destined for this host.

Sure, that seems useful.  I'll work on that for rev 2.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
