From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Mon, 02 Feb 2015 10:52:16 -0800
Message-ID: <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:46093 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbBBSwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 13:52:18 -0500
In-Reply-To: <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-02 at 11:27 +0100, Michal Kazior wrote:

> While testing I've had my internal GRO patch for ath10k and no stretch
> ack patches.

Thanks for the data, I took a look at it.

I am afraid this GRO patch might be the problem.

It seems to break ACK clocking badly (linux stack has a somewhat buggy
tcp_tso_should_defer(), which relies on ACK being received smoothly, as
no timer is setup to split the TSO packet.)

I am seeing huge delays on ACK packets and bursts like that :

05:01:53.413038 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 76745, win 4435, options [nop,nop,TS val 4294758508 ecr 4294757300], length 0
05:01:53.413407 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 79641, win 4435, options [nop,nop,TS val 4294758508 ecr 4294757301], length 0
05:01:53.413969 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 92673, win 4435, options [nop,nop,TS val 4294758510 ecr 4294757302], length 0
05:01:53.413990 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 97017, win 4435, options [nop,nop,TS val 4294758510 ecr 4294757302], length 0
05:01:53.414011 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 110049, win 4435, options [nop,nop,TS val 4294758510 ecr 4294757302], length 0
...
05:01:53.422663 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 189689, win 4435, options [nop,nop,TS val 4294758519 ecr 4294757310], length 0
05:01:53.424354 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 198377, win 4435, options [nop,nop,TS val 4294758520 ecr 4294757311], length 0
05:01:53.424400 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 202721, win 4435, options [nop,nop,TS val 4294758520 ecr 4294757313], length 0
05:01:53.424409 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 205617, win 4435, options [nop,nop,TS val 4294758520 ecr 4294757313], length 0
...
05:01:53.450248 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 419921, win 4435, options [nop,nop,TS val 4294758547 ecr 4294757337], length 0
05:01:53.450266 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 427161, win 4435, options [nop,nop,TS val 4294758547 ecr 4294757340], length 0
05:01:53.450289 IP 192.168.1.2.5001 > 192.168.1.3.49669: Flags [.], ack 431505, win 4435, options [nop,nop,TS val 4294758547 ecr 4294757340], length 0

Could you make again your experiments using upstream kernel (David
Miller net tree) ?

You also could post the GRO patch so that we can comment on it.

Thanks
