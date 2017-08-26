From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 20:25:26 -0700
Message-ID: <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
 <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
 <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
 <1503529476.2499.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <6c88e440-3f36-858d-1a08-bd32a2c66f4e@gmail.com>
 <1503535426.2499.66.camel@edumazet-glaptop3.roam.corp.google.com>
 <4adb4b66-590c-c55a-44aa-27dd409ce14f@gmail.com>
 <3c44d27e-27d9-e9c4-04b3-17c0366e60d9@gmail.com>
 <1503705440.11498.9.camel@edumazet-glaptop3.roam.corp.google.com>
 <ce4af8cc-3de1-a777-967c-a57103994e1d@gmail.com>
 <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, willemb@google.com,
        davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:37615 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754074AbdHZDZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 23:25:31 -0400
Received: by mail-qt0-f170.google.com with SMTP id d15so7015060qta.4
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 20:25:30 -0700 (PDT)
In-Reply-To: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/25/2017 06:52 PM, Eric Dumazet wrote:
> On Fri, 2017-08-25 at 18:17 -0700, Florian Fainelli wrote:
>> On 08/25/2017 04:57 PM, Eric Dumazet wrote:
>>> On Fri, 2017-08-25 at 16:18 -0700, Florian Fainelli wrote:
>>>
>>>> Eric, are there areas of the stack where we are allowed to drop packets,
>>>> not propagate that back to write(2) and also not increment any counter
>>>> either, or maybe I am not looking where I should...
>>>
>>> What happens if you increase these sysctls ?
>>
>> I don't see packet loss after I tweak these two sysctls according to
>> your suggestions.
>>
>> Tweaking eth0's sysctls did not change anything, but tweaking gphy's
>> sysctl resolved the loss. This was a little surprising considering that
>> gphy is an IFF_NO_QUEUE interface and eth0 is the conduit interface that
>> does the real transmission.
>>
>> Does that make sense with respect to what I reported earlier? Should I
>> try to dump the neigh stats?
> 
> Note that if you had TCP traffic, the neighbour would be constantly
> confirmed and no losses would happen.

OK, that still sounds like quite a lot for a not so long UDP session (60
seconds).

I was finally able to get a better capture by switching to an ARM64
kernel, and as confirmed this is all coming from the neighbour code:

# Event count (approx.): 1970
#
# Children      Self  Trace output

# ........  ........
....................................................................
#
     3.10%     3.10%  skbaddr=0xffffffc2fa22a800 protocol=2048
location=0xffffff80086e53f4
            |
            ---write
               el0_svc_naked
               sys_write
               vfs_write
               __vfs_write
               sock_write_iter
               sock_sendmsg
               inet_sendmsg
               udp_sendmsg
               udp_send_skb
               ip_send_skb
               ip_local_out
               ip_output
               ip_finish_output
               ip_finish_output2
               neigh_resolve_output
               __neigh_event_send
               kfree_skb
               kfree_skb

     3.10%     3.10%  skbaddr=0xffffffc2fa22a900 protocol=2048
location=0xffffff80086e53f4
            |
            ---write
               el0_svc_naked
               sys_write
               vfs_write
               __vfs_write
               sock_write_iter
               sock_sendmsg
               inet_sendmsg
               udp_sendmsg
               udp_send_skb
               ip_send_skb
               ip_local_out
               ip_output
               ip_finish_output
               ip_finish_output2
               neigh_resolve_output
               __neigh_event_send
               kfree_skb
               kfree_skb

     3.10%     3.10%  skbaddr=0xffffffc2fa22aa00 protocol=2048
location=0xffffff80086e53f4
            |
            ---write
               el0_svc_naked
               sys_write
               vfs_write
               __vfs_write
               sock_write_iter
               sock_sendmsg
               inet_sendmsg
               udp_sendmsg
               udp_send_skb
               ip_send_skb
               ip_local_out
               ip_output
               ip_finish_output
               ip_finish_output2
               neigh_resolve_output
               __neigh_event_send
               kfree_skb
               kfree_skb

> 
> I guess we should an SNMP counter for packets dropped in neigh queues.

It would. Since the call trace involves udp_send_skb() how come we are
not returning an error to write(2)? are there other code paths where the
neighbor code can do drops like these?
-- 
Florian
