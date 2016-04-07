From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] macvlan: Support interface operstate properly
Date: Thu, 7 Apr 2016 13:05:01 +0200
Message-ID: <57063EDD.3040406@cumulusnetworks.com>
References: <1459982173-791-1-git-send-email-dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Debabrata Banerjee <dbanerje@akamai.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37063 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713AbcDGLFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 07:05:06 -0400
Received: by mail-wm0-f48.google.com with SMTP id n3so99633153wmn.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 04:05:04 -0700 (PDT)
In-Reply-To: <1459982173-791-1-git-send-email-dbanerje@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2016 12:36 AM, Debabrata Banerjee wrote:
> Set appropriate macvlan interface status based on lower device and our
> status. Can be up, down, or lowerlayerdown.
What about dormant ?

> 
> de7d244d0 improved operstate by setting it from unknown to up, however
> it did not handle transferring down or lowerlayerdown.
No, this is not correct. It did not set it to "up", lowerlayerdown is currently
being set when the lower device is carrier-off, the only thing not handled is
the lower device going to admin down state. Up until this patch lowerlayerdown is
correctly propagated and set based on lower and macvlan device's carrier states,
after this patch you also include the device flags which makes things inconsistent
because you can overwrite the operstate set by link_watch (or user) afterwards, and
this is especially true for the dormant case. In fact you won't be able to set dormant
on a macvlan device, it'll always get overwritten.
Also another (minor) inconsistency is that user-space will no longer get IFF_RUNNING in the
flags by dev_get_flags() so when the lower device is down but carrier-on and the macvlan
is now in LOWERLAYERDOWN, so it will also show up as NO-CARRIER:
6: mac1@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state LOWERLAYERDOWN mode DEFAULT group default qlen 1000

But you can also see packets going through the macvlan device while it is in
the state above which is confusing.
# tcpdump -e -n -i mac1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on mac1, link-type EN10MB (Ethernet), capture size 262144 bytes
12:08:37.330771 3a:83:f3:52:47:3b > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 42: Request who-has 192.168.99.2 tell 192.168.99.1, length 28
12:08:38.332846 3a:83:f3:52:47:3b > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 42: Request who-has 192.168.99.2 tell 192.168.99.1, length 28

That being said I understand the need to switch to lowerlayerdown when the lower
device is in "down", which is basically the most important change of this patch.
The rest is already handled by link watch based on carrier state. By now people
are used to having lowerlayerdown when there's no carrier, now it can also mean
that the lower device has been brought admin down.

Here's another interesting state:
6: mac1@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP,LOWER_UP,DORMANT,M-DOWN> mtu 1500 qdisc noqueue state LOWERLAYERDOWN mode DEFAULT group default qlen 1000
Prior to this patch the macvlan would stay in dormant state and it will also propagate
to devices stacked on top of it.

> 
> Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
> ---
> v2: Fix locking and update commit message
> 
>  drivers/net/macvlan.c | 47 +++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 45 insertions(+), 2 deletions(-)
> 
