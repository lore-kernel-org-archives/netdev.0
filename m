From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: mlx4+vxlan offload breaks gre tunnels
Date: Thu, 6 Nov 2014 09:53:26 +0200
Message-ID: <CAJ3xEMgN2GFHFtKm6_gp_SpqMSXk2hKmy4OzWYc6A811cRfevw@mail.gmail.com>
References: <20141105150448.GA20776@breakpoint.cc>
	<545A4DB7.5010603@mellanox.com>
	<637ce8e1-89e5-4254-a928-4ab2a4eb8c29@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>
To: Sathya Perla <Sathya.Perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:37034 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbaKFHx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 02:53:27 -0500
Received: by mail-ob0-f172.google.com with SMTP id wp4so439664obc.17
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 23:53:26 -0800 (PST)
In-Reply-To: <637ce8e1-89e5-4254-a928-4ab2a4eb8c29@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 6, 2014 at 9:21 AM, Sathya Perla <Sathya.Perla@emulex.com> wrote:
>> I think the best effort we can do now is
>>
>> 1. come up with something such as the below patch for 3.18 which is
>> back-ward portable for -stable kernels, it will only arm the hw offloads
>> if the OS tells us there's VXLAN in action

> Or, wouldn't the patch below not work (i.e., the same issue would persist)
> when there is both VXLAN and some other (say GRE) tunnel in the system
> and the NIC HW is capable of supporting checksum offload only on VxLAN.

Indeed, this would be the case. But the patch below will make things
to work when
only GRE is used (or when  only VXLAN is used). So we're making
progress vs. the current
situation where GRE breaks over a HW which is capable to do VXLAN offloads even
if there's no VXLAN tunnel around.


Or.


>> 2. come  up with proper kernel APIs to let NICs advertize which encap
>> schemes they can actually offload the inner checksum, Tom... your work
>> which now runs over netdev.

>> tested to work with the  following which is a bit different, tell me if
>> it works for you
>>
>> # node A - with mlx4_en address192.168.31.18
>> ip tunnel add gre1 mode gre local 192.168.31.18 remote 192.168.31.17 ttl 255
>> ifconfig gre1 10.10.10.18/24 up
>> ifconfig gre1 mtu 1450
>>
>> # node B - with mlx4_en address192.168.31.17
>> ip tunnel add gre1 mode gre local 192.168.31.17 remote 192.168.31.18 ttl 255
>> ifconfig gre1 10.10.10.17/24 up
>> ifconfig gre1 mtu 1450
