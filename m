From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Tue, 17 Jun 2014 14:35:23 -0700
Message-ID: <CAK6E8=e=EoxMfGMFnO90MVfBWGmoua8=4ptG978-jfD2S-J8Fw@mail.gmail.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
 <20140616211954.6E12BA3A89@unicorn.suse.cz> <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
 <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
 <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
 <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com> <20140617122038.GA7275@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:38261 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964852AbaFQVgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 17:36:03 -0400
Received: by mail-ie0-f169.google.com with SMTP id at1so7034415iec.28
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 14:36:03 -0700 (PDT)
In-Reply-To: <20140617122038.GA7275@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 5:20 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> On Mon, Jun 16, 2014 at 08:44:04PM -0400, Neal Cardwell wrote:
>> On Mon, Jun 16, 2014 at 8:25 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> > However Linux is inconsistent on the loss of a retransmission. It
>> > reduces ssthresh (and cwnd) if this happens on a timeout, but not in
>> > fast recovery (tcp_mark_lost_retrans). We should fix that and that
>> > should help dealing with traffic policers.
>>
>> Yes, great point!
>
> Does it mean the patch itself would be acceptable if the reasoning in
> its commit message was changed? Or would you prefer a different way to
> unify the two situations?

It's the latter but it seems to belong to a different patch (and it'll
not solve the problem you are seeing).

The idea behind the RFC is that TCP should reduce cwnd and ssthresh
across round trips of send, but not within an RTT. Suppose cwnd was
10 on first timeout, so cwnd becomes 1 and ssthresh is 5. Then after 3
round trips, we time out again. By the design of Reno this should
reset cwnd from 8 to 1, and ssthresh from 5 to 2.5.

Of course this may not make sense in various cases. But it will be a
design bug in the congestion control rather than an implementation bug
in the loss recovery. We are seeing many similar issues where
non-queue-overflow drops mess up CCs relying on ssthresh :(

>
>                                                         Michal Kubecek
>
