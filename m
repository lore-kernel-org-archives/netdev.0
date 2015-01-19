From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Sun, 18 Jan 2015 17:53:01 -0800
Message-ID: <CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
References: <0397034D-1DF4-409F-B335-FCD0D7EAB940@holtmann.org>
	<E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36534 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbbASBxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 20:53:03 -0500
Received: by mail-wg0-f47.google.com with SMTP id z12so3663149wgg.6
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 17:53:01 -0800 (PST)
In-Reply-To: <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch needs to be reverted ASAP.  git bisect landed me here also;
my processes are getting the OOM msgs.  What testing was done?

Seems someone does care that nlmsg_end() returns skb->len.

-scott

On Sun, Jan 18, 2015 at 3:44 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi Johannes,
>
>> your commit 053c095a82cf773075e83d7233b5cc19a1f73ece is causing problems with systemd-networkd.
>>
>> I have an up-to-date Arch Linux installation in a KVM and your change causes massive problems. It makes systemd-networkd to run out of memory.
>>
>> systemd-fsck[84]: /dev/vda1: clean, 53283/131072 files, 409813/524032 blocks
>> Out of memory: Kill process 142 (systemd-network) score 923 or sacrifice child
>> Killed process 142 (systemd-network) total-vm:478416kB, anon-rss:463472kB, file-rss:460kB
>> [FAILED] Failed to start Network Service.
>> See "systemctl status systemd-networkd.service" for details.
>>         Stopping Network Service...
>> [  OK  ] Stopped Network Service.
>>         Starting Network Service...
>>
>> Arch Linux 3.19.0-rc4-devel+ (ttyS0)
>>
>> marcel login: Out of memory: Kill process 154 (systemd-network) score 932 or sacrifice child
>> Killed process 154 (systemd-network) total-vm:540784kB, anon-rss:468380kB, file-rss:132kB
>> Out of memory: Kill process 158 (systemd-network) score 932 or sacrifice child
>> Killed process 158 (systemd-network) total-vm:540388kB, anon-rss:468528kB, file-rss:48kB
>> Out of memory: Kill process 160 (systemd-network) score 932 or sacrifice child
>> Killed process 160 (systemd-network) total-vm:540916kB, anon-rss:468528kB, file-rss:4kB
>> Out of memory: Kill process 162 (systemd-network) score 931 or sacrifice child
>> Killed process 162 (systemd-network) total-vm:540916kB, anon-rss:468104kB, file-rss:76kB
>
> so this was freaking nasty to find since I had to dig into every single RTNL location that might have an affect on this. I think that I tracked this down to these two locations:
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index e13b9dbdf154..0e26b9f66cad 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1327,7 +1327,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>                          */
>                         WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
>
> -                       if (err <= 0)
> +                       if (err < 0)
>                                 goto out;
>
>                         nl_dump_check_consistent(cb, nlmsg_hdr(skb));
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8975d9501d50..d6b4f5d08014 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4213,7 +4213,7 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
>                                 goto cont;
>
>                         if (in6_dump_addrs(idev, skb, cb, type,
> -                                          s_ip_idx, &ip_idx) <= 0)
> +                                          s_ip_idx, &ip_idx) < 0)
>                                 goto done;
>  cont:
>                         idx++;
>
> However I am not sure that these are the only ones. We might have additional issues in functionality that systemd-networkd actually does not use at the moment. These two changes make my KVM image boot properly again.
>
> And actually I am not even sure that these two changes are correct. My KVM image is a dead simple image with no IPv6 support. This change might actually just broke IPv6 and I would not notice.
>
> Tom, do you know if we can do anything in systemd-networkd in regards to RTNL and netlink handling to throw a big warning when something comes back from the kernel that would cause massive memory allocation.
>
> Regards
>
> Marcel
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
