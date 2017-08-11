From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 10:21:12 -0700
Message-ID: <1dbd514e-af5f-ad42-25d4-69ba8e24c311@oracle.com>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
 <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
 <20170811183957.47f418e6@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Matthias Schiffer <mschiffer@universe-factory.net>
To: Jiri Benc <jbenc@redhat.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48427 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752724AbdHKRVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 13:21:37 -0400
In-Reply-To: <20170811183957.47f418e6@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

>>> @@ -2933,6 +2945,8 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
>>>                   */
>>>                  if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
>>>                      !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
>>> +                       NL_SET_ERR_MSG(extack,
>>> +                                      "VXLAN GPE does not support this combination of attributes");
>>>                          return -EINVAL;
>>>                  }
>>
>> "collect metadata not supported with vxlan gpe"

Actually, VXLAN GPE is only supported together with external keyword. From 
ip-link(8)...

       gpe - enables the Generic Protocol extension (VXLAN-GPE). Currently, this
            is only supported together with the external keyword.

> That's completely wrong message. Not saying that the capitalization is
> wrong, too. Girish's wording precisely explains what went wrong.

Furthermore, the condition not only checks for collect metadata but also it 
checks to see if any attribute specified is outside of what is allowed by 
VXLAN_F_ALLOWED_GPE.

> 
>>>                  lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
>>> -               if (!lowerdev)
>>> +               if (!lowerdev) {
>>> +                       NL_SET_ERR_MSG(extack,
>>> +                                      "Specified interface for tunnel endpoint communications not found");
>>>                          return -ENODEV;
>>
>> "invalid vxlan remote link interface, device not found"
> 
> Finally one that looks better :-) Modulo the missing capitalization,
> though.

It is not the remote link interface. It is the local interface itself that needs 
to be specified.

> 
>>> -               if (vxlan_addr_multicast(&conf->remote_ip))
>>> +               if (vxlan_addr_multicast(&conf->remote_ip)) {
>>> +                       NL_SET_ERR_MSG(extack,
>>> +                                      "Interface need to be specified for multicast destination");
>>
>> "vxlan remote link interface required for multicast remote destination"
> 
> I like this one better, too.
> 
>>>   #if IS_ENABLED(CONFIG_IPV6)
>>> -               if (conf->flags & VXLAN_F_IPV6_LINKLOCAL)
>>> +               if (conf->flags & VXLAN_F_IPV6_LINKLOCAL) {
>>> +                       NL_SET_ERR_MSG(extack,
>>> +                                      "Interface need to be specified for link-local local/remote addresses");
>>>                          return -EINVAL;
>>
>> "vxlan link interface required for link-local local/remote addresses"
> 
> Okay but to be consistent (and more clear), it should be "remote link
> interface".

There is no remote link while configuring VXLAN. It is the local interface 
through which VXLAN packets will be send out.

Thanks all for the review,
~Girish
