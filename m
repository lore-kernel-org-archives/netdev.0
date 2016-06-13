From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 02/15] net: Merge VXLAN and GENEVE push notifiers
 into a single notifier
Date: Mon, 13 Jun 2016 14:58:35 -0700
Message-ID: <CAKgT0UcbqAvN=NprtD8hsK-y1ex5m8wPOZinTVPHi72yoqwVsw@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
 <20160613174806.15186.64702.stgit@localhost.localdomain> <77eb25b2-d775-ec6f-c945-524d73113c96@redhat.com>
 <CAKgT0Ufd_BNSLrJUqN-eWjytf0aD2w_LVWFD7E1ym+A0jRhCtA@mail.gmail.com> <014f26d6-c747-5506-8dee-59866408c760@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33836 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422854AbcFMV6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:58:37 -0400
Received: by mail-io0-f195.google.com with SMTP id d2so11383267iof.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:58:36 -0700 (PDT)
In-Reply-To: <014f26d6-c747-5506-8dee-59866408c760@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 2:08 PM, Hannes Frederic Sowa <hannes@redhat.com> wrote:
> On 13.06.2016 21:47, Alexander Duyck wrote:
>> On Mon, Jun 13, 2016 at 10:57 AM, Hannes Frederic Sowa
>> <hannes@redhat.com> wrote:
>>> Hi Alex,
>>>
>>> very cool series!
>>>
>>> On 13.06.2016 19:48, Alexander Duyck wrote:
>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>> index d101e4d904ba..e959b6348f91 100644
>>>> --- a/include/linux/netdevice.h
>>>> +++ b/include/linux/netdevice.h
>>>> @@ -1269,6 +1269,14 @@ struct net_device_ops {
>>>>       void                    (*ndo_del_geneve_port)(struct  net_device *dev,
>>>>                                                      sa_family_t sa_family,
>>>>                                                      __be16 port);
>>>> +     void                    (*ndo_add_udp_enc_port)(struct  net_device *dev,
>>>> +                                                    sa_family_t sa_family,
>>>> +                                                    __be16 port,
>>>> +                                                    unsigned int type);
>>>> +     void                    (*ndo_del_udp_enc_port)(struct  net_device *dev,
>>>> +                                                    sa_family_t sa_family,
>>>> +                                                    __be16 port,
>>>> +                                                    unsigned int type);
>>>>       void*                   (*ndo_dfwd_add_station)(struct net_device *pdev,
>>>>                                                       struct net_device *dev);
>>>>       void                    (*ndo_dfwd_del_station)(struct net_device *pdev,
>>>
>>> What do you think about adding a struct as argument to
>>> ndo_*_udp_enc_port? As a result we can much easier add new fields in
>>> case future NICs allow us to e.g. specify a bound ip address?
>>
>> Actually that is probably a good idea.  Suggestions on the name are
>> welcome.  Otherwise I will try to come up with something in a bit as I
>> am currently going through and flushing out all the driver specific
>> VXLAN and GENEVE build flags.
>
> Hmmm... struct net_device_hw_offload, to be most generic? Maybe we can
> even drop the udp_enc in the name and go completely generic:
>
> int (*ndo_apply_offload)(..., struct hw_offload).

The only probably with generically using the offload keyword is it is
not very clear about what is going on.

For now I am just going with udp_enc_endpoint_info since that is
basically what we are passing.  Then I just use the pointer variable
ei for passing it back and forth between the functions.

> (enc reminded me too much at encryption)

I don't know.  In a way that isn't too far off since we are looking at
packet data buried inside of a UDP packet.  I thought it worked based
on the fact that we have hw_enc_features which is what is used to
indicate the hw features when a packet is encapsulated.  I could add a
few more letters and move things over to "encap" if you prefer.  It
just means adding 2 more letters.

> Another idea, should we add error indications also for the future? We
> can signal if a specific card was not able to enable offloading.
> Different situations can be signaled: port list depleted, protocol
> unsupported etc.
>
> Might make sense for later postprocessing and signaling to user space.

The problem is we are using a notifier type setup.  As such we cannot
really exit out if an error occurs on one of the ports.

- Alex
