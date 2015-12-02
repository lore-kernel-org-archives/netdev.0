From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 2 Dec 2015 08:12:48 -0800
Message-ID: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
References: <CAHo-OoyN7OgvHSuXxjk7C4FitXhoWffOxY1wkQBWwi+nc013_w@mail.gmail.com>
	<1448937147-38043-1-git-send-email-lorenzo@google.com>
	<CALx6S36fb7C9-LCo5egFZyOo1mZ1A9kHN6xpgNUUQS=njQ8Y-g@mail.gmail.com>
	<CAKD1Yr2qyKCmfo75+OpsfqrUoFquXiA_GqwVr_BsU1AW5MmPbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36462 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbbLBQMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 11:12:49 -0500
Received: by igcph11 with SMTP id ph11so113497474igc.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 08:12:49 -0800 (PST)
In-Reply-To: <CAKD1Yr2qyKCmfo75+OpsfqrUoFquXiA_GqwVr_BsU1AW5MmPbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 7:18 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Tue, Dec 1, 2015 at 11:53 AM, Tom Herbert <tom@herbertland.com> wrote:
>> This is awesome! The only thing I would suggest is to make
>> sock_destroy a proto_op so that it can be called from within the
>> kernel. This should be preferred to externally calling tcp_done
>> (hopefully we can unexport that symbol then).
>
> I'm not sure there is value in making it a proto op. The sock_diag
> code that finds the socket based on the netlink diag request is
> specific to both the protocol family (e.g., the sock_diag structures
> for inet and unix differ) and protocol (e.g., TCP, UDPv4 and UDPv6 use
> different hash tables).
>
> So even if we add a proto_op (or struct proto function pointer) to
> destroy a socket, we can't just have a generic function (or even an
> inet-specific function) that just finds a socket and does "return
> sk->sk_prot->diag_destroy(sk)" regardless of what protocol that socket
> is.
>
> The code does look better if the protocol-specific code is moved to a
> new tcp_abort function that just takes a pointer to the sk.

The in kernel caller would already have a pointer to the socket so the
call would just be sk->sk_prot->destroy(sk). That call should make its
way down to same backend function in TCP that the diag path would use.
We need this in the kernel for the same reasons you want this in
userspace, if a third party hits an unrecoverable error on the socket
it needs to signal this condition to the owner of the socket but can't
actually close the socket (useful to RDS, KCM, probably
TLS-in-kernel).
