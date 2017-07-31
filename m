From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Long stalls creating a new netns after a netns with a SMB client exits
Date: Mon, 31 Jul 2017 15:01:07 -0700
Message-ID: <CAM_iQpW4im2sk3-SXh0fgA9fNp1rN5=+UrwP2wATd=hh1CVo7Q@mail.gmail.com>
References: <CA+pO-2cm7bz861KvPMpugP8rVwf6rU8QYrVq7PVO-ZXx2kh1fw@mail.gmail.com>
 <CAM_iQpW+gSgCDWdGoHvN0wObda_g40FcyCBem5VVJ4XLHNMRaQ@mail.gmail.com>
 <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
 <4a56fd38-11f6-4824-bdab-d0f2d46cdf51@gmail.com> <CA+pO-2c+uR_3bfEkNAErJp9H4ngwMjeWp=rSKFJxPrgXZpD38g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Ahern <dsahern@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37811 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdGaWB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 18:01:29 -0400
Received: by mail-wm0-f66.google.com with SMTP id t138so456187wmt.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 15:01:28 -0700 (PDT)
In-Reply-To: <CA+pO-2c+uR_3bfEkNAErJp9H4ngwMjeWp=rSKFJxPrgXZpD38g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 9:22 AM, Rolf Neugebauer
<rolf.neugebauer@docker.com> wrote:
> On Fri, Jul 28, 2017 at 8:16 PM, David Ahern <dsahern@gmail.com> wrote:
>> On 7/28/17 12:58 PM, Rolf Neugebauer wrote:
>>>>> I can readily reproduce this on 4.9.39, 4.11.12 and another user
>>>>> repro-ed it on 4.12.3. It seems to happen every time. At least one
>>>>> user reported issues with NFS mounts as well, but we were not able to
>>>>> reproduce it. It's not clear to me if this is directly related to
>>>>> 'mount.cifs' or if that just happens to reliably repro it.
>>>>
>>>> OK, so commit d747a7a51b00984127a88113c does not help this case
>>>> either.
>>>
>>> d747a7a51b009("tcp: reset sk_rx_dst in tcp_disconnect()") indeed seems
>>> a different issue. As I understand that actually caused the ref count
>>> never to get decremented, while here eventually some cleanup kicks in
>>> after a long timeout.
>>
>> It could be a dst is cached on a socket and does not get cleared until
>> the socket time outs are done.
>>
>> Test that theory by something like this for IPv4 TCP (similar change for
>> UDP if the client is UDP based):
>>
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index 3a19ea28339f..37db087b6c97 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1855,7 +1855,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const
>> struct sk_buff *skb)
>>  {
>>         struct dst_entry *dst = skb_dst(skb);
>>
>> -       if (dst && dst_hold_safe(dst)) {
>> +       if (0 && dst && dst_hold_safe(dst)) {
>>                 sk->sk_rx_dst = dst;
>>                 inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
>>         }
>
>
> This removes the 200s stall (the test is IPv4/TCP based)


Interesting. This means we have a kernel socket which holds
the dst refcnt.

Looking at the cifs code, it does create a TCP kernel socket
which doesn't hold refcnt to netns but its sk_rx_dst could
still be set as usual, therefore this socket could hold the dst
which holds lo device after the netns is gone. But its timeout
seems to be 60sec (SMB_ECHO_INTERVAL_DEFAULT),
not 200sec.

Ideally it should use a per netns socket so that it would have
a same life-time with netns. But you need to check this with
cifs developers, I don't understand cifs at all.
