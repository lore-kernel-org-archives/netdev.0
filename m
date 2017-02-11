From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/5] vxlan: support fdb and learning in COLLECT_METADATA
 mode
Date: Fri, 10 Feb 2017 20:55:55 -0800
Message-ID: <589E995B.9090405@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com> <1485932395-58422-3-git-send-email-roopa@cumulusnetworks.com> <CAPWQB7GGEvpjdnU6O6XM6r8MPQGZG1CV6wYdOkX33T6Ja5jtNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        Thomas Graf <tgraf@suug.ch>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>, pravin shelar <pshelar@ovn.org>,
        David Ahern <dsa@cumulusnetworks.com>, hadi@mojatatu.com,
        Jarno Rajahalme <jarno@ovn.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33028 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbdBKEz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 23:55:59 -0500
Received: by mail-pg0-f41.google.com with SMTP id 204so16265131pge.0
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 20:55:59 -0800 (PST)
In-Reply-To: <CAPWQB7GGEvpjdnU6O6XM6r8MPQGZG1CV6wYdOkX33T6Ja5jtNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/10/17, 8:05 PM, Joe Stringer wrote:
> On 31 January 2017 at 22:59, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> @@ -1289,7 +1331,12 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
>>         if (!vs)
>>                 goto drop;
>>
>> -       vxlan = vxlan_vs_find_vni(vs, vxlan_vni(vxlan_hdr(skb)->vx_vni));
>> +       vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
>> +
>> +       if ((vs->flags & VXLAN_F_COLLECT_METADATA) && !vni)
>> +               goto drop;
>> +
>> +       vxlan = vxlan_vs_find_vni(vs, vni);
>>         if (!vxlan)
>>                 goto drop;
> Hi Roopa,
>
> We've noticed a failure in OVS system-traffic kmod test cases and
> bisected it down to this commit. It seems that it's related to this
> new drop condition here. Can you explain what's meant to be special
> about VNI 0? I can't see anything mentioned about it in RFC7348, so I
> don't see why it should be dropped.
>
> In the OVS testsuite, we configure OVS in the root namespace with an
> OVS vxlan device (which has VXLAN_F_COLLECT_METADATA set), with vni 0.
> Then, we configure a veth pair into another namespace where we have
> the other end of the tunnel configured using a regular native linux
> vxlan device on vni 0. Prior to this commit, the test worked; after
> this test it failed. If we manually change to use a nonzero VNI, it
> works. The test is here:
To be honest, I thought vni 0 was only used for the collect metadata device for lookup
of the device until a real vni was derived. and since i moved the line that got the vni from the packet
up, I ended up adding that check. Did not realize vni 0 could be valid vni in the packet.
>
> https://github.com/openvswitch/ovs/blob/branch-2.7/tests/system-traffic.at#L218
>
> Jarno also tried setting up two namespaces with regular vxlan devices
> and VNI 0, and this worked too. Presumably this is because this would
> not use VXLAN_F_COLLECT_METADATA.
yeah, that should be it.

I will send a patch in a few hours. Thanks for reporting. I am glad you ran these tests.. as I was not able to
completely verify all cases for ovs.
