From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel
 support
Date: Tue, 22 Nov 2016 23:34:03 -0800
Message-ID: <5835466B.6080405@cumulusnetworks.com>
References: <CAADnVQ+MdPeZv1FpzD=omH1ftr2vW3uYiqdLL3Y_teaZj=tEbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, david.lebrun@uclouvain.be,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33871 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbcKWHeG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 02:34:06 -0500
Received: by mail-pg0-f49.google.com with SMTP id x23so3128501pgx.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 23:34:06 -0800 (PST)
In-Reply-To: <CAADnVQ+MdPeZv1FpzD=omH1ftr2vW3uYiqdLL3Y_teaZj=tEbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/16, 4:16 PM, Alexei Starovoitov wrote:
> On Wed, Nov 16, 2016 at 8:32 AM, David Miller <davem@davemloft.net> wrote:
>> From: David Lebrun <david.lebrun@uclouvain.be>
>> Date: Tue, 15 Nov 2016 16:14:04 +0100
>>
>>> This patch adds a new option CONFIG_IPV6_SEG6_LWTUNNEL to enable/disable
>>> support of encapsulation with the lightweight tunnels. When this option
>>> is enabled, CONFIG_LWTUNNEL is automatically selected.
>>>
>>> Fix commit 6c8702c60b88 ("ipv6: sr: add support for SRH encapsulation and injection with lwtunnels")
>>>
>>> Without a proper option to control lwtunnel support for SR-IPv6, if
>>> CONFIG_LWTUNNEL=n then the IPv6 initialization fails as a consequence
>>> of seg6_iptunnel_init() failure with EOPNOTSUPP:
>>>
>>> NET: Registered protocol family 10
>>> IPv6: Attempt to unregister permanent protocol 6
>>> IPv6: Attempt to unregister permanent protocol 136
>>> IPv6: Attempt to unregister permanent protocol 17
>>> NET: Unregistered protocol family 10
>>>
>>> Tested (compiling, booting, and loading ipv6 module when relevant)
>>> with possible combinations of CONFIG_IPV6={y,m,n},
>>> CONFIG_IPV6_SEG6_LWTUNNEL={y,n} and CONFIG_LWTUNNEL={y,n}.
>>>
>>> Reported-by: Lorenzo Colitti <lorenzo@google.com>
>>> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
>> Applied.
> ipv6 seems to be still broken in the latest net-next
> when CONFIG_LWTUNNEL is not set:
> # ping 127.0.0.1
> ping: socket: Address family not supported by protocol
> # ping -4 127.0.0.1
> PING localhost.localdomain (127.0.0.1) 56(84) bytes of data.
> 64 bytes from localhost.localdomain (127.0.0.1): icmp_seq=1 ttl=64 time=0.067 ms
>
> it works with CONFIG_LWTUNNEL=y
>
> Roopa, David, please take a look.
>
I can't seem to reproduce the problem you are seeing. still trying..
I don't have CONFIG_LWTUNNEL set nor any of the other SEG6 configs.
My CONFIG_IPV6 is on and compiled as a module. I have also tried disabling it.
If you can send me the config, I can try again. Looking back at the patches,
I do see a few things below ..but they may not fix your problem directly.

Though I had none of the ipv6 segment routing configs turned on,
I do see the "Segment Routing with IPv6" msg at bootup.
Was looking at david's patches again, and a few things (I had missed seeing the last version):

In my review comment I was hinting at CONFIG_IPV6_SEG6 to cover all of ipv6 segment routing,
including the lwtunnel bits.

something like below:

config IPV6_SEG6
        bool "IPv6: Segment Routing Header encapsulation support"
        depends on LWTUNNEL && IPV6

DavidL, do you see a problem doing it this way ?. with this 'seg6.o' will be part of CONFIG_IPV6_SEG6 and not
get initialized unless it is enabled..which seems like the right thing to do.

DaveM had suggested compiling LWTUNNEL in by default. I can submit a patch for that.
But it is not clear to me yet why the right depends will not fix it.

thanks.
