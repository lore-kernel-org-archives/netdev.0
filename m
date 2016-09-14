From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 08:39:15 -0600
Message-ID: <e8df55df-c22f-19a3-fabc-5fb592433706@cumulusnetworks.com>
References: <20160914124025.13417-1-vincent@bernat.im>
 <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com>
 <87h99ipnhu.fsf@zoro.exoscale.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:38894 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763545AbcINOjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 10:39:22 -0400
Received: by mail-it0-f44.google.com with SMTP id n143so27056422ita.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 07:39:21 -0700 (PDT)
In-Reply-To: <87h99ipnhu.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/14/16 8:25 AM, Vincent Bernat wrote:
>  ❦ 14 septembre 2016 16:15 CEST, David Ahern <dsa@cumulusnetworks.com> :
> 
>>> When a user wants to assign a routing table to a group of incoming
>>> interfaces, the current solutions are:
>>>
>>>  - one IP rule for each interface (scalability problems)
>>>  - use of fwmark and devgroup matcher (don't work with internal route
>>>    lookups, used for example by RPF)
>>>  - use of VRF devices (more complex)
>>
>> Why do you believe that? A VRF is a formalized grouping of interfaces
>> that includes an API for locally generated traffic to specify which
>> VRF/group to use. And, with the l3mdev rule you only need 1 rule for
>> all VRFs regardless of the number which is the best solution to the
>> scalability problem of adding rules per device/group/VRF.
>>
>> What use case are trying to solve?
> 
> Local processes have to be made aware of the VRF by binding to the
> pseudo-device. Some processes may be tricked by LD_PRELOAD but some
> won't (like stuff written in Go). Maybe I should just find a better way
> to bind a process to a VRF without its cooperation.
> 

What API are you using for interface groups? How does an app tell the kernel to use interface group 1 versus group 2?


LD_PRELOAD and overloading socket is an ad-hoc hack at best with many holes - as you have found.

We (Cumulus Linux) are using this cgroups patch:
   http://www.mail-archive.com/netdev@vger.kernel.org/msg93408.html

I want something formal like the cgroups patch or even the first idea of adding a default sk_bound_dev_if to the task struct:
    https://github.com/dsahern/linux/commit/b3e5ccc291505c8a503edb20ea2c2b5e86bed96f

Parent-to-child inheritance of the setting is a requirement as is the setting getting applied to all IPv4/v6 sockets without action by the process itself.

Still have some work to do to get a solution into the kernel.
