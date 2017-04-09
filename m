From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/8] rtnetlink: Do not generate notifications for
 MTU events
Date: Sat, 8 Apr 2017 22:58:44 -0400
Message-ID: <e3765283-f5e5-1f85-2762-b7b99f99bd1a@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
 <1491600340-8359-2-git-send-email-dsa@cumulusnetworks.com>
 <4ebd4c86-5fbe-f6d3-653b-5b9f0048f312@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: vyasevic@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35980 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751961AbdDIC6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 22:58:46 -0400
Received: by mail-pg0-f45.google.com with SMTP id g2so88741480pge.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 19:58:46 -0700 (PDT)
In-Reply-To: <4ebd4c86-5fbe-f6d3-653b-5b9f0048f312@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/17 9:36 PM, Vlad Yasevich wrote:
> On 04/07/2017 05:25 PM, David Ahern wrote:
>> Changing MTU on a link currently causes 3 messages to be sent to userspace:
>>
>> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1490 qdisc noqueue state UNKNOWN group default event PRE_CHANGE_MTU
>>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
>>
>> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default event CHANGE_MTU
>>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
>>
>> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
>>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
>>
>> Remove the PRE_CHANGE_MTU and CHANGE_MTU messages.
> Actually, I have plans for the CHANGE_MTU event.  The last message is not an event. If you
> remove the event, it is much harder to track mtu changes.

it is a set of redundant messages. Roopa suggested using a bitmask for
the events changed by do_setlink which gets added to the last message
seen above. In doing so you only generate 1 message. The above causes
libnl (for example):

- message 1: delete dummy1 from its cache and re-create it
- message 2: delete dummy1 from its cache and re-create it
- message 3: delete dummy1 from its cache and re-create it

All you need is a single message at the end with an attribute that says
"MTU changed"
