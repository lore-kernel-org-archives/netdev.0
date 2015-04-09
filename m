From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Thu, 9 Apr 2015 09:33:59 -0700
Message-ID: <CAF2d9jgZ+32LT5FxcqH97n1rbEChEgK7a4RtCEiUaUWOEyTmhA@mail.gmail.com>
References: <1427409698.18540.11.camel@redhat.com> <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
 <1427749308.1913.28.camel@redhat.com> <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
 <CAF2d9jikrJU0k3sS=awZQN+SD46qnN4r0bubjXZiY7K9vQieEQ@mail.gmail.com>
 <1427921700.6874.8.camel@redhat.com> <CAF2d9jgqJBfWVnX1mye5xMfYznA_NFte3dEEKG5CyogXTM73Rw@mail.gmail.com>
 <1427985636.5282.9.camel@redhat.com> <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
 <1428340638.16890.15.camel@redhat.com> <CAF2d9jgx6R5w_PoVzkstVgr0tATxTQv9S81QC9_YiX32vpRQVA@mail.gmail.com>
 <1428435900.6449.25.camel@redhat.com> <1428594679.15316.0.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34691 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbbDIQeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 12:34:22 -0400
Received: by obbry2 with SMTP id ry2so22601190obb.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 09:34:21 -0700 (PDT)
In-Reply-To: <1428594679.15316.0.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> You're right.  I mis-read your proposal above.
>>
>> But having re-read it, are you proposing a 2m timer on interface up?  If
>> so (and ignore this if not) I don't think that works well either,
>> because there's no guarantee that interface configuration will happen
>> only close to interface up.  Maybe userspace adds IPv6 addresses
>> initially, and then later tries to do DHCP for some reason.  We simply
>> cannot rely on specific ordering of operations that userspace might want
>> to do.
>>
>> If you don't mean a 2m timer from interface up, then ignore that, and
>> then what kind of time do you mean? :)
>>
>> > If the link is stripped off of address(es), then it should again go
>> > back into the config-mode where it would turn on the broadcast bit and
>> > enable timer to get it configured. May be I'm missing something.
>>
>> As above, I was wrong about the DHCPv4 lease expiration thing, but this
>> may still run afoul of userspace operation ordering if you are talking
>> about a 2m timer from interface up.
>>
>> Just had another thought though; what if instead of snooping for all the
>> DHCP stuff, the code just snooped outgoing IPv4 packets for a broadcast
>> destination address?  Then turn on the broadcast bit filter for 2m.
>> That would look something like this:
>>
>> static bool is_bcast4(struct sk_buff *skb)
>> {
>>       struct iphdr *ip4h;
>>
>>       switch (skb->protocol) {
>>       case htons(ETH_P_ALL):
>>               /* Raw sockets */
>>               if (eth_hdr(skb)->h_proto != htons(ETH_P_IP))
>>                       break;
>>               /* Fall through */
>>       case htons(ETH_P_IP):
>>               if (unlikely(!pskb_may_pull(skb, sizeof(*ip4h))))
>>                       return NULL;
>>               ip4h = ip_hdr(skb);
>>               if (ip4h->ihl < 5 || ip4h->version != 4)
>>                       return NULL;
>>               return ip4h->daddr == INADDR_BROADCAST;
>>       }
>>       return false;
>> }
>>
>> static int ipvlan_xmit_mode_l2(...)
>> {
>>       if (!ipvlan->ipv4cnt && !ipvlan->bcast4_seen && is_bcast4(skb)) {
>>               ipvlan->bcast4_seen = true;
>>               ipvlan_set_broadcast_mac_filter(ipvlan, true);
>>       }
>>
>> Yes, it's still snooping for all packets, but it's a lot fewer compares
>> than looking for DHCP specifically.
>
> Any thoughts on this Mahesh?  Is this non-DHCP approach more to your
> liking?  If so I'll generate an actual patch and do some testing.
>
Sorry about the late reply but some how I missed that.

Yes, this looks better, but I'm thinking of solving this issue with a
different approach which does not involve snooping. Or if it does, it
wont be in a fast path! It is sort of falling back to your original
patch which eliminates setting / resetting the broadcast bit but after
deferring the broadcast / multicast processing to a work-queue. This
will keep the fast path clean and we can do all sort of jugglery in
work-queue (if needed) without affecting the performance of the device
(fast path) whether it's IPv6 or IPv4 traffic.

Also Eric pointed out how multicast is broken in IPvlan, that needs a
fix too. I have cooked something, but needs some testing, I'll push
out those patches as soon as I'm happy with it's testing.

Thanks,
--mahesh..


> Dan
>
