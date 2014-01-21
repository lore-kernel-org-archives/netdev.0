From: Jesse Gross <jesse@nicira.com>
Subject: Re: issues with vxlan RX checksum offload under OVS datapath
Date: Tue, 21 Jan 2014 09:37:50 -0800
Message-ID: <CAEP_g=-AP0E4_mFXLVvE3ha0T84rLD6EnDYXNPwzhywtuti1wQ@mail.gmail.com>
References: <52DC4C1B.5000309@mellanox.com> <CALnjE+rUTejbU_d39G7WSn=k0aY2xELCE3UxjDr_Zdq3iwHbNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:42900 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755115AbaAURiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 12:38:11 -0500
Received: by mail-ie0-f176.google.com with SMTP id tp5so3861418ieb.21
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:38:11 -0800 (PST)
In-Reply-To: <CALnjE+rUTejbU_d39G7WSn=k0aY2xELCE3UxjDr_Zdq3iwHbNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 21, 2014 at 9:30 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Sun, Jan 19, 2014 at 2:05 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Hi Pravin,
>>
>> While testing the gro udp patches over a setup with openvswitch I noted that
>> the RX checksum offload support introduced by Joseph's commit 0afb166
>> "vxlan: Add capability of Rx checksum offload for inner packet" works fine
>> when you use a setup made of
>>
>> NIC --> IP stack --> vxlan device --> bridge --> tap
>>
>> but not when its
>>
>> NIC --> IP stack --> ovs vxlan port --> OVS DP --> tap
>>
>> I narrowed it down to the fact the when going the OVS pathskb->encapsulation
>> remains true also after the decap is done. Basically, this is the original
>> hunk
>>
>>
>>> @@ -607,7 +607,17 @@ static int vxlan_udp_encap_recv(struct sock *sk,
>>> struct sk_buff *skb)
>>>
>>>         __skb_tunnel_rx(skb, vxlan->dev);
>>>         skb_reset_network_header(skb);
>>> -       skb->ip_summed = CHECKSUM_NONE;
>>> +
>>> +       /* If the NIC driver gave us an encapsulated packet with
>>> +        * CHECKSUM_UNNECESSARY and Rx checksum feature is enabled,
>>> +        * leave the CHECKSUM_UNNECESSARY, the device checksummed it
>>> +        * for us. Otherwise force the upper layers to verify it.
>>> +        */
>>> +       if (skb->ip_summed != CHECKSUM_UNNECESSARY || !skb->encapsulation
>>> ||
>>> +           !(vxlan->dev->features & NETIF_F_RXCSUM))
>>> +               skb->ip_summed = CHECKSUM_NONE;
>>> +
>>> +       skb->encapsulation = 0;
>>
>>
>> which was moved by your commits
>>
>> 5cfccc5 vxlan: Add vxlan recv demux.
>> 7ce0475 vxlan: Restructure vxlan receive.
>>
>> to a code which isn't shared by the vxlan driver and ovs vxlan datapath
>> code, and I was thinking lets just move it back to vxlan_udp_encap_recv.
>> However, we can't really make the "vxlan->dev->features & NETIF_F_RXCSUM"
>> check - since there's no vxlan device for ovs datapath, any idea how to
>> overcome this.
>>
>> Moving this to shared code (while removing the check for
>> vxlan->dev->features) made things to work on my setup, but this misses one
>> of the original conditions, ideas?
>>
> I kept csum check in vxlan-device recv path for same reason. As of now
> there is no efficient way to get ovs-dev features.
> May be we can cache device features in struct datapath from datapath-netdev.\

I don't think that getting the features from the internal device makes
sense - a packet could be destined to a VM instead.

I think that controlling RX checksum on the device that physically
received it should be enough to be able to check for broken devices.
It's not clear what the benefit to turning it off at the VXLAN layer
is - if you really don't want it for some reason, you can always throw
away the checksum later.
