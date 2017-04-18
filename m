From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/8] rtnetlink: Do not generate notifications for
 MTU events
Date: Tue, 18 Apr 2017 09:52:06 +0200
Message-ID: <b56b63b8-759f-2b94-be68-3471417e0460@6wind.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
 <1491600340-8359-2-git-send-email-dsa@cumulusnetworks.com>
 <58E92699.6090909@cumulusnetworks.com>
 <63e0a6c1-ec09-4f04-7e41-edd0adf871b2@cumulusnetworks.com>
 <58E92966.5000506@cumulusnetworks.com>
 <7dfa18fc-3e99-9630-7b3c-31823c66155a@redhat.com>
 <541c220b-9e55-8206-3886-6a98c86ae2e7@cumulusnetworks.com>
 <34331f55-e3ef-4cfa-f911-4201d5a2014e@redhat.com>
 <95494531-1a4e-e5d2-4442-cc3298df8090@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, vyasevic@redhat.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:35315 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755897AbdDRHwK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 03:52:10 -0400
Received: by mail-wr0-f172.google.com with SMTP id o21so96472176wrb.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 00:52:09 -0700 (PDT)
In-Reply-To: <95494531-1a4e-e5d2-4442-cc3298df8090@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2017 à 06:26, David Ahern a écrit :
> +Nicolas
> 
> On 4/14/17 7:51 PM, Vlad Yasevich wrote:
>> On 04/10/2017 11:49 AM, David Ahern wrote:
>>> On 4/10/17 9:39 AM, Vlad Yasevich wrote:
>>>> OK, so this will work for the events that are generated as a result of device state change
>>>> (like mtu, address, and others).
>>>>
>>>> However, the original event data may be needed for other events that may be
>>>> of use to userspace like NETDEV_NOTIFY_PEERS and NETDEV_RESEND_IGMP (possibly others...)
>>>
>>> sure. My objection is to multiple messages with identical content.
>>>
>>> I think the rtnetlink_event message is unique for those 2 netdev events,
>>> so no objections if it has value.
>>>
>>
>> So, I've been looking at adding a bitmap and collecting all modification, however
>> I ran into an interesting issue in do_setlink.
>>
>> Currently the notifications from do_setlink() don't appear to work as one would
>> expect and it's somewhat confusing upon deeper inspection.
>>
>> We have 2 values DO_SETLINK_MODIFIED (1) and DO_SETLINK_NOTIFY (3).  These 2 'attempt'
>> to do different jobs, but really fail at it.  The function will generate notifications
>> regardless of which of the above values is used.
>>
>> Those changes were done in commit ba9989069f4e426b1e0ed7018eacc9e1ba607095 (cc Nicolas
>> just in case he remembers the history)
>>
>> I am not sure which changes should really trigger a call netdev_state_change(), thus this
>> message.  Right now, all changes done in this function trigger them.  If that's how that
>> should function, that I can simplify the code.  If not, then some of the changes may
>> require us to export the event to the user.
If I remember well, the goal was to trigger a netlink event as soon as
'something' changed. It was not the case before that patch, some updates (I
don't remember which one) were not advertised via netlink.

>>
>> To use the dreaded NETDEV_CHANGEMTU event as an example, we used to generate 3 messages
>> (PRECHANGEMTU, CHANGEMTU, and a message from netdev_state_change).  With recent changes,
>> we now only generate a message from netdev_state_change.  However, mtu change is tagged
>> with DO_SETLINK_MODIFIED which doesn't include the notify bit.  So, should there be a
>> NETDEV_CHANGE event associated with this change and a rtnl message (as it is now) or not?
The rtnl msg is mandatory.


Regards,
Nicolas
